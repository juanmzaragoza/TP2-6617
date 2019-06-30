----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/20/2019 04:52:45 PM
-- Design Name: 
-- Module Name: tile_number_calculator - Behavioral
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

entity tile_number_calculator is
    generic(
		AW: integer := 13 -- para una RAM con 2^AW posiciones
	);
    port ( clk : in std_logic;
           pixel_x: in std_logic_vector(9 downto 0);
           pixel_y : in std_logic_vector(9 downto 0);
           tile_number : out std_logic_vector(AW-1 downto 0));
end tile_number_calculator;

architecture Behavioral of tile_number_calculator is
    signal tile_number_aux: integer := 0;
begin

    process(clk)
	begin
		if rising_edge(clk) then
			tile_number_aux <= 80 * to_integer(unsigned(pixel_x(9 downto 3))) + to_integer(unsigned(pixel_y(9 downto 3))); -- divido por 8
		end if;
	end process;
	
	tile_number <= std_logic_vector(to_unsigned(tile_number_aux, tile_number'length));
	
end Behavioral;
