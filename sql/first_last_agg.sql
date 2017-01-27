CREATE OR REPLACE FUNCTION last_sfunc(anyelement, anyelement)
RETURNS anyelement
AS '$libdir/first_last_agg', 'last_sfunc'
LANGUAGE C IMMUTABLE STRICT;

CREATE OR REPLACE FUNCTION first_sfunc(anyelement, anyelement)
RETURNS anyelement
AS '$libdir/first_last_agg', 'first_sfunc'
LANGUAGE C IMMUTABLE STRICT;

DROP AGGREGATE IF EXISTS first(anyelement);
CREATE AGGREGATE first(anyelement) (
    SFUNC = first_sfunc,
    STYPE = anyelement
);

DROP AGGREGATE IF EXISTS last(anyelement);
CREATE AGGREGATE last(anyelement) (
    SFUNC = last_sfunc,
    STYPE = anyelement
);

CREATE OR REPLACE FUNCTION nullable_last_sfunc(anyelement, anyelement)
RETURNS anyelement
AS '$libdir/first_last_agg', 'nullable_last_sfunc'
LANGUAGE C IMMUTABLE CALLED ON NULL INPUT;

CREATE OR REPLACE FUNCTION nullable_first_sfunc(anyelement, anyelement)
RETURNS anyelement
AS '$libdir/first_last_agg', 'nullable_first_sfunc'
LANGUAGE C IMMUTABLE CALLED ON NULL INPUT;

CREATE OR REPLACE FUNCTION nullable_first_final(anyelement)
RETURNS anyelement
AS '$libdir/first_last_agg', 'nullable_first_final'
LANGUAGE C IMMUTABLE CALLED ON NULL INPUT;

DROP AGGREGATE IF EXISTS nullable_last(anyelement);
CREATE AGGREGATE nullable_last(anyelement) (
    SFUNC = nullable_last_sfunc,
    STYPE = anyelement
);

DROP AGGREGATE IF EXISTS nullable_first(anyelement);
CREATE AGGREGATE nullable_first(anyelement) (
    SFUNC = nullable_first_sfunc,
    STYPE = anyelement,
    FINALFUNC = nullable_first_final
);
