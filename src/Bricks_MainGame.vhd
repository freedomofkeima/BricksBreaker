-- Created by Iskandar Setiadi - freedomofkeima and Yusuf Fajar Ardiana
LIBRARY  IEEE; 
USE  IEEE.STD_LOGIC_1164.ALL; 
USE  IEEE.STD_LOGIC_ARITH.ALL; 
use	 IEEE.NUMERIC_STD.ALL;
USE  IEEE.STD_LOGIC_UNSIGNED.ALL;
USE  IEEE.MATH_REAL.ALL; 
 
ENTITY Bricks_MainGame  IS 
	PORT( 
	    PushKanan          : IN STD_LOGIC;  --Sebagai tombol arah kanan (RIGHT), Tombol ke-1
	    PushKiri           : IN STD_LOGIC;  --Sebagai tombol arah kiri (LEFT), Tombol ke-2
	    Reset			   : IN STD_LOGIC;  --Sebagai tombol untuk mengulang permainan, Tombol ke-3
	    LevelMode          : IN STD_LOGIC;  --Untuk mengatur kecepatan bujursangkar
	    ClockSystem        : IN STD_LOGIC;  --CLOCK AUTOMATIC dari sistem
	    i_pixel_column     : IN STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	    i_pixel_row        : IN STD_LOGIC_VECTOR( 9 DOWNTO 0 );
	    o_red              : OUT STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	    o_green            : OUT STD_LOGIC_VECTOR( 7 DOWNTO 0 );
	    o_blue             : OUT STD_LOGIC_VECTOR( 7 DOWNTO 0 ));
--Keluaran sebagai sinyal warna RGB
END Bricks_MainGame; 


ARCHITECTURE behavioral OF Bricks_MainGame  IS 

--Tipe eksekusi FSM
TYPE executionStage IS (s1,s2,s3,s4,s5);
SIGNAL currentstate, nextstate : executionStage;

--Tipe bentukan bricks
TYPE BRICKSELMT IS
	RECORD
		BATASKIRI 	: INTEGER;
		BATASKANAN 	: INTEGER;
		BATASATAS 	: INTEGER;
		BATASBAWAH 	: INTEGER;
		ISHIDUP		: BOOLEAN;
	END RECORD;

TYPE BRICKSTYPE IS ARRAY (0 TO 8) OF BRICKSELMT; --Mendefinisikan tipe bentukan dalam array
SIGNAL BRICKS : BRICKSTYPE; --Variabel yang akan digunakan, misal BRICKS(0).BATASKIRI
SHARED VARIABLE ISKENABRICKS : BOOLEAN := FALSE; --Jika bola mengenai bricks

--Untuk mengatur arah pantulan bola
SHARED VARIABLE ROTASIX : INTEGER := 1;
SHARED VARIABLE ROTASIY : INTEGER := -1;

CONSTANT TVD  : INTEGER := 479; --THD, batas horizontal layar
CONSTANT THD  : INTEGER := 639; --TVD, batas vertikal layar

--Batas arah bujur sangkar yang akan digerakkan
--Ubah bentuknya menjadi bola // menggunakan persamaan kuadrat x^2 + y^2
SHARED VARIABLE BOLAATAS	 : INTEGER := 340;
SHARED VARIABLE BOLAKIRI	 : INTEGER := 295;
SHARED VARIABLE BOLAKANAN	 : INTEGER := 344;
SHARED VARIABLE BOLABAWAH 	 : INTEGER := 389;

--Untuk mengatur posisi papan pemantul
SHARED VARIABLE PAPANKIRI    : INTEGER := 260;
SHARED VARIABLE PAPANKANAN   : INTEGER := 380;
SHARED VARIABLE PAPANATAS    : INTEGER := 390;
SHARED VARIABLE PAPANBAWAH   : INTEGER := 400;

--Mengatur posisi Counter dari BCD-to-7-Segment, Koordinat X
SHARED VARIABLE X1 : INTEGER := 20;
SHARED VARIABLE X2 : INTEGER := 25;
SHARED VARIABLE X3 : INTEGER := 40;
SHARED VARIABLE X4 : INTEGER := 45;

--Mengatur posisi Counter dari BCD-to-7-Segment, Koordinat Y
SHARED VARIABLE Y1 : INTEGER := 410;
SHARED VARIABLE Y2 : INTEGER := 415;
SHARED VARIABLE Y3 : INTEGER := 430;
SHARED VARIABLE Y4 : INTEGER := 435;
SHARED VARIABLE Y5 : INTEGER := 450;
SHARED VARIABLE Y6 : INTEGER := 455;

--Mengatur lampu state menang dan kalah
SHARED VARIABLE X5 : INTEGER := 400;
SHARED VARIABLE X6 : INTEGER := 500;
SHARED VARIABLE X7 : INTEGER := 600;

SHARED VARIABLE IsKalah : BOOLEAN := FALSE;
SHARED VARIABLE IsMenang: BOOLEAN := FALSE;
--Mengatur kondisi lampu untuk counter
SIGNAL IsCounter : STD_LOGIC_VECTOR (6 downto 0) := "0000000";

--Mengatur skor dari permainan
SHARED VARIABLE SCORE : INTEGER := 0;
SIGNAL BCDPortInput : STD_LOGIC_VECTOR (3 downto 0) := "0000";


--Mengatur kecepatan dari bujur sangkar
SHARED VARIABLE SPEED 		: INTEGER := 0;
--Clock sebagai buffer CLOCKDIV
SIGNAL clock40hz 	: STD_LOGIC;

--Variabel Homepage
SHARED VARIABLE COUNTERHOME : INTEGER := 0;
SHARED VARIABLE ISHOME : BOOLEAN := TRUE;

--Komponen Clockdiv digunakan agar pergerakan bujur sangkar dapat terlihat oleh pengguna
COMPONENT CLOCKDIV IS
 port(	CLK: IN std_logic;
		DIVOUT: buffer std_logic);
end component;

--Komponen BCD to 7 Segment untuk mengkonversikan skor menjadi tampilan
COMPONENT Bcd_7seg 
	PORT ( D0, D1, D2, D3    : IN STD_LOGIC  ;
	  A, B, C, D, E, F, G    : OUT STD_LOGIC );
END COMPONENT;

BEGIN 

PROCESS
	BEGIN
	WAIT UNTIL (clock40hz'EVENT) AND (clock40hz = '1');
	--Melakukan konversi skor menjadi binary 4 bit
	BCDPortInput <= STD_LOGIC_VECTOR(TO_UNSIGNED(SCORE, 4));
	--Untuk mereset / mengulang permainan
	IF (Reset = '0') THEN
			--Memasuki state homepage
			currentstate <= s1;
	ELSE
			currentstate <= nextstate;
	END IF;
END PROCESS;

PROCESS(currentstate, i_pixel_row,i_pixel_column, PushKanan, PushKiri, LevelMode, IsCounter, Bricks)
BEGIN

IF (clock40hz'EVENT) AND (clock40hz = '1') THEN
   --Mengatur kecepatan bujursangkar sesuai dengan state SW[0]
	CASE currentstate IS
 	  WHEN s1 =>
 	    --Homepage Permainan
 	    COUNTERHOME := COUNTERHOME + 1;
 	    IF COUNTERHOME < 50 THEN
			ISHOME := TRUE;
			nextstate <= currentstate; 
		ELSE
			nextstate <= s2;
		    ISHOME := FALSE;
		    COUNTERHOME := 0;
		END IF;
	  WHEN s2 =>
	  	--Inisialisasi Variabel
		 IsKalah   := FALSE;
		 BOLAATAS  := 340;
		 BOLABAWAH := 359;
		 BOLAKIRI  := 305;
		 BOLAKANAN := 324;
		 
		 PAPANKIRI  := 260;
		 PAPANKANAN := 380;
		 PAPANATAS	:= 390;
		 PAPANBAWAH	:= 400;
		 
		 SCORE := 0;
		 ISMENANG := FALSE;
		 ISKALAH := FALSE;
		 
		 --Inisialisasi Bricks
		 FOR i IN 0 TO 2 LOOP -- Looping untuk variabel i
			FOR j IN 0 TO 2 LOOP -- Looping untuk variabel j
				BRICKS(i + (j*3)).BATASKIRI <= 150 + (j * 150);
				BRICKS(i + (j*3)).BATASKANAN <= 200 + (j * 150);
				BRICKS(i + (j*3)).BATASATAS <= 50 + (i * 80);
				BRICKS(i + (j*3)).BATASBAWAH <= 80 + (i * 80);
				BRICKS(i + (j*3)).ISHIDUP <= TRUE;
			END LOOP;
		END LOOP;		
		 
		 nextstate <= s3;
		 
	  WHEN s3 =>
	   IF LevelMode = '1' THEN
	     		SPEED := 2; --saat SW[0] = '1' maka mode lambat
	   ELSE
	    		SPEED := 5; --saat SW[0] = '0' maka mode cepat
       END IF;
	
    	IF BOLAATAS <= 0 THEN ROTASIY := 1;
			ELSIF BOLABAWAH >= TVD THEN ROTASIY := -1;
			ELSE ROTASIY := ROTASIY; --Delete this later
	    END IF;
	
	    IF BOLAKIRI <= 0 THEN ROTASIX := 1;
			ELSIF BOLAKANAN >= THD THEN ROTASIX := -1;
			ELSE ROTASIX := ROTASIX;
	    END IF;
	
	  --Kondisi Papan, PAPANATAS = 390
	
	    IF (BOLABAWAH >= PAPANATAS) AND (BOLABAWAH <= PAPANBAWAH) THEN
	    	--Jika sumbu x bola Valid
	 	  IF ((BOLAKANAN >= PAPANKIRI) AND (BOLAKANAN <= PAPANKANAN)) OR ((BOLAKIRI >= PAPANKIRI) AND (BOLAKIRI <= PAPANKANAN)) THEN
			--Inversi arah Y
	    		IF ROTASIY = 1 THEN ROTASIY := -1;
			ELSE ROTASIY := 1;
			END IF;
		  END IF;
	   END IF;
	   
      --Kondisi masih hijau (lampu merah belum menyala)
      IF BOLABAWAH <= 395 THEN
	    BOLAATAS := BOLAATAS + ROTASIY * SPEED;
	    BOLABAWAH := BOLABAWAH + ROTASIY * SPEED;
	    BOLAKIRI := BOLAKIRI + ROTASIX * SPEED;
	    BOLAKANAN := BOLAKANAN + ROTASIX * SPEED;
	  END IF;
	
	  FOR i IN 0 TO 8 LOOP
		 IF (BRICKS(i).ISHIDUP) THEN
			ISKENABRICKS := FALSE; --Inisialisasi Variabel
			--Mengecek apakah Bola mengenai Bricks
				--Bagian Atas
					IF (BOLABAWAH >= BRICKS(i).BATASATAS) AND (BOLABAWAH <= BRICKS(i).BATASBAWAH) THEN
					--Jika sumbu x bola Valid
					  IF ((BOLAKANAN >= BRICKS(i).BATASKIRI) AND (BOLAKANAN <= BRICKS(i).BATASKANAN)) OR ((BOLAKIRI >= BRICKS(i).BATASKIRI) AND (BOLAKIRI <= BRICKS(i).BATASKANAN)) THEN
				     	--Melakukan Inversi arah Y dari 1 ke -1 (Pantulan arah atas)
					   	ROTASIY := -1;
					    --Menghancurkan brick
					    ISKENABRICKS := TRUE;
					   END IF;
					END IF;			
				--Bagian Kiri
					IF (BOLAKANAN >= BRICKS(i).BATASKIRI) AND (BOLAKANAN <= BRICKS(i).BATASKANAN) THEN
					--Jika sumbu x bola Valid
					  IF ((BOLAATAS >= BRICKS(i).BATASATAS) AND (BOLAATAS <= BRICKS(i).BATASBAWAH)) OR ((BOLABAWAH >= BRICKS(i).BATASATAS) AND (BOLABAWAH <= BRICKS(i).BATASBAWAH)) THEN
				     	--Melakukan Inversi arah X dari 1 ke -1 (Pantulan arah kiri)
					   	ROTASIX := -1;
					    --Menghancurkan brick
					    ISKENABRICKS := TRUE;
					   END IF;
					END IF;				
				--Bagian Kanan
					IF (BOLAKIRI >= BRICKS(i).BATASKIRI) AND (BOLAKIRI <= BRICKS(i).BATASKANAN) THEN
					--Jika sumbu x bola Valid
					  IF ((BOLAATAS >= BRICKS(i).BATASATAS) AND (BOLAATAS <= BRICKS(i).BATASBAWAH)) OR ((BOLABAWAH >= BRICKS(i).BATASATAS) AND (BOLABAWAH <= BRICKS(i).BATASBAWAH)) THEN
				     	--Melakukan Inversi arah X dari -1 ke 1 (Pantulan arah kanan)
					   	ROTASIX := 1;
					    --Menghancurkan brick
					    ISKENABRICKS := TRUE;
					   END IF;
					END IF;			
				--Bagian Bawah
					IF (BOLAATAS >= BRICKS(i).BATASATAS) AND (BOLAATAS <= BRICKS(i).BATASBAWAH) THEN
					--Jika sumbu x bola Valid
					  IF ((BOLAKANAN >= BRICKS(i).BATASKIRI) AND (BOLAKANAN <= BRICKS(i).BATASKANAN)) OR ((BOLAKIRI >= BRICKS(i).BATASKIRI) AND (BOLAKIRI <= BRICKS(i).BATASKANAN)) THEN
				     	--Melakukan Inversi arah Y dari -1 ke 1 (Pantulan arah bawah)
					   	ROTASIY := 1;
					    --Menghancurkan brick
					    ISKENABRICKS := TRUE;
					   END IF;
					END IF;			
			--Jika Bola mengenai Bricks, hancurkan Bricks, Tambahkan Skor
			IF (ISKENABRICKS) THEN
				BRICKS(i).ISHIDUP <= FALSE;
				--Menambahkan Skor
				SCORE := SCORE + 1;
			END IF;
	     END IF;
		END LOOP;

	  --Mengatur pergerakan papan
	  IF (PushKanan = '0') AND (PushKiri = '1') THEN -- Arah Kanan
		 PAPANKIRI := PAPANKIRI + 5;
		 PAPANKANAN := PAPANKANAN + 5;
	    	IF PAPANKIRI >= THD - (380 - 260) THEN --Jika Papan mencapai batas kanan
			  PAPANKIRI  := THD - (380 - 260);
			  PAPANKANAN := THD; 
	    	END IF;
	   ELSIF (PushKanan = '1') AND (PushKiri = '0') THEN -- Arah Kiri
		 PAPANKIRI := PAPANKIRI - 5;
		 PAPANKANAN := PAPANKANAN - 5;
		  IF PAPANKANAN <= (380 - 260) THEN -- Jika Papan mencapai batas kiri
			  PAPANKIRI  := 0; 
		   	  PAPANKANAN := 380 - 260;
		   END IF;	
	   ELSE
		PAPANKIRI := PAPANKIRI;
		PAPANKANAN := PAPANKANAN;
	   END IF;
	  
	
	  IF BOLABAWAH > 395 THEN
	       nextstate <= s4;
	  ELSIF SCORE = 9 THEN
			nextstate <= s5;
	  ELSE nextstate <= currentstate;
	  END IF;
	  
	  WHEN s4 =>
			IsKalah := TRUE;
			nextstate <= currentstate;
			
	  WHEN s5 =>
			IsMenang := TRUE;
			nextstate <= currentstate;
 	END CASE; 
 END IF;	
  --Untuk mengatur posisi

  IF ISHOME THEN
    --Menampilkan posisi layar Home
    --huruf B
    IF ((i_pixel_row > 10)  AND (i_pixel_row <120)  ) AND ((i_pixel_column >= 120)  AND (i_pixel_column < 150) AND (COUNTERHOME >= 3)  ) THEN 
	o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; --kotak B paling pinggir
	ELSIF((i_pixel_row > 10)  AND (i_pixel_row < 30)  ) AND ((i_pixel_column >= 150)  AND (i_pixel_column < 220) AND (COUNTERHOME >= 3) ) THEN 
	o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; --kotak B pertama atas
	ELSIF((i_pixel_row >= 30)  AND (i_pixel_row < 100)  ) AND ((i_pixel_column >= 190)  AND (i_pixel_column < 220) AND (COUNTERHOME >= 3) ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak B paling kanan
	ELSIF ((i_pixel_row > 55)  AND (i_pixel_row <75)  ) AND ((i_pixel_column >= 150)  AND (i_pixel_column < 190) AND (COUNTERHOME >= 3) ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak B tengah 
	ELSIF ((i_pixel_row >= 100)  AND (i_pixel_row < 120)  ) AND ((i_pixel_column >= 150)  AND (i_pixel_column <220) AND (COUNTERHOME >= 3) ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak B paling bawah
    --huruf R
    ELSIF ((i_pixel_row > 10)  AND (i_pixel_row <120 )  ) AND ((i_pixel_column >= 230)  AND (i_pixel_column < 260) AND (COUNTERHOME >= 6)  ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak R paling KIRI 
	ELSIF ((i_pixel_row > 10)  AND (i_pixel_row <30 )  ) AND ((i_pixel_column >= 260)  AND (i_pixel_column < 330) AND (COUNTERHOME >= 6)   ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak R paling atas
	ELSIF ((i_pixel_row >= 30)  AND (i_pixel_row <50 )  ) AND ((i_pixel_column >= 300)  AND (i_pixel_column < 330) AND (COUNTERHOME >= 6)  ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak R paling kanan atas
	ELSIF ((i_pixel_row >= 50)  AND (i_pixel_row <70)  ) AND ((i_pixel_column >= 260)  AND (i_pixel_column < 330) AND (COUNTERHOME >= 6)  ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak R paling tengah
	ELSIF ((i_pixel_row >= 70)  AND (i_pixel_row <120 )  ) AND ((i_pixel_column >= 300)  AND (i_pixel_column < 330) AND (COUNTERHOME >= 6)  ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak R paling kanan bawah
    -- huruf I
	ELSIF ((i_pixel_row > 10)  AND (i_pixel_row <120 )  ) AND ((i_pixel_column >= 340)  AND (i_pixel_column < 370) AND (COUNTERHOME >= 9)  ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak i
	-- huruf C
	ELSIF ((i_pixel_row > 10)  AND (i_pixel_row <120 )  ) AND ((i_pixel_column >= 380)  AND (i_pixel_column < 410) AND (COUNTERHOME >= 12)  ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak ckiri
	ELSIF ((i_pixel_row > 10)  AND (i_pixel_row <30)  ) AND ((i_pixel_column >= 410)  AND (i_pixel_column < 450) AND (COUNTERHOME >= 12)  ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak c atas
	ELSIF ((i_pixel_row >100)  AND (i_pixel_row <120 )  ) AND ((i_pixel_column >= 410)  AND (i_pixel_column < 450) AND (COUNTERHOME >= 12)  ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak c bawah
	-- huruf K
    ELSIF ((i_pixel_row > 10)  AND (i_pixel_row <120 )  ) AND ((i_pixel_column >= 460)  AND (i_pixel_column < 490) AND (COUNTERHOME >= 15)  ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak k kiri
	ELSIF ((i_pixel_row > 45)  AND (i_pixel_row <65 )  ) AND ((i_pixel_column >= 490)  AND (i_pixel_column < 500) AND (COUNTERHOME >= 15)  ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak k tengah
	ELSIF ((i_pixel_row > 20)  AND (i_pixel_row <45)  ) AND ((i_pixel_column >= 500)  AND (i_pixel_column < 525) AND (COUNTERHOME >= 15)  ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak k kanan atas
	ELSIF((i_pixel_row > 65)  AND (i_pixel_row <120 )  ) AND ((i_pixel_column >= 500)  AND (i_pixel_column < 525) AND (COUNTERHOME >= 15)  ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak k kanan bawah
	--HURUF B PADA BREAKER
    ELSIF ((i_pixel_row > 130)  AND (i_pixel_row <240)  ) AND ((i_pixel_column >= 5)  AND (i_pixel_column < 35) AND (COUNTERHOME >= 18)  ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak b kiri
	ELSIF((i_pixel_row > 130)  AND (i_pixel_row <150)  ) AND ((i_pixel_column >= 35)  AND (i_pixel_column < 75) AND (COUNTERHOME >= 18)  ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak b atas
	ELSIF ((i_pixel_row >= 130)  AND (i_pixel_row<= 240 )  ) AND ((i_pixel_column >= 75)  AND (i_pixel_column < 105) AND (COUNTERHOME >= 18)  ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak b kanan
	ELSIF ((i_pixel_row > 175)  AND (i_pixel_row <195 )  ) AND ((i_pixel_column >= 35)  AND (i_pixel_column < 75) AND (COUNTERHOME >= 18)  ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak b tengah
	ELSIF ((i_pixel_row >220)  AND (i_pixel_row <240 )  ) AND ((i_pixel_column >= 35)  AND (i_pixel_column < 75) AND (COUNTERHOME >= 18)  ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak b bawah
    --huruf R
    ELSIF ((i_pixel_row > 130)  AND (i_pixel_row <240 )  ) AND ((i_pixel_column >= 115)  AND (i_pixel_column <145) AND (COUNTERHOME >= 21)  ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak R kiri
	ELSIF ((i_pixel_row > 130)  AND (i_pixel_row <150)  ) AND ((i_pixel_column >= 145)  AND (i_pixel_column < 185) AND (COUNTERHOME >= 21)  ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak R atas
	ELSIF ((i_pixel_row > 130)  AND (i_pixel_row <240 )  ) AND ((i_pixel_column >= 185)  AND (i_pixel_column < 215) AND (COUNTERHOME >= 21)  ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak R kanan
	ELSIF ((i_pixel_row > 170)  AND (i_pixel_row <190)  ) AND ((i_pixel_column >= 145)  AND (i_pixel_column < 185) AND (COUNTERHOME >= 21)  ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak R tengah
	
  	-- huruf E
	ELSIF ((i_pixel_row > 130)  AND (i_pixel_row <240 )  ) AND ((i_pixel_column >= 225)  AND (i_pixel_column < 255) AND (COUNTERHOME >= 24)  ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak E kiri 
	ELSIF ((i_pixel_row > 130)  AND (i_pixel_row <150 )  ) AND ((i_pixel_column >= 255)  AND (i_pixel_column < 300) AND (COUNTERHOME >= 24)  ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak E atas
	ELSIF ((i_pixel_row > 170)  AND (i_pixel_row <190 )  ) AND ((i_pixel_column >= 255)  AND (i_pixel_column < 300) AND (COUNTERHOME >= 24)  ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak E tengah
	ELSIF ((i_pixel_row > 220)  AND (i_pixel_row <240 )  ) AND ((i_pixel_column >= 255)  AND (i_pixel_column < 300) AND (COUNTERHOME >= 24)  ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak E bawah
    -- huruf A
    ELSIF ((i_pixel_row > 130)  AND (i_pixel_row <240 )  ) AND ((i_pixel_column >= 310)  AND (i_pixel_column < 340) AND (COUNTERHOME >= 27)  ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak A kiri
	ELSIF ((i_pixel_row > 130)  AND (i_pixel_row <150 )  ) AND ((i_pixel_column >= 340)  AND (i_pixel_column < 380) AND (COUNTERHOME >= 27)   ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak A atas
	ELSIF ((i_pixel_row > 130)  AND (i_pixel_row <240 )  ) AND ((i_pixel_column >= 380)  AND (i_pixel_column <410) AND (COUNTERHOME >= 27)  ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak A kanan
	ELSIF((i_pixel_row > 165)  AND (i_pixel_row <185 )  ) AND ((i_pixel_column >= 340)  AND (i_pixel_column < 380) AND (COUNTERHOME >= 27)  ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak A tengah
	-- huruf K
	ELSIF ((i_pixel_row > 130)  AND (i_pixel_row <240)  ) AND ((i_pixel_column >= 415)  AND (i_pixel_column < 445) AND (COUNTERHOME >= 30)  ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak K kiri
	ELSIF ((i_pixel_row > 165)  AND (i_pixel_row <185 )  ) AND ((i_pixel_column >= 445)  AND (i_pixel_column < 465) AND (COUNTERHOME >= 30)   ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak K tengah
	ELSIF ((i_pixel_row > 145)  AND (i_pixel_row <165 )  ) AND ((i_pixel_column >= 465)  AND (i_pixel_column < 485) AND (COUNTERHOME >= 30)   ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak K atas kanan
	ELSIF ((i_pixel_row > 185)  AND (i_pixel_row <240 )  ) AND ((i_pixel_column >= 465)  AND (i_pixel_column < 485) AND (COUNTERHOME >= 30)  ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak K kanan bawah
	-- HURUF E
	ELSIF ((i_pixel_row > 130)  AND (i_pixel_row <240 )  ) AND ((i_pixel_column >= 495)  AND (i_pixel_column < 525) AND (COUNTERHOME >= 33)  ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak E KIRI
	ELSIF ((i_pixel_row > 130)  AND (i_pixel_row <150 )  ) AND ((i_pixel_column >= 525)  AND (i_pixel_column < 565) AND (COUNTERHOME >= 33)   ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak E ATAS
	ELSIF ((i_pixel_row > 170)  AND (i_pixel_row <190 )  ) AND ((i_pixel_column >= 525)  AND (i_pixel_column < 565) AND (COUNTERHOME >= 33)  ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak E tengah
	ELSIF((i_pixel_row > 210)  AND (i_pixel_row <240 )  ) AND ((i_pixel_column >= 525)  AND (i_pixel_column < 565) AND (COUNTERHOME >= 33)  ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak E bawah
	--huruf R
	ELSIF ((i_pixel_row > 130)  AND (i_pixel_row <240 )  ) AND ((i_pixel_column >= 570)  AND (i_pixel_column < 590) AND (COUNTERHOME >= 36)  ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak R kiri
	ELSIF ((i_pixel_row > 130)  AND (i_pixel_row <150 )  ) AND ((i_pixel_column >= 590)  AND (i_pixel_column < 620) AND (COUNTERHOME >= 36)  ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak R atas
	ELSIF ((i_pixel_row > 130)  AND (i_pixel_row <240)  ) AND ((i_pixel_column >= 620)  AND (i_pixel_column < 640) AND (COUNTERHOME >= 36)  ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak R kanan 
	ELSIF((i_pixel_row > 185)  AND (i_pixel_row <205 )  ) AND ((i_pixel_column >= 590)  AND (i_pixel_column < 620) AND (COUNTERHOME >= 36)  ) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; -- kotak R tengah
    ELSE o_red <= X"FF"; o_green <= X"FF"; o_blue <= X"FF";
    END IF;
    
  ELSE

   IF ((i_pixel_row > BOLAATAS) AND (i_pixel_row < BOLABAWAH) AND (i_pixel_column > BOLAKIRI) AND  (i_pixel_column < BOLAKANAN)) AND (NOT IsKalah) THEN 
   o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00";
   --Untuk mengatur posisi papan  
	ELSIF ((i_pixel_row > PAPANATAS) AND (i_pixel_row < PAPANBAWAH) AND (i_pixel_column > PAPANKIRI) AND  (i_pixel_column < PAPANKANAN)) THEN 
    o_red <= X"00"; o_green <= X"00"; o_blue <= X"FF";
	ELSIF ((i_pixel_row >= Y1) AND (i_pixel_row <= Y2) AND ( i_pixel_column >= X2) AND (i_pixel_column <= X3) AND (IsCounter(0) = '1')) THEN 
    o_red <= X"FF"; o_green <= X"FF"; o_blue <= X"00"; --Lampu A
	ELSIF ((i_pixel_row >= Y2) AND (i_pixel_row <= Y3) AND ( i_pixel_column >= X3) AND (i_pixel_column <= X4) AND (IsCounter(1) = '1')) THEN 
    o_red <= X"FF"; o_green <= X"FF"; o_blue <= X"00"; --Lampu B
	ELSIF ((i_pixel_row >= Y4) AND (i_pixel_row <= Y5) AND ( i_pixel_column >= X3) AND (i_pixel_column <= X4) AND (IsCounter(2) = '1')) THEN 
    o_red <= X"FF"; o_green <= X"FF"; o_blue <= X"00"; --Lampu C
	ELSIF ((i_pixel_row >= Y5) AND (i_pixel_row <= Y6) AND ( i_pixel_column >= X2) AND (i_pixel_column <= X3) AND (IsCounter(3) = '1')) THEN 
    o_red <= X"FF"; o_green <= X"FF"; o_blue <= X"00"; --Lampu D
	ELSIF ((i_pixel_row >= Y4) AND (i_pixel_row <= Y5) AND ( i_pixel_column >= X1) AND (i_pixel_column <= X2) AND (IsCounter(4) = '1')) THEN 
    o_red <= X"FF"; o_green <= X"FF"; o_blue <= X"00"; --Lampu E
	ELSIF ((i_pixel_row >= Y2) AND (i_pixel_row <= Y3) AND ( i_pixel_column >= X1) AND (i_pixel_column <= X2) AND (IsCounter(5) = '1')) THEN 
    o_red <= X"FF"; o_green <= X"FF"; o_blue <= X"00"; --Lampu F
	ELSIF ((i_pixel_row >= Y3) AND (i_pixel_row <= Y4) AND ( i_pixel_column >= X2) AND (i_pixel_column <= X3) AND (IsCounter(6) = '1')) THEN 
    o_red <= X"FF"; o_green <= X"FF"; o_blue <= X"00"; --Lampu G
	ELSIF ((i_pixel_row > BRICKS(0).BATASATAS) AND (i_pixel_row < BRICKS(0).BATASBAWAH) AND (i_pixel_column > BRICKS(0).BATASKIRI) AND (i_pixel_column < BRICKS(0).BATASKANAN) AND (BRICKS(0).ISHIDUP)) THEN 
    o_red <= X"FF"; o_green <= X"14"; o_blue <= X"93"; --Bricks 1
	ELSIF ((i_pixel_row > BRICKS(1).BATASATAS) AND (i_pixel_row < BRICKS(1).BATASBAWAH) AND (i_pixel_column > BRICKS(1).BATASKIRI) AND (i_pixel_column < BRICKS(1).BATASKANAN) AND (BRICKS(1).ISHIDUP)) THEN 
    o_red <= X"00"; o_green <= X"FF"; o_blue <= X"FF"; --Bricks 2
	ELSIF ((i_pixel_row > BRICKS(2).BATASATAS) AND (i_pixel_row < BRICKS(2).BATASBAWAH) AND (i_pixel_column > BRICKS(2).BATASKIRI) AND (i_pixel_column < BRICKS(2).BATASKANAN) AND (BRICKS(2).ISHIDUP)) THEN 
    o_red <= X"FF"; o_green <= X"14"; o_blue <= X"93"; --Bricks 3
	ELSIF ((i_pixel_row > BRICKS(3).BATASATAS) AND (i_pixel_row < BRICKS(3).BATASBAWAH) AND (i_pixel_column > BRICKS(3).BATASKIRI) AND (i_pixel_column < BRICKS(3).BATASKANAN) AND (BRICKS(3).ISHIDUP)) THEN 
    o_red <= X"00"; o_green <= X"FF"; o_blue <= X"FF"; --Bricks 4
	ELSIF ((i_pixel_row > BRICKS(4).BATASATAS) AND (i_pixel_row < BRICKS(4).BATASBAWAH) AND (i_pixel_column > BRICKS(4).BATASKIRI) AND (i_pixel_column < BRICKS(4).BATASKANAN) AND (BRICKS(4).ISHIDUP)) THEN 
    o_red <= X"FF"; o_green <= X"14"; o_blue <= X"93"; --Bricks 5
	ELSIF ((i_pixel_row > BRICKS(5).BATASATAS) AND (i_pixel_row < BRICKS(5).BATASBAWAH) AND (i_pixel_column > BRICKS(5).BATASKIRI) AND (i_pixel_column < BRICKS(5).BATASKANAN) AND (BRICKS(5).ISHIDUP)) THEN 
    o_red <= X"00"; o_green <= X"FF"; o_blue <= X"FF"; --Bricks 6
	ELSIF ((i_pixel_row > BRICKS(6).BATASATAS) AND (i_pixel_row < BRICKS(6).BATASBAWAH) AND (i_pixel_column > BRICKS(6).BATASKIRI) AND (i_pixel_column < BRICKS(6).BATASKANAN) AND (BRICKS(6).ISHIDUP)) THEN 
    o_red <= X"FF"; o_green <= X"14"; o_blue <= X"93"; --Bricks 7
	ELSIF ((i_pixel_row > BRICKS(7).BATASATAS) AND (i_pixel_row < BRICKS(7).BATASBAWAH) AND (i_pixel_column > BRICKS(7).BATASKIRI) AND (i_pixel_column < BRICKS(7).BATASKANAN) AND (BRICKS(7).ISHIDUP)) THEN 
    o_red <= X"00"; o_green <= X"FF"; o_blue <= X"FF"; --Bricks 8
	ELSIF ((i_pixel_row > BRICKS(8).BATASATAS) AND (i_pixel_row < BRICKS(8).BATASBAWAH) AND (i_pixel_column > BRICKS(8).BATASKIRI) AND (i_pixel_column < BRICKS(8).BATASKANAN) AND (BRICKS(8).ISHIDUP)) THEN 
    o_red <= X"FF"; o_green <= X"14"; o_blue <= X"93"; --Bricks 9
	ELSIF ((i_pixel_row >= Y3) AND (i_pixel_row <= Y5) AND ( i_pixel_column >= X5) AND (i_pixel_column < X6)) AND (IsMenang) THEN 
    o_red <= X"00"; o_green <= X"FF"; o_blue <= X"00"; --Lampu Menang
	ELSIF ((i_pixel_row >= Y3) AND (i_pixel_row <= Y5) AND ( i_pixel_column >= X5) AND (i_pixel_column < X6)) AND (NOT IsMenang) THEN 
    o_red <= X"EE"; o_green <= X"EE"; o_blue <= X"EE"; --Lampu Menang Mati
	ELSIF ((i_pixel_row >= Y3) AND (i_pixel_row <= Y5) AND ( i_pixel_column >= X6) AND (i_pixel_column < X7)) AND (IsKalah) THEN 
    o_red <= X"FF"; o_green <= X"00"; o_blue <= X"00"; --Lampu Kalah
	ELSIF ((i_pixel_row >= Y3) AND (i_pixel_row <= Y5) AND ( i_pixel_column >= X6) AND (i_pixel_column < X7)) AND (NOT IsKalah) THEN 
    o_red <= X"EE"; o_green <= X"EE"; o_blue <= X"EE"; --Lampu Kalah Mati
	ELSE 
	o_red <= X"DE"; o_green <= X"CA"; o_blue <= X"FE";
	END IF;

  END IF;
  
END PROCESS;

--Melakukan PORT MAP terhadap clockdiv
load_clockdiv : clockdiv
	PORT MAP (
	CLK=>   ClockSystem,
	DIVOUT=> clock40hz
	);

--load BCD to 7 Segment
load_bcdtest :  Bcd_7Seg
	PORT MAP(
	D0 => BCDPortInput(0),
    D1 => BCDPortInput(1),
	D2 => BCDPortInput(2),
	D3 => BCDPortInput(3),
	A  => IsCounter(0),
	B  => IsCounter(1),
	C  => IsCounter(2),
	D  => IsCounter(3),
	E  => IsCounter(4),
	F  => IsCounter(5),
	G  => IsCounter(6));

END behavioral;
-- All Rights Reserved 2012