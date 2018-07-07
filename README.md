# A-UVM-verification-for-DAC-and-ADC-model-with-APB-BFM
A UVM verification with a APB BFM (Bus functional model), connected to two write-only DAC and two read-only ADC slaves. The sequence generates addresses and allows the driver to tell the BFM which slave to choose. Subsequently four monitors and scoreboards record each slave’s test results.


- top.sv		top module, including test, sequence item, sequencer, and driver
- seq.svh		sequence
- bfm_env.svh		bus functional model as an environment
- intf.svh		dac interface
- adc_intf.svh		adc interface
- dac.sv		a given dac
- adc.sv		a given adc
- monitor1.svh		DAC1 monitor
- monitor2_dac.svh	DAC2 monitor
- monitor1_adc.svh	ADC1 monitor
- monitor2_adc.svh	ADC2 monitor
- scoreboard1.svh	DAC1 scoreboard
- scoreboard2_dac.svh	DAC2 scoreboard
- scoreboard1_adc.svh	ADC1 scoreboard
- scoreboard2_adc.svh	ADC2 scoreboard
