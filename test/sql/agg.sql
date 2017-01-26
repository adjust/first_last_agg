BEGIN;
SET client_min_messages TO 'WARNING';
\set ECHO none
\i sql/first_last_agg.sql
\set ECHO all
RESET client_min_messages;

CREATE TEMPORARY TABLE agg_test (
    akey integer,
    val1 integer,
    val2 integer
);

INSERT INTO agg_test (akey, val1, val2)
VALUES (1, 2, 1), (1, 4, 2), (1, 3, 3),
       (2, 1, 4), (2, 5, 3), (2, NULL, 2), (2, 2, 1),
       (3, NULL, NULL),
       (4, 3, 1), (4, 5, NULL), (4, 7, 2),
       (5, 5, 1), (5, 5, 2), (5, 5, 3);

SELECT akey, first(val1 ORDER BY val2) AS first, last(val1 ORDER BY val2) AS last FROM agg_test GROUP BY akey ORDER BY akey;
SELECT akey, first(val1 ORDER BY val2 NULLS LAST) AS first, last(val1 ORDER BY val2 NULLS LAST) AS last FROM agg_test GROUP BY akey ORDER BY akey;
SELECT akey, first(val1 ORDER BY val2 ASC) AS first, last(val1 ORDER BY val2 DESC) AS last FROM agg_test GROUP BY akey ORDER BY akey;
SELECT akey, first(val1 ORDER BY val2 ASC NULLS FIRST) AS first, last(val1 ORDER BY val2 NULLS FIRST) AS last FROM agg_test GROUP BY akey ORDER BY akey;
SELECT akey, first(val1) AS first, last(val1) AS last FROM agg_test WHERE akey IN (3, 5) GROUP BY akey ORDER BY akey;
SELECT akey, first(val1) AS first, last(val1) AS last FROM agg_test WHERE akey = 100 GROUP BY akey;

SELECT akey, nullable_last(val1 ORDER BY val2) AS null_val1, nullable_last(val2 ORDER BY val2) AS null_val2 FROM agg_test GROUP BY akey ORDER BY akey;
SELECT akey, nullable_last(val1 ORDER BY val1) AS null_val1, nullable_last(val2 ORDER BY val2 NULLS FIRST) AS null_val2 FROM agg_test GROUP BY akey ORDER BY akey;
SELECT akey, nullable_last(val1 ORDER BY val1 NULLS LAST) AS null_val1, nullable_last(val2 ORDER BY val2 NULLS LAST) AS null_val2 FROM agg_test GROUP BY akey ORDER BY akey;
SELECT akey, nullable_last(val1) AS nullable_last FROM agg_test WHERE akey = 100 GROUP BY akey;
SELECT nullable_last(val1) AS null_val1, nullable_last(val2) AS null_val2 FROM agg_test where akey = 4 AND val1 = 5;

ROLLBACK;
