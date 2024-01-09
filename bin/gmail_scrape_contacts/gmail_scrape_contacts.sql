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
-- TODO: make a metadata table for shared config, eg:
-- INSERT INTO metadata 
-- config = 1, key = 'email_blacklist_regex' value = 'regex from below'; ..........
-- name_blacklist_regex = 'Apple Store|akaldkfjadls'
-- most popular senders
----------------------------------------
SELECT
    name,
    email,
    header,
    COUNT(DISTINCT (thread_id)) AS c
FROM
    email_contacts
WHERE
    header = 'From'
    AND name NOT REGEXP 'Apple Business'
    AND email NOT REGEXP '4pfp|accounts*@|admin|agent@|alert|amazon|assistant\.|atlas@e\.stripe|atlas@stripe|billing|community@|coned|confirm|connect@|contact@|customer|document|docusign|email@|etrade|events*@|filmfest@|feedback@|festival@|filings@|giving@|googlegroups|googlenest|hello@|help|id\.apple\.com|info@|invest@|invoice|legal@|lexisnexis|istening\.id\.me|mail\.vresp|mail\.comms\.yahoo\.net|marketing|microsoft@|momence|mskcc|my_merrill|news@|notifications*@|notifier|notify@|optimum@mail\.optimumemail1\.com|orders*@|paperlesspost|postmaster|providers*@|proxyvote\.com|psyd|quotes*@|receipts@|reply|reservations*@|robot@|security|securemessag|service|statement|submissions*@|subscription|substack|support|sxsw@|team@|ticket|tracking@|update|venmo@|verify@|verizonwireless|vimeo@|welcome|world@'
GROUP BY
    name,
    email
ORDER BY
    c desc;