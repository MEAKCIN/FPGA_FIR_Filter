-- influenced from repositories by https://github.com/DHMarinov
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fir is
    Generic (FILTER_TAPS  : integer := 19;
             INPUT_WIDTH  : integer := 16; 
             COEFF_WIDTH  : integer := 16;
             OUTPUT_WIDTH : integer := 16 );
    Port (clk    : in STD_LOGIC;
          data_i : in STD_LOGIC_VECTOR (INPUT_WIDTH-1 downto 0);--represent until 2^16
          data_o : out STD_LOGIC_VECTOR (OUTPUT_WIDTH-1 downto 0) );--represent until 2^16
end fir;

architecture Behavioral of fir is

attribute use_dsp : string;
attribute use_dsp of Behavioral : architecture is "no";

constant MAC_WIDTH : integer := COEFF_WIDTH+INPUT_WIDTH;--32

type inputs is array(0 to FILTER_TAPS-1) of signed(INPUT_WIDTH-1 downto 0);--15 downto0
signal x : inputs := (others=>(others=>'0'));

type coeffs is array(0 to FILTER_TAPS-1) of signed(COEFF_WIDTH-1 downto 0);--15 downto0
signal b : coeffs :=(
    x"0552", x"05c4", x"062c", x"068a", x"06db", x"0720", x"0756",
    x"077e", x"0796", x"079e", x"0796", x"077e", x"0756", x"0720",
    x"06db", x"068a", x"062c", x"05c4", x"0552"
);

type results is array(0 to FILTER_TAPS-1) of signed(MAC_WIDTH-1 downto 0);--31 downto 0
signal y : results := (others=>(others=>'0'));

type temp_res is array(0 to FILTER_TAPS-1) of signed(INPUT_WIDTH + COEFF_WIDTH-1 downto 0);--31 downto 0
signal temp_result: temp_res := (others=>(others=>'0'));

begin  
--data_o <= std_logic_vector(y(0)(MAC_WIDTH-2 downto MAC_WIDTH-OUTPUT_WIDTH-1));   It is the previous code which is 30 downto 15 which means 16 bit 
--how ever two 16 bit sum can be 17 bit and multiplication is 16*2 32 bit but there is just 31 bit range which is a problem
    data_o <= std_logic_vector(y(0)(MAC_WIDTH-1 downto MAC_WIDTH-OUTPUT_WIDTH));   --31 downto 16 there are min 16 bit and max is the 32 bit     
    process(clk)
    begin
        if rising_edge(clk) then
            for i in 0 to FILTER_TAPS-1 loop
                x(i) <= signed(data_i); 
                --pipeline added
                if (i < FILTER_TAPS-1) then
                    temp_result(i)<= x(i)*b(i); --first we keep the temp data in temp result for pipeline
                    y(i) <= temp_result(i)+ y(i+1);--then we add it
                elsif (i = FILTER_TAPS-1) then
                    y(i)<= x(i)*b(i);
                end if;
            end loop;
        end if;
    end process;
end Behavioral;