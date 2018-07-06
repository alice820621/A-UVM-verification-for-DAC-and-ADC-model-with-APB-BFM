class ADC2_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(ADC2_scoreboard)
    
        reg [31:0] cv_test;
        reg [31:0] cv_test1;
        reg [31:0] test_PRDATA;
        reg [31:0] test_PRDATA1;
    
        uvm_tlm_analysis_fifo #(adc2_monitor_message) from_sender_adc2;
        uvm_tlm_analysis_fifo #(adc2_result_message) from_result_adc2;
    
        adc2_monitor_message my_adc2_msg;
        adc2_result_message my_adc2_rslt;

        
    function new(string name="dac1_scoreboard", uvm_component parent = null);
        super.new(name,parent);
    endfunction: new
    
    function void build_phase (uvm_phase phase);
        from_sender_adc2 = new ("from_sender_dac1", this);
        my_adc2_msg = new();
        from_result_adc2 = new ("from_result_dac1", this);
        my_adc2_rslt = new();

    endfunction : build_phase
    
    task run_phase(uvm_phase phase);
    
        forever begin
            fork
                begin
                    from_sender_adc2.get(my_adc2_msg);
                        if(my_adc2_msg.PSEL && my_adc2_msg.PENABLE && !my_adc2_msg.PWRITE) begin
                            cv_test=(my_adc2_msg.vin*(2**14));
                            if (cv_test[31:14] != 0) begin
                                test_PRDATA = #1 32'hFFFC_0000;
                            end else begin
                                test_PRDATA = #1 cv_test << 18;
                            end
                            if(my_adc2_msg.PRDATA == test_PRDATA)begin
                                //$display("adc2:\n\t Expected: %d\n\t Actual:   %d", test_PRDATA, my_adc2_msg.PRDATA);
                            end
                            if(my_adc2_msg.PRDATA != test_PRDATA)begin
                                $display("ADC2 ERROR: The ADC output does not match\n\t Expected: %d\n\t Actual:   %d", test_PRDATA, my_adc2_msg.PRDATA);
                            end
                        end else begin
                            $display("ADC2 ERROR: PREADY Asserted without proper inputs: \n\t PSEL = %d\n\t PENABLE = %d\n\t PWRITE = %d", my_adc2_msg.PSEL, my_adc2_msg.PENABLE, my_adc2_msg.PWRITE);
                        end
                end
                
                begin
                    from_result_adc2.get(my_adc2_rslt);
                        if(my_adc2_rslt.PREADY == 1)begin
                            if(my_adc2_rslt.PREADY == 0 && my_adc2_rslt.PSEL == 1 && my_adc2_rslt.PENABLE == 1 &&   my_adc2_rslt.PWRITE == 1) begin
                                cv_test1=(my_adc2_rslt.vin*(2**14));
                                if (cv_test1[31:14] != 0) begin
                                    test_PRDATA1 = #1 32'hFFFC_0000;
                                end else begin
                                    test_PRDATA1 = #1 cv_test1 << 18;
                                end
                                if(test_PRDATA1 == my_adc2_rslt.PRDATA) begin
                                    $display("ADC2 ERROR: An output came with PREADY low and: \n\t PSEL = %d\n\t PENABLE = %d\n\t PWRITE = %d", my_adc2_rslt.PSEL, my_adc2_rslt.PENABLE, my_adc2_rslt.PWRITE);
                                end
                            end
                        end 
                end
            join_any
        end
        
    endtask : run_phase

endclass : ADC2_scoreboard
