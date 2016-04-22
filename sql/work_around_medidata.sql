set search_path to devbelviq;


CREATE TABLE devbelviq.uo_track_changes
(
  objtype text NOT NULL,
  identifier INTEGER 
  
);

ALTER TABLE devbelviq.uo_track_changes
  OWNER TO wctdba;


CREATE OR REPLACE FUNCTION devbelviq.fn_report_changes()
  RETURNS trigger AS
$BODY$
DECLARE
sqlStr text;
screen TEXT;
is_need_change_recorded boolean:=true;

BEGIN
screen := TG_ARGV[0];
RAISE NOTICE 'screen=%',screen;
IF (screen='site_S2') THEN
        
        --Changes from screen S2 it might either user or sites
        sqlStr:=' SELECT CASE WHEN count(*) = 0 THEN TRUE ELSE false END as change_recorded 
        FROM devbelviq.uo_track_changes where objtype='||quote_literal('site')||
        ' AND identifier='||quote_literal(new.site_id);
        EXECUTE sqlStr INTO is_need_change_recorded;
        
        IF (is_need_change_recorded) THEN 
                sqlStr:='INSERT INTO devbelviq.uo_track_changes(objtype,identifier) 
                 VALUES ('||quote_literal('site')||','||quote_literal(new.site_id)||')';
            
            EXECUTE sqlStr;
        END IF;
        
        --second check
        sqlStr:=' SELECT CASE WHEN count(*) = 0 THEN TRUE ELSE false END as change_recorded 
        FROM devbelviq.uo_track_changes where objtype='||quote_literal('user')||
        ' AND identifier='||quote_literal(new.site_id);
        EXECUTE sqlStr INTO is_need_change_recorded;

        IF (is_need_change_recorded) THEN 
                sqlStr:='INSERT INTO devbelviq.uo_track_changes(objtype,identifier) 
                 VALUES ('||quote_literal('user')||','||quote_literal(new.site_id)||')';
            RAISE NOTICE 'PIPO';
        EXECUTE sqlStr;
        END IF;
ELSE 
        sqlStr:=' SELECT CASE WHEN count(*) = 0 THEN TRUE ELSE false END as change_recorded 
        FROM devbelviq.uo_track_changes where objtype='||quote_literal('user') ||
        ' AND identifier='||quote_literal(new.site_id);
        EXECUTE sqlStr INTO is_need_change_recorded;
        IF (is_need_change_recorded) THEN
            sqlStr:='INSERT INTO devbelviq.uo_track_changes(objtype,identifier) 
                 VALUES ('||quote_literal('user')||','||quote_literal(new.site_id)||')';
            EXECUTE sqlStr;  
        END IF;
END IF;

RETURN NULL;
END
$BODY$
  LANGUAGE plpgsql VOLATILE SECURITY DEFINER
COST 100;


DROP TRIGGER tr_add_update_sites ON devbelviq."site_S1";

CREATE TRIGGER tr_add_update_sites
  AFTER INSERT OR UPDATE
  ON devbelviq."site_S1"
  FOR EACH ROW
EXECUTE PROCEDURE devbelviq.fn_report_changes('site_S1');

DROP TRIGGER tr_add_update_sites ON devbelviq."site_S2"

CREATE TRIGGER tr_add_update_sites
  AFTER INSERT OR UPDATE
  ON devbelviq."site_S2"
  FOR EACH ROW
EXECUTE PROCEDURE devbelviq.fn_report_changes('site_S2');


update "site_S1" set "Tel"='9999999999' where site_id=1 and x_form_id=14;

update "site_S2" set "City"='test' where site_id=2 and x_form_id=127;


select * from devbelviq.uo_track_changes;

truncate table devbelviq.uo_track_changes;


