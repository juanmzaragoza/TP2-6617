----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/29/2019 09:42:28 PM
-- Design Name: 
-- Module Name: tile_calculator_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity tile_calculator_tb is
--  Port ( );
end tile_calculator_tb;

architecture Behavioral of tile_calculator_tb is

    signal clk_tb: std_logic := '0';
    signal pixel_x, pixel_y: std_logic_vector(9 downto 0) := (others => '0');
    signal tile_number: std_logic_vector(12 downto 0);
    signal ii,jj: integer := 0;
    
begin

    clk_tb <= not clk_tb after 10 ns;
    
    dut: entity work.tile_number_calculator
        generic map(
            AW => 13
        )
		port map(
			clk	=> clk_tb,
            pixel_x => pixel_x,
            pixel_y => pixel_y,
            tile_number => tile_number
		);
		
    process(clk_tb)
        variable i,j: integer := 0;
	begin
		if rising_edge(clk_tb) then
		    
			
--			assert (j+i) = to_integer(unsigned(tile_number)) report
--				"Error: Pixel x = " & 
--				integer'image(to_integer(pixel_x)) &
--				", Pixel y = " &
--				integer'image(to_integer(pixel_y)) &
--				", Tile number = " &
--				integer'image(to_integer(tile_number))
--				severity warning;
			
			j := j + 1;
			if j = 640 then
			 i := i + 1;
			 pixel_x <= std_logic_vector(to_unsigned(i ,pixel_x'length));
			 j := 0;
			elsif i = 480 then
			 assert false
                report "simulation ended"
                severity failure;
            else
			 pixel_y <= std_logic_vector(to_unsigned(j,pixel_y'length));
			end if;
			
			ii <= i;
			jj <= j;
			
		end if;
	end process;

end Behavioral;
