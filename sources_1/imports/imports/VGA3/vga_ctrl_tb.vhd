library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_ctrl_tb is
end vga_ctrl_tb;

architecture vga_ctrl_tb_arq of vga_ctrl_tb is

	signal clk_tb: std_logic := '0';
	signal rst_tb: std_logic := '1';
	signal sw_tb: std_logic_vector(2 downto 0) := "011";

	signal rgb_tb: std_logic_vector(2 downto 0);
	signal hsync_tb, vsync_tb: std_logic;
	
	signal pixel_x_tb, pixel_y_tb: std_logic_vector(9 downto 0) := (others => '0');


begin

	clk_tb <= not clk_tb after 10 ns;
	rst_tb <= '0' after 500 ns;
	
	dut: entity work.vga_ctrl
		port map(
			clk	=> clk_tb,
			rst	=> rst_tb,
			--sw	=> sw_tb,
			hsync => hsync_tb,
			vsync => vsync_tb,
			rgb => rgb_tb
			--pixel_x => pixel_x_tb,
			--pixel_y => pixel_y_tb
		);
		
	
	
end vga_ctrl_tb_arq;