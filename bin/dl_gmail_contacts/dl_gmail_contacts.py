#!/usr/bin/env python3
"""

deps:

pip install types-python-dateutil
pip install google-api-python-client-stubs
pip install google-auth-stubs
pip install sqlalchemy

"""
import argparse
import email
import email.utils
import pprint
import re
from contextlib import contextmanager
from dataclasses import dataclass, field
from datetime import date, datetime, timedelta
from email.header import decode_header
from email.utils import mktime_tz, parsedate_tz
from time import sleep
from typing import Any, List, Optional

import pytz
from dateutil import parser
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from googleapiclient.errors import HttpError
from sqlalchemy import DateTime, Integer, String, create_engine
from sqlalchemy.orm import DeclarativeBase, Mapped, Session, mapped_column
from sqlalchemy.sql.schema import ForeignKey

MAX_MESSAGE_RESULTS = 500
CREDENTIALS_PATH = "/Users/kortina/.ssh/dl_gmail_contacts.json"
CREDENTIALS = Credentials.from_authorized_user_file(CREDENTIALS_PATH)
DB_PATH = "dl_gmail_contacts.db"
ENGINE_URL = f"sqlite:///{DB_PATH}"
ENGINE = create_engine(ENGINE_URL)

# TODO: ensure this defaults everywhere or just allow NULL?
UNDEF = "_UNDEF_"
CONTACTS_KEYS = ["from", "to", "cc", "bcc", "reply-to", "sender", "return-path", "delivered-to"]

# see googleapiclient docs:
#   https://developers.google.com/gmail/api/reference/rest/v1/users.messages#Message
GMailMessage = Any
GMailHeaders = Any
GmailService = Any


def init_gmail_service():
    print("init_gmail_service......")
    return build("gmail", "v1", credentials=CREDENTIALS)


# define this as a global so we can refresh it on exceptions:
GMAIL_SERVICE = init_gmail_service()


@contextmanager
def allow_exceptions_per_minutes(per_minutes=5, max_per_minutes=3, wait_secs=45):
    # this function will refresh the gmail service in attempt to resolve some HTTP exceptions
    global GMAIL_SERVICE
    exceptions_timestamps = []

    try:
        yield
    # intermittent google api errors:
    except (HttpError, TimeoutError) as e:
        while True:
            now = datetime.now()
            # Remove timestamps older than one minute
            exceptions_timestamps = [
                t for t in exceptions_timestamps if now - t < timedelta(minutes=per_minutes)
            ]

            if len(exceptions_timestamps) < max_per_minutes:
                exceptions_timestamps.append(now)
                print(
                    f"CAUGHT <{e}>. {len(exceptions_timestamps)} of {max_per_minutes} allowed per {per_minutes} minutes."
                )
                for remaining in range(wait_secs, 0, -1):
                    print(f"Waiting to retry: {remaining}s...", end="\r")
                    sleep(1)
                GMAIL_SERVICE = init_gmail_service()
                continue
            else:
                raise  # Too many exceptions in the last minute


def pp(obj):
    pprint.PrettyPrinter(indent=2).pprint(obj)


def parse_dt(date_str):
    return parser.parse(date_str)


