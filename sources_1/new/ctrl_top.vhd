----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 06/20/2019 02:18:13 PM
-- Design Name: 
-- Module Name: ctrl_top - Behavioral
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

entity ctrl_top is
    generic(
        BAUD_RATE: integer := 115200;   
        CLOCK_RATE: integer := 50E6
    );
    port(
        -- inputs
		clk_pin, rst_pin:         in std_logic;
		rxd_pin:                  in std_logic; 		-- Uart input
		-- outputs
		txd_pin:                  out std_logic; 		-- Uart output
		hsync_pin , vsync_pin :   out std_logic; 
		rgb :                     out std_logic_vector(2 downto 0)
	);
end ctrl_top;

architecture Behavioral of ctrl_top is

    component meta_harden is
		port(
			clk_dst: 	in std_logic;	-- Destination clock
			rst_dst: 	in std_logic;	-- Reset - synchronous to destination clock
			signal_src: in std_logic;	-- Asynchronous signal to be synchronized
			signal_dst: out std_logic	-- Synchronized signal
		);
	end component;
	
	component uart_rx is
		generic(
			BAUD_RATE: integer := 115200; 	-- Baud rate
			CLOCK_RATE: integer := 50E6
		);

		port(
			-- Write side inputs
			clk_rx: in std_logic;       				-- Clock input
			rst_clk_rx: in std_logic;   				-- Active HIGH reset - synchronous to clk_rx
							
			rxd_i: in std_logic;        				-- RS232 RXD pin - Directly from pad
			rxd_clk_rx: out std_logic;					-- RXD pin after synchronization to clk_rx
		
			rx_data: out std_logic_vector(7 downto 0);	-- 8 bit data output
														--  - valid when rx_data_rdy is asserted
			rx_data_rdy: out std_logic;  				-- Ready signal for rx_data
			frm_err: out std_logic       				-- The STOP bit was not detected	
		);
	end component;
	
	component font_ROM is
        generic(
            AW: integer := 11; -- usar 2^10
            DW: integer := 8
        );
        port(
            addrIn: in std_logic_vector(AW-1 downto 0);
            dataOut: out std_logic_vector(DW-1 downto 0)
        );
    end component;
    
    component video_tile_RAM is
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
    end component;
    
    component tile_number_calculator is
        generic(
            AW: integer := 13 -- para una RAM con 2^AW posiciones
        );
        port ( clk : in std_logic;
               pixel_x: in std_logic_vector(9 downto 0);
               pixel_y : in std_logic_vector(9 downto 0);
               tile_number : out std_logic_vector(AW-1 downto 0));
    end component;
	
	
	-- signals and constants
	constant SIZE_ADDRESS_RAM_WORD: integer := 13; -- porque tenemos una pantalla de 4800 tiles (8191 posicion de memoria total)
	constant SIZE_ADDRESS_ROM_WORD: integer := 10; -- 2^7 codigos ASCII x 2^3 filas por caracter
	constant SIZE_DATA_ROM_WORD, SIZE_DATA_RAM_WORD: integer := 8; -- cada fila de cada caracter ocupa 8 bits
	
    signal rst_clk_rx: std_logic;
    
    -- rom signals
    signal ram_address: std_logic_vector(SIZE_ADDRESS_RAM_WORD-1 downto 0);
    signal row_char_addr: std_logic_vector(SIZE_ADDRESS_ROM_WORD-1 downto 0);
    signal line_address, line_font_ram: std_logic_vector(SIZE_DATA_ROM_WORD-1 downto 0);
    
    -- Between uart_rx and vga
	signal rx_data, char_data: std_logic_vector(7 downto 0); 	-- Data output of uart_rx
	signal rx_data_rdy, old_rx_data_rdy: std_logic;  				-- Data ready output of uart_rx
	
	-- VGA
	signal pixel_x, pixel_y: std_logic_vector(9 downto 0);
	
begin
    
    vga_ctrl: entity work.vga_ctrl
		port map(
			clk	=> clk_pin,
			rst	=> rst_pin,
			hsync => hsync_pin,
			vsync => vsync_pin,
			rgb => rgb,
			pixel_x => pixel_x,
			pixel_y => pixel_y
		);
	
	meta_harden_rst_i0: meta_harden
		port map(
			clk_dst 	=> clk_pin,
			rst_dst 	=> '0',    		-- No reset on the hardener for reset!
			signal_src 	=> rst_pin,
			signal_dst 	=> rst_clk_rx
		);
		
	uart_rx_i0: uart_rx
		generic map(
			CLOCK_RATE 	=> CLOCK_RATE,
			BAUD_RATE  	=> BAUD_RATE
		)
		port map(
			clk_rx     	=> clk_pin,
			rst_clk_rx 	=> rst_clk_rx,
	
			rxd_i      	=> rxd_pin,
			rxd_clk_rx 	=> open,
	
			rx_data_rdy	=> rx_data_rdy,
			rx_data    	=> rx_data,
			frm_err    	=> open
		);
    
    tile_calculator: tile_number_calculator
        generic map(
            AW => SIZE_ADDRESS_RAM_WORD -- para una RAM con 2^AW posiciones
        )
        port map(
            clk         => clk_pin,
            pixel_x     => pixel_x,
            pixel_y     => pixel_y,
            tile_number => ram_address
        );
        
    tile_RAM: video_tile_RAM
        generic map(
            AW =>       SIZE_ADDRESS_RAM_WORD, -- usar 2^13 = 8192 posiciones
            DW =>       SIZE_DATA_RAM_WORD
        )
        port map(
            clk                 => clk_pin,
            write_enable        => rx_data_rdy, -- supongo que se pone en 1 cuando se recibio el dato => habilito RAM a escribir
            addr                => ram_address, -- direccion donde se encuentra el dato a buscar
            data_in             => rx_data, -- se escribe este dato cuando cuando write_enable = 1
            reset_on_position   => 4799, -- al llegar a esta posicion, comienza a reescribirse
            data_out            => line_font_ram -- dato leido de la RAM de la posicion addr
        );
    
	-- direccion guardada en la RAM + posicion de la fila
	row_char_addr <= line_font_ram&pixel_y(2 downto 0);
	
    ROM: font_ROM
	   generic map(
            AW =>       SIZE_ADDRESS_ROM_WORD, -- usar 2^10
            DW =>       SIZE_DATA_ROM_WORD
        )
        port map(
            addrIn  =>  row_char_addr,
            dataOut =>  line_address
        );
    
    rgb <= (others => '1') when line_address(to_integer(unsigned(pixel_x(2 downto 0)))) = '1' 
            else (others => '0');
            
	txd_pin<=rxd_pin;
	
	process(clk_pin)
	begin
		if rising_edge(clk_pin) then
			if rst_clk_rx = '1' then
				old_rx_data_rdy <= '0';
				char_data       <= "00000000";
			else
				-- Capture the value of rx_data_rdy for edge detection
				old_rx_data_rdy <= rx_data_rdy;
				-- If rising edge of rx_data_rdy, capture rx_data
				if (rx_data_rdy = '1' and old_rx_data_rdy = '0') then
					char_data <= rx_data;	
				end if;
			end if;	-- if !rst
		end if;
	end process;

end Behavioral;
