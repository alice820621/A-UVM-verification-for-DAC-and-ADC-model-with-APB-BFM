class DAC_scoreboard1 extends uvm_scoreboard;
    `uvm_component_utils(DAC_scoreboard1)
    
        uvm_tlm_analysis_fifo #(dac1_monitor_message) from_sender_dac1;
        uvm_tlm_analysis_fifo #(dac1_result_message) from_result_dac1;
    
        dac1_monitor_message my_dac1_msg;
        dac1_result_message my_dac1_rslt;
        reg [31:0] dac1_calculation, dac1_calculation_result;
        real dac1_solution, dac1_solution_result;
        virtual dac_intf dac1;
        
    function new(string name="dac1_scoreboard", uvm_component parent = null);
        super.new(name,parent);
    endfunction: new
    
    function void build_phase (uvm_phase phase);
        from_sender_dac1 = new ("from_sender_dac1", this);
        my_dac1_msg = new();
        from_result_dac1 = new ("from_result_dac1", this);
        my_dac1_rslt = new();
        
                if (!uvm_config_db #(virtual dac_intf)::get(null, "*", "vif", this.dac1)) begin
            `uvm_error("connect", "dac_intf not found")
        end
    endfunction : build_phase
    
    task run_phase(uvm_phase phase);
        forever begin
        fork
            begin
            from_sender_dac1.get(my_dac1_msg);
                dac1_calculation = my_dac1_msg.PWDATA;
                dac1_solution = dac1_calculation/(2.0**32);
                if(my_dac1_msg.PSEL && my_dac1_msg.PENABLE && my_dac1_msg.PWRITE && my_dac1_msg.PREADY) begin
                        if (dac1_solution != my_dac1_msg.vout)begin
                            $display("DAC1 ERROR: The DAC output does not match.\n\t Expected: %g\n\t Got: %g", dac1_solution, my_dac1_msg.vout);
                        end
                        if (dac1_solution == my_dac1_msg.vout)begin
                            //$display("DAC1 Result matched: %g", my_dac1_msg.vout);
                        end
                end else if(my_dac1_msg.PREADY) begin
                    $display("DAC1 ERROR: PREADY Asserted without proper inputs: \n\t PSEL = %d\n\t PENABLE = %d\n\t PWRITE = %d", my_dac1_msg.PSEL, my_dac1_msg.PENABLE, my_dac1_msg.PWRITE);
                end else if((!my_dac1_msg.PREADY) && (dac1_solution != my_dac1_msg.vout)) begin
                    $display("DAC1 ERROR: Output not latching");
                end
            end
            begin
            from_result_dac1.get(my_dac1_rslt);
                dac1_calculation_result = my_dac1_rslt.PWDATA;
                dac1_solution_result = dac1_calculation_result/(2.0**32);
                if(my_dac1_rslt.PREADY == 0 && my_dac1_rslt.PSEL == 1 && my_dac1_rslt.PENABLE == 1 &&   my_dac1_rslt.PWRITE == 1) begin
                    if(dac1_solution_result == my_dac1_rslt.vout) begin
                        $display("DAC1 ERROR: An output came with PREADY low and: \n\t PSEL = %d\n\t PENABLE = %d\n\t PWRITE = %d", my_dac1_rslt.PSEL, my_dac1_rslt.PENABLE, my_dac1_rslt.PWRITE);
                    end
                end
                if(my_dac1_rslt.PREADY == 0) begin
                    if(dac1_solution_result != my_dac1_rslt.vout) begin
                        $display("DAC1 ERROR: Output not latching");
                    end
                end
            end
        join_any
        end
        
    endtask : run_phase

endclass : DAC_scoreboard1
