set search_path to "[study]", public;
	
-- create the views
select * from public.create_smart_view('[study]', 'as_subject_details_report', 'as_subject_details_report');

DELETE FROM report_category WHERE report_id = (SELECT report_id FROM report WHERE report_view_name = 'as_subject_details_report');
DELETE FROM report_favourite WHERE report_id = (SELECT report_id FROM report WHERE report_view_name = 'as_subject_details_report');
DELETE FROM report_column WHERE report_id = (SELECT report_id FROM report WHERE report_view_name = 'as_subject_details_report');
DELETE FROM report WHERE report_view_name = 'as_subject_details_report';
	
-- insert report on portal
INSERT INTO report (report_view_name, report_name, report_long_name, report_description, report_class, report_type_id, report_group_by_first, outputs) VALUES ('as_subject_details_report', 'as_subject_details_report', 'Subject Summary', 'A summary of subjects at site', 'bIsTabular', '1', 't', '{json,xls,csv,print}');
INSERT INTO report_category (report_id, category_id) VALUES ( (SELECT report_id FROM report WHERE report_view_name = 'as_subject_details_report'), (SELECT category_id FROM category WHERE category_name = 'Subject Management'));
-- grant user permisions
GRANT SELECT ON as_subject_details_report TO "[study]_ro";
