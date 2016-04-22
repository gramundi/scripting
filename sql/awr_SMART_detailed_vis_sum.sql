set search_path to "[study]", public;

-- create the view(s)
select * from public.create_smart_view('[study]', 'as_detailed_vis_sum_report', 'as_detailed_vis_sum_report');        -- subject details report

-- delete from relevant tables
DELETE FROM report_category WHERE report_id = (SELECT report_id FROM report WHERE report_view_name = 'as_detailed_vis_sum_report');
DELETE FROM report_favourite WHERE report_id = (SELECT report_id FROM report WHERE report_view_name = 'as_detailed_vis_sum_report');
DELETE FROM report_column WHERE report_id = (SELECT report_id FROM report WHERE report_view_name = 'as_detailed_vis_sum_report');
DELETE FROM report WHERE report_view_name = 'as_detailed_vis_sum_report';

-- insert report on portal
INSERT INTO report (report_view_name, report_name, report_long_name, report_description, report_class, report_type_id, report_group_by_first, outputs) VALUES ('as_detailed_vis_sum_report', 'as_detailed_vis_sum_report', 'Detailed Visit Summary', 'A summary of subject visit dates and the IMP dispensed at that visit', 'bIsTabular', '1', 't', '{json,xls,csv,print}');
INSERT INTO report_category (report_id, category_id) VALUES ( (SELECT report_id FROM report WHERE report_view_name = 'as_detailed_vis_sum_report'), (SELECT category_id FROM category WHERE category_name = 'Subject Management'));

-- grant user permisions
GRANT SELECT ON as_detailed_vis_sum_report TO "[study]_ro";
