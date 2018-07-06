`include "./DAC1_Monitors_Scoreboard/monitor1.svh"
`include "./DAC1_Monitors_Scoreboard/monitor1_result.svh"
`include "./DAC1_Monitors_Scoreboard/scoreboard1.svh"

`include "./DAC2_Monitors_Scoreboard/monitor2_dac.svh"
`include "./DAC2_Monitors_Scoreboard/monitor_2_result.svh"
`include "./DAC2_Monitors_Scoreboard/scoreboard2_dac.svh"

`include "./ADC1_Monitors_Scoreboards/monitor1_adc.svh"
`include "./ADC1_Monitors_Scoreboards/monitor1_result_adc.svh"
`include "./ADC1_Monitors_Scoreboards/scoreboard1_adc.svh"

`include "./ADC2_Monitors_Scoreboards/monitor2_adc.svh"
`include "./ADC2_Monitors_Scoreboards/monitor2_result_adc.svh"
`include "./ADC2_Monitors_Scoreboards/scoreboard2_adc.svh"

class bfm extends uvm_env;
    `uvm_component_utils(bfm)
    
    uvm_tlm_analysis_fifo #(sq_msg) from_sender;
    sq_msg m_from_sender;
    virtual dac_intf dac1;
    virtual dac1_intf dac2;
    virtual adc_intf adc1;
    virtual adc1_intf adc2;
    
    DAC_monitor1 m1;
    DAC_result_monitor1 m1r;
    DAC_scoreboard1 sb1;
    
    DAC2_monitor m2;
    DAC2_result_monitor m2r;
    DAC2_scoreboard sb2;
    
    ADC_monitor1 m1a;
    ADC_result_monitor1 m1ar;
    ADC_scoreboard1 sb1a;
    
    ADC2_monitor m2a;
    ADC2_result_monitor m2ar;
    ADC2_scoreboard sb2a;
    
    reg dac1_PREADY_flag, adc1_PREADY_flag, dac2_PREADY_flag, adc2_PREADY_flag = 0;
    
    function new(string name = "bfm_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction : new
    
    function void build_phase(uvm_phase phase);
        from_sender = new ("from_sender", this);
        m_from_sender = new();
        m1 = DAC_monitor1::type_id::create("DAC_monitor1", this);
        m1r = DAC_result_monitor1::type_id::create("DAC_result_monitor1", this);
        sb1 = DAC_scoreboard1::type_id::create("DAC_scoreboard1", this);
        
        m2 = DAC2_monitor::type_id::create("DAC2_monitor", this);
        m2r = DAC2_result_monitor::type_id::create("DAC2_result_monitor", this);
        sb2 = DAC2_scoreboard::type_id::create("DAC2_scoreboard", this);
        
        m1a = ADC_monitor1::type_id::create("ADC_monitor1", this);
        m1ar = ADC_result_monitor1::type_id::create("ADC_result_monitor1", this);
        sb1a = ADC_scoreboard1::type_id::create("ADC_scoreboard1", this);
        
        m2a = ADC2_monitor::type_id::create("ADC2_monitor", this);
        m2ar = ADC2_result_monitor::type_id::create("ADC2_result_monitor", this);
        sb2a = ADC2_scoreboard::type_id::create("ADC2_scoreboard", this);
        
    endfunction : build_phase
    
    function void connect_phase(uvm_phase phase);
        if (!uvm_config_db #(virtual dac_intf)::get(null, "*", "vif", this.dac1)) begin
            `uvm_error("connect", "dac_intf not found")
        end
        if (!uvm_config_db #(virtual dac1_intf)::get(null, "*", "vif", this.dac2)) begin
            `uvm_error("connect", "dac_intf not found")
        end
        if (!uvm_config_db #(virtual adc_intf)::get(null, "*", "vif", this.adc1)) begin
            `uvm_error("connect", "dac_intf not found")
        end
        if (!uvm_config_db #(virtual adc1_intf)::get(null, "*", "vif", this.adc2)) begin
            `uvm_error("connect", "dac_intf not found")
        end
        
        m1.item_collected_port_dac1.connect(sb1.from_sender_dac1.analysis_export);
        m1r.item_collected_port_result_dac1.connect(sb1.from_result_dac1.analysis_export);
        
        m2.item_collected_port_dac2.connect(sb2.from_sender_dac2.analysis_export);
        m2r.item_collected_port_result_dac2.connect(sb2.from_result_dac2.analysis_export);
        
        m1a.item_collected_port_adc1.connect(sb1a.from_sender_adc1.analysis_export);
        m1ar.item_collected_port_result_adc1.connect(sb1a.from_result_adc1.analysis_export);
        
        m2a.item_collected_port_adc2.connect(sb2a.from_sender_adc2.analysis_export);
        m2ar.item_collected_port_result_adc2.connect(sb2a.from_result_adc2.analysis_export);
        

    endfunction : connect_phase
    
    task run_phase(uvm_phase phase);
        forever begin

            from_sender.get(m_from_sender);

                    if(m_from_sender.addr == 32'h00000000) begin
                        //$display("I'm in DAC1");
                        dac1_PREADY_flag <= 0;
                        @(posedge(dac1.PCLK)) begin
                            #1;
                            dac1.PSEL <= 1;
                            dac1.PENABLE <= 0;
                            dac1.PWRITE <= m_from_sender.write; 
                            dac1.PWDATA <= m_from_sender.w_data;
                                dac2.PSEL <= 0;
                                adc1.PSEL <= 0;
                                adc2.PSEL <= 0;
                        end
                        
                        @(posedge(dac1.PCLK)) begin
                            #1;
                            dac1.PENABLE <= 1;
                        end
                        fork
                            begin
                                @(posedge(dac1.PREADY)) begin
                                    dac1_PREADY_flag <= 1;
                                    @(posedge(dac1.PCLK)) begin
                                        dac1.PENABLE <=0;
                                    end
                                end
                            end
                            begin
                                repeat(5) begin
                                    @(posedge(dac1.PCLK));
                                end
                                #1;
                                if (dac1_PREADY_flag == 0)begin
                                    if((dac1.PSEL == 1) && (dac1.PENABLE == 1) && (dac1.PWRITE == 1)) begin
                                        $display("DAC1 ERROR: PREADY was not asserted"); 
                                    end
                                end
                            end
                        join_any
                    end
                    
                    if(m_from_sender.addr == 32'h00000001) begin
                    //$display("I'm in DAC2");
                     dac2_PREADY_flag <= 0;
                        @(posedge(dac2.PCLK)) begin
                            #1;
                            dac2.PSEL <= 1;
                            dac2.PENABLE <= 0;
                            dac2.PWRITE <= m_from_sender.write; 
                            dac2.PWDATA <= m_from_sender.w_data;
                                dac1.PSEL <= 0;
                                adc1.PSEL <= 0;
                                adc2.PSEL <= 0;
                        end
                        
                        @(posedge(dac2.PCLK)) begin
                            #1;
                            dac2.PENABLE <= 1;
                        end
                        fork
                            begin
                                @(posedge(dac2.PREADY)) begin
                                    dac2_PREADY_flag <= 1;
                                    @(posedge(dac2.PCLK)) begin
                                        dac2.PENABLE <=0;
                                    end
                                end
                            end
                            begin
                                repeat(5) begin
                                    @(posedge(dac2.PCLK));
                                end
                                #1;
                                if (dac2_PREADY_flag == 0)begin
                                    if((dac2.PSEL == 1) && (dac2.PENABLE == 1) && (dac2.PWRITE == 1)) begin
                                        $display("DAC2 ERROR: PREADY was not asserted"); 
                                    end
                                end
                            end
                        join_any

                    end
                    
                    if(m_from_sender.addr == 32'h00000002) begin
                            //$display("I'm in ADC1");
                            adc1_PREADY_flag <= 0;
                        @(posedge(adc1.PCLK)) begin
                            #1
                            adc1.PSEL <= 1;
                            adc1.PENABLE <= 0;
                            adc1.PWRITE <= m_from_sender.write;
                                dac1.PSEL <= 0;
                                dac2.PSEL <= 0;
                                adc2.PSEL <= 0;
                        end
                        
                        @(posedge(adc1.PCLK)) begin
                            #1;
                            adc1.PENABLE <= 1;
                        end
                        fork
                            begin
                                @(posedge(adc1.PREADY)) begin
                                    adc1_PREADY_flag <= 1;
                                    @(posedge(adc1.PCLK)) begin
                                        adc1.PENABLE <= 0;
                                    end
                                end
                            end
                            begin
                                repeat(5) begin
                                    @(posedge(adc1.PCLK));
                                end
                                #1;
                                if(adc1_PREADY_flag == 0) begin
                                    if((adc1.PSEL == 1) && (adc1.PENABLE == 1) && (adc1.PWRITE == 0)) begin
                                        $display("ADC1 ERROR: PREADY was not asserted"); 
                                    end
                                end
                            end
                        join_any
                    end
                    
                    if(m_from_sender.addr == 32'h00000003) begin
                            //$display("I'm in ADC2");
                            adc2_PREADY_flag <= 0;
                        @(posedge(adc2.PCLK)) begin
                            #1
                            adc2.PSEL <= 1;
                            adc2.PENABLE <= 0;
                            adc2.PWRITE <= m_from_sender.write;
                                dac1.PSEL <= 0;
                                dac2.PSEL <= 0;
                                adc1.PSEL <= 0;
                        end
                        
                        @(posedge(adc2.PCLK)) begin
                            #1;
                            adc2.PENABLE <= 1;
                        end
                        fork
                            begin
                                @(posedge(adc2.PREADY)) begin
                                    adc2_PREADY_flag <= 1;
                                    @(posedge(adc2.PCLK)) begin
                                        adc2.PENABLE <= 0;
                                    end
                                end
                            end
                            begin
                                repeat(5) begin
                                    @(posedge(adc2.PCLK));
                                end 
                                #1;
                                if(adc2_PREADY_flag == 0) begin
                                    if((adc2.PSEL == 1) && (adc2.PENABLE == 1) && (adc2.PWRITE == 0)) begin
                                        $display("ADC2 ERROR: PREADY was not asserted"); 
                                    end
                                end
                            end
                        join_any
                    end
            
        end
    endtask : run_phase 
    
endclass : bfm
