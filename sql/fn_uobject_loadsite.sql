CREATE OR REPLACE FUNCTION transfer.fn_uo_site(source_name TEXT,schemaname TEXT,dotype TEXT)
  RETURNS integer AS
$BODY$

DECLARE
	rtnVal 	integer := 0;
	rdata 	record;
	rdata2 	record;
	dotype_id	integer;
    sqlSearchPath TEXT :='';
    sqlStr TEXT:= '';
	sqlStrCom TEXT:='';
	
    insFixStr  text ;
	delFixStr  text ;
	updFixStr  text ;
    tmpSql     text ;
    escStr TEXt :=''; 

    BEGIN

    insFixStr:= 'insert into dataobjects (source_id,dotype_id,answrsid,study_id,schemaname,jsondata) VALUES ';
	delFixStr:= 'delete from dataobjects where dotype_id = (select dotype_id from dataobject where typename = ' || quote_literal(dotype) || ')';
	updFixStr:= 'update dataobjects set jsondata = ';

    sqlSearchPath:='SET SEARCH_PATH TO transfer,'||schemaname;
    
    EXECUTE sqlSearchPath;

    -- TODO -- abstract the SQL statements below into config tables and a common function based on type

   --Load the escape expression and 
	
   CASE dotype
     WHEN 'sites' THEN -- Generate datarows for sites
            escStr:='E\'{"site_number":"\' || site_id ||\'","number":"\' || site_name||\'","name":"\' || 
              coalesce("Short",\'\') ||\'","address_line_1":"\' || coalesce("Addr1",\'\')|| \'","address_line_2":"\' || 
              coalesce("Addr2",\'\')||\'","address_line_3":"\' || coalesce("Addr3",\'\')|| \'","city":"\' || 
              coalesce("City",\'\')|| \'","state":"\' || coalesce("State",\'\')||\'","country":"\' || 
              coalesce("Country",\'\')||\'","postal_code":"\' || coalesce("Pcode",\'\')||\'"}\'';
            sqlStr :='SELECT
            (SELECT source_id from source where sourcename = '||quote_literal(source_name)||') AS source_id,
            (SELECT dotype_id FROM dotype  WHERE typename = ' ||quote_literal(dotype)||') AS dotype_id ,
            site_id as answrsid,
            (SELECT study_id FROM umgr.study  WHERE study_name ='||quote_literal(schemaname) || ') AS study_id ,'||
            escStr||' as jsondata 
            FROM site join "site_SA" USING (site_id) LEFT JOIN "site_S2" USING( site_id) WHERE "LT"='||quote_literal('Main')||'';
     WHEN 'subjects' THEN --Generates datarows for subjects
            
            escStr:='E\'{"site_id":"\' || subjectlist.site_id ||\'","sitenum":"\' ||subjectlist.sitenum||\'","subnum":"\'||subnum||\'","InformedConsentDate":"\'||dm."DMICDT"||\'"}\'';
            sqlStr :='SELECT
            (SELECT source_id from source where sourcename = '||quote_literal(source_name)||') AS source_id,
            (SELECT dotype_id FROM dotype  WHERE typename = ' ||quote_literal(dotype)||') AS dotype_id ,
            subject_id as answrsid,
            (SELECT study_id FROM umgr.study  WHERE study_name ='||quote_literal(schemaname) || ') AS study_id ,'||
            escStr||'as jsondata
            FROM site_data_sitelist as sitelist
            INNER JOIN "subject_data_subjectlist" as subjectlist ON sitelist."siteid" = subjectlist."siteid"
            INNER JOIN "site_DM" as dm ON subjectlist."subnum" = dm."SUBNUM"';
     ELSE
        RAISE NOTICE 'Object Type %',dotype;
   END CASE;

   
    -- FIXME -- NOT GOING TO DO THIS HERE AS WE WOULD LOSE ANY "user_object_mappings"!!!
	-- clear out the "universal_objects" of this "universal_object_type" first
	-- EXECUTE delStr;

	-- populate the "universal_objects" storing the keys and json to fire
	RAISE NOTICE '%', sqlStr;

    tmpSql := 'select dotype_id from dotype where typename = '|| quote_literal(dotype);
    EXECUTE tmpSql into dotype_id;
    
    if dotype_id is null THEN 
                RAISE NOTICE 'dataobject type % not defined',dotype;
    END IF;

    FOR rdata IN
		EXECUTE sqlStr
	LOOP
		
		IF rdata.answrsid IS NOT NULL AND rdata.jsondata IS NOT NULL AND rdata.dotype_id IS NOT NULL
		THEN
			-- check if an entry in "universal_objects" exists already for this key
			tmpSql := 'select answrsid  from dataobjects where answrsid = '||rdata.answrsid||
                      ' and dotype_id = (select dotype_id from dotype where typename = '  || 
                      quote_literal(dotype) || ')';
			EXECUTE tmpSQL into rdata2;
		
            --Check if we nee to create or update the dataobject
			IF rdata2 IS NOT NULL AND rdata2.answrsid IS NOT NULL
			THEN -- UPDATE
				sqlStrCom:= updFixStr || quote_literal(rdata.jsondata) || ',utime=NOW() where answrsid =  '|| rdata.answrsid;
				RAISE NOTICE '%', sqlStrCom;
				EXECUTE sqlStrCom;
			ELSE -- INSERT
                --(source_id,dotype,answrsid,study_id,schemaname,jsondata)
				sqlStrCom := insFixStr || '('||rdata.source_id||','||rdata.dotype_id||','||rdata.answrsid||','
                          ||rdata.study_id||','||quote_literal(schemaname)||','|| quote_literal(rdata.jsondata)||')';
			    --RAISE NOTICE '%', insStr;
				EXECUTE sqlStrCom;
                
			END IF;			
        END IF;
       
	END LOOP;

	RETURN rtnVal;
END
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER
  COST 100;
ALTER FUNCTION devbelviq.fn_uo_site()
  OWNER TO wctdba;


set search_path to transfer,umgr,devbelviq;

truncate dataobject;


select * from transfer.fn_uo_site('Bioclinica','devbelviq','site');

select * from transfer.fn_uo_site('Bioclinica','myedc4461','subjects');

select * from dataobject;

