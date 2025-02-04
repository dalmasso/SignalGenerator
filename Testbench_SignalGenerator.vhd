------------------------------------------------------------------------
-- Engineer:    Dalmasso Loic
-- Create Date: 30/01/2025
-- Module Name: SignalGenerator
-- Description:
--      Simple ROM-based Signal Generator Module with PWM. Selector allows to switch to several signal types:
--          - Sine
--          - Triangle
--          - Sawtooth
--          - Square
--      User specify the signal waveform accuracy (depth & size of ROM) in bits, the expected frequency output and a frequence error range in Hz.
--
-- Generics
--      sys_clock: System Input Clock Frequency (Hz)
--      waveform_addr_bits: ROM Address Bits length
--      waveform_data_bits: ROM Data Bits length
--		signal_output_freq: Signal Output Frequency (Hz)
--		signal_output_freq_error: Range of Signal Output Error Range (Hz)
-- Ports
--		Input 	-	i_sys_clock: System Input Clock
--		Input 	-	i_reset: Reset ('0': No Reset, '1': Reset)
--		Input 	-	i_waveform_select: Waveform Generator Type Selector ("00": Sine, "01": Triangle, "10": Sawtooth, "11": Square)
--		Output 	-	o_signal: Signal Ouput Value
------------------------------------------------------------------------

LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.NUMERIC_STD.ALL;

ENTITY Testbench_SignalGenerator is
END Testbench_SignalGenerator;

ARCHITECTURE Behavioral of Testbench_SignalGenerator is

COMPONENT SignalGenerator is

    GENERIC(
        sys_clock: INTEGER := 100_000_000;
        waveform_addr_bits: INTEGER range 1 to 30 := 8;
        waveform_data_bits: INTEGER range 1 to 31 := 8;
        signal_output_freq: INTEGER := 7;
        signal_output_freq_error: INTEGER := 1
    );
    
    PORT(
        i_sys_clock: IN STD_LOGIC;
        i_reset: IN STD_LOGIC;
        i_waveform_select: IN STD_LOGIC_VECTOR (1 downto 0);
        o_signal: OUT STD_LOGIC
    );

END COMPONENT;

signal clock: STD_LOGIC := '0';
signal reset: STD_LOGIC := '0';
signal waveform_select: STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
signal output_signal: STD_LOGIC := '0';

begin

-- Clock 100 MHz
clock <= not(clock) after 5 ns;

-- Reset
reset <= '1', '0' after 145 ns;

-- Waveform Select
waveform_select <= "00", "01" after 150 ms, "10" after 300 ms, "11" after 450 ms;

uut: SignalGenerator
    GENERIC map(
        sys_clock => 100_000_000,
        waveform_addr_bits => 8,
        waveform_data_bits => 8,
        signal_output_freq => 7,
        signal_output_freq_error => 1)

    PORT map(
        i_sys_clock => clock,
        i_reset => reset,
        i_waveform_select=> waveform_select,
        o_signal => output_signal);

end Behavioral;