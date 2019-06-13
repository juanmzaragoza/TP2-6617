----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 26.09.2018 21:36:42
-- Design Name: 
-- Module Name: Prescaler - Behavioral
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
use IEEE.numeric_std.all;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Prescaler is
    Port ( clk_in : in STD_LOGIC;
           rst : in STD_LOGIC;
           N1 : in integer;
--           N1 : in std_logic_vector(3 downto 0);
           clk_1 : out STD_LOGIC);
end Prescaler;

architecture Behavioral of Prescaler is

signal salida : std_logic;

begin
    process (clk_in,rst)
    variable conteo : integer := 0;
    begin
    if (rst = '1') then
        conteo := 0;
    elsif (rising_edge (clk_in)) then
            conteo := conteo + 1;
            if (conteo = N1) then
                conteo := 0;
                salida <= '1';
            else
                salida <= '0';
            end if;
    end if;
end process;

clk_1 <= salida; 


end Behavioral;
