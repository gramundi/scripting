CREATE OR REPLACE FUNCTION devbelviq.fn_uo_site()
  RETURNS integer AS
$BODY$
DECLARE
	rtnVal 	integer := 0;
	rdata 	record;
	rdata2 	record;
	uotid	integer;
	-- TODO -- abstract the SQL statements below into config tables and a common function based on type
	sqlStr 	text := E'SELECT site_id as uo_keys,
			\'{"site_number":"\' || site_id ||\'","number":"\' || site_name||\'","name":"\' || coalesce("Short",\'\') ||\'","address_line_1":"\' || coalesce("Addr1",\'\')|| \'","address_line_2":"\' || coalesce("Addr2",\'\')||\'","address_line_3":"\' || coalesce("Addr3",\'\')|| \'","city":"\' || coalesce("City",\'\')|| \'","state":"\' || coalesce("State",\'\')||\'","country":"\' || coalesce("Country",\'\')||\'","postal_code":"\' || coalesce("Pcode",\'\')||\'"}\' AS uo_json, 
			(SELECT "UOTID" FROM universal_object_type WHERE uot_name = \'site\') AS uotid 
			FROM site join "site_SA" USING (site_id) LEFT JOIN "site_S2" USING( site_id)
                      inner join uo_track_changes as uotc ON (uotc.identifier=site.site_id)
             WHERE objtype=''site'' AND "LT"=\'Main\'';
	insStr  text := 'insert into universal_object (uo_keys, uo_json, "UOTID") VALUES ';
	delStr 	text := 'delete from universal_object where "UOTID" = (select "UOTID" from universal_object_type where uot_name = ' || quote_literal('site') || ')';
	updStr  text := 'update universal_object set uo_json = ';
	tmpSql  text := '';
BEGIN

	-- FIXME -- NOT GOING TO DO THIS HERE AS WE WOULD LOSE ANY "user_object_mappings"!!!
	-- clear out the "universal_objects" of this "universal_object_type" first
	-- EXECUTE delStr;

	-- populate the "universal_objects" storing the keys and json to fire
	RAISE NOTICE '%', sqlStr;
	FOR rdata IN
		EXECUTE sqlStr
	LOOP
		insStr := 'insert into universal_object (uo_keys, uo_json, "UOTID") VALUES ';
		updStr := 'update universal_object set uo_json = ';

		IF rdata.uo_keys IS NOT NULL AND rdata.uo_json IS NOT NULL AND rdata.uotid IS NOT NULL
		THEN
			-- check if an entry in "universal_objects" exists already for this key
			tmpSql := 'select "UOID" as uoid from universal_object where uo_keys = ''{' || rdata.uo_keys || '}'' and "UOTID" = (select "UOTID" from universal_object_type where uot_name = ' || quote_literal('site') || ')';
			EXECUTE tmpSQL into rdata2;
		
			IF rdata2 IS NOT NULL AND rdata2.uoid IS NOT NULL
			THEN -- UPDATE
				updStr := updStr || quote_literal(rdata.uo_json) || ' where "UOID" =  '|| rdata2.uoid ;
				RAISE NOTICE '%', updStr;
				EXECUTE updStr;
			ELSE -- INSERT
				insStr := insStr || '(''{' || rdata.uo_keys || '}'',' || quote_literal(rdata.uo_json) || ',' || rdata.uotid || ')';
				RAISE NOTICE '%', insStr;
				EXECUTE insStr;
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


select * from universal_object;

select * from devbelviq.fn_uo_site();


set search_path to devbelviq;


--Query to cacth the istes to upload in medidata
SELECT site_id as uo_keys,
			'{"site_number":"' || site_id ||'","number":"' || site_name||'","name":"' || coalesce("Short",'') ||'","address_line_1":"' || coalesce("Addr1",'')|| '","address_line_2":"' || coalesce("Addr2",'')||'","address_line_3":"' || coalesce("Addr3",'')|| '","city":"' || coalesce("City",'')|| '","state":"' || coalesce("State",'')||'","country":"' || coalesce("Country",'')||'","postal_code":"' || coalesce("Pcode",'')||'"}' AS uo_json, 
			(SELECT "UOTID" FROM universal_object_type WHERE uot_name = 'site') AS uotid 
			FROM site join "site_SA" USING (site_id) LEFT JOIN "site_S2" USING( site_id) WHERE "LT"='Main'


set search_path to devbelviq,umgr;


select * from devbelviq.fn_uo_study();

select * from devbelviq.fn_uo_study_user();



select * from universal_object;

select * from universal_object_update;

SELECT * FROm universal_object_mapping;

SELECT * FROm universal_object_type;


TRUNCATE TABLE universal_object_mapping;

truncate table universal_object;

truncate table universal_object_update;


delete universal_object where 

--What is mapped after running the task
select uo.uo_json,uot.uot_name,uom."UUID"
from 
universal_object as uo
inner JOIn universal_object_mapping as uom using ("UOID")
INNER JOIN universal_object_type AS uot USING ("UOTID")


delete from universal_object where "UOID"!='1893824'


set search_path to devbelviq,umgr;


SELECT  u.user_id as uo_keys, 
			'{"name":"' ||user_first_name|| '.' || user_last_name || 
			'","first_name":"'||user_first_name || '","last_name":"' ||user_last_name || '","email":"'||user_email||'","local":"eng","time_zone":"London"' || ',"title":"'||COALESCE(user_title, '') ||	
			'","telephone":"' ||COALESCE("Tel", '' ) || '","mobile":"'|| COALESCE("Mob", '')|| '","fax":"'|| COALESCE("Fax", '' ) || 
			'","address_line_1":"'||COALESCE("Addr1", '') || '","address_line_2":"'||COALESCE("Addr2", '')||  '","address_line_3":"' ||COALESCE("Addr3", '')||
			'","city":"' || COALESCE("City", '') || '","state":"'||COALESCE("State",'') ||'","country":"'|| COALESCE("Country", '')||'","postal_code":"' ||COALESCE("Pcode", '')|| '"}' as uo_json,
			CASE WHEN  to_date( "To", 'YYYY-MM-DD') < now()  THEN true ELSE false END as is_exists,
			(select "UOTID" from universal_object_type where uot_name = 'study_user') as uotid
			 FROM users u
LEFT JOIN user_map um ON (u.user_id = um.user_id)
LEFT JOIN "site_SC" sc ON (um.nodes_name = sc."User_ID")
LEFT JOIN "site_S1" s1 using (site_id, "Code")
LEFT JOIN "site_S2" s2 on (sc.site_id = s2.site_id and s1."Addr" = s2."Code")
INNER JOIN study s ON (um.study_id = s.study_id)

select user_name,study_name
from user_map as um
INNER JOIN study as s ON (um.study_id = s.study_id)
INNER JOIN users as usr using (user_id)

--Roles Mapping
select 
source_name,ext_role_name,role_name
from 
ext_role_mapping as es
INNER JOIN umgr.role USING(role_id)
INNER JOIN data_source as ds ON ds.source_id=es.data_source_id;


select * from ext_role_name;

-- I think we need to extend the fn_uo_study_user to map the roles and app with Imedidata. Further development for us and for Cake;
set search_path to devbelviq;

select distinct public.fn_decoderole(coalesce("site_S1"."UR",'301'),'devbelviq')
from 
"site_S1"



SELECT site_id as uo_keys,
			'{"site_number":"' || site_id ||'","number":"' || site_name||'","name":"' || coalesce("Short",'') ||'","address_line_1":"' || coalesce("Addr1",'')|| '","address_line_2":"' || coalesce("Addr2",'')||'","address_line_3":"' || coalesce("Addr3",'')|| '","city":"' || coalesce("City",'')|| '","state":"' || coalesce("State",'')||'","country":"' || coalesce("Country",'')||'","postal_code":"' || coalesce("Pcode",'')||'"}' AS uo_json, 
			(SELECT "UOTID" FROM universal_object_type WHERE uot_name = 'site') AS uotid 
			FROM site join "site_SA" USING (site_id) LEFT JOIN "site_S2" USING( site_id)
                      inner join uo_track_changes as uotc ON (uotc.identifier=site.site_id)
             WHERE objtype='site' AND 
             "LT"='Main'




