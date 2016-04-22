set search_path to develop;

DROP TABLE IF EXISTS employees;

CREATE TABLE employees (
   employee_id   NUMERIC       NOT NULL,
   first_name    VARCHAR(1000) NOT NULL,
   last_name     VARCHAR(1000) NOT NULL,
   date_of_birth DATE                   ,
   phone_number  VARCHAR(1000) NOT NULL,
   junk          CHAR(1000),
   CONSTRAINT employees_pk PRIMARY KEY (employee_id)
);


DROP FUNCTION IF EXISTS random_string(integer);

CREATE FUNCTION random_string(len INTEGER)
RETURNS VARCHAR(1000)
AS
$$
DECLARE
  rv VARCHAR(1000) := '';
  i  INTEGER := 0;
BEGIN
  IF len < 1 THEN
    RETURN rv;
  END IF;

  FOR i IN 1..len LOOP
    --chr(97) from a to z alphabet
    rv := rv || chr(97+(random() * 25)::int);
  END LOOP;
  RETURN rv;
END;
$$ LANGUAGE plpgsql;

DROP FUNCTION IF EXISTS generate_employees(integer);

CREATE FUNCTION generate_employees(nr_employee integer)
RETURNS VOID
AS 
$$
DECLARE
SqlStr text;
BEGIN

SqlStr:='INSERT INTO employees (employee_id,  first_name,
                       last_name,    date_of_birth, 
                       phone_number, junk)
SELECT GENERATE_SERIES
     , initcap(lower(random_string(2+(random()*8)::int)))
     , initcap(lower(random_string(2+(random()*8)::int)))
     , CURRENT_DATE - (random() * 365 * 10)::int - 40 * 365
     , (random() * 9000 + 1000)::int
     , '||quote_literal('junk')||'
  FROM GENERATE_SERIES(1, 1000)';

EXECUTE SqlStr;
 
END;
$$ LANGUAGE plpgsql;


explain select generate_employees(10);

analyze employees;

explain select * from employees where employee_id > 30



