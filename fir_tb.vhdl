library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use std.textio.all;
use IEEE.NUMERIC_STD.ALL;

entity fir_tb is
    Generic(INPUT_FILE_NAME  : string := "C:/Users/Mehmet Emin Akin/lab3/src/Filter_input.txt";
            OUTPUT_FILE_NAME : string := "C:/Users/Mehmet Emin Akin/lab3/src/Filter_output.txt";
            FILTER_TAPS  : integer := 19;
            INPUT_WIDTH  : integer := 16; 
            COEFF_WIDTH  : integer := 16;
            OUTPUT_WIDTH : integer := 16 );
end fir_tb;

architecture Behavioral of fir_tb is
    component fir is
        Generic (FILTER_TAPS  : integer := 19;
                 INPUT_WIDTH  : integer := 16; 
                 COEFF_WIDTH  : integer := 16;
                 OUTPUT_WIDTH : integer := 16 );
        Port (clk    : in STD_LOGIC;
              data_i : in STD_LOGIC_VECTOR (INPUT_WIDTH-1 downto 0);
              data_o : out STD_LOGIC_VECTOR (OUTPUT_WIDTH-1 downto 0) );
    end component;
    
    signal clk : std_logic := '0';
    constant clock_period  : time := 8.33 ns;
    
    signal int_input_s : integer := 0;
    signal data_in : signed(INPUT_WIDTH-1 downto 0) := (others=>'0');
    signal data_out : std_logic_vector(OUTPUT_WIDTH-1 downto 0) := (others=>'0');
begin

    Filter_inst: fir
    generic map (
        FILTER_TAPS  => FILTER_TAPS  ,
        INPUT_WIDTH  => INPUT_WIDTH  ,
        COEFF_WIDTH  => COEFF_WIDTH  ,
        OUTPUT_WIDTH => OUTPUT_WIDTH 
    )
    port map(
        clk    => clk,
        data_i => std_logic_vector(data_in),
        data_o => data_out 
    );
    
    process(clk)       
        file     input_file  : text is in INPUT_FILE_NAME;
        variable input_line  : line; 
        file     output_file : text is out OUTPUT_FILE_NAME;         
        variable output_line : line;    
        variable int_input_v : integer := 0;       
        variable good_v      : boolean;                
    begin        
        if rising_edge(clk) then
            if (not endfile(input_file)) then
                write(output_line, to_integer(signed(data_out)), left, 10);
                writeline(output_file, output_line);        
                readline(input_file, input_line);
                read(input_line, int_input_v, good_v);
                int_input_s <= int_input_v;
            else
                assert (false) report "Reading operation completed!" severity failure;
            end if;
            data_in <= shift_right(to_signed(int_input_s, data_in'length), 0);
        end if;
    end process;
    
    Clock_gen: process                                
    begin
        clk <= '0', '1' after clock_period/2;
        wait for clock_period; 
    end process;

end Behavioral;