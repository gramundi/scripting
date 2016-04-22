set search_path to myedc4461;
WITH 
subject_visit AS (
select site_id,x_form_id,page_id,"SUBID","SUBNUM","VISITID","STATUSID","VIDT" AS "VISITDATE"
FROM
"site_VI"
union
select site_id,x_form_id,page_id,"SUBID","SUBNUM","VISITID","STATUSID","DMICDT" AS "VISITDATE"
FROM
"site_DM"
),
visittype AS (
select distinct id,name from  site_design_visitschedules
order by id
),
subjectstatus AS (
SELECT DISTINCT statusid,statusname from subject_data_subjectlist
)
SELECT sds.site_id,
       sds.sitenum, 
       sdl.subnum,
       sdl.statusname ,
       (SELECT visittype.name from  visittype where visittype.id='30') as visitname, 
       --Day 1 is for id 30 and it is  for enrollement date
       (select "VISITDATE" from subject_visit WHERE "SUBNUM"=sdl.subnum AND "VISITID"='30'  AND "STATUSID"='25' ) as enrollmendate,
       --Day 15 is for id 80 and it is discontinuation date
       (SELECT visittype.name from  visittype where visittype.id='80') as visitname, 
       (select "VISITDATE" from subject_visit WHERE "SUBNUM"=sdl.subnum AND "VISITID"='80'  AND "STATUSID"='10' )as discontinuationdate,
       --Screening if for 10 and it is screening Date
       (SELECT visittype.name from  visittype where visittype.id='10') as visitname,
       (select "VISITDATE" from subject_visit WHERE "SUBNUM"=sdl.subnum AND "VISITID"='10' AND "STATUSID"='5' )as screendate,
       (select "VISITDATE" from subject_visit WHERE "SUBNUM"=sdl.subnum AND "VISITID"='10' AND "STATUSID"='5' )as InformedConsentSigned
FROM 
subject_data_subjectlist   AS sdl
INNER JOIN  site_data_sitelist         as sds ON sds.site_id=sdl.site_id
--WHERE sdl.statusname='Early Discontinued' OR sdl.statusname='Enrolled' 
order by 1,2,3



WITH subvisit AS (
select site_id,x_form_id,page_id,"SUBID","SUBNUM","VISITID","STATUSID","DMICDT"
from 
"site_DM"
UNION
select site_id,x_form_id,page_id,"SUBID","SUBNUM","VISITID","STATUSID","VIDT" 
from 
"site_VI")
select sbv.*
from subvisit as sbv
INNER JOIN site_design_visitschedules as sds ON sbv."VISITID" = sds.id 
INNER JOIN site_data_sitelist as d  ON d.site_id=sbv.site_id
ORDER BY "SUBNUM"

select * from site_design_visitschedules;



select site_id,x_form_id,page_id,"SUBID","SUBNUM","VISITID",count(*) 
from 
"site_DM"
group by 1,2,3,4,5,6
HAVING count(*) > 1
order by "SUBNUM"

