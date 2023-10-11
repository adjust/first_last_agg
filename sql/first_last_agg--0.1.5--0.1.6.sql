CREATE OR REPLACE FUNCTION first_lax_sfunc(internal, anyelement)
RETURNS internal
AS '$libdir/first_last_agg', 'first_lax_sfunc'
LANGUAGE C IMMUTABLE PARALLEL SAFE;

CREATE OR REPLACE FUNCTION first_lax_final(internal, anyelement)
RETURNS anyelement
AS '$libdir/first_last_agg', 'first_lax_final'
LANGUAGE C IMMUTABLE PARALLEL SAFE;

DROP AGGREGATE IF EXISTS first_lax(anyelement);
CREATE AGGREGATE first_lax(anyelement) (
    sfunc = first_lax_sfunc,
    finalfunc = first_lax_final,
    stype = internal,
    finalfunc_extra
);
