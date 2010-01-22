CREATE OR REPLACE FUNCTION cleat_link_next_key() RETURNS varchar AS $$
  DECLARE
    key varchar := '';
    conflicting_key varchar := '';
  BEGIN
    LOOP
      SELECT base36_encode(nextval('cleat_links_id_seq'::regclass)) INTO key;
      IF cleat_word_is_clean(key) THEN
        SELECT short_url FROM cleat_links WHERE short_url = key INTO conflicting_key;
        IF NOT FOUND THEN
          RETURN key;
        END IF;
      END IF;
    END LOOP;
  END;
$$ LANGUAGE 'plpgsql';