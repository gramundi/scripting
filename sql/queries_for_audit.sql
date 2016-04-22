CREATE OR REPLACE FUNCTION develop.fn_trasnfer_audit(study TEXT,dom TEXT,audtype TEXT)
RETURNS VOID AS $$
DECLARE
        sqlStr text;
        dom_id integer=0;
        
BEGIN


sqlStr:='set search_path to '||study;

EXECUTE sqlStr;

CASE audtype WHEN 'lfi' THEN
        --latest  forms arrived for a give domain
        SqlStr:='select 
        df.domain_id,df.form_id,form_name,max(track_timestamp) as timearr
        from '||dom||'_form
        join track_x tr using (x_form_id)
        JOIN domain_form df ON (df.form_id=tr.form_id)
        group by df.domain_id,df.form_id,form_name 
        order by form_name';               
    ELSE 
            SqlStr:='SELECT domain_id from data_domain where domain_name='||quote_literal(dom);
            Execute SqlStr into dom_id;
            --Latest form Arrived for a given domain
            SqlStr:='select form_name,track_timestamp
            from 
            track_x 
            join domain_form df USING(form_id)
            WHERE df.domain_id='||dom_id||' AND track_timestamp=(select max(track_timestamp) from track_x)';

END CASE;

RAISE NOTICE 'Run Query=>%',SqlStr;

END;
$$ LANGUAGE plpgsql;


select develop.fn_trasnfer_audit('devbelviq','subject','lf');

set search_path to devbelviq;

select form_name,track_timestamp
            from 
            track_x 
            join domain_form(form_id)
            WHERE domain_id=2 and track_timestamp=(select max(track_timestamp) from track_x)