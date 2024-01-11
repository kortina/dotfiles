----------------------------------------
-- view metadata
----------------------------------------
SELECT
    *
FROM
    md
ORDER BY
    k ASC;

----------------------------------------
-- sample emails
----------------------------------------
SELECT
    *
FROM
    emails
ORDER BY
    `date` desc
LIMIT
    100;

----------------------------------------
-- oldest email date
----------------------------------------
SELECT
    *
FROM
    emails
ORDER BY
    `date` asc
LIMIT
    1;

----------------------------------------
-- popular recipients
----------------------------------------
WITH
    recipients AS (
        SELECT
            email,
            name,
            count(DISTINCT (thread_id)) AS c
        FROM
            email_contacts
        WHERE
            (
                header = 'To'
                OR header = 'Cc'
                OR header = 'Bcc'
            )
            AND email IS NOT NULL
            AND email != ''
        GROUP BY
            email,
            name
    ),
    ranked AS (
        SELECT
            email,
            name,
            c,
            -- sum over email to get total count across email ANY name
            SUM(c) OVER (
                PARTITION BY
                    email
            ) AS tc,
            -- rank to get most frequent name
            ROW_NUMBER() OVER (
                PARTITION BY
                    email
                ORDER BY
                    c DESC
            ) AS rank
        FROM
            recipients
    )
SELECT
    email,
    name,
    tc as c
FROM
    ranked
WHERE
    rank = 1
ORDER BY
    c DESC,
    name ASC;

----------------------------------------
-- TODO: make a metadata table for shared config, eg:
-- INSERT INTO metadata 
-- config = 1, key = 'email_blacklist_regex' value = 'regex from below'; ..........
-- name_blacklist_regex = 'Apple Store|akaldkfjadls'
-- most popular senders
----------------------------------------
WITH
    senders AS (
        SELECT
            name,
            email,
            header,
            COUNT(DISTINCT (thread_id)) AS c
        FROM
            email_contacts
        WHERE
            header = 'From'
            AND name NOT REGEXP 'Apple Business|craigslist'
            AND email NOT REGEXP '4pfp|accounts*@|511tactical|actors@|admin|agent@|alert|allianz|amazon|^ar@acc|assistant\.|atlas@e\.stripe|atlas@stripe|^att@|^\.att\.|axs\.com|billing|booking|community@|coned|confirm|connect@|contact@|customer|daemon|devops|document|docusign|email@|etrade|events*@|filmfest@|feedback|festival@|filings@|@fin\.com|@finxpc\.com|followup|forums*@|giving@|googlegroups|googlenest|hello@|help|id\.apple\.com|iftt|info@|info\.|^ir@|@inside\.garmin\.com|invest@|invoice|jetblueairways|legal@|lexisnexis|listening\.id\.me|mailgun|mail\.vresp|mail\.comms\.yahoo\.net|marketing|@member|members*@|microsoft@|momence|mskcc|my_merrill|news@|notifications*@|notifier|notify@|optimum@mail\.optimumemail1\.com|orders*@|paperlesspost|postmaster|providers*@|proxyvote\.com|psyd|quotes*@|receipts@|reply|reservations*@|robot@|security|securemessag|service|^sff@|statement|status@|submissions*@|subscription|substack|support|sxsw@|team@|ticket|tracking@|update|venmo@|verify@|verizonwireless|vimeo@|welcome|world@'
        GROUP BY
            name,
            email
        ORDER BY
            c desc
    )
SELECT
    name,
    email,
    c,
    row_number() OVER (
        PARTITION BY
            email
        ORDER BY
            c DESC
    ) AS rank
FROM
    senders
ORDER BY
    email ASC,
    c DESC;