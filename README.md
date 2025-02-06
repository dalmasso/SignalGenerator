# SignalGenerator
This module implements a simple ROM-based Signal Generator Module with PWM. Selector allows to switch to several signal types:
- Sine
- Triangle
- Sawtooth
- Square

<img width="452" alt="signgen" src="https://github.com/user-attachments/assets/e3585295-d75c-4e92-8336-e413496782c2" />

## Architecture Overview

<img width="1065" alt="signgendetail" src="https://github.com/user-attachments/assets/cfe47fce-e905-43ce-94ac-1318fbbd3d15" />

## Usage

User specifies the signal waveform accuracy (depth & size of ROM) in bits, the expected frequency output and a frequence error range in Hz.

## Signal Generator Pin Description

### Generics

| Name | Description |
| ---- | ----------- |
| sys_clock | System Input Clock Frequency (Hz) |
| waveform_addr_bits | ROM Address Bits length |
| waveform_data_bits | ROM Data Bits length |
| signal_output_freq | PWM Signal Output Frequency (Hz) |
| signal_output_freq_error | Range of PWM Signal Output Error Range (Hz) |

### Ports

| Name | Type | Description |
| ---- | ---- | ----------- |
| i_sys_clock | Input | System Input Clock |
| i_reset | Input | Reset ('0': No Reset, '1': Reset) |
| i_waveform_select | Input | Waveform Generator Type Selector ("00": Sine, "01": Triangle, "10": Sawtooth, "11": Square)|
| o_signal | Output | Signal Ouput Value |
