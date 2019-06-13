---------------------------------------------------------
--
-- Generador de las senales de sincronismo para VGA
-- 
--
--
---------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity vga_sync is
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
end vga_sync;

architecture vga_sync_arq of vga_sync is

	-- Parametros del sincronismo para VGA 640 x 480
	constant HD: integer := 640; 	-- area horizontal visible
	constant HF: integer:= 16 ; 	-- front porch horizontal
	constant HB: integer:= 48 ; 	-- back porch horizontal
	constant HR: integer:= 96 ; 	-- retorno horizonatal
	constant VD: integer := 480;	-- area vertical visible
	constant VF: integer:= 10; 		-- front porch vertical
	constant VB: integer := 33; 	-- back porch vertical
	constant VR: integer := 2; 		-- retorno vertical
	
	constant MAX_H_COUNT: integer := HD + HF + HB + HR - 1;
	constant MAX_V_COUNT: integer := VD + VF + VB + VR - 1;
	
	-- Contadores
	signal v_count : unsigned(9 downto 0) := (others => '0');
	signal h_count : unsigned(9 downto 0 ) := (others => '0');
	
	-- Senales de estado
--	signal h_end , v_end , pixel_tick: std_logic;
	signal pixel_tick: std_Logic := '0';
	
begin
	
	-- Tick de 25 MHz
	process(clk)
    begin
        if rising_edge(clk) then
            pixel_tick <= not pixel_tick;
        end if;
    end process;

	-- Contador del sincronismo horizontal (modulo 800)
	process(clk)
	begin
		if rising_edge(clk) then
			if pixel_tick = '1' then -- 25 MHz tick
				-- if h_end = '1' then
				if (h_count = MAX_H_COUNT) then
					h_count <= (others => '0');
				else
					h_count <= h_count + 1;
				end if ;
			end if;
		end if;
			
	end process;
	
	-- Contador del sincronismo vertical (modulo 525)
	process(clk)
	begin
		if rising_edge(clk) then
			if pixel_tick = '1' and (h_count = MAX_H_COUNT) then -- 25 MHz tick
				-- if (v_end = '1') then
				if (v_count = MAX_V_COUNT) then
					v_count <= (others => '0');
				else
					v_count <= v_count + 1;			
				end if;
			end if;
		end if;
			
	end process;

	-- Generacion de las senales de sincronismo
	hsync <= '1' when (h_count >= (HD + HF) and (h_count <= (HD + HF + HR - 1))) else '0';
	vsync <= '1' when (v_count >= (VD + VF) and (v_count <= (VD + VF + VR - 1))) else '0';
	
	-- Hablitacion de video
	vidon <= '1' when (h_count < HD) and (v_count < VD) else '0';
		
	-- Senales de salida
	pixel_x <= std_logic_vector(h_count);
	pixel_y <= std_logic_vector(v_count);
--	p_tick <= pixel_tick;
	
end vga_sync_arq;