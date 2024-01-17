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
-- contains apostrophe
----------------------------------------
SELECT
    email
  , name
  , count(DISTINCT (thread_id)) AS c
FROM
    email_contacts
WHERE
    name LIKE '%''%'
GROUP BY
    email
  , name
ORDER BY
    c DESC;

----------------------------------------
-- replace apostrophe
----------------------------------------
UPDATE email_contacts
SET
    name = TRIM(REPLACE (REPLACE (name, "'", ' '), '"', ' '))
WHERE
    name LIKE '%''%';

SELECT
    *
FROM
    email_contacts
WHERE
    email NOT REGEXP (
        SELECT
            v
        FROM
            md
        WHERE
            k = 'email_blacklist'
    );

----------------------------------------
-- popular people
----------------------------------------
WITH
    recipients AS (
        SELECT
            email
          , name
          , count(DISTINCT (thread_id)) AS c
        FROM
            email_contacts
        WHERE
            (
                header = 'To'
                OR header = 'Cc'
                OR header = 'Bcc'
                -- include senders also:
                OR header = 'From'
            )
            AND email IS NOT NULL
            AND email != ''
        GROUP BY
            email
          , name
    )
  , ranked AS (
        SELECT
            email
          , name
          , c, -- sum over email to get total count across email ANY name
            SUM(c) OVER (
                PARTITION BY
                    email
            ) AS tc, -- rank to get most frequent name
            ROW_NUMBER() OVER (
                PARTITION BY
                    email
                ORDER BY
                    c DESC
            ) AS rank
        FROM
            recipients
    )
  , top_names_per_email AS (
        SELECT
            email
          , name
          , rank
          , c
          , tc
          , tc != c AS multiple_names
        FROM
            ranked
        WHERE
            rank = 1
            OR rank = 2
        ORDER BY
            c DESC
          , name ASC
    )
SELECT
    l.email
  , CASE
        WHEN l.name = ''
        OR l.name IS NULL THEN r.name
        ELSE l.name
    END AS name
  , l.tc
    -- l.rank
    -- , l.name AS l_name
    -- , r.name AS r_name
    -- , l.tc
FROM
    top_names_per_email l
    -- join table to itself to get the top 2 names per email
    -- so we can throw out null names
    LEFT OUTER JOIN top_names_per_email r ON l.email = r.email
    AND l.rank = 1
    AND r.rank = 2
WHERE
    l.rank = 1
    AND l.email NOT REGEXP (
        SELECT
            v
        FROM
            md
        WHERE
            k = 'email_blacklist'
    )
    AND l.name NOT REGEXP (
        SELECT
            v
        FROM
            md
        WHERE
            k = 'name_blacklist'
    )
ORDER BY
    l.tc DESC;