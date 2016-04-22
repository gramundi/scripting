DROP   SCHEMA IF EXISTS transfer CASCADE;
DROP   ROLE   IF EXISTS transfer;
 
CREATE SCHEMA transfer;

CREATE ROLE transfer;

grant usage ON SCHEMA transfer TO transfer;

GRANT CREATE ON SCHEMA transfer TO transfer;


--Cretate the object inside the transfer schema
--With this with don't need suffix with the schema name

SET SEARCH_PATH to transfer;

CREATE SEQUENCE track_id_seq        START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE dataset_id_seq      START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE dotype_id_seq       START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE dataobject_id_seq   START WITH 1 INCREMENT BY 1;
CREATE SEQUENCE source_id_seq       START WITH 1 INCREMENT BY 1;


CREATE TABLE source
(
  source_id  integer NOT NULL DEFAULT nextval('source_id_seq'::regclass), -- unique id for transfer task
  sourcename  TEXT NOT NULL,
  description TEXT DEFAULT NULL,
  url         TEXT DEFAULT NULL,
  entered     DATE DEFAULT NOW(),
  modified date,
  CONSTRAINT source_id_pkey PRIMARY KEY (source_id)
);


CREATE TABLE track
(
  track_id   integer NOT NULL DEFAULT nextval('transfer.track_id_seq'::regclass), -- unique id for transfer task
  source_id  INTEGER,
  state      TEXT NOT NULL DEFAULT 'CREATED',
  atime      timestamp, --Time when the data transfer has been created,
  etime      timestamp,--Time whe we finish to transfer,
  CONSTRAINT track_id_pkey PRIMARY KEY (track_id),
  CONSTRAINT source_id_fkey FOREIGN KEY (source_id)
      REFERENCES transfer.source(source_id)
  
);
COMMENT ON TABLE track
  IS 'This table store the data transfer for external systems';
COMMENT ON COLUMN transfer.track.source_id IS 'the external system to integrate';


CREATE TABLE datasets
(
  dataset_id integer NOT NULL DEFAULT nextval('transfer.dataset_id_seq'::regclass), -- unique id for transfer task
  track_id   integer NOT NULL,
  tratype    TEXT,
  extstudy   TEXT,
  intstudy   TEXT,
  study_id  integer NOT NULL,
  CONSTRAINT dataset_id_pkey PRIMARY KEY (dataset_id),
  CONSTRAINT track_id_fkey FOREIGN KEY (track_id)
      REFERENCES transfer.track(track_id),
  CONSTRAINT study_id_fkey FOREIGN KEY (study_id)
      REFERENCES umgr.study(study_id)
);
COMMENT ON TABLE datasets
  IS 'This table store dataset associated to a transfer';

CREATE TABLE dotype
(
  dotype_id integer NOT NULL DEFAULT nextval('transfer.dotype_id_seq'::regclass), -- unique id for transfer task
  typename   TEXT,
  CONSTRAINT dotype_id_pkey PRIMARY KEY (dotype_id)
  
);

CREATE TABLE dataobjects
(
  dataobject_id  integer NOT NULL DEFAULT nextval('dataobject_id_seq'::regclass), -- unique id for transfer task
  source_id      INTEGER NOT NULL,--This id to link with the external system 
  dataset_id     INTEGER, 
  dotype_id      integer NOT NULL,
  ouid           TEXT    DEFAULT '',-- This id come from the external system and is used to map the object
  answrsid       INTEGER NOT NULL,--This is the id cominf from the answrs system
  study_id       INTEGER NOT NULL,--The study where we fetch the dataobject
  schemaname     TEXt,    --The schema name associated to the study
  ctime          DATE DEFAULT NOW(),   --the date when the row has been created
  utime          date DEFAULT NULL,   --The date of the last update
  jsonfk         TEXT NULL, --the foreign key value for the object in format json 
  jsondata       TEXT NOT NULL,-- the data for the object in json format {"field1":"value1","field2":"value2"}

  CONSTRAINT dataobject_id_pkey PRIMARY KEY (dataobject_id),
  CONSTRAINT dotype_id_fkey FOREIGN KEY (dotype_id)
      REFERENCES dotype(dotype_id),
  CONSTRAINT study_id_fkey FOREIGN KEY (study_id)
      REFERENCES umgr.study(study_id)

);

