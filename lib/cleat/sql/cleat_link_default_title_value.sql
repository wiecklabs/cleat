CREATE OR REPLACE FUNCTION cleat_link_default_title_value() RETURNS TRIGGER AS $$
  BEGIN
    IF NEW.title = '' OR NEW.title is null THEN
      UPDATE cleat_links SET title = NEW.start_date::date || ':' || NEW.short_url WHERE short_url = NEW.short_url;
    END IF;
    RETURN NEW;
  END;
$$ LANGUAGE 'plpgsql';

CREATE TRIGGER cleat_link_default_title AFTER INSERT ON cleat_links FOR EACH ROW
EXECUTE PROCEDURE cleat_link_default_title_value();