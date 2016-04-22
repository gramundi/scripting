set search_path to umgr;

select user_name,role_name,study_name 
from users 
inner join user_role using (user_id) 
inner join role using (role_id) 
inner join study using (STUDY_id)
WHERE USER_NAME LIKE 'gio%'
ORDER BY 1,2,3 


set search_path to umgr;


delete FROM user_role where user_id=(SELECT user_id from users where user_name='giovanni.ramundi');


insert into user_role
(
select
( select user_id from users where user_name = 'giovanni.ramundi' LIMIT 1 ) as user_id,
study_id,
1 as role_id from study
WHERE STUDY_name in ('devdeclare','devbelviq')
AND is_active is true
);


insert into user_role
(
select
( select user_id from users where user_name = 'christopher.mogg' LIMIT 1 ) as user_id,
study_id,
2 as role_id from study
WHERE STUDY_name in ('devbelviq')
AND is_active is true
);

insert into user_role
(
select
( select user_id from users where user_name = 'christopher.mogg' LIMIT 1 ) as user_id,
study_id,
1 as role_id from study
WHERE STUDY_name in ('devbelviq')
AND is_active is true
);

set search_path to devbelviq,umgr,public;

--Which study have I got
select user_name,role_name,study_name
from
users 
inner join user_role using (user_id)
INNER JOIN study USING(study_id)
INNER JOIN role using(role_id)
INNER JOIN study_role USING (role_id)
where user_name like 'christopher.mogg'
AND study_name='devbelviq'

select user_id from users where user_name='timothy.morgan'
