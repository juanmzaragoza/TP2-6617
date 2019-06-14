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
		rgb : out std_logic_vector(2 downto 0)
		--pixel_x: out std_logic_vector(9 downto 0);
		--pixel_y: out std_logic_vector(9 downto 0)
	);

end vga_ctrl;

architecture vga_ctrl_arch of vga_ctrl is

	signal rgb_reg: std_logic_vector(2 downto 0);
	signal video_on, clk_prescaler: std_logic;
	signal pixel_x_aux, pixel_y_aux: std_logic_vector(9 downto 0);
	signal pixel_x,pixel_y: std_logic_vector(9 downto 0);
	signal sw:  std_logic_vector (2 downto 0) := "111";

begin

	-- instanciacion del controlador VGA
	vga_sync_unit: entity work.vga_sync
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

	pixeles: entity work.gen_pixels
		port map(
			clk		=> clk_prescaler,
			rst	    => rst,
			sw		=> sw,
			pixel_x	=> pixel_x_aux,
			pixel_y	=> pixel_y_aux,
			ena		=> video_on,
			rgb		=> rgb
		);
		
	prescaler: entity work.prescaler
        port map(
           clk_in => clk,
           rst => '0',
           N1 =>  5,
--           N1 : in std_logic_vector(3 downto 0);
           clk_1 => clk_prescaler
        
        );
		
	pixel_x <= pixel_x_aux;
	pixel_y <= pixel_y_aux;

end vga_ctrl_arch;