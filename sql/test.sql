CREATE OR REPLACE FUNCTION transfer.fn_uo_site(source_name TEXT,schemaname TEXT)
  RETURNS integer AS
$BODY$

DECLARE
	rtnVal 	integer := 0;
	sqlSearchPath TEXT :='';
    sqlStr TEXT:= '';
	escStr TEXt :=''; 
BEGIN

    sqlSearchPath:='SET SEARCH_PATH TO transfer,'||schemaname;
    
    EXECUTE sqlSearchPath;

    -- TODO -- abstract the SQL statements below into config tables and a common function based on type
	
   escStr:='E\'{"site_number":"\' || site_id ||\'","number":"\' || site_name||\'","name":"\' || 
              coalesce("Short",\'\') ||\'","address_line_1":"\' || coalesce("Addr1",\'\')|| \'","address_line_2":"\' || 
              coalesce("Addr2",\'\')||\'","address_line_3":"\' || coalesce("Addr3",\'\')|| \'","city":"\' || 
              coalesce("City",\'\')|| \'","state":"\' || coalesce("State",\'\')||\'","country":"\' || 
              coalesce("Country",\'\')||\'","postal_code":"\' || coalesce("Pcode",\'\')||\'"}\'';

   sqlStr :='SELECT
            (SELECT source_id from source where sourcename = '||quote_literal('Bioclinica')||') AS source_id,
            (SELECT dotype_id FROM dotype  WHERE typename = ' ||quote_literal('site')||') AS dotype_id ,
            site_id as answrsid,
            (SELECT study_id FROM umgr.study  WHERE study_name ='||quote_literal(schemaname) || ') AS study_id ,'||
            quote_literal(schemaname)|| 'as schemaname,'||escStr||' as jsondata 
            FROM site join "site_SA" USING (site_id) LEFT JOIN "site_S2" USING( site_id) WHERE "LT"='||quote_literal('Main')||'';

        --sqlStr:='SELECT study_id FROM umgr.study  WHERE study_name ='||quote_literal(schemaname); 

	RAISE NOTICE '%', sqlStr;
	
	RETURN rtnVal;
END
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER
  COST 100;
ALTER FUNCTION devbelviq.fn_uo_site()
  OWNER TO wctdba;


select  transfer.fn_uo_site('Bioclinica','devbelviq')
