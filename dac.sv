//
// A simple dac on the apb bus
//


module dac(input reg PCLK,input reg PRESET,
    input reg PSEL,input reg PENABLE, input reg PWRITE,
    output reg PREADY, input reg [31:0] PWDATA, output reg PSLVERR,
    output real vout);
    real cv;
    
    always @(posedge(PCLK)) begin
       PREADY= #1 0;
       
       if(PSEL && PENABLE && PWRITE) begin // a read
            repeat($urandom_range(0,3)) begin   
                PREADY= #1 0;
                @(posedge(PCLK)) ;
            end
            PREADY= #1 1;
            cv=PWDATA;
            vout = cv/(2.0**32);
        end
    end
    
    
endmodule : dac
