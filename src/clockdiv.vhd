-- Created by Iskandar Setiadi - freedomofkeima and Yusuf Fajar Ardiana
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE  IEEE.STD_LOGIC_ARITH.ALL; 
USE  IEEE.STD_LOGIC_UNSIGNED.ALL;
USE  IEEE.MATH_REAL.ALL;

--Mendefinisikan entitas Clock
entity CLOCKDIV is port(
	CLK: IN std_logic;
	DIVOUT: buffer std_logic);
end CLOCKDIV;

architecture behavioral of CLOCKDIV is
	begin
		PROCESS(CLK)
			variable count: integer:=0;
			--Konstanta untuk mengatur framerate
			constant div: integer:=900000;		
		begin
				--Counter
				if CLK'event and CLK='1' then
	
					if(count<div) then
						count:=count+1;						
						if(DIVOUT='0') then
							DIVOUT<='0';
						elsif(DIVOUT='1') then
							DIVOUT<='1';
						end if;
					else
						if(DIVOUT='0') then
							DIVOUT<='1';
						elsif(DIVOUT='1') then
							DIVOUT<='0';
						end if;
					count:=0;
					end if;

				end if;
		end process;
end behavioral;
-- All Rights Reserved 2012		