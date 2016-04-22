set search_path to myedc4461;


select *
from subject
INNER JOIN site USING(site_id)





select * 

from "site_VI"

INNER JOIN site_design_visitschedules



SELECT * 
FROM subject_data_subjectlist
JOIN site_data_sitelist USING (site_id)
JOIN "site_VI" ON subject_data_subjectlist.subid = "site_VI"."SUBID"
JOIN site_design_visitschedules ON "site_VI"."VISITID" = site_design_visitschedules.id


select * from site_design_visitschedules
where lower(name) like '%enr%'


SELECT DISTINCT ( SELECT study.study_long_name
                   FROM umgr.study
                  WHERE study.study_name::text = 'myedc4461'::text) AS "STUDYOID", to_char(site_data_sitelist.sitenum::integer, '000'::text) AS "SITEOID", to_char(subject_data_subjectlist.subnum::integer, '000000'::text) AS "SUBJECTOID", ''::text AS "RANDOMID", ''::text AS "RANDOMIZEDDATE", ''::text AS "INFORMEDCONSENTDATE", 
                CASE
                    WHEN subject_data_subjectlist.statusname = ((( SELECT config.config_value
                       FROM myedc4461.config
                      WHERE config.config_name::text = 'screenfail'::text))::text) THEN '1'::text
                    ELSE '0'::text
                END AS "SCREENFAIL", 
                CASE
                    WHEN subject_data_subjectlist.statusname = ((( SELECT config.config_value
                       FROM myedc4461.config
                      WHERE config.config_name::text = 'discontinued'::text))::text) THEN '1'::text
                    ELSE '0'::text
                END AS "DISCONTINUED", 
                CASE
                    WHEN "site_DM"."VISITID" = '10'::text THEN 1
                    ELSE "site_DM"."VISITID"::integer
                END AS "VISITOID", site_design_visitschedules.name AS "VISITNAME", "site_DM"."DMSCDT" AS "VISITDATE", subject_data_subjectlist.statusname AS "SUBJECT STATUS"
           FROM myedc4461.subject_data_subjectlist
      JOIN myedc4461.site_data_sitelist USING (site_id)
   JOIN myedc4461."site_DM" ON subject_data_subjectlist.subid = "site_DM"."SUBID"
   JOIN myedc4461.site_design_visitschedules ON "site_DM"."VISITID" = site_design_visitschedules.id
  ORDER BY 2, 3, 9;