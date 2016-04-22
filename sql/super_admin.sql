--##Make a User Super Admin for all the Studies
set search_path to umgr;

--Clean Up the acces privileges fro the users
delete from user_role where user_id = (select user_id from users where user_name='giovanni.ramundi');

insert into user_role
(

select
(select user_id from users where user_name = 'giovanni.ramundi' LIMIT 1 ) as user_id,
 study_id,1 as role_id from study WHERE is_active is true and study_name like 'PR%'
);


select user_name,role_name,study_name
 from
users
inner join user_role using (user_id)
INNER JOIN study USING(study_id)
INNER JOIN role using(role_id)
where user_name like 'giovanni.ramundi'


select study_name,
(select user_id from users where user_name = 'giovanni.ramundi' LIMIT 1 ) as user_id,
 study_id,1 as role_id from study 
WHERE is_active is true 
and study_name like 'PR%'