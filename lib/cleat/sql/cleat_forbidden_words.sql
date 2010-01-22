drop table if exists cleat_forbidden_words;
create table cleat_forbidden_words (word varchar primary key not null);
  
CREATE OR REPLACE FUNCTION cleat_word_is_clean(potentially_dirty_word varchar) RETURNS boolean AS $$
  BEGIN
    PERFORM 1 FROM cleat_forbidden_words WHERE
      position("word" in translate(potentially_dirty_word, '4310875', 'aeiobts')) > 0 OR
      position("word" in replace(translate(potentially_dirty_word, '4310875', 'aeiobts'), 'x', 'cks')) > 0;

    IF FOUND THEN
      RETURN false;
    ELSE
      RETURN true;
    END IF;

  END;
$$ LANGUAGE 'plpgsql';

INSERT INTO "cleat_forbidden_words" (word) VALUES ('ass');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('bastard');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('beastial');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('bestial');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('bitch');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('blowjob');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('clit');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('cock');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('crap');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('cum');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('cunilingus');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('cunt');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('damn');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('dick');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('dildo');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('dink');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('ejaculate');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('fag');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('fart');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('felat');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('fuc');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('fuck');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('fuk');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('gangbang');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('handjob');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('hell');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('horniest');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('horny');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('jism');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('jiz');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('kock');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('kondum');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('kum');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('kunilingus');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('lust');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('nigger');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('orgasim');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('orgasims');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('orgasm');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('phuk');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('phuq');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('piss');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('porn');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('prick');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('pussies');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('pussy');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('sex');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('shit');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('slut');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('smut');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('spunk');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('suck');
INSERT INTO "cleat_forbidden_words" (word) VALUES ('twat');