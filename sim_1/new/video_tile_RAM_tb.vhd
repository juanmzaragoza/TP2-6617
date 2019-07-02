----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/29/2019 10:40:43 PM
-- Design Name: 
-- Module Name: video_tile_RAM_tb - Behavioral
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

entity video_tile_RAM_tb is
--  Port ( );
end video_tile_RAM_tb;

architecture Behavioral of video_tile_RAM_tb is
    
    signal clk_tb, enable_write_ram_tb: std_logic := '0';
    signal ram_address: std_logic_vector(13-1 downto 0) := (others => '0');
    signal read_data_out: std_logic_vector(7-1 downto 0);
    signal data_in: std_logic_vector(7-1 downto 0) := (others => '0');
    
    signal ii,jj: integer := 0;
    
begin
    
    clk_tb <= not clk_tb after 10 ns;
    enable_write_ram_tb <= not enable_write_ram_tb after 20 ns;
    
    dut: entity work.video_tile_RAM
        generic map(
            AW =>       13,
            DW =>       7
        )
        port map(
            clk                 => clk_tb,
            write_enable        => enable_write_ram_tb, -- supongo que se pone en 1 cuando se recibio el dato => habilito RAM a escribir
            addr                => ram_address, -- direccion donde se encuentra el dato a buscar
            data_in             => data_in,
            reset_on_position   => 4799, -- al llegar a esta posicion, comienza a reescribirse
            data_out            => read_data_out -- dato leido de la RAM de la posicion addr
        );
        
    process(clk_tb)
        variable i, j, count: integer := 0;
	begin
		if rising_edge(clk_tb) and enable_write_ram_tb = '1' then
			
			--if count = 4799 then -- cuento hasta 4799 para no pisar los datos
			 ram_address <= std_logic_vector(to_unsigned(j ,ram_address'length));
			 j := j + 1;
			 jj <= j;
			--else
			 data_in <= std_logic_vector(to_unsigned(i ,data_in'length));
			 if i = 127 then
			     i := 0;
			 else
			     i := i + 1;
			 end if;
			 ii <= i;
			 count := count + 1;
			--end if;
			
			
--			assert to_integer(unsigned(line_font_ram)) = to_integer(unsigned("1000010")) report
--				"Error: Salida de RAM = " & 
--				integer'image(to_integer(line_font_ram)) &
--				", Direccion de RAM = " &
--				integer'image(to_integer(ram_address))
--				severity warning;

		end if;
	end process;

end Behavioral;
