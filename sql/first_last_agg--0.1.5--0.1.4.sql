/*
 * Downgrade from 0.1.5 to 0.1.4: remove parallel safety from aggregate
 * functions.
 *
 * NOTE: downgrade limitations
 *
 * This downgrade requires PostgreSQL 12 or later, for the same reason as
 * the upgrade: CREATE OR REPLACE AGGREGATE (needed to safely redefine
 * aggregates with potential dependent objects) was introduced in PostgreSQL
 * 12.
 * Databases below PG 12 may have reached 0.1.5+ via a fresh installation
 * or the old direct upgrade path (which used DROP+CREATE) if they had no
 * dependency.  Those databases cannot use this downgrade script.
 * Since PG 10 and PG 11 are both EOL, no workaround is provided.  If you face
 * this problem, you will have to upgrade your PostgreSQL instance to at least
 * PostgreSQL 12 in order to be able to downgrade the extension.
 */

DO $$
BEGIN
  IF current_setting('server_version_num')::integer < 120000 THEN
    RAISE EXCEPTION
      'Downgrading first_last_agg from 0.1.5 requires PostgreSQL 12 or later '
      '(current version: %).',
      current_setting('server_version');
  END IF;
END;
$$;

ALTER FUNCTION last_sfunc(anyelement, anyelement) PARALLEL UNSAFE;
ALTER FUNCTION first_sfunc(anyelement, anyelement) PARALLEL UNSAFE;

CREATE OR REPLACE AGGREGATE first(anyelement) (
    SFUNC = first_sfunc,
    STYPE = anyelement
);

CREATE OR REPLACE AGGREGATE last(anyelement) (
    SFUNC = last_sfunc,
    STYPE = anyelement
);