# parse a date string into
# utc datetime and tz offset string ("+0100", "-0800")
def parse_dtz(date_str: str):
    # parse the string to datetime object
    parsed_date = parsedate_tz(date_str)

    # ensure this is a 10 element tuple
    if parsed_date:
        timestamp = mktime_tz(parsed_date)
    else:
        raise Exception(f"ak: PARSE DATE FAILED {date_str}")
    date_in_utc = datetime.fromtimestamp(timestamp, pytz.utc)

    # extract the timezone offset
    tz_offset_seconds = float(parsed_date[9] or 0)
    tz_offset = timedelta(seconds=tz_offset_seconds)

    # format the offset as a string (e.g., +0100, -0800)
    offset_hours = int(tz_offset.total_seconds() // 3600)
    offset_minutes = int((tz_offset.total_seconds() % 3600) // 60)
    tz_str = f"{offset_hours:+03d}{offset_minutes:02d}"

    return date_in_utc, tz_str


def default_dt():
    return datetime(1970, 1, 1)


def header_has_contacts(header_name):
    return header_name.lower() in CONTACTS_KEYS


class Base(DeclarativeBase):
    def __repr__(self):
        return f"<{self.__class__.__name__} {self.__dict__}>"


# table with all calendar days from 1970 to 2100
@dataclass
class Day(Base):
    __tablename__ = "days"
    date: Mapped[date] = mapped_column(DateTime, primary_key=True)

    FIRST = datetime(1970, 1, 1)
    LAST = datetime(2100, 1, 1)

    @classmethod
    def find_by_date(cls, _d):
        return db_session.query(cls).where(cls.date == _d).first()

    @classmethod
    def upsert(cls, _d):
        if cls.find_by_date(_d):
            return
        d = Day()
        d.date = _d
        print(f"INSERT: {d} (not committing)")
        db_session.add(d)

    @classmethod
    def setup(cls):
        create_tables_if_not_exist()
        current_date = cls.FIRST
        while current_date < cls.LAST:
            cls.upsert(current_date)
            current_date += timedelta(days=1)
        print("COMMIT: Day.setup")
        db_session.commit()


# TODO: add "my_email" metadata
@dataclass
class Md(Base):
    __tablename__ = "md"
    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    # key name
    k: Mapped[str] = mapped_column(String, unique=True)
    # value name
    v: Mapped[str] = mapped_column(String)

    @classmethod
    def find_by_k(cls, _k):
        return db_session.query(cls).where(cls.k == _k).first()

    @classmethod
    def upsert(cls, _k, _v):
        md = cls.find_by_k(_k) or Md()
        md.k = _k
        md.v = _v
        db_session.add(md)
        db_session.commit()

    @classmethod
    def setup(cls):
        create_tables_if_not_exist()
        # setup the md table:
        md = {
            "name_blacklist": "Apple Business|craigslist",
            "email_blacklist": (
                "4pfp|accounts*@|"
                "511tactical|actors@|admin|agent@|alert|allianz|amazon|^ar@acc|assistant\.|"
                "atlas@e\.stripe|atlas@stripe|^att@|^\.att\.|axs\.com|"
                "billing|booking|"
                "community@|coned|confirm|connect@|contact@|customer|"
                "daemon|devops|document|docusign|"
                "email@|etrade|events*@|"
                "filmfest@|feedback|festival@|filings@|@fin\.com|@finxpc\.com|followup|forums*@|"
                "giving@|googlegroups|googlenest|"
                "hello@|help|"
                "id\.apple\.com|iftt|info@|info\.|^ir@|"
                "@inside\.garmin\.com|invest@|invoice|"
                "jetblueairways|"
                "legal@|lexisnexis|listening\.id\.me|"
                "mailgun|mail\.vresp|mail\.comms\.yahoo\.net|marketing|@member|members*@|microsoft@|"
                "momence|mskcc|my_merrill|"
                "news@|notifications*@|notifier|notify@|"
                "optimum@mail\.optimumemail1\.com|orders*@|"
                "paperlesspost|postmaster|providers*@|proxyvote\.com|psyd|"
                "quotes*@|receipts@|reply|reservations*@|robot@|"
                "security|securemessag|service|^sff@|statement|status@|submissions*@|"
                "subscription|substack|support|"
                "sxsw@|"
                "team@|ticket|tracking@|"
                "update|"
                "venmo@|"
                "verify@|verizonwireless|vimeo@|"
                "welcome|world@"
            ),
        }
        print("--------------")
        print("Setting up md:")
        print("--------------")
        for k, v in md.items():
            print(f"{k}:\n    {v}")
            cls.upsert(k, v)
        # setup the days table:
        Day.setup()


@dataclass
class Contact(Base):
    __tablename__ = "contacts"

    # columns
    name: Mapped[str] = mapped_column(String)
    email: Mapped[str] = mapped_column(String, primary_key=True)
    email_raw: Mapped[str] = mapped_column(String)
    header: Mapped[str] = mapped_column(String)

    def __repr__(self):
        return f"<{self.__class__.__name__} {self.header}: {self.email}"

    @classmethod
    def find_by_email(cls, _email):
        return db_session.query(cls).where(cls.email == _email).first()

    def insert(self):
        print(f"INSERT: {self}")
        db_session.add(self)
        db_session.commit()

    def insert_if_not_exists(self):
        _exists = self.find_by_email(self.email)
        if not _exists:
            self.insert()

    @classmethod
    def _normalize_name(cls, _raw):
        # to lowercase
        _name = _raw.lower()
        # replace ' with space
        _name = re.sub(r"'", " ", _name)
        # replace multiple spaces with single space
        _name = re.sub(r"\s+", " ", _name)
        # trim leading / trailing white space
        _name = _name.strip()

        return _name

    @classmethod
    def _normalize_email(cls, _raw):
        # to lowercase
        _email = _raw.lower()
        # name+junk@gmail.com to name@gmail.com
        _email = re.sub(r"\+[^@]*@", "@", _email)
        return _email

    @classmethod
    def split(cls, _h_name, _h_value):
        addresses = email.utils.getaddresses([_h_value])
        contacts = []

        for _p_name, _email_raw in addresses:
            _n = "".join(
                # decode according to charset
                _p.decode(_enc or "utf-8") if isinstance(_p, bytes) else _p
                for _p, _enc in decode_header(_p_name)
            )
            # normalize email:
            _email = cls._normalize_email(_email_raw)
            _name = cls._normalize_name(_n)
            p = Contact(name=_name, email=_email, email_raw=_email_raw, header=_h_name)
            contacts.append(p)

        return contacts

    @classmethod
    def all_from_header(cls, _h_name, _h_value) -> List["Contact"]:
        return cls.split(_h_name, _h_value)


@dataclass
class Email(Base):
    __tablename__ = "emails"

    # columns
    id: Mapped[str] = mapped_column(String, primary_key=True)
    thread_id: Mapped[str] = mapped_column(String, default=UNDEF)
    subject: Mapped[str] = mapped_column(String, nullable=True)
    c_from: Mapped[str] = mapped_column(String, default=UNDEF)
    date: Mapped[datetime] = mapped_column(DateTime, default=default_dt)
    tz: Mapped[str] = mapped_column(String, default=UNDEF)
    date_raw: Mapped[str] = mapped_column(String, nullable=True)
    headers_raw: Mapped[str] = mapped_column(String, default="{}")

    # not persisted as raw dict to db
    headers: Any = field(default_factory=dict)

    def __repr__(self):
        return f"<{self.__class__.__name__} id: {self.id} // Subject: {self.subject[:64]}>"

    FROM = "From"

    @classmethod
    def find_by_id(cls, _id):
        return db_session.query(cls).where(cls.id == _id).first()

    def insert(self):
        print(f"INSERT: {self}")
        db_session.add(self)
        db_session.commit()

    def insert_if_not_exists(self):
        _exists = self.find_by_id(self.id)
        if not _exists:
            self.insert()

    @classmethod
    def from_message(cls, m: GMailMessage):
        e = Email()
        e.id = m.get("id")
        e.thread_id = m.get("threadId")

        # parse the headers
        _hl: GMailHeaders = m.get("payload").get("headers") or []
        e.headers = dict([(h.get("name"), h.get("value")) for h in _hl])

        # get subject, date, from from headers
        e.subject = str(e.headers.get("Subject"))

        if not e.headers.get("Date"):
            return None

        e.date_raw = str(e.headers.get("Date"))
        dt, tz = parse_dtz(e.date_raw)
        e.date = dt
        e.tz = tz
        # e.date = parse_dt(e.date_raw)

        _from = e.headers.get(cls.FROM)
        if _from:
            contacts = Contact.all_from_header(cls.FROM, _from)
            if contacts:
                # contact email has been normalized:
                e.c_from = contacts[0].email
        return e

    def utc_timestamp(self):
        dt = self.date
        # Ensure that the datetime is timezone-aware and set to UTC
        if dt.tzinfo is None or dt.tzinfo.utcoffset(dt) is None:
            dt = pytz.utc.localize(dt)
        return int(dt.timestamp())

    @classmethod
    def oldest(cls):
        oldest = db_session.query(cls).order_by(cls.date.asc()).first()
        return oldest

    @classmethod
    def oldest_timestamp(cls):
        # format date of oldest email as
        #  All dates used in the search query are interpreted as midnight on
        #    that date in the PST timezone. To specify accurate dates for other
        #    timezones pass the value in seconds instead:
        #
        # ?q=in:sent after:1388552400 before:1391230800
        # https://developers.google.com/gmail/api/guides/filtering
        oldest = cls.oldest()
        if oldest:
            return oldest.utc_timestamp()


@dataclass
class EmailContact(Base):
    __tablename__ = "email_contacts"
    __allow_unmapped__ = True

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    email_id: Mapped[str] = mapped_column(
        String, ForeignKey("emails.id"), index=True, default=UNDEF
    )
    # could be useful for quick aggregations:
    thread_id: Mapped[str] = mapped_column(String, default=UNDEF)
    name: Mapped[str] = mapped_column(String, default=UNDEF)
    email: Mapped[str] = mapped_column(
        String, default=UNDEF
    )  # normalized # ForeignKey("contacts.email")
    email_raw: Mapped[str] = mapped_column(String, default=UNDEF)

    date: Mapped[datetime] = mapped_column(DateTime, default=default_dt)
    header: Mapped[str] = mapped_column(String, default=UNDEF)
    # don't confuse this for a database column:
    _contact: Optional[Contact] = None

    def __repr__(self):
        # date in YYYY-MM-DD format:
        dt = "None"
        if self.date:
            dt = self.date.strftime("%Y-%m-%d")
        return f"<{self.__class__.__name__} {self.header}: {self.email} // {dt}>"

    @classmethod
    def find_by_email_id_and_email_and_header(cls, _email_id, _email, _header):
        return (
            db_session.query(cls)
            .where(cls.email_id == _email_id)
            .where(cls.email == _email)
            .where(cls.header == _header)
            .first()
        )

    def insert_if_not_exists(self):
        _exists = self.find_by_email_id_and_email_and_header(self.email_id, self.email, self.header)
        if not _exists:
            print(f"INSERT: {self}")
            db_session.add(self)
            db_session.commit()

    @classmethod
    def from_email(cls, email) -> List["EmailContact"]:
        ecs = []
        for _h_name in email.headers:
            _h_value = email.headers.get(_h_name)
            if header_has_contacts(_h_name):
                contacts = Contact.all_from_header(_h_name, _h_value)
                if contacts:
                    # create one EmailContact per Email x Contact
                    for c in contacts:
                        ec = EmailContact()
                        ec._contact = c
                        ec.email_id = email.id
                        ec.thread_id = email.thread_id
                        # contact name has already been normalized:
                        ec.name = c.name
                        ec.email = c.email
                        ec.email_raw = c.email_raw
                        ec.date = email.date
                        ec.header = _h_name
                        ecs.append(ec)
        return ecs


##################################################
# sqlalchemy
##################################################

db_session = Session(ENGINE)


def create_tables_if_not_exist():
    Base.metadata.create_all(ENGINE)


##################################################
# gmail api
##################################################


def messages_list(list_query, page_token=None):
    with allow_exceptions_per_minutes(per_minutes=5, max_per_minutes=3, wait_secs=45):
        response = (
            GMAIL_SERVICE.users()
            .messages()
            .list(userId="me", q=list_query, pageToken=page_token, maxResults=MAX_MESSAGE_RESULTS)
            .execute()
        )
        return response


def messages_get(messages):
    for msg in messages:
        email_id = msg.get("id")
        _exists = Email.find_by_id(email_id)
        if _exists:
            print(f"SKIP:   {_exists}")
            continue

        m = {}
        with allow_exceptions_per_minutes(per_minutes=5, max_per_minutes=3, wait_secs=45):
            # use api to get email headers:
            m = GMAIL_SERVICE.users().messages().get(userId="me", id=email_id).execute()

        # create Email and insert:
        _email = Email.from_message(m)
        if not _email:
            continue
        _email.insert()

        # create Contacts and EmailContacts and insert:
        ecs = EmailContact.from_email(_email)
        for ec in ecs:
            ec.insert_if_not_exists()
            if ec._contact:
                ec._contact.insert_if_not_exists()

        db_session.commit()

    return _email


##################################################
# dl
##################################################
def dl(resume_oldest: bool):
    create_tables_if_not_exist()
    # search query for the gmail api:
    q = ""
    if resume_oldest:
        oldest_timestamp = Email.oldest_timestamp()
        # TODO: should we set this to one day BEFORE oldest timestamp?
        # TODO: really should track COMPLETED days in separate table -- perhaps use the on: operator?
        if oldest_timestamp:
            # All dates used in the search query are interpreted as midnight on that
            #  date in the PST timezone. To specify accurate dates for other timezones
            #  pass the value in seconds instead:
            #  ?q=in:sent after:1388552400 before:1391230800
            q = f"before: {oldest_timestamp}"
            print("---------------------------")
            print(q)
            print("---------------------------")

    # Setup the Gmail API client

    response = messages_list(q)

    while "messages" in response:
        messages_get(response["messages"])
        if "nextPageToken" in response:
            response = messages_list(q, response["nextPageToken"])
        else:
            break


##################################################
# rank
##################################################
def rank():
    create_tables_if_not_exist()
    raise NotImplementedError("See dl_gmail_contacts.sql")


def main():
    parser = argparse.ArgumentParser(description="""Download and rank google contacts.""")
    parser.add_argument("action", help="action to take", choices=["dl", "rank", "setup_md"])
    parser.add_argument("--resume-oldest", action="store_true")
    # parser.add_argument("-v", "--verbose", action="store_true")
    args = parser.parse_args()

    if args.action == "dl":
        dl(resume_oldest=args.resume_oldest)
    elif args.action == "setup_md":
        Md.setup()
    elif args.action == "rank":
        rank()
    else:
        print("Invalid action `{args.action}`")
        exit(1)


if __name__ == "__main__":
    main()
