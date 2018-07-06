class adc1_monitor_message;
    reg PCLK;
    reg PRESET;
    reg PSEL;
    reg PREADY;
    reg PENABLE;
    reg PWRITE;
    reg [31:0] PRDATA;
    real vin;
    
    function copy(adc1_monitor_message mymes);
        this.PCLK = mymes.PCLK;
        this.PRESET = mymes.PRESET;
        this.PSEL = mymes.PSEL;
        this.PREADY = mymes.PREADY;
        this.PENABLE = mymes.PENABLE;
        this.PWRITE = mymes.PWRITE;
        this.PRDATA = mymes.PRDATA;
        this.vin = mymes.vin;
    endfunction : copy
    
    virtual function adc1_monitor_message clone();
        adc1_monitor_message new_message;
        new_message = new();
        new_message.copy(this);
        return (new_message);
    endfunction : clone
    
endclass : adc1_monitor_message

//dac d_1(dac1.PCLK, dac1.PRESET, dac1.PSEL, dac1.PENABLE, dac1.PWRITE, dac1.PREADY, dac1.PWDATA, dac1.PSLVERR, dac1.vout);

class ADC_monitor1 extends uvm_monitor;
    `uvm_component_utils(ADC_monitor1)
    virtual adc_intf adc1;
    
    uvm_analysis_port #(adc1_monitor_message) item_collected_port_adc1;
    adc1_monitor_message my_adc1_msg;
    
    function new(string name = "Monitor_adc1", uvm_component parent = null);
        super.new(name,parent);
        my_adc1_msg = new();
        item_collected_port_adc1 = new("item_collected_port", this);
    endfunction : new
    
    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if(!uvm_config_db#(virtual adc_intf)::get(null, "*", "vif", adc1))begin
            `uvm_error("monitor build", "dac_intf not found")
        end
    endfunction : build_phase
    
    task run_phase(uvm_phase phase);
        
        forever begin
            @(posedge(adc1.PREADY)) begin
                #2;
                my_adc1_msg.PSEL <= adc1.PSEL;
                my_adc1_msg.PENABLE <= adc1.PENABLE;
                my_adc1_msg.PWRITE <= adc1.PWRITE;
                my_adc1_msg.PREADY <= adc1.PREADY;
                my_adc1_msg.vin <= adc1.vin;
                my_adc1_msg.PRDATA <= adc1.PRDATA;
                #1;
                item_collected_port_adc1.write(my_adc1_msg);
                $cast(my_adc1_msg, my_adc1_msg.clone());
            end
        end
    endtask :  run_phase
    
endclass : ADC_monitor1

