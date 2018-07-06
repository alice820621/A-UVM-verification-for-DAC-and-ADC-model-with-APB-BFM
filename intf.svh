interface dac_intf(input reg PCLK,input reg PRESET);
    
    reg PSEL;
    reg PENABLE;
    reg PWRITE;
    reg [31:0] PWDATA;
    //reg [31:0] PRDATA;
    reg PREADY;
    reg PSLVERR;
    real vout;
    
    
    modport adc_dac(input PCLK, input PRESET, input PSEL, input PENABLE,
        input PWRITE, output PREADY, input PWDATA, output PSLVERR, output vout);


endinterface : dac_intf

interface dac1_intf(input reg PCLK,input reg PRESET);
    
    reg PSEL;
    reg PENABLE;
    reg PWRITE;
    reg [31:0] PWDATA;
    //reg [31:0] PRDATA;
    reg PREADY;
    reg PSLVERR;
    real vout;
    
    
    modport adc_dac(input PCLK, input PRESET, input PSEL, input PENABLE,
        input PWRITE, output PREADY, input PWDATA, output PSLVERR, output vout);


endinterface : dac1_intf


//module dac(input reg PCLK,input reg PRESET,
   // input reg PSEL,input reg PENABLE, input reg PWRITE,
  //  output reg PREADY, input reg [31:0] PWDATA, output reg PSLVERR,
  //  output real vout);
