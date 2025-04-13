---------------------------------------------------------------------------------- 
-- 
-- Create Date: 01/12/2025 06:18:14 PM
-- Design Name: SQRT
-- Module Name: tb_sqrt - Behavioral
-- Project Name: Square Root Extraction
-- Target Devices: 
-- Tool Versions: 
-- Description: Extrage radacina patrata dintr-un numar in virgula flotanta si o converteste intr-un numar zecimal
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity tb_conv is
end tb_conv;

architecture Behavioral of tb_conv is
    component sqrt
        Port ( x : in  STD_LOGIC_VECTOR (31 downto 0);
               y : out  STD_LOGIC_VECTOR (31 downto 0));
    end component;

    signal x : STD_LOGIC_VECTOR (31 downto 0) := (others => '0');
    signal y : STD_LOGIC_VECTOR (31 downto 0);

    signal clk : STD_LOGIC := '0';
    signal rst : STD_LOGIC := '0';
   
   --semnale pentru rezultat
    signal sign : STD_LOGIC; 
    signal integer_part : STD_LOGIC_VECTOR(7 downto 0);  
    signal fractional_part : STD_LOGIC_VECTOR(22 downto 0);
    
    --semnale pentru numarul introdus sa il vad in format zecimal
    signal signX : STD_LOGIC; 
    signal integer_partX : STD_LOGIC_VECTOR(7 downto 0);  
    signal fractional_partX : STD_LOGIC_VECTOR(22 downto 0);
    
    signal exp_bias: STD_LOGIC_VECTOR(7 downto 0) := "01111111"; 
begin
    uut: sqrt port map (
        x => x,
        y => y
    );
    
    clk_process: process
    begin
        clk <= not clk after 10 ns;  
        wait for 10 ns;
    end process;

    simulare_process: process
    begin
        rst <= '1';
        wait for 20 ns;
        rst <= '0';
        wait for 20 ns; 
        
        x <= x"421C0000"; 
        --41BCCCCD --23.6
        --"41400000"; --12
        --"42200000"; --40 -> r = 6.3245553
        --"42C80000"; --100
        --"41C80000"; --25.0
        --"421C0000";  -- 39.0 -> r = 6.244998e+00
        --"42140000";  -- 37.0 -> r = 6.08276253
        wait for 40 ns;
        wait;
    end process;
    
    --conversia din format IEEE 754 pentru numarul introdus
    conversion_processX: process(x)
        variable power_of_twoX : real; 
        variable iX : integer; 
        variable resultX : real;  
        variable mantisaX: real;
        variable exponent_valueX : integer;
        
        variable integer_part_valX : integer;
        variable fractional_part_valX : integer;
    begin
        signX <= x(31);
        exponent_valueX := to_integer(unsigned(x(30 downto 23))) - to_integer(unsigned(exp_bias));  
        report "Exponentul numarului introdus are valoarea: " & integer'image(exponent_valueX);

        fractional_partX <= x(22 downto 0);

        mantisaX := 0.0; 
        for i in 0 to 22 loop
            power_of_twoX := 2.0**(-(i+1)); 
            if (x(22-i) = '1') then 
                mantisaX := mantisaX + power_of_twoX;  
            end if;
        end loop;
        
        mantisaX := 1.0 + mantisaX;

        if signX = '1' then
            resultX := -1.0 * mantisaX * (2.0**exponent_valueX);
        else
            resultX := mantisaX * (2.0**exponent_valueX); 
        end if;
        report "--------------------------";
        report real'image(resultX);
        integer_part_valX := integer(resultX); 
        fractional_part_valX := integer((resultX - real(integer_part_valX)) * 100.0);
        report "Partea intreaga a numarului introdus este " & integer'image(integer_part_valX);
        report "Partea fractionara a numarului introdus este " & integer'image(fractional_part_valX);
        report "--------------------------"; 
        integer_partX <= std_logic_vector(to_unsigned(integer_part_valX, 8));  
        fractional_partX <= std_logic_vector(to_unsigned(fractional_part_valX, 23));

    end process;
    
    --conversia din format IEEE 754 pentru rezultatul exragerii radacinii patrate
    conversion_process: process(y)
        variable power_of_two : real; 
        variable i : integer; 
        variable result : real;  
        variable mantisa: real;
        variable exponent_value : integer;
        
        variable integer_part_val : integer;
        variable fractional_part_val : integer;
    begin
        sign <= y(31);
        exponent_value := to_integer(unsigned(y(30 downto 23))) - to_integer(unsigned(exp_bias));  -- Exponentul
        report "Exponentul are valoarea: " & integer'image(exponent_value);

        fractional_part <= y(22 downto 0);

        mantisa := 0.0; 

        for i in 0 to 22 loop
            power_of_two := 2.0**(-(i+1)); 
            if (y(22-i) = '1') then 
                mantisa := mantisa + power_of_two;  
            end if;
        end loop;
        
        mantisa := 1.0 + mantisa;
         if sign = '1' then
            result := -1.0 * mantisa * (2.0**exponent_value);
        else
            result := mantisa * (2.0**exponent_value); 
        end if;
        report real'image(result);
        integer_part_val := integer(result); 
        fractional_part_val := integer((result - real(integer_part_val)) * 100.0);
        report "Partea intreaga este " & integer'image(integer_part_val);
        report "Partea fractionara este " & integer'image(fractional_part_val);
        
        integer_part <= std_logic_vector(to_unsigned(integer_part_val, 8));  -- Partea întreagă
        fractional_part <= std_logic_vector(to_unsigned(fractional_part_val, 23));

    end process;
end Behavioral;