COMMENT ON TABLE dataobjects
  IS 'This table store dataobject within a dataset it si a store for all the object that we are pushing to the other system';

insert into source(sourcename,description,url) values('Bioclinica','OnPoint Bioclinica CTMS','https://wct-clinbus-dev.portal.bioclinica.com');

--Insert data objects types
insert into dotype(typename) VALUES('sites');
insert into dotype(typename) VALUES('subjects');
insert into dotype(typename) VALUES('subjects visits');




SET SEARCH_PATH to transfer;

DROP SEQUENCE transfer.mapecosscreen_id_seq CASCADE;

CREATE SEQUENCE mapecosscreen_id_seq START WITH 1 INCREMENT BY 1;

--To map structure for differn eCOS Study
CREATE TABLE mapecosecreen
(
  mapecosscreen_id  integer NOT NULL DEFAULT nextval('mapecosscreen_id_seq'::regclass), 
  studyname      TEXT,
  itemname       TEXT,
  screen         TEXT,
  field          TEXT,
CONSTRAINT mapecosscreen_id_pkey PRIMARY KEY (mapecosscreen_id)
);

INSERT INTO transfer.mapecosscreen (mapecosscreen_id,studyname,itemname,screen,field) VALUES(2,'myedc4461','InformedConsentDate','"site_DM"','sa."DMICDT"');

select nextval('mapecosscreen_id_seq')


create OR REPLACE view transfer.last_transferdetails as 
SELECT 
  source.sourcename, 
  datasets.track_id,
  track.state, 
  track.atime as startuptime,
  track.etime AS endtime,  
  datasets.tratype, 
  CASE  WHEN  datasets.tratype   =  'upload' THEN intstudy||'-->'||extstudy 
        ELSE  extstudy||'-->'||intstudy  END  AS "Transfer details",
  datasets.dataset_id,
  dataobjects.dataobject_id,
  dotype.typename,
  dataobjects.jsondata
FROM 
  transfer.datasets, 
  transfer.source, 
  transfer.track,
  transfer.dataobjects,
  transfer.dotype
WHERE 
  datasets.track_id = track.track_id     AND
  track.source_id = source.source_id     AND
  dataobjects.dataset_id=datasets.dataset_id AND
  dataobjects.dotype_id=dotype.dotype_id 
ORDER by 1,2,3,3,5,6,7,8,9,10;
COMMENT ON VIEW transfer.last_transferdetails IS 'this view is a detail of the last transfer';


CREATE VIEW OR REPLACE view transfer.transferedobjects as 
SELECT so.sourcename, 
       tr.state, 
       ds.tratype,
       CASE
            WHEN ds.tratype = 'upload'::text THEN (ds.intstudy || '-->'::text) || ds.extstudy
            ELSE (ds.extstudy || '-->'::text) || ds.intstudy
       END AS "Transfer details",
   dot.typename, dao.jsondata
   FROM 
   transfer.source   so
   INNER JOIN transfer.track    tr     USING (source_id)
   INNER JOIN transfer.datasets ds     USING (track_id)
   INNER JOIN transfer.dataobjects dao  using (dataset_id)
   INNER JOIN transfer.dotype   dot    USINg (dotype_id)
WHERE ds.track_id = tr.track_id 
  AND tr.source_id = so.source_id 
  AND dao.dataset_id = ds.dataset_id 
  AND dao.dotype_id = dot.dotype_id
  AND dao.ouid !=''
ORDER BY ds.tratype,dot.typename
COMMENT ON VIEW transfer.last_transferdetails IS 'this view is a detail of all the dataobjects transfered';

