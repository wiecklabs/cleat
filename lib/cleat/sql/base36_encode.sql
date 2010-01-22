CREATE OR REPLACE FUNCTION base36_encode(x bigint) RETURNS varchar AS $$
  DECLARE
    alphabet char[] := '{0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z}';
  BEGIN
    IF x = 0 THEN
      RETURN alphabet[1];
    ELSE
      DECLARE
        i bigint := x;
        remainder int;
        encoded text := '';
      BEGIN
        WHILE i > 0 LOOP
          encoded := alphabet[(i % 36) + 1] || encoded;
          i := i / 36;
        END LOOP;
        RETURN encoded;
      END;
    END IF;
  END;
$$ LANGUAGE 'plpgsql';