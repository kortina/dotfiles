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
from datetime import datetime
from email.header import decode_header
from typing import Any, List, Optional

from dateutil import parser
from google.oauth2.credentials import Credentials
from googleapiclient.discovery import build
from sqlalchemy import DateTime, Integer, String, create_engine, select
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
        return db_session.execute(select(cls).where(cls.email == _email)).first()

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
    date_raw: Mapped[str] = mapped_column(String, default=UNDEF)
    headers_raw: Mapped[str] = mapped_column(String, default="{}")

    # not persisted as raw dict to db
    headers: Any = field(default_factory=dict)

    def __repr__(self):
        return f"<{self.__class__.__name__} id: {self.id} Subject: {self.subject}>"

    FROM = "From"

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
        e.date = parse_dt(e.date_raw)

        _from = e.headers.get(cls.FROM)
        if _from:
            contacts = Contact.all_from_header(cls.FROM, _from)
            if contacts:
                e.c_from = contacts[0].email
        return e


@dataclass
class EmailContact(Base):
    __tablename__ = "email_contacts"
    __allow_unmapped__ = True

    id: Mapped[int] = mapped_column(Integer, primary_key=True, autoincrement=True)
    email_id: Mapped[str] = mapped_column(
        String, ForeignKey("emails.id"), index=True, default=UNDEF
    )
    thread_id: Mapped[str] = mapped_column(String, default=UNDEF)
    subject: Mapped[str] = mapped_column(String, default=UNDEF)
    name: Mapped[str] = mapped_column(String, default=UNDEF)
    email: Mapped[str] = mapped_column(
        String, default=UNDEF
    )  # normalized # ForeignKey("contacts.email")
    email_raw: Mapped[str] = mapped_column(String, default=UNDEF)

    date: Mapped[datetime] = mapped_column(DateTime, default=default_dt)
    date_raw: Mapped[str] = mapped_column(String, default=UNDEF)
    header: Mapped[str] = mapped_column(String, default=UNDEF)
    _contact: Optional[Contact] = None

    def __repr__(self):
        return f"<{self.__class__.__name__} {self.header}: {self.email} // email_subject: {self.subject}>"

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
                        ec.subject = email.subject
                        ec.name = c.name
                        ec.email = c.email
                        ec.email_raw = c.email_raw
                        ec.date = email.date
                        ec.date_raw = email.date_raw
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
        db_session.add(email)
        db_session.commit()

        ecs = EmailContact.from_email(email)
        for ec in ecs:
            db_session.add(ec)
            if ec._contact:
                ec._contact.insert_if_not_exists()

        db_session.commit()

        pp(ecs)

        # commit all the rows to DB:
        db_session.commit()
    return email


def scrape():
    create_tables_if_not_exist()

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
        service.users().messages().list(userId="me", q="", maxResults=MAX_MESSAGE_RESULTS).execute()
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
                    q="",
                    maxResults=MAX_MESSAGE_RESULTS,
                )
                .execute()
            )
        else:
            break


##################################################
# TODO: create for each @dataclass
# - Emails
# - Contacts
# - EmailContacts
# - and metadata
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
    # parser.add_argument("-v", "--verbose", action="store_true")
    args = parser.parse_args()

    if args.action == "scrape":
        scrape()
    elif args.action == "rank":
        rank()
    else:
        print("Invalid action `{args.action}`")
        exit(1)


if __name__ == "__main__":
    main()
