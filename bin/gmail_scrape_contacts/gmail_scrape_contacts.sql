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
    AND email NOT LIKE '%reply%'
    AND email NOT LIKE '%info%'
    AND email NOT REGEXP '4pfp|accounts*@|admin|agent@|alert|amazon|assistant\.|coned|customer|document|docusign|email@|events*@|filmfest@|festival@|googlegroups|googlenest|hello@|help|invoice|lexisnexis|marketing|momence|mskcc|my_merrill|notifications*@|notifier|orders*@|proxyvote\.com|quotes*@|robot@|security|securemessag|service|statement|submissions*@|subscription|substack|support|sxsw@|team@|ticket|update|venmo@|verizonwireless|vimeo@|welcome'
GROUP BY
    name,
    email
ORDER BY
    c desc;