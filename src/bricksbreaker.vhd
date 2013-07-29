-- Created by Iskandar Setiadi - freedomofkeima and Yusuf Fajar Ardiana
LIBRARY  IEEE; 
USE  IEEE.STD_LOGIC_1164.ALL; 
USE  IEEE.STD_LOGIC_ARITH.ALL; 
USE  IEEE.STD_LOGIC_UNSIGNED.ALL;
USE  IEEE.MATH_REAL.ALL; 

--Komponen utama bricksbreaker, menerima 4 masukkan dari pengguna, 1 clock, serta mengeluarkan sinyal untuk display LCD 
ENTITY bricksbreaker  IS
PORT(
		PushKanan		: IN STD_LOGIC; --Sebagai tombol arah kanan (RIGHT)
		PushKiri		: IN STD_LOGIC; --Sebagai tombol arah kiri (LEFT)
		Reset			: IN STD_LOGIC; --Sebagai tombol untuk mengulang permainan
		LevelMode		: IN STD_LOGIC; --Untuk mengatur kecepatan bujursangkar
		ClockSystem		: IN STD_LOGIC; --CLOCK AUTOMATIC dari sistem
		VGA_R           : OUT STD_LOGIC_VECTOR( 5 DOWNTO 0 );
		VGA_G           : OUT STD_LOGIC_VECTOR( 5 DOWNTO 0 );
		VGA_B           : OUT STD_LOGIC_VECTOR( 5 DOWNTO 0 );
		VGA_HS          : OUT STD_LOGIC;
		VGA_VS          : OUT STD_LOGIC;
		VGA_CLK         : OUT STD_LOGIC;
		VGA_BLANK       : OUT STD_LOGIC);
END bricksbreaker;

ARCHITECTURE behavioral OF bricksbreaker  IS
	--Sinyal sinyal untuk proses scanning pixel pada layar
	SIGNAL  red                 :        STD_LOGIC_VECTOR (5 DOWNTO 0);
	SIGNAL  green               :        STD_LOGIC_VECTOR (5 DOWNTO 0);
	SIGNAL  blue                :        STD_LOGIC_VECTOR (5 DOWNTO 0);
	SIGNAL  red_color           :        STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL  green_color         :        STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL  blue_color          :        STD_LOGIC_VECTOR (7 DOWNTO 0);
	SIGNAL  pixel_row           :        STD_LOGIC_VECTOR (9 DOWNTO 0);
	SIGNAL  pixel_column        :        STD_LOGIC_VECTOR (9 DOWNTO 0);
	SIGNAL  red_on              :        STD_LOGIC;
	SIGNAL  green_on            :        STD_LOGIC;
	SIGNAL  blue_on             :        STD_LOGIC;

--Mengintegrasikan modul vga
COMPONENT vga  IS
PORT(
		i_clk              :  IN   STD_LOGIC;
		i_red              :  IN   STD_LOGIC;
		i_green            :  IN   STD_LOGIC;
		i_blue             :  IN   STD_LOGIC;
		--Untuk menentukan warna keluaran
		o_red              :  OUT  STD_LOGIC;
		o_green            :  OUT  STD_LOGIC;
		o_blue             :  OUT  STD_LOGIC;
		--Untuk sinkronisasi sinyal sync
		o_horiz_sync       :  OUT  STD_LOGIC;
		o_vert_sync        :  OUT  STD_LOGIC;
		--Untuk menentukan koordinat pixel pada layar LCD
		o_pixel_row        :  OUT  STD_LOGIC_VECTOR( 9 DOWNTO 0 );
		o_pixel_column     :  OUT  STD_LOGIC_VECTOR( 9 DOWNTO 0 ));
END COMPONENT;

COMPONENT Bricks_MainGame  IS
PORT(
		PushKanan          : IN STD_LOGIC; --Sebagai tombol arah kanan (RIGHT)
		PushKiri           : IN STD_LOGIC; --Sebagai tombol arah kiri (LEFT)
		Reset			 : IN STD_LOGIC; --Sebagai tombol untuk mengulang permainan
		LevelMode          : IN STD_LOGIC; --Untuk mengatur kecepatan bujursangkar
		ClockSystem        : IN STD_LOGIC; --CLOCK AUTOMATIC dari sistem
		i_pixel_column     : IN STD_LOGIC_VECTOR( 9 DOWNTO 0 );
		i_pixel_row        : IN STD_LOGIC_VECTOR( 9 DOWNTO 0 );
		o_red              : OUT STD_LOGIC_VECTOR( 7 DOWNTO 0 );
		o_green            : OUT STD_LOGIC_VECTOR( 7 DOWNTO 0 );
		o_blue             : OUT STD_LOGIC_VECTOR( 7 DOWNTO 0 ));
		--Keluaran sebagai sinyal warna RGB
END COMPONENT;

BEGIN
	--Melakukan PORT MAP modul vga
	vga_driver0 : vga
PORT MAP (
		i_clk            => ClockSystem,
		i_red            => '1',
		i_green          => '1',
		i_blue           => '1',
		o_red            => red_on,
		o_green          => green_on,
		o_blue           => blue_on,
		o_horiz_sync     => VGA_HS,
		o_vert_sync      => VGA_VS,
		o_pixel_row      => pixel_row,
		o_pixel_column   => pixel_column);

--Melakukan PORT MAP main game
maingame : Bricks_MainGame
PORT MAP (
		PushKanan        => PushKanan,
		PushKiri         => PushKiri,
		Reset			=> Reset,
		LevelMode        => LevelMode,
		ClockSystem      => ClockSystem,
		i_pixel_column   => pixel_column,
		i_pixel_row      => pixel_row,
		o_red            => red_color,
		o_green          => green_color,
		o_blue           => blue_color);

		red   <= red_color  (7 DOWNTO 2) ;
		green <= green_color(7 DOWNTO 2) ;
		blue  <= blue_color (7 DOWNTO 2) ;

--Melakukan pemrosesan, menerima masukkan logika sinyal warna dan mengirimkannya ke VGA
PROCESS(red_on,green_on,blue_on,red,green,blue)
BEGIN

IF (red_on = '1'  ) THEN VGA_R <=  red;  -- Jika merah aktif
ELSE  VGA_R <=  "000000";
END IF;

IF (green_on = '1'  ) THEN VGA_G <=  green; -- Jika hijau aktif
ELSE VGA_G <=  "000000";
END IF;

IF (blue_on = '1'  ) THEN VGA_B <=  blue; -- Jika biru aktif
ELSE VGA_B <=  "000000";
END IF;


END PROCESS;
END behavioral;
-- All Rights Reserved 2012
