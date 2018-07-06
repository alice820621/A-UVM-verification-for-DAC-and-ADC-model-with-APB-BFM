class dac1_monitor_message;
    reg PCLK;
    reg PRESET;
    reg PSEL;
    reg PREADY;
    reg PENABLE;
    reg PWRITE;
    reg [31:0] PWDATA;
    real vout;
    
    function copy(dac1_monitor_message mymes);
        this.PCLK = mymes.PCLK;
        this.PRESET = mymes.PRESET;
        this.PSEL = mymes.PSEL;
        this.PREADY = mymes.PREADY;
        this.PENABLE = mymes.PENABLE;
        this.PWRITE = mymes.PWRITE;
        this.PWDATA = mymes.PWDATA;
        this.vout = mymes.vout;
    endfunction : copy
    
    virtual function dac1_monitor_message clone();
        dac1_monitor_message new_message;
        new_message = new();
        new_message.copy(this);
        return (new_message);
    endfunction : clone
    
endclass : dac1_monitor_message

//dac d_1(dac1.PCLK, dac1.PRESET, dac1.PSEL, dac1.PENABLE, dac1.PWRITE, dac1.PREADY, dac1.PWDATA, dac1.PSLVERR, dac1.vout);

class DAC_monitor1 extends uvm_monitor;
    `uvm_component_utils(DAC_monitor1)
    virtual dac_intf dac1;
    
    uvm_analysis_port #(dac1_monitor_message) item_collected_port_dac1;
    dac1_monitor_message my_dac1_msg;
    
    function new(string name = "Monitor_dac1", uvm_component parent = null);
        super.new(name,parent);
        my_dac1_msg = new();
        item_collected_port_dac1 = new("item_collected_port", this);
    endfunction : new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual dac_intf)::get(null, "*", "vif", dac1))begin
            `uvm_error("monitor build", "dac_intf not found")
        end
    endfunction : build_phase
    
    task run_phase(uvm_phase phase);
        
        forever begin
            @((dac1.PREADY))begin
                my_dac1_msg.PWDATA <= dac1.PWDATA;
                my_dac1_msg.PENABLE <= dac1.PENABLE;
                my_dac1_msg.PWRITE <= dac1.PWRITE;
                my_dac1_msg.PSEL <= dac1.PSEL;
                my_dac1_msg.PREADY <= dac1.PREADY;
                #1;
                my_dac1_msg.vout <= dac1.vout;
                #1;
                item_collected_port_dac1.write(my_dac1_msg);
                $cast(my_dac1_msg, my_dac1_msg.clone());
            end
        end
        
    endtask :  run_phase
    
endclass : DAC_monitor1

