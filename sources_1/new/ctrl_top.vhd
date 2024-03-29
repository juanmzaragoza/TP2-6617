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
	
	
	component vga_ctrl is
	port(
		clk, rst: in std_logic;
		--sw: in std_logic_vector (2 downto 0);
		hsync , vsync : out std_logic; 
		rgb : out std_logic_vector(2 downto 0);
		pixel_x: out std_logic_vector(9 downto 0);
		pixel_y: out std_logic_vector(9 downto 0)
	);
	end component;

	
	component Prescaler is
    Port ( clk_in : in STD_LOGIC;
           rst : in STD_LOGIC;
           N1 : in integer;
--           N1 : in std_logic_vector(3 downto 0);
           clk_1 : out STD_LOGIC);
    end component;
	
	-- signals and constants
	constant SIZE_ADDRESS_RAM_WORD: integer := 13; -- porque tenemos una pantalla de 4800 tiles (8191 posicion de memoria total)
	constant SIZE_ADDRESS_ROM_WORD: integer := 10; -- 2^7 codigos ASCII x 2^3 filas por caracter
	constant SIZE_DATA_ROM_WORD: integer := 8; -- cada fila de cada caracter ocupa 8 bits
	constant SIZE_DATA_RAM_WORD: integer := 7; -- represento 2^7=128 ASCII codes
	
    signal rst_clk_rx: std_logic;
    
    -- rom signals
    signal ram_address: std_logic_vector(SIZE_ADDRESS_RAM_WORD-1 downto 0);
    signal row_char_addr: std_logic_vector(SIZE_ADDRESS_ROM_WORD-1 downto 0);
    signal line_address: std_logic_vector(SIZE_DATA_ROM_WORD-1 downto 0);
    signal line_font_ram: std_logic_vector(SIZE_DATA_RAM_WORD-1 downto 0);
    
    -- Between uart_rx and vga
	signal rx_data, char_data: std_logic_vector(7 downto 0); 	-- Data output of uart_rx
	signal rx_data_rdy, old_rx_data_rdy, enable_write_ram,clk_prescaler: std_logic;  				-- Data ready output of uart_rx
	
	-- VGA
	signal pixel_x, pixel_y: std_logic_vector(9 downto 0);
	
begin
		clk_prescalerr: prescaler
        port map(
           clk_in => clk_pin,
           rst => '0',
           N1 =>  5,
--           N1 : in std_logic_vector(3 downto 0);
           clk_1 => clk_prescaler
           );
           
	meta_harden_rst_i0: meta_harden
		port map(
			clk_dst 	=> clk_prescaler,
			rst_dst 	=> '0',    		-- No reset on the hardener for reset!
			signal_src 	=> rst_pin,
			signal_dst 	=> rst_clk_rx
		);
	
	-- (1) se genera el dato de UART
	uart_rx_i0: uart_rx
		generic map(
			CLOCK_RATE 	=> CLOCK_RATE,
			BAUD_RATE  	=> BAUD_RATE
		)
		port map(
			clk_rx     	=> clk_prescaler,
			rst_clk_rx 	=> rst_clk_rx,
	
			rxd_i      	=> rxd_pin,
			rxd_clk_rx 	=> open,
	
			rx_data_rdy	=> rx_data_rdy,
			rx_data    	=> rx_data,
			frm_err    	=> open
		);
    
    -- (2) guardo el dato en la memoria de video
    -- (5) buscamos en RAM con el valor del tile (cuadricula) que nos devuelve el ASCII que habia en esa posicion (line_font_ram)
    tile_RAM: video_tile_RAM
        generic map(
            AW =>       SIZE_ADDRESS_RAM_WORD, -- usar 2^13 = 8192 posiciones
            DW =>       SIZE_DATA_RAM_WORD
        )
        port map(
            clk                 => clk_prescaler,
            write_enable        => enable_write_ram, -- supongo que se pone en 1 cuando se recibio el dato => habilito RAM a escribir
            addr                => ram_address, -- direccion donde se encuentra el dato a buscar
            --TODO: descomentar esto y comentar la de abajo
            --data_in             => char_data(6 downto 0), -- se escribe este dato cuando cuando write_enable = 1
            data_in             => "1000010",
            reset_on_position   => 4799, -- al llegar a esta posicion, comienza a reescribirse
            data_out            => line_font_ram -- dato leido de la RAM de la posicion addr
        );
    
    -- (3) por otra parte, se generan los pixeles y la senal de sincronismo
    vga_ctrll:vga_ctrl
		port map(
			clk	=> clk_prescaler,
			rst	=> rst_pin,
			hsync => hsync_pin,
			vsync => vsync_pin,
			rgb => open,
			pixel_x => pixel_x,
			pixel_y => pixel_y
		);
    
    -- (4) con los pixeles generados, calculamos cual es el tile (cuadricula) al que pertenece el pixel_x y pixel_y
    -- devuelve una ram_address (0...4799) [memoria de video]
    tile_calculator: tile_number_calculator
        generic map(
            AW => SIZE_ADDRESS_RAM_WORD -- para una RAM con 2^AW posiciones
        )
        port map(
            clk         => clk_prescaler,
            pixel_x     => pixel_x,
            pixel_y     => pixel_y,
            tile_number => ram_address
        );
    
	-- direccion guardada en la RAM + posicion de la fila
	-- (6) con el codigo ASCII en los 7 bits mas significativos de [row_char_addr] obtengo la direccion de ese caracter en la ROM
	-- y con los 3 bits menos significativos obtenemos la fila del caracter en la ROM que los  tomamos  de  los  4  bits  menos 
    -- significativos la fila  del píxel
	--row_char_addr <= line_font_ram&pixel_y(2 downto 0);
	row_char_addr <= line_font_ram&pixel_y(2 downto 0);
	
	-- (7) obtenemos los 8 pixeles de la fila del caracter que queremos [line_address]
    ROM: font_ROM
	   generic map(
            AW =>       SIZE_ADDRESS_ROM_WORD, -- usar 2^10
            DW =>       SIZE_DATA_ROM_WORD
        )
        port map(
            addrIn  =>  row_char_addr,
            dataOut =>  line_address
        );
    
    -- (8) De estos  8 bits seleccionaremos el bit de la columna en que  estemos. Esta co lumna la obtendremos con los 3 bits menos 
    -- significativos del píxel de la columna [pixel_x]
    rgb <= (others => '1') when line_address(to_integer(unsigned(pixel_x(2 downto 0)))) = '1' 
            else "000";
            
	txd_pin<=rxd_pin;
	
	process(clk_prescaler)
	begin
		if rising_edge(clk_prescaler) then
			if rst_clk_rx = '1' then
			    enable_write_ram <= '0';
				old_rx_data_rdy <= '0';
				char_data       <= "00000000";
			else
				-- Capture the value of rx_data_rdy for edge detection
				old_rx_data_rdy <= rx_data_rdy;
				-- If rising edge of rx_data_rdy, capture rx_data
				if (rx_data_rdy = '1' and old_rx_data_rdy = '0') then
				    enable_write_ram <= '1';
					char_data <= rx_data;
				else
				    enable_write_ram <= '0';
				end if;
			end if;	-- if !rst
		end if;
	end process;

end Behavioral;
