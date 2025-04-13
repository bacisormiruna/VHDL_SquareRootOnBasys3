----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 01/12/2025 06:18:14 PM
-- Design Name: 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity sqrt is
    Port ( x : in  STD_LOGIC_VECTOR (31 downto 0);
           y : out  STD_LOGIC_VECTOR (31 downto 0));
end sqrt;

architecture Behavioral of sqrt is
    --pe scurt se expandeaza un vector care reprezinta mantisa intr-un vector in care o valoare este duplicata si adaugat un 0 dupa
    --x'left indică indicele maxim al vectorului x.
    function expandare(x: STD_LOGIC_VECTOR) return STD_LOGIC_VECTOR is
        variable numar : STD_LOGIC_VECTOR(2*x'left+1 downto 0);
    begin
        for i in x'left downto 0 loop --dublez bitul dupa care adaug un 0
            numar(2*i):=x(i);
            numar(2*i+1):='0';
        end loop;
        return numar;
    end;
begin
    process(x)
        --pentru numarul introdus
        variable signX : STD_LOGIC;
        variable mantisaX : STD_LOGIC_VECTOR (22 downto 0);
        variable exponentX : STD_LOGIC_VECTOR (7 downto 0);
        
        --pentru rezultatul extragerii radacinii patrate din x
        variable signY : STD_LOGIC;
        variable mantisaY : STD_LOGIC_VECTOR (22 downto 0);
        variable exponentY : STD_LOGIC_VECTOR (7 downto 0);

        variable registru : STD_LOGIC_VECTOR (51 downto 0);--se pastreaza rezultatul temporar
        variable rezPartial : STD_LOGIC_VECTOR (52 downto 0);--rezultatul partial
        variable normalizare: STD_LOGIC_VECTOR (25 downto 0); --. Aceasta este folosită pentru a stoca o combinație între mantisa și exponentul numărului de intrare
       
        variable pattern : STD_LOGIC_VECTOR (25 downto 0); --pattern pentru biti
        variable parteIntreaga : STD_LOGIC_VECTOR (51 downto 0); --partea intreaga a radacinii patrate
        
    begin
       --descompun numarul introdus in Semn + Exponent + Mantisa
       signX := x(31);
       mantisaX := x(22 downto 0);
       exponentX := x(30 downto 23);
       
       --pun semnul rezultatului 0 pentru ca nu pot avea din numere intregi radacina patrata negativa
       signY := '0';

        if (exponentX = "00000000") then --cazurile de nedeterminare
            exponentY := (others => '0');
            mantisaY := (others => '0');
        elsif (exponentX = "11111111") then --NaN
            exponentY := (others => '1');
            mantisaY := (others => '0');
        else
            if (exponentX(0) = '1') then --daca numarul este impar
                exponentY := '0' &exponentX(7 downto 1) + 64;
                normalizare := "01" &mantisaX & '0';
            else 
                exponentY := '0' &exponentX(7 downto 1) + 63; --daca numarul este par
                normalizare := '1' &mantisaX & "00";
        end if;
        
        --initializarea valorilor cu care urmeaza sa fac calculul propriu-zis prin operatii de bitwise
        parteIntreaga := (others => '0');
        pattern := "10" & x"000000"; 
        registru(51 downto 26) := normalizare; 
        registru(25 downto 0) := (others => '0');

        --calculul iterativ prin aproximari a radacinii patrate
        for i in 25 downto 0 loop
            --rezPartial reprezintă diferența dintre valorile curente din registru și o valoare calculată pe baza apropierii de radicalul pătrat.
            --rezPartial are o dimensiune mai mare decât registru, având 52 de biți (și un bit suplimentar la începutul său pentru a efectua operații de scădere corect). rezPartial este folosit pentru a 
            
            --determina dacă aproprierea radicalului pătrat este suficient de bună pentru a opri calculul sau dacă este necesară o nouă iterație.
             rezPartial := ('0' & registru) - ('0' & (parteIntreaga or expandare(pattern)));
             parteIntreaga := '0' & parteIntreaga(51 downto 1); 
             if (rezPartial(52) = '0') then
                 registru := rezPartial(51 downto 0);
                 parteIntreaga := parteIntreaga or expandare(pattern); 
             end if;
             pattern := '0' & pattern(25 downto 1);
        end loop;

        --impart rezultatul in partea intreaga si partea fractionara (mantisa)
        parteIntreaga(24 downto 2) := parteIntreaga(24 downto 2) + parteIntreaga(1);
        mantisaY := parteIntreaga(24 downto 2);
        end if;

        --la fel am rezultatul sub forma de format ieee 754 Semn + Exponent + Mantisa
        y(22 downto 0) <= mantisaY;
        y(30 downto 23) <= exponentY;
        y(31) <= signY;
    end process;
end Behavioral;

