---------------------------------------------------------
--
-- Controlador de VGA
-- Version actualizada a 07/06/2016
--
-- Modulos:
--    vga_sync
--    gen_pixels
---
---------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_ctrl is
	port(
		clk, rst: in std_logic;
		--sw: in std_logic_vector (2 downto 0);
		hsync , vsync : out std_logic; 
		rgb : out std_logic_vector(2 downto 0);
		pixel_x: out std_logic_vector(9 downto 0);
		pixel_y: out std_logic_vector(9 downto 0)
	);

end vga_ctrl;

architecture vga_ctrl_arch of vga_ctrl is

component gen_pixels is
	port(
		clk, rst: in std_logic;
		sw: in std_logic_vector (2 downto 0);
		pixel_x, pixel_y : in std_logic_vector (9 downto 0);
		ena: in std_logic;
		rgb : out std_logic_vector(2 downto 0)
	);
	
end component;


component Prescaler is
	port(
	     clk_in : in STD_LOGIC;
         rst : in STD_LOGIC;
         N1 : in integer;
         clk_1 : out STD_LOGIC
		);
	end component;
	

component vga_sync is
	port (
		clk		: in std_logic;						-- reloj de 50 MHz
		rst		: in std_logic;						-- reset del sistema
		hsync	: out std_logic;					-- sincronismo horizontal
		vsync 	: out std_logic;					-- sincronismo vertical
		vidon 	: out std_logic;					-- habilitacion de salda de video
--		p_tick	: out std_logic;					-- 25 MHz ticks
		pixel_x : out std_logic_vector(9 downto 0);	-- posicion horizontal del pixel
		pixel_y : out std_logic_vector(9 downto 0)	-- posicion vertical del pixel
	);
end component;



--	signal rgb_reg: std_logic_vector(2 downto 0); -- no se usa
	signal video_on, clk_prescaler: std_logic;
	signal pixel_x_aux, pixel_y_aux: std_logic_vector(9 downto 0);
	signal sw:  std_logic_vector (2 downto 0) := "111";

begin

	-- instanciacion del controlador VGA
	vga_sync_unit: vga_sync
		port map(
			clk 	=> clk_prescaler,
			rst 	=> rst,
			hsync 	=> hsync,
			vsync 	=> vsync,
			vidon	=> video_on,
--			p_tick 	=> open,
			pixel_x => pixel_x_aux,
			pixel_y => pixel_y_aux
		);

	pixeles: gen_pixels
		port map(
			clk		=> clk_prescaler,
			rst	    => rst,
			sw		=> sw,
			pixel_x	=> pixel_x_aux,
			pixel_y	=> pixel_y_aux,
			ena		=> video_on,
			rgb		=> rgb
		);		
		
		
	prescalerr: Prescaler
        port map(
           clk_in => clk,
           rst => '0',
           N1 =>  5,
--         N1 : in std_logic_vector(3 downto 0);
           clk_1 => clk_prescaler
        
        );
		
	pixel_x <= pixel_x_aux;
	pixel_y <= pixel_y_aux;

end vga_ctrl_arch;