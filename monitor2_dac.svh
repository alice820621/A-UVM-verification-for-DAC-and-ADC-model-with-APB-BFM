class dac2_monitor_message;
    reg PCLK;
    reg PRESET;
    reg PSEL;
    reg PREADY;
    reg PENABLE;
    reg PWRITE;
    reg [31:0] PWDATA;
    real vout;
    
    function copy(dac2_monitor_message mymes);
        this.PCLK = mymes.PCLK;
        this.PRESET = mymes.PRESET;
        this.PSEL = mymes.PSEL;
        this.PREADY = mymes.PREADY;
        this.PENABLE = mymes.PENABLE;
        this.PWRITE = mymes.PWRITE;
        this.PWDATA = mymes.PWDATA;
        this.vout = mymes.vout;
    endfunction : copy
    
    virtual function dac2_monitor_message clone();
        dac2_monitor_message new_message;
        new_message = new();
        new_message.copy(this);
        return (new_message);
    endfunction : clone
    
endclass : dac2_monitor_message

//dac d_1(dac2.PCLK, dac2.PRESET, dac2.PSEL, dac2.PENABLE, dac2.PWRITE, dac2.PREADY, dac2.PWDATA, dac2.PSLVERR, dac2.vout);

class DAC2_monitor extends uvm_monitor;
    `uvm_component_utils(DAC2_monitor)
    virtual dac1_intf dac2;
    
    uvm_analysis_port #(dac2_monitor_message) item_collected_port_dac2;
    dac2_monitor_message my_dac2_msg;
    
    function new(string name = "Monitor_dac2", uvm_component parent = null);
        super.new(name,parent);
        my_dac2_msg = new();
        item_collected_port_dac2 = new("item_collected_port_dac2", this);
    endfunction : new
     
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual dac1_intf)::get(null, "*", "vif", dac2))begin
            `uvm_error("monitor build", "dac_intf not found")
        end
    endfunction : build_phase 
    
    task run_phase(uvm_phase phase);
        
        forever begin
            @((dac2.PREADY)) begin
                my_dac2_msg.PWDATA <= dac2.PWDATA;
                my_dac2_msg.PENABLE <= dac2.PENABLE;
                my_dac2_msg.PWRITE <= dac2.PWRITE;
                my_dac2_msg.PSEL <= dac2.PSEL;
                my_dac2_msg.vout <= dac2.vout;
                my_dac2_msg.PREADY <= dac2.PREADY;
                #1;
                item_collected_port_dac2.write(my_dac2_msg);
                $cast(my_dac2_msg, my_dac2_msg.clone());
            end
        end
    endtask :  run_phase
    
endclass : DAC2_monitor
