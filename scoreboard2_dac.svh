class DAC2_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(DAC2_scoreboard)
    
        uvm_tlm_analysis_fifo #(dac2_monitor_message) from_sender_dac2;
        uvm_tlm_analysis_fifo #(dac2_result_message) from_result_dac2;
    
        dac2_monitor_message my_dac2_msg;
        dac2_result_message my_dac2_rslt;
        reg [31:0] dac2_calculation, dac2_calculation_result;
        real dac2_solution, dac2_solution_result;
        //virtual dac1_intf dac2;
        
    function new(string name="dac2_scoreboard", uvm_component parent = null);
        super.new(name,parent);
    endfunction: new
    
    function void build_phase (uvm_phase phase);
        from_sender_dac2 = new ("from_sender_dac2", this);
        my_dac2_msg = new();
        from_result_dac2 = new ("from_result_dac2", this);
        my_dac2_rslt = new();
        
        //if (!uvm_config_db #(virtual dac1_intf)::get(null, "*", "vif", this.dac2)) begin
        //    `uvm_error("connect", "dac_intf not found")
        //end
    endfunction : build_phase
    
    task run_phase(uvm_phase phase);
        forever begin
        fork
            begin
            from_sender_dac2.get(my_dac2_msg);
                dac2_calculation = my_dac2_msg.PWDATA;
                dac2_solution = dac2_calculation/(2.0**32);
                if(my_dac2_msg.PSEL && my_dac2_msg.PENABLE && my_dac2_msg.PWRITE && my_dac2_msg.PREADY) begin
                        if (dac2_solution != my_dac2_msg.vout)begin
                            $display("DAC2 ERROR: The DAC output does not match.\n\t Expected: %g\n\t Got: %g", dac2_solution, my_dac2_msg.vout);
                        end
                        if (dac2_solution == my_dac2_msg.vout)begin
                            //$display("DAC2 Result matched: %g", my_dac2_msg.vout);
                        end
                end else if(my_dac2_msg.PREADY) begin
                    $display("DAC2 ERROR: PREADY Asserted without proper inputs: \n\t PSEL = %d\n\t PENABLE = %d\n\t PWRITE = %d", my_dac2_msg.PSEL, my_dac2_msg.PENABLE, my_dac2_msg.PWRITE);
                end else if((!my_dac2_msg.PREADY) && (dac2_solution != my_dac2_msg.vout))begin
                    $display("DAC2 ERROR: Output not latching");
                end
            end
            begin
            from_result_dac2.get(my_dac2_rslt);
                dac2_calculation_result = my_dac2_rslt.PWDATA;
                dac2_solution_result = dac2_calculation_result/(2.0**32);
                if(my_dac2_rslt.PREADY == 0 && my_dac2_rslt.PSEL == 1 && my_dac2_rslt.PENABLE == 1 &&   my_dac2_rslt.PWRITE == 1) begin
                   if(dac2_solution_result == my_dac2_rslt.vout) begin
                      $display("DAC2 ERROR: An output came with PREADY low and: \n\t PSEL = %d\n\t PENABLE = %d\n\t PWRITE = %d", my_dac2_rslt.PSEL, my_dac2_rslt.PENABLE, my_dac2_rslt.PWRITE);
                   end
                end
                if(my_dac2_rslt.PREADY == 0) begin
                    if(dac2_solution_result != my_dac2_rslt.vout) begin
                        $display("DAC2 ERROR: Output not latching");
                    end
                end
                
            end
        join_any
        end
        
    endtask : run_phase

endclass : DAC2_scoreboard

