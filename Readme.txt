===========================================README FILE===========================================
|Created by / Dibuat oleh:								        |
|-	Iskandar Setiadi	13511073					                |
|-	Yusuf Fajar Ardiana	18011049						        |
|Asisten : Fajar Arief P. / 13209099								|
|					  REGU 4B					        |
|		          SEKOLAH TINGGI ELEKTRONIKA DAN INFORMATIKA                            |
|			       	  INSTITUT TEKNOLOGI BANDUNG                                    |
|					  SEMESTER 3                                            |
|				      TAHUN 2012 / 2013                                         |
=================================================================================================
I. Contents / Isi CD
   - Folder src yang berisikan File VHD dan QSF dari BricksBreaker
   - Video BricksBreaker
   - Laporan Praktikum
   - Desain FSM
   - Dan tentunya, Readme File ini

---------------------------------------------------------------------------------------------------
II. Cara Penggunaan FPGA DE-1
   Control / Input:
   - 3 Push_Buttons
	* Push_Button[3] = Tombol Arah Kiri Papan
	* Push_Button[2] = Tombol Arah Kanan Papan
	* Push_Button[1] = Tombol Reset / Start Permainan
   - 1 Switch
	* SW[0] = Untuk mengatur kecepatan kotak / bola yang dipantulkan

----------------------------------------------------------------------------------------------------
III. Cara Kerja
    1. Lakukan kompilasi file src menggunakan ALTERA QUARTUS II 9.0
    2. Hubungkan dengan FPGA DE-1
    3. Pertama-tama, anda akan melihat tulisan "BRICK BREAKER" di layar (Homepage)
    4. Pada interface utama, anda akan melihat 9 bricks, 1 kotak / bola yang dipantulkan, papan
       pemantul, penunjuk skor, dan lampu state (menang / kalah)
    5. Gerakkan papan pemantul kearah kiri / kanan menggunakan Push_Button yang ada
       Anda dinyatakan kalah apabila kotak / bola berhasil melewati batas bawah papan pemantul
       Anda dinyatakan menang apabila kesembilan bricks / bata dilayar berhasil dihancurkan
    6. Untuk membuat permainan semakin menarik, ketika SW[0] diberi logika '0', maka kecepatan kotak
       / bola akan 2 kali lipat dibandingkan ketika SW[0] diberi logika '1'

----------------------------------------------------------------------------------------------------
IV. Lain-lain
	Terima kasih kepada semua orang yang telah membantu terselenggaranya praktikum sistem digital
	BricksBreaker version release 1.0 beta
	All Rights Reserved, 2012.
