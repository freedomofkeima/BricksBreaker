-- Created by Iskandar Setiadi - freedomofkeima and Yusuf Fajar Ardiana
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

ENTITY Bcd_7seg IS
	PORT ( D0, D1, D2, D3      : IN STD_LOGIC  ;
		  A, B, C, D, E, F, G    : OUT STD_LOGIC );
end Bcd_7seg;
--Convert to STD LOGIC VECTOR, untuk INTEGER --> BINARY 4 BIT
ARCHITECTURE behavioural OF Bcd_7seg IS

BEGIN
	A <= (D1 OR D3 OR ((NOT D0) AND (NOT D2)) OR (D0 AND D2));
	B <= ((NOT D2) OR (D0 AND D1) OR ((NOT D0) AND (NOT D1)));
	C <= (D0 OR (NOT D1) OR D2);
	D <= (D3 OR (D1 AND (NOT D2)) OR ((NOT D0) AND (NOT D2)) OR (D0 AND (NOT D1) AND D2) OR (D1 AND (NOT D0)));
	E <= (((NOT D0) AND (NOT D2)) OR ((NOT D0) AND D1));
	F <= (D3 OR ((NOT D0) AND (NOT D1)) OR ((NOT D0) AND D2) OR ((NOT D1) AND D2));
	G <= (D3 OR (D1 AND (NOT D2)) OR ((NOT D1) AND D2) OR ((NOT D0) AND D2));

END behavioural;
-- All Rights Reserved 2012