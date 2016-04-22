\set ON_ERROR_ROLLBACK on
\t
\o d_cons.sql
--Drop constraints 
SELECT 'ALTER TABLE '||nspname||'.'||relname||' DROP CONSTRAINT '||conname||' CASCADE;'
FROM pg_constraint 
INNER JOIN pg_class ON conrelid=pg_class.oid 
INNER JOIN pg_namespace ON pg_namespace.oid=pg_class.relnamespace
WHERE  nspname='mytest'
ORDER BY CASE WHEN contype='f' THEN 0 ELSE 1 END,contype,nspname,relname,conname;

\o

\o r_cons.sql
SELECT 'ALTER TABLE '||nspname||'.'||relname||' ADD CONSTRAINT '||conname||' '|| pg_get_constraintdef(pg_constraint.oid)||';'
FROM pg_constraint
INNER JOIN pg_class ON conrelid=pg_class.oid
INNER JOIN pg_namespace ON pg_namespace.oid=pg_class.relnamespace
WHERE  nspname='mytest'
ORDER BY CASE WHEN contype='f' THEN 0 ELSE 1 END DESC,contype DESC,nspname DESC,relname DESC,conname DESC;

\o

\echo 'Drop constraint in the schema'
\set cs 'd_cons.sql'
\i :cs
\echo 'script done'

--Do what ever you want 
SELECT 'PROCESSING';
SELECT 'PROCESSING';
SELECT 'PROCESSING';

\echo 'Rebuild the constraints'
\set cs 'r_cons.sql'
\i :cs
\echo 'script done'
