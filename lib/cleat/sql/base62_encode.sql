CREATE OR REPLACE FUNCTION base62_encode(x bigint) RETURNS varchar AS $$
  DECLARE
    alphabet char[] := '{0,1,2,3,4,5,6,7,8,9,a,b,c,d,e,f,g,h,i,j,k,l,m,n,o,p,q,r,s,t,u,v,w,x,y,z,A,B,C,D,E,F,G,H,I,J,K,L,M,N,O,P,Q,R,S,T,U,V,W,X,Y,Z}';
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
          encoded := alphabet[(i % 62) + 1] || encoded;
          i := i / 62;
        END LOOP;
        RETURN encoded;
      END;
    END IF;
  END;
$$ LANGUAGE 'plpgsql';