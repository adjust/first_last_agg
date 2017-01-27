/*------------------------------------------------------------------------
 *
 * first-last-agg.c
 *     first() and last() aggregate functions working on anyelement
 *
 * Copyright (c) 2011, PostgreSQL Global Development Group
 *
 *-------------------------------------------------------------------------
 */
#include "postgres.h"

#include "fmgr.h"
#include "utils/array.h"


PG_MODULE_MAGIC;

extern Datum first_sfunc(PG_FUNCTION_ARGS);
extern Datum last_sfunc(PG_FUNCTION_ARGS);
extern Datum nullable_last_sfunc(PG_FUNCTION_ARGS);
extern Datum nullable_first_sfunc(PG_FUNCTION_ARGS);
extern Datum nullable_first_final(PG_FUNCTION_ARGS);


PG_FUNCTION_INFO_V1(first_sfunc);

Datum
first_sfunc(PG_FUNCTION_ARGS)
{
	Datum	element;

	/* simply return the first argument */
	element = PG_GETARG_DATUM(0);
	PG_RETURN_DATUM(element);
}


PG_FUNCTION_INFO_V1(last_sfunc);

Datum
last_sfunc(PG_FUNCTION_ARGS)
{
	Datum	element;

	/* simply return the second argument */
	element = PG_GETARG_DATUM(1);
	PG_RETURN_DATUM(element);
}


PG_FUNCTION_INFO_V1(first_nullable_sfunc);

Datum
first_nullable_sfunc(PG_FUNCTION_ARGS)
{
	Datum	element;

	/* simply return the first argument */
	element = PG_GETARG_DATUM(0);
	PG_RETURN_DATUM(element);
}


#define PG_ARGISVOID(n) (!PG_GETARG_DATUM(n) && !PG_ARGISNULL(n))

PG_FUNCTION_INFO_V1(nullable_first_sfunc);

Datum
nullable_first_sfunc(PG_FUNCTION_ARGS)
{
	Datum	element;

        if (PG_ARGISVOID(0)) {
                PG_RETURN_VOID();                
        } else if(PG_ARGISNULL(0)) {
                /* first call into the function => map NULL to VOID */
                if (PG_ARGISVOID(1)) {
                        ereport(ERROR,
                                (errcode(ERRCODE_INVALID_PARAMETER_VALUE),
                                 errmsg("VOID on first input is not supported")));
                }
                else if (PG_ARGISNULL(1)) {
                        PG_RETURN_VOID();
                }
                else {
                        element = PG_GETARG_DATUM(1);
                        PG_RETURN_DATUM(element);
                }
        } else {
                /* non-NULL first ever aggregated value case */
                element = PG_GETARG_DATUM(0);
                PG_RETURN_DATUM(element);
        }
}

PG_FUNCTION_INFO_V1(nullable_first_final);

Datum
nullable_first_final(PG_FUNCTION_ARGS)
{
        Datum element;

        if(PG_ARGISNULL(0)) {
                PG_RETURN_NULL();
        } else if (PG_ARGISVOID(0)) {
                PG_RETURN_NULL();
        } else {
                element = PG_GETARG_DATUM(0);
                PG_RETURN_DATUM(element);
        }
}


PG_FUNCTION_INFO_V1(nullable_last_sfunc);

Datum
nullable_last_sfunc(PG_FUNCTION_ARGS)
{
	Datum	element;

        if (PG_ARGISNULL(1)) {
                PG_RETURN_NULL();
        } else {
                /* simply return the second argument */
                element = PG_GETARG_DATUM(1);
                PG_RETURN_DATUM(element);
        }
}

