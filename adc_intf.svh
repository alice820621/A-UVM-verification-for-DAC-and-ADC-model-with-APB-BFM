interface adc_intf(input reg PCLK,input reg PRESET);
    
    reg PSEL;
    reg PENABLE;
    reg PWRITE;
    //reg [31:0] PWDATA;
    reg [31:0] PRDATA;
    reg PREADY;
    reg PSLVERR;
    real vin;
    
    
    modport adc_dac(input PCLK, input PRESET, input PSEL, input PENABLE,
        input PWRITE, output PREADY, output PRDATA, output PSLVERR, input vin);


endinterface : adc_intf


interface adc1_intf(input reg PCLK,input reg PRESET);
    
    reg PSEL;
    reg PENABLE;
    reg PWRITE;
    //reg [31:0] PWDATA;
    reg [31:0] PRDATA;
    reg PREADY;
    reg PSLVERR;
    real vin;
    
    
    modport adc_dac(input PCLK, input PRESET, input PSEL, input PENABLE,
        input PWRITE, output PREADY, output PRDATA, output PSLVERR, input vin);


endinterface : adc1_intf
