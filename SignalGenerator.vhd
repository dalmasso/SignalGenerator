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

ENTITY SignalGenerator is

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
    
END SignalGenerator;
    
ARCHITECTURE Behavioral of SignalGenerator is

------------------------------------------------------------------------
-- Component Declarations
------------------------------------------------------------------------
COMPONENT WaveformGenerator is

    GENERIC(
        rom_addr_bits: INTEGER range 1 to 30 := 8;
        rom_data_bits: INTEGER range 1 to 31 := 8
    );
    
    PORT(
        i_sys_clock: IN STD_LOGIC;
        i_waveform_select: IN STD_LOGIC_VECTOR(1 downto 0);
        i_waveform_step: IN UNSIGNED(rom_addr_bits-1 downto 0);
        o_waveform: OUT UNSIGNED(rom_data_bits-1 downto 0)
    );

END COMPONENT;

COMPONENT PwmController is

    GENERIC(
        sys_clock: INTEGER := 100_000_000;
        pwm_resolution: INTEGER := 8;
        signal_output_freq: INTEGER := 7;
        signal_output_freq_error: INTEGER := 1
    );
    
    PORT(
        i_sys_clock: IN STD_LOGIC;
        i_reset: IN STD_LOGIC;
        i_duty_cycle: IN UNSIGNED(pwm_resolution downto 0);
        o_next_duty_cycle_trigger: OUT STD_LOGIC;
        o_pwm: OUT STD_LOGIC
    );

END COMPONENT;

------------------------------------------------------------------------
-- Constant Declarations
------------------------------------------------------------------------
signal WAVEFORM_OUT_MAX: UNSIGNED(waveform_data_bits-1 downto 0) := (others => '1');

------------------------------------------------------------------------
-- Signal Declarations
------------------------------------------------------------------------
-- Waveform Step Counter (No initial value to allow ROM primitives mapping)
signal waveform_step_counter: UNSIGNED(waveform_addr_bits -1 downto 0);

-- Waveform Generator Output
signal waveform_out: UNSIGNED(waveform_data_bits-1 downto 0) := (others => '0');

-- PWM Duty Cycle
signal pwm_duty_cycle: UNSIGNED(waveform_data_bits downto 0) := (others => '0');

-- Next PWN Duty Cycle Trigger
signal next_duty_cycle_trigger: STD_LOGIC := '0';

------------------------------------------------------------------------
-- Module Implementation
------------------------------------------------------------------------
begin

	---------------------------
	-- Waveform Step Handler --
	---------------------------
	process(i_sys_clock)
	begin
		if rising_edge(i_sys_clock) then

			-- Reset Waveform Step Counter
			if (i_reset = '1') then
				waveform_step_counter <= (others => '0');

			-- Increment Waveform Step Counter (only when PWM Next Duty Cycle is Ready)
			elsif (next_duty_cycle_trigger = '1') then
                waveform_step_counter <= waveform_step_counter +1;
			end if;
		end if;
	end process;

	------------------------
	-- Waveform Generator --
	------------------------
    inst_waveform_generator: WaveformGenerator
        generic map (
            rom_addr_bits => waveform_addr_bits,
            rom_data_bits => waveform_data_bits)
        
        port map (
            i_sys_clock => i_sys_clock,
            i_waveform_select => i_waveform_select,
            i_waveform_step => waveform_step_counter,
            o_waveform => waveform_out);

	------------------------------
	-- PWM Duty Cycle Formatter --
	------------------------------
    process(i_sys_clock)
	begin
		if rising_edge(i_sys_clock) then

            -- Apply PWM Duty Cycle
            pwm_duty_cycle <= '0' & waveform_out;

			-- 1-Bit Waveform Generator Output Extender
            if (waveform_out = WAVEFORM_OUT_MAX) then
                pwm_duty_cycle(waveform_data_bits) <= '1';
            end if;
		end if;
	end process;

	--------------------
	-- PWM Controller --
	--------------------
    inst_pwm_controller: PwmController
        generic map (
            sys_clock => sys_clock,
            pwm_resolution => waveform_data_bits,
            signal_output_freq => signal_output_freq,
            signal_output_freq_error => signal_output_freq_error)
        
        PORT map(
            i_sys_clock => i_sys_clock,
            i_reset => i_reset,
            i_duty_cycle=> pwm_duty_cycle,
            o_next_duty_cycle_trigger => next_duty_cycle_trigger,
            o_pwm => o_signal);

end Behavioral;