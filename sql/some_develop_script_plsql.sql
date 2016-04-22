DROP SCHEMA IF EXISTS develop cascade; 

DROP ROLE IF EXISTS usertest ;

CREATE ROLE usertest;

CREATE SCHEMA develop AUTHORIZATION user_test;

-- Table: develop.mytable

DROP TABLE IF EXISTS develop.mytable;


CREATE TABLE develop.mytable
(
  col1 integer,
  col2 text
)
WITH (
  OIDS=TRUE
);
ALTER TABLE develop.mytable
  OWNER TO wctdba;

DROP FUNCTION IF EXISTS  develop.fn_simple_transaction(integer);

CREATE OR REPLACE FUNCTION develop.fn_simple_transaction(nrloop integer)
RETURNS VOID AS $$
DECLARE
        sqlStr text;
        count integer=0;
BEGIN

LOOP
    -- some computations
    IF count = nrloop THEN
        EXIT;  -- exit loop
    END IF;
   
      sqlStr := 'INSERT INTO mytable(col1, col2)
      VALUES ('||count||','||quote_literal('test')||')';
      
      BEGIN
      EXECUTE sqlStr;
      EXCEPTION WHEN others THEN 
	raise notice 'The transaction is in an uncommittable state. ';
        raise notice '% %', SQLERRM, SQLSTATE;
        EXIT;
      count:=count+1;
      END;                 
END LOOP;
END;
$$ LANGUAGE plpgsql;

set search_path to develop;

select fn_simple_transaction(60000);

 update  mytable set col2='newtestlock';


select * from pg_stat_activity                                                                       
where current_query!='<IDLE>'                                                                                   ;
and wating='t'
 