set search_path to "myedc4461"


       SELECT site_id,subject_id,subnum
       FROM subject_data_subjectlist as su_da
       JOIN site_data_sitelist USING (site_id)
       LEFT JOIN site_design_visitschedules USING(site_id)
       order by site_id,subject_id
       
       
JOIN site_design_visitschedules USING(site_id)
       

select * from site_design_visitschedules