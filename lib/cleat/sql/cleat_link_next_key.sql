CREATE OR REPLACE FUNCTION cleat_link_next_key() RETURNS varchar AS $$
  DECLARE
    key varchar := '';
  BEGIN
    LOOP
      SELECT base36_encode(nextval('cleat_links_id_seq'::regclass)) INTO key;
      IF is_clean(key) THEN
        RETURN key;
      END IF;
    END LOOP;
  END;
$$ LANGUAGE 'plpgsql';