`timescale 1us/1ns

`include "dac.sv"
`include "intf.svh"
`include "adc.sv"
`include "adc_intf.svh"

package APB_BFM;

import uvm_pkg::*;

class sq_msg extends uvm_sequence_item;
    `uvm_object_utils(sq_msg)
    
    reg [32] addr;
    reg [32] w_data;
    reg write;
    real vin;
    
    
    function new(string name = "sequence message");
        super.new(name);
    endfunction: new
    
        //Clone method
    function copy(sq_msg mymes);
        this.addr = mymes.addr;
        this.w_data = mymes.w_data;
        this.write = mymes.write;
        this.vin = mymes.vin;
    endfunction : copy
    
    virtual function sq_msg clone();
        sq_msg new_message;
        new_message = new();
        new_message.copy(this);
        return (new_message);
    endfunction : clone
    
endclass : sq_msg 

`include "seq.svh"
`include "bfm_env.svh"

class sqr extends uvm_sequencer #(sq_msg);
    `uvm_component_utils(sqr)
    
    function new(string name = "sequencer", uvm_component parent = null);
        super.new(name,parent);
    endfunction : new
    
endclass : sqr 

class driver extends uvm_driver #(sq_msg);
    `uvm_component_utils(driver)
    
    uvm_analysis_port #(sq_msg) to_bfm;
    sq_msg BFM_message;
    virtual adc_intf adc1;
    virtual adc1_intf adc2;
    virtual dac_intf dac1;
    virtual dac1_intf dac2;
    
    function new(string name = "my-driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new
    
    function void build_phase (uvm_phase phase);
        to_bfm = new("to_bfm", this);
        BFM_message = new();
    endfunction : build_phase
    
    function void connect_phase(uvm_phase phase);
        if (!uvm_config_db #(virtual adc_intf)::get(null, "*", "vif", this.adc1)) begin
            `uvm_error("connect", "vend_intf not found")
        end
        if (!uvm_config_db #(virtual adc1_intf)::get(null, "*", "vif", this.adc2)) begin
            `uvm_error("connect", "vend_intf not found")
        end
         if (!uvm_config_db #(virtual dac_intf)::get(null, "*", "vif", this.dac1)) begin
            `uvm_error("connect", "dac_intf not found")
        end
        if (!uvm_config_db #(virtual dac1_intf)::get(null, "*", "vif", this.dac2)) begin
            `uvm_error("connect", "dac_intf not found")
        end
        //Want a FIFO into the BFM
    endfunction : connect_phase;
    
    task run_phase(uvm_phase phase);
        repeat(5) @(posedge(dac1.PCLK), posedge(adc1.PCLK)) #1;
        forever begin
            
            seq_item_port.get_next_item(BFM_message);

            if(BFM_message.addr == 32'h0000002)begin
                adc1.vin <= BFM_message.vin;
            end
            else if(BFM_message.addr == 32'h0000003)begin
                adc2.vin <= BFM_message.vin;
            end
            @(posedge(dac1.PCLK),posedge(adc1.PCLK));
            to_bfm.write(BFM_message);
            $cast(BFM_message, BFM_message.clone());
            seq_item_port.item_done();
            repeat(20) @(posedge(dac1.PCLK), posedge(adc1.PCLK));
        end
    endtask : run_phase
    
endclass : driver
    

class my_test extends uvm_test;
    `uvm_component_utils(my_test);
    
    driver d1;
    sqr seq1;
    BFM_Sequence t0;
    bfm bfm_env;
    
    function new(string name ="myBFM_test", uvm_component parent = null);
        super.new(name,parent);
    endfunction : new
    
    function void build_phase(uvm_phase phase);
        d1 = driver::type_id::create("driver1", this);
        seq1 = sqr::type_id::create("sequencer1", this);
        bfm_env = bfm::type_id::create("my_bfm", this);
    endfunction : build_phase
    
    function void connect_phase(uvm_phase phase);
        d1.seq_item_port.connect(seq1.seq_item_export);
        d1.to_bfm.connect(bfm_env.from_sender.analysis_export);
    endfunction : connect_phase
    
    task run_phase(uvm_phase phase);
        phase.raise_objection(this, "starting");
            t0 = BFM_Sequence::type_id::create("the test");
            t0.start(seq1);
        phase.drop_objection(this, "done");
    endtask : run_phase 

    
endclass : my_test

endpackage : APB_BFM

import uvm_pkg::*;

module top();

reg clk,rst;
//vend_intf vendx(clk,rst);
dac_intf dac1(clk,rst);
dac1_intf dac2(clk,rst);
adc_intf adc1(clk,rst);
adc1_intf adc2(clk,rst);

initial begin
    clk=0;
    rst=1;
    #5;
    rst = 0;
    repeat(1000000) begin
        #5 clk=1;
        #5 clk=0;
    end
    $display("\n\n\nRan out of clocks\n\n\n");
    $finish;
end

initial begin
    //uvm_config_db #(virtual vend_intf)::set(null, "*", "vif" , vendx);
    uvm_config_db #(virtual dac_intf)::set(null, "*", "vif" , dac1);
    uvm_config_db #(virtual dac1_intf)::set(null, "*", "vif" , dac2);
    uvm_config_db #(virtual adc_intf)::set(null, "*", "vif" , adc1);
    uvm_config_db #(virtual adc1_intf)::set(null, "*", "vif" , adc2);

    run_test("my_test");
end

//vend v(vendx.clk,vendx.reset,vendx.detect_5 
    //,vendx.detect_10 ,vendx.detect_25 ,vendx.amount 
   // ,vendx.buy ,vendx.return_coins 
    //,vendx.empty_5 ,vendx.empty_10 ,vendx.empty_25 
   // ,vendx.ok ,vendx.return_5 
   // ,vendx.return_10 ,vendx.return_25);
adc a_1(adc1.PCLK, adc1.PRESET, adc1.PSEL, adc1.PENABLE, adc1.PWRITE, adc1.PREADY, adc1.PRDATA, adc1.PSLVERR, adc1.vin);

adc a_2(adc2.PCLK, adc2.PRESET, adc2.PSEL, adc2.PENABLE, adc2.PWRITE, adc2.PREADY, adc2.PRDATA, adc2.PSLVERR, adc2.vin); 

dac d_1(dac1.PCLK, dac1.PRESET, dac1.PSEL, dac1.PENABLE, dac1.PWRITE, dac1.PREADY, dac1.PWDATA, dac1.PSLVERR, dac1.vout);

dac d_2(dac2.PCLK, dac2.PRESET, dac2.PSEL, dac2.PENABLE, dac2.PWRITE, dac2.PREADY, dac2.PWDATA, dac2.PSLVERR, dac2.vout);


    

initial begin
    $dumpfile("BFM.vpd");
    $dumpvars(9, top);
end

endmodule : top
    
