set search_path to "[study]", public;

-- create the view(s)
select * from public.create_smart_view('[study]', 'as_ctry_recruit_report', 'as_ctry_recruit_report');          -- Recruitment by Country
select * from public.create_smart_view('[study]', 'as_site_recruit_report', 'as_site_recruit_report');          -- Recruitment by Site

-- RECRUITMENT BY COUNTRY

-- delete from relevant tables
DELETE FROM report_category WHERE report_id = (SELECT report_id FROM report WHERE report_view_name = 'as_ctry_recruit_report');
DELETE FROM report_favourite WHERE report_id = (SELECT report_id FROM report WHERE report_view_name = 'as_ctry_recruit_report');
DELETE FROM report_column WHERE report_id = (SELECT report_id FROM report WHERE report_view_name = 'as_ctry_recruit_report');
DELETE FROM report WHERE report_view_name = 'as_ctry_recruit_report';

-- insert report on portal
INSERT INTO report (report_view_name, report_name, report_long_name, report_description, report_class, report_type_id, report_group_by_first, outputs) VALUES ('as_ctry_recruit_report', 'as_ctry_recruit_report', 'Recruitment by Country', 'A summary of recruitment details per country', 'bIsTabular', '1', 'f', '{json,xls,csv,print}');
INSERT INTO report_category (report_id, category_id) VALUES ( (SELECT report_id FROM report WHERE report_view_name = 'as_ctry_recruit_report'), (SELECT category_id FROM category WHERE category_name = 'Study Management'));

-- grant user permisions
GRANT SELECT ON as_ctry_recruit_report TO "[study]_ro";

-- RECRUITMENT BY SITE

-- delete from relevant tables
DELETE FROM report_category WHERE report_id = (SELECT report_id FROM report WHERE report_view_name = 'as_site_recruit_report');
DELETE FROM report_favourite WHERE report_id = (SELECT report_id FROM report WHERE report_view_name = 'as_site_recruit_report');
DELETE FROM report_column WHERE report_id = (SELECT report_id FROM report WHERE report_view_name = 'as_site_recruit_report');
DELETE FROM report WHERE report_view_name = 'as_site_recruit_report';

-- insert report on portal
INSERT INTO report (report_view_name, report_name, report_long_name, report_description, report_class, report_type_id, report_group_by_first, outputs) VALUES ('as_site_recruit_report', 'as_site_recruit_report', 'Recruitment by Site', 'A summary of recruitment details per site', 'bIsTabular', '1', 't', '{json,xls,csv,print}');
INSERT INTO report_category (report_id, category_id) VALUES ( (SELECT report_id FROM report WHERE report_view_name = 'as_site_recruit_report'), (SELECT category_id FROM category WHERE category_name = 'Study Management'));

-- grant user permisions
GRANT SELECT ON as_site_recruit_report TO "[study]_ro";
