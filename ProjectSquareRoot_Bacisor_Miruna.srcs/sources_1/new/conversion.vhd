----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/12/2025 06:56:47 PM
-- Design Name: 
-- Module Name: conversion - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

entity conversion is
    Port ( 
        n : in  STD_LOGIC_VECTOR(31 downto 0);  
        integer_part : out STD_LOGIC_VECTOR(7 downto 0);  
        fractional_part : out STD_LOGIC_VECTOR(22 downto 0)  
    );
end conversion;

architecture Behavioral of conversion is
    signal sign : STD_LOGIC;
    signal exponent : integer;
    signal mantisa : real;
    signal result : real;
    signal integer_part_val : integer;
    signal fractional_part_val : integer;
begin
    process(n)
        variable power_of_two : real; 
        variable i : integer;  
    begin
        sign <= n(31);
        exponent <= to_integer(unsigned(n(30 downto 23))) - 127;
        mantisa <= 0.0;
        for i in 0 to 22 loop
            power_of_two := 2.0 ** (-(i + 1)); 
            if (n(22 - i) = '1') then 
                mantisa <= mantisa + power_of_two;  
            end if;
        end loop;
        mantisa <= 1.0 + mantisa;  
        if sign = '1' then
            result <= -1.0 * mantisa * (2.0 ** exponent);
        else
            result <= mantisa * (2.0 ** exponent); 
        end if;
        integer_part_val <= integer(result); 
        fractional_part_val <= integer((result - real(integer_part_val)) * (2.0 ** 23));  
        integer_part <= std_logic_vector(to_unsigned(integer_part_val, 8));
        fractional_part <= std_logic_vector(to_unsigned(fractional_part_val, 23));
    end process;
end Behavioral;
