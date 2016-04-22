set search_path to "[study]", public;

-- create the view(s)
select * from public.create_smart_view('[study]', 'as_wh_inv_report', 'as_wh_inv_report');        -- Unblinded Drug Inventory: Warehouse

-- delete from relevant tables
DELETE FROM report_category WHERE report_id = (SELECT report_id FROM report WHERE report_view_name = 'as_wh_inv_report');
DELETE FROM report_favourite WHERE report_id = (SELECT report_id FROM report WHERE report_view_name = 'as_wh_inv_report');
DELETE FROM report_column WHERE report_id = (SELECT report_id FROM report WHERE report_view_name = 'as_wh_inv_report');
DELETE FROM report WHERE report_view_name = 'as_wh_inv_report';

-- insert report on portal
INSERT INTO report (report_view_name, report_name, report_long_name, report_description, report_class, report_type_id, report_group_by_first, outputs) VALUES ('as_wh_inv_report', 'as_wh_inv_report', 'Unblinded Drug Inventory: Warehouse', 'A summary of drug at warehouse', 'bIsTabular', '1', 't', '{json,xls,csv,print}');
INSERT INTO report_category (report_id, category_id) VALUES ( (SELECT report_id FROM report WHERE report_view_name = 'as_wh_inv_report'), (SELECT category_id FROM category WHERE category_name = 'Unblinded Drug Management'));

-- grant user permisions
GRANT SELECT ON as_wh_inv_report TO "[study]_ro";
