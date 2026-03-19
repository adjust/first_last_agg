/*
 * No-op upgrade from 0.1.5 to 0.1.6.
 *
 * Version 0.1.6 introduces no changes to SQL object definitions.
 *
 * History of this upgrade path:
 * - 0.1.4 defined the aggregates without parallel support.
 * - 0.1.5 added PARALLEL SAFE + COMBINEFUNC, requiring PostgreSQL 12+.
 * - 0.1.6 was originally intended to provide a PostgreSQL 10-safe direct:
 *   - migration path from 0.1.4 via DROP + CREATE with a dependency check
 *   - that approach has been superseded: 0.1.5+ now simply requires PG 12+
 *     and uses CREATE OR REPLACE AGGREGATE
 *   - the SQL object definitions in 0.1.5 and 0.1.6 are therefore identical
 *
 * Databases already at 0.1.5 already have the parallel-safe definitions, so
 * nothing needs to be done here.
 */