CREATE VIEW OR REPLACE view transfer.objectsnottransfered as 
SELECT so.sourcename, 
       tr.state, 
       ds.tratype,
       CASE
            WHEN ds.tratype = 'upload'::text THEN (ds.intstudy || '-->'::text) || ds.extstudy
            ELSE (ds.extstudy || '-->'::text) || ds.intstudy
       END AS "Transfer details",
   dot.typename, dao.jsondata
   FROM 
   transfer.source   so
   INNER JOIN transfer.track    tr     USING (source_id)
   INNER JOIN transfer.datasets ds     USING (track_id)
   INNER JOIN transfer.dataobjects dao  using (dataset_id)
   INNER JOIN transfer.dotype   dot    USINg (dotype_id)
WHERE ds.track_id = tr.track_id 
  AND tr.source_id = so.source_id 
  AND dao.dataset_id = ds.dataset_id 
  AND dao.dotype_id = dot.dotype_id
  AND dao.ouid =''
ORDER BY ds.tratype,dot.typename
COMMENT ON VIEW transfer.last_transferdetails IS 'this view is a detail of all the dataobjects transfered';


CREATE TYPE transfer.ecosstruct AS (screen TEXT,field text);

create Or REPLACe FUNCTIOn transfer.fn_getecosstructure(study TEXT,item TEXT) RETURNS SETOF
ecosstruct as
$$
SELECT screen,field FROM "mapecosscreen" WHERE studyname=$1
AND itemname=$2;
$$ LANGUAGE sql;




--This routine is in charge to fetch the data object from the ANSWRS study data database and refresh 
--the transfer dataobject table.
--The fuction build up a dinamic query to pull data from the right screen and fields. 
--Since the screen and fileds depend upon the ecos study configuration the function use a call to 
--to get the right configuration and build up the right dinamic query.
--At the moment this is implemented by using screenField and screen varaiables.
--When we got a full example fo the data we can wrute down a simple routine to fetch those automatically; 
CREATE OR REPLACE FUNCTION transfer.fn_refreshdataobj(source_name TEXT,schemaname TEXT,dotype TEXT)
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
    screenField TEXT:='sa."DMICDT"';
    screen TEXT:='"site_DM"';
    map_r ecosstruct;
    
    BEGIN

    insFixStr:= 'insert into dataobjects (source_id,dotype_id,answrsid,study_id,schemaname,jsondata) VALUES ';
	delFixStr:= 'delete from dataobjects where dotype_id = (select dotype_id from dataobject where typename = ' || quote_literal(dotype) || ')';
	updFixStr:= 'update dataobjects set jsondata = ';

    sqlSearchPath:='SET SEARCH_PATH TO transfer,'||schemaname;
    
    EXECUTE sqlSearchPath;

    --Get the structure dinamically depends on the eCOS study

   SqlStr:='SELECT * FROM  fn_getecosstructure('||quote_literal(schemaname)||','
                                                ||quote_literal('InformedConsentDate')||')';
   
   EXECUTE  SqlStr into map_r;
   
   --RAISE NOTICE 'map screen % map field % screen'map_r.screen,map_r.field;  
   
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
            escStr:='E\'{"site_id":"\' || subjectlist.site_id ||\'","sitenum":"\' ||subjectlist.sitenum||\'","subnum":"\'||subnum||\'","InformedConsentDate":"\'||screenfield||\'"}\'';
            sqlStr :='SELECT
            (SELECT source_id from source where sourcename = '||quote_literal(source_name)||') AS source_id,
            (SELECT dotype_id FROM dotype  WHERE typename = ' ||quote_literal(dotype)||') AS dotype_id ,
            subject_id as answrsid,
            (SELECT study_id FROM umgr.study  WHERE study_name ='||quote_literal(schemaname) || ') AS study_id ,'||
            escStr||' as jsondata
            FROM site_data_sitelist as sitelist
            INNER JOIN "subject_data_subjectlist" as subjectlist ON sitelist."siteid" = subjectlist."siteid"
            INNER JOIN  screen as sa ON subjectlist."subnum" = sa."SUBNUM"';
            sqlStr:=replace(sqlStr,'screenfield',map_r.field);
            sqlStr:=replace(sqlStr,'screen',map_r.screen);
            
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
ALTER FUNCTION transfer.fn_refreshdataobj(TEXT,TEXT,TEXT)
  OWNER TO wctdba;

SELECT * from transfer.fn_refreshdataobj('Bioclinica','myedc4461','subjects')

select * from 



