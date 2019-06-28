----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/20/2019 03:07:39 PM
-- Design Name: 
-- Module Name: video_tile_RAM - Behavioral
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

entity video_tile_RAM is
    generic(
		AW: integer := 13; -- RAM con 2^AW posiciones
		DW: integer := 8
	);
	port(
		clk: in std_logic;
		write_enable: in std_logic;
		addr: in std_logic_vector(AW-1 downto 0);
		data_in: in std_logic_vector(DW-1 downto 0);
		reset_on_position: integer := 4799; -- al llegar a esta posicion, comienza a reescribirse
		data_out: out std_logic_vector(DW-1 downto 0)
	);
end video_tile_RAM;

architecture Behavioral of video_tile_RAM is
    type rom_type is array (0 to (2**AW)-1) of std_logic_vector(DW-1 downto 0);
    signal RAM: rom_type := (others=>(others=>'0'));
    signal actual_position, next_position: integer := 0;
begin
    
    setRegA: process (clk)
	begin
		if rising_edge(clk) then
		  -- Write to ram
		  if(write_enable = '1') then
            if next_position = reset_on_position then
                actual_position <= 0;
                RAM(actual_position) <= data_in;
                next_position <= actual_position + 1;
            else
                actual_position <= next_position;
                RAM(actual_position) <= data_in;
                next_position <= actual_position + 1;
		    end if;
		  end if;

		end if;
	end process;
    
	-- Read from it
    data_out <= RAM(to_integer(unsigned(addr)));
end Behavioral;
