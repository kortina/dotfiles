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
from dataclasses import dataclass, field
from datetime import datetime, timedelta
from email.header import decode_header
from email.utils import mktime_tz, parsedate_tz
from typing import Any, List, Optional

import pytz
from dateutil import parser
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from sqlalchemy import DateTime, Integer, String, create_engine
from sqlalchemy.orm import DeclarativeBase, Mapped, Session, mapped_column
from sqlalchemy.sql.schema import ForeignKey

MAX_MESSAGE_RESULTS = 500
CREDENTIALS_PATH = "/Users/kortina/.ssh/gmail_scrape_contacts.json"
DB_PATH = "gmail_scrape_contacts.db"
ENGINE_URL = f"sqlite:///{DB_PATH}"
ENGINE = create_engine(ENGINE_URL)

# TODO: ensure this defaults everywhere or just allow NULL?
UNDEF = "_UNDEF_"
CONTACTS_KEYS = ["from", "to", "cc", "bcc", "reply-to", "sender", "return-path", "delivered-to"]

# see googleapiclient docs:
#   https://developers.google.com/gmail/api/reference/rest/v1/users.messages#Message
GMailMessage = Any
GMailHeaders = Any


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

    def insert_if_not_exists(self):
        _exists = self.find_by_email(self.email)
        if not _exists:
            db_session.add(self)
            db_session.commit()

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
            p = Contact(name=_n, email=_email, email_raw=_email_raw, header=_h_name)
            contacts.append(p)

        pp(contacts)
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
    date_raw: Mapped[str] = mapped_column(String, default=UNDEF)
    headers_raw: Mapped[str] = mapped_column(String, default="{}")

    # not persisted as raw dict to db
    headers: Any = field(default_factory=dict)

    def __repr__(self):
        return f"<{self.__class__.__name__} id: {self.id} Subject: {self.subject}>"

    FROM = "From"

    @classmethod
    def find_by_id(cls, _id):
        return db_session.query(cls).where(cls.id == _id).first()

    def insert_if_not_exists(self):
        _exists = self.find_by_id(self.id)
        if not _exists:
            db_session.add(self)
            db_session.commit()

    @classmethod
    def from_message(cls, m: GMailMessage):
        e = Email()
        e.id = m.get("id")
        e.thread_id = m.get("threadId")

        # parse the headers
        _hl: GMailHeaders = m.get("payload").get("headers") or []
        e.headers = dict([(h.get("name"), h.get("value")) for h in _hl])

        # get subject, date, from from headers
        e.subject = str(e.headers.get("Subject") or UNDEF)
        e.date_raw = str(e.headers.get("Date") or UNDEF)
        dt, tz = parse_dtz(e.date_raw)
        e.date = dt
        e.tz = tz
        # e.date = parse_dt(e.date_raw)

        _from = e.headers.get(cls.FROM)
        if _from:
            contacts = Contact.all_from_header(cls.FROM, _from)
            if contacts:
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
                        ec.name = c.name
                        ec.email = c.email
                        ec.email_raw = c.email_raw
                        ec.date = email.date
                        ec.header = _h_name
                        print(ec)
                        ecs.append(ec)
        return ecs


##################################################
# sqlalchemy
##################################################

db_session = Session(ENGINE)

##################################################
# main methods
##################################################


def fetch_messages(service, messages):
    for msg in messages:
        md = {"id": msg.get("id"), "threadId": msg.get("threadId")}
        # additional api call to get message details like email headers:
        m = service.users().messages().get(userId="me", id=md.get("id")).execute()
        email = Email.from_message(m)
        email.insert_if_not_exists()

        ecs = EmailContact.from_email(email)
        for ec in ecs:
            ec.insert_if_not_exists()
            if ec._contact:
                ec._contact.insert_if_not_exists()

        db_session.commit()

        pp(ecs)

        # commit all the rows to DB:
        db_session.commit()
    return email


def scrape(resume_oldest: bool):
    create_tables_if_not_exist()
    # search query for the gmail api:
    q = ""
    if resume_oldest:
        oldest_timestamp = Email.oldest_timestamp()
        # TODO: should we set this to one day BEFORE oldest timestamp?
        if oldest_timestamp:
            q = f"before: {oldest_timestamp}"
            print("---------------------------")
            print(q)
            print("---------------------------")

    credentials = Credentials.from_authorized_user_file(CREDENTIALS_PATH)

    # Get the timestamp of the last processed email:
    # create_tables_if_not_exist()
    # last_email_id = get_last_processed_email_id()

    # Setup the Gmail API client
    service = build("gmail", "v1", credentials=credentials)

    # Retrieve all messages after ts.
    # All dates used in the search query are interpreted as midnight on that
    #  date in the PST timezone. To specify accurate dates for other timezones
    #  pass the value in seconds instead:
    #  ?q=in:sent after:1388552400 before:1391230800
    response = (
        service.users().messages().list(userId="me", q=q, maxResults=MAX_MESSAGE_RESULTS).execute()
    )

    while "messages" in response:
        fetch_messages(service, response["messages"])
        if "nextPageToken" in response:
            response = (
                service.users()
                .messages()
                .list(
                    userId="me",
                    pageToken=response["nextPageToken"],
                    q=q,
                    maxResults=MAX_MESSAGE_RESULTS,
                )
                .execute()
            )
        else:
            break


##################################################
# setup db
##################################################
def create_tables_if_not_exist():
    Base.metadata.create_all(ENGINE)


#     conn = sqlite3.connect(DB_PATH)
#     conn.execute(
#         """
#         CREATE TABLE IF NOT EXISTS emails (
#             id INTEGER PRIMARY KEY,
#             subject TEXT,
#             from_address TEXT,
#             sent_datetime TEXT
#         )
#         """
#     )

#     conn.execute(
#         """
#         CREATE TABLE IF NOT EXISTS email_headers (
#             id INTEGER PRIMARY KEY,
#             email_id INTEGER,
#             header_name TEXT,
#             raw_value TEXT,
#             normalized_value TEXT,
#             FOREIGN KEY (email_id) REFERENCES emails(id)
#         )
#         """
#     )

#     conn.execute(
#         """
#         CREATE TABLE IF NOT EXISTS email_contacts (
#             id INTEGER PRIMARY KEY,
#             email_id INTEGER,
#             email_address TEXT,
#             count INTEGER,
#             FOREIGN KEY (email_id) REFERENCES emails(id),
#             UNIQUE (email_id, email_address)
#         )
#         """
#     )

#     conn.execute(
#         """
#         CREATE TABLE IF NOT EXISTS metadata (
#             key TEXT PRIMARY KEY,
#             value TEXT
#         )
#         """
#     )

#     conn.commit()
#     conn.close()


# # TODO: move save functions to each @dataclass
# # TODO: eg https://code.likeagirl.io/using-data-classes-to-create-database-models-in-python-b936301aa4ad
# def save_emails_to_database(emails):
#     conn = sqlite3.connect(DB_PATH)

#     for em in emails:
#         # Save email to "emails" table
#         conn.execute(
#             "INSERT INTO emails (id, subject, from_address, sent_datetime) VALUES (?, ?, ?, ?)",
#             (em.id, em.subject, em.from_address, em.sent_datetime),
#         )

#         # Save headers to "email_headers" table
#         headers = {
#             "To": em.to_addresses,
#             "Cc": em.cc_addresses,
#             "Bcc": em.bcc_addresses,
#         }

#         for header_name, header_values in headers.items():
#             for raw_value in header_values:
#                 raise Exception
#                 normalized_value = re.findall(EMAIL_REGEX, raw_value)[0].lower()
#                 print(f"{em.id} {header_name} {raw_value} {normalized_value}")
#                 conn.execute(
#                     "INSERT INTO email_headers (email_id, header_name, raw_value, normalized_value) VALUES (?, ?, ?, ?)",
#                     (em.id, header_name, raw_value, normalized_value),
#                 )

#     conn.commit()
#     conn.close()


# def save_last_processed_email_id(last_email_id):
#     conn = sqlite3.connect(DB_PATH)
#     conn.execute(
#         "INSERT OR REPLACE INTO metadata (key, value) VALUES (?, ?)",
#         ("last_email_id", last_email_id),
#     )
#     conn.commit()
#     conn.close()


# def get_last_processed_email_id():
#     conn = sqlite3.connect(DB_PATH)
#     cursor = conn.execute("SELECT value FROM metadata WHERE key = 'last_email_id'")
#     row = cursor.fetchone()
#     last_email_id = int(row[0]) if row is not None else None
#     conn.close()
#     return last_email_id


def rank():
    create_tables_if_not_exist()
    raise NotImplementedError
    # # Connect to the SQLite database
    # conn = sqlite3.connect(DB_PATH)
    # cursor = conn.cursor()

    # # Query to retrieve contact emails and their counts
    # query = """
    #     SELECT email_address, COUNT(email_address) AS contact_count
    #     FROM email_contacts
    #     GROUP BY email_address
    #     ORDER BY contact_count DESC
    # """

    # cursor.execute(query)
    # rows = cursor.fetchall()

    # # Print the results in tab-delimited format
    # print("Email Address\tContact Count")
    # print("------------------------\t-------------")
    # for row in rows:
    #     email_address, contact_count = row
    #     print(f"{email_address}\t{contact_count}")

    # # Close the database connection
    # conn.close()


def main():
    parser = argparse.ArgumentParser(description="""Download and rank google contacts.""")
    parser.add_argument("action", help="action to take", choices=["scrape", "rank"])
    parser.add_argument("--resume-oldest", action="store_true")
    # parser.add_argument("-v", "--verbose", action="store_true")
    args = parser.parse_args()

    if args.action == "scrape":
        scrape(resume_oldest=args.resume_oldest)
    elif args.action == "rank":
        rank()
    else:
        print("Invalid action `{args.action}`")
        exit(1)


if __name__ == "__main__":
    main()
