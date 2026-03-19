/*
 * Upgrade from 0.1.4 to 0.1.5: make aggregate functions parallel safe on
 * supported server versions (PostgreSQL 12+).
 *
 * NOTE: upgrade limitations
 *
 * This upgrade requires PostgreSQL 12 or later. CREATE OR REPLACE AGGREGATE,
 * which is needed to safely redefine aggregates that may have dependent
 * objects, was introduced in PostgreSQL 12. Attempting this upgrade on an
 * older version will raise an error; stay on 0.1.4 in that case.
 *
 * NOTE: parallel safety and sorted aggregates
 *
 * The primary use of first()/last() is with per-aggregate ORDER BY, such as
 * "last(col ORDER BY sort_col)".
 * As of PostgreSQL 18, PostgreSQL does not apply the Parallel Aggregate plan
 * node to aggregates with ORDER BY or DISTINCT modifiers, so PARALLEL SAFE +
 * COMBINEFUNC have no effect on query performance for that pattern.
 * ref. https://www.postgresql.org/docs/18/parallel-plans.html#PARALLEL-AGGREGATION
 *
 * Parallel aggregation is currently only expected to apply outside of these
 * cases.
 */

DO $$
BEGIN
  IF current_setting('server_version_num')::integer < 120000 THEN
    RAISE EXCEPTION
      'Upgrading first_last_agg to 0.1.5 requires PostgreSQL 12 or later '
      '(current version: %). Stay on version 0.1.4 or upgrade your PostgreSQL.',
      current_setting('server_version');
  END IF;
END;
$$;

ALTER FUNCTION last_sfunc(anyelement, anyelement) PARALLEL SAFE;
ALTER FUNCTION first_sfunc(anyelement, anyelement) PARALLEL SAFE;

CREATE OR REPLACE AGGREGATE first(anyelement) (
    SFUNC = first_sfunc,
    STYPE = anyelement,
    COMBINEFUNC = first_sfunc,
    PARALLEL = SAFE
);

CREATE OR REPLACE AGGREGATE last(anyelement) (
    SFUNC = last_sfunc,
    STYPE = anyelement,
    COMBINEFUNC = last_sfunc,
    PARALLEL = SAFE
);
