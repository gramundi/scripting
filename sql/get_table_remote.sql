set search_path to develop;

DROP TABLE IF EXISTS enviroments;

CREATE TABLE enviroments(
name text,
parameters text[]
)

INSERT INTO enviroments
VALUES ('development',
'{"baboon","5433","wctdba","password"}'
);

INSERT INTO enviroments
VALUES ('test',
'{"uatserver","5433","wctdba","pEeiMI2Q"}'
);


DROP FUNCTION develop.set_dblink(text,text);

CREATE OR REPLACE FUNCTION develop.set_dblink(link_name text,ConnStr text)
RETURNS TEXT AS $$
DECLARE
        SqlStr  text;
BEGIN
	
	SqlStr:='select * from public.dblink_connect('||quote_literal(link_name)||','||quote_literal(ConnStr)||')';
	BEGIN
	      EXECUTE sqlStr;
	      EXCEPTION
          --Exception name from postgres error code documentantion
          WHEN DUPLICATE_OBJECT THEN 
            --disconnect and recconect 
            SqlStr:='select public.dblink_disconnect('||quote_literal(link_name)||')';
            EXECUTE sqlStr;
            SqlStr:='select * from public.dblink_connect('||quote_literal(link_name)||','||quote_literal(ConnStr)||')';
            EXECUTE sqlStr;
          WHEN others THEN 
                raise notice 'sql= %',SqlStr;
		raise notice 'The transaction is in an uncommittable state. ';
		raise notice '% %', SQLERRM, SQLSTATE;
		EXIT;
	END;
        RETURN link_name;
END;
$$ LANGUAGE plpgsql;


DROP FUNCTION IF EXISTS develop.get_table(text,text,text,text,TEXT);
#####
#### Copy data and eventually the structure of a remote table
####
CREATE OR REPLACE FUNCTION develop.get_table(enviroment text,conn_name TEXT, db text,rem_schema text,table_name text)
RETURNS VOID AS $$
DECLARE
SqlStr text;
ConnStr text;
linkname text;
params text[];
col_def_str TEXT:='';
colmun_defs RECORD;

BEGIN
	--Grab the parameters connection from enviroment table 
	SqlStr:='select parameters from enviroments where name ='||quote_literal(enviroment);
	EXECUTE SqlStr INTO params; 
	IF params is NULL 
	THEN 
		RAISE NOTICE 'Impossible to catch parameter for the enviormen %',enviroment;
	ELSE

		ConnStr:='host='||params[1]||' dbname='||db||' user='||params[3]||' port='||params[2]||' password='||params[4];
                RAISE NOTICE 'connstr %',ConnStr;
		SqlStr:='select set_dblink('||quote_literal(conn_name)||','||quote_literal(ConnStr)||')';
                RAISE NOTICE '%',SqlStr;
		EXECUTE sqlStr INTO linkname;
        
        SqlStr:='DROP table IF EXISTS temptable ';
        
        EXECUTE sqlStr;
        
        SqlStr:='select * from develop.columns_tables('||quote_literal(linkname)||') where table_name='||quote_literal(table_name)||'
        AND table_schema='||quote_literal(rem_schema);
        
        FOR colmun_defs IN EXECUTE SqlStr
        LOOP
            RAISE NOTICE '%',colmun_defs.column_name;
            --col_def_str:=col_def_str||colmun_defs.column_name||' '||colmun_defs.data_type||', '; 
            col_def_str:=col_def_str||colmun_defs.column_name||' TEXT, '; 
        END LOOP;
        
        col_def_str:=substr(col_def_str,1,length(col_def_str)-2);
        
        
        RAISE NOTICE '%', col_def_str;

        SqlStr:=' create table temptable as select * from public.dblink('||quote_literal(linkname)||','||
                         quote_literal('select * from '||rem_schema||'.'||table_name)||'
                        ,true) as rec('||col_def_str||')';
         
		RAISE NOTICE 'sqlquery %',SqlStr;
        EXECUTE sqlStr;
        END IF;
END;
$$ LANGUAGE plpgsql;


DROP FUNCTION develop.columns_tables(TEXT);
create or replace function develop.columns_tables(conn_name TEXT)
returns table (table_schema TEXT,table_name TEXT,column_name text, data_type text)
language plpgsql
as $$
begin
    return query select * from public.dblink (conn_name, 
        'select table_schema,table_name,column_name,data_type from information_schema.columns')
    as tables (table_schema TEXT,table_name TEXT,column_name text, data_type text);
end $$;
select * from develop.columns_tables('ldo')
where table_name='country'
AND table_schema='public'


create or replace function develop.datatable()
returns TABLE 
language plpgsql
as $$
begin
    return query select * from public.dblink ('ldo', 
        'select * from country')
    as TABLE;
end $$;


select *
from develop.dblink_tables()
where table_schema = 'public'
order by 1


set search_path to develop;

select get_table('uatserver','ldo','answrs','umgr','users');


select * from  temptable

create table temptable as 
select * from public.dblink('ldo','select * from public.country'
                        ,true) as rec(country_id TEXT,country_name TEXT,  country_code_2 TEXT, country_code_3 TEXT)


select * from public.country