class adc2_monitor_message;
    reg PCLK;
    reg PRESET;
    reg PSEL;
    reg PREADY;
    reg PENABLE;
    reg PWRITE;
    reg [31:0] PRDATA;
    real vin;
    
    function copy(adc2_monitor_message mymes);
        this.PCLK = mymes.PCLK;
        this.PRESET = mymes.PRESET;
        this.PSEL = mymes.PSEL;
        this.PREADY = mymes.PREADY;
        this.PENABLE = mymes.PENABLE;
        this.PWRITE = mymes.PWRITE;
        this.PRDATA = mymes.PRDATA;
        this.vin = mymes.vin;
    endfunction : copy
    
    virtual function adc2_monitor_message clone();
        adc2_monitor_message new_message;
        new_message = new();
        new_message.copy(this);
        return (new_message);
    endfunction : clone
    
endclass : adc2_monitor_message

//dac d_1(dac1.PCLK, dac1.PRESET, dac1.PSEL, dac1.PENABLE, dac1.PWRITE, dac1.PREADY, dac1.PWDATA, dac1.PSLVERR, dac1.vout);

class ADC2_monitor extends uvm_monitor;
    `uvm_component_utils(ADC2_monitor)
    virtual adc1_intf adc2;
    
    uvm_analysis_port #(adc2_monitor_message) item_collected_port_adc2;
    adc2_monitor_message my_adc2_msg;
    
    function new(string name = "Monitor_adc2", uvm_component parent = null);
        super.new(name,parent);
        my_adc2_msg = new();
        item_collected_port_adc2 = new("item_collected_port", this);
    endfunction : new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual adc1_intf)::get(null, "*", "vif", adc2))begin
            `uvm_error("monitor build", "dac_intf not found")
        end
    endfunction : build_phase
    
    task run_phase(uvm_phase phase);
        
        forever begin
            @(posedge(adc2.PREADY)) begin
                #2;
                my_adc2_msg.PSEL <= adc2.PSEL;
                my_adc2_msg.PENABLE <= adc2.PENABLE;
                my_adc2_msg.PWRITE <= adc2.PWRITE;
                my_adc2_msg.PREADY <= adc2.PREADY;
                my_adc2_msg.vin <= adc2.vin;
                my_adc2_msg.PRDATA <= adc2.PRDATA;
                #1;
                item_collected_port_adc2.write(my_adc2_msg);
                $cast(my_adc2_msg, my_adc2_msg.clone());
            end
        end
    endtask :  run_phase
    
endclass : ADC2_monitor

