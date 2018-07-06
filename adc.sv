//
// A simple adc on the apb bus
//


module adc(input reg PCLK,input reg PRESET,
    input reg PSEL,input reg PENABLE, input reg PWRITE,
    output reg PREADY, output reg [31:0] PRDATA, output reg PSLVERR,
    input real vin);
    
    reg [31:0] cv;
    
    always @(posedge(PCLK)) begin
        PREADY= #1 0;
        PRDATA=$random;
        
        if(PSEL && PENABLE && !PWRITE) begin // a read
            repeat($urandom_range(0,3)) begin
                PREADY= #1 0;
                @(posedge(PCLK)) ;
            end
            PREADY= #1 1;
            cv=(vin*(2**14));
            if (cv[31:14] != 0) begin
                PRDATA = #1 32'hFFFC_0000;
            end else begin
                PRDATA = #1 cv << 18;
            end
        end
    end
    
endmodule : adc

