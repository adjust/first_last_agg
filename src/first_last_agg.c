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

PG_MODULE_MAGIC;

extern Datum first_sfunc(PG_FUNCTION_ARGS);
extern Datum last_sfunc(PG_FUNCTION_ARGS);


typedef struct AggState
{
	Datum value;
	bool isnull;
} AggState;


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


PG_FUNCTION_INFO_V1(first_lax_sfunc);

Datum
first_lax_sfunc(PG_FUNCTION_ARGS)
{
	AggState *state = NULL;

	state = PG_ARGISNULL(0) ? NULL : (AggState *) PG_GETARG_POINTER(0);

	if (state == NULL)
	{
		MemoryContext agg_context;
		MemoryContext old_context;

		if (!AggCheckCallContext(fcinfo, &agg_context))
			elog(ERROR, "aggregate function called in non-aggregate context");

		old_context = MemoryContextSwitchTo(agg_context);

		state = (AggState *) palloc0(sizeof(AggState));

		MemoryContextSwitchTo(old_context);

		if (PG_ARGISNULL(1))
			state->isnull = true;
		else
		{
			state->value = PG_GETARG_DATUM(1);
			state->isnull = false;
		}
	}

	PG_RETURN_POINTER(state);
}

PG_FUNCTION_INFO_V1(first_lax_final);

Datum
first_lax_final(PG_FUNCTION_ARGS)
{
	AggState *state;

	if (PG_ARGISNULL(0))
		PG_RETURN_NULL();

	state = (AggState *) PG_GETARG_POINTER(0);

	if (state->isnull)
		PG_RETURN_NULL();
	else
		PG_RETURN_DATUM(state->value);
}
