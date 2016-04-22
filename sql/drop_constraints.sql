\set ON_ERROR_ROLLBACK on
\t
\o d_cons.sql
 

SELECT 'ALTER TABLE '||nspname||'.'||relname||' DROP CONSTRAINT '||conname||'CASCADE;'
FROM pg_constraint 
INNER JOIN pg_class ON conrelid=pg_class.oid 
INNER JOIN pg_namespace ON pg_namespace.oid=pg_class.relnamespace
WHERE  nspname='[study]'
ORDER BY CASE WHEN contype='f' THEN 0 ELSE 1 END,contype,nspname,relname,conname;

\echo 'calling the script generated from the select'
\set sc 'd_cons.sql'
\i :sc
\echo 'script done'
