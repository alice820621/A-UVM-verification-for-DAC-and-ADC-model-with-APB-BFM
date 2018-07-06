class BFM_Sequence extends uvm_sequence #(sq_msg);
    `uvm_object_utils(BFM_Sequence)
    sq_msg m1;
    int unsigned value;
    function new(string name = "BFM_sequence");
        super.new(name);
    endfunction : new
    
    task body;
        m1 = sq_msg::type_id::create("m1");
        
            begin
                repeat(5000) begin
                    start_item(m1);
                        m1.addr = 32'h00000000;
                        m1.randomize(w_data);
                        m1.write = 1;
                    finish_item(m1);
                end
                
                repeat(5000) begin
                    start_item(m1);
                        m1.addr = 32'h00000001;
                        m1.randomize(w_data);
                        m1.write = 1;
                    finish_item(m1);
                end
                
                repeat(10000)begin
                    start_item(m1);
                        m1.randomize(addr) with { addr <= 32'h00000001; };
                        m1.randomize(w_data);
                        m1.randomize(write);
                    finish_item(m1);
                end
                
                repeat(5000) begin
                    start_item(m1);
                        m1.addr = 32'h00000002;
                        randomize(value);
                        m1.vin <= (real'(value)/(32'hFFFFFFFF));
                        m1.write = 0;
                    finish_item(m1);
                end
                
                repeat(5000) begin
                    start_item(m1);
                        m1.addr = 32'h00000003;
                        randomize(value);
                        m1.vin <= (real'(value)/(32'hFFFFFFFF));
                        m1.write = 0;
                    finish_item(m1);
                end
                
                repeat(10000)begin
                    
                    start_item(m1);
                        m1.randomize(addr) with { addr <= 32'h00000003; addr >= 32'h00000002;};
                        m1.randomize(write);
                        randomize(value);
                        m1.vin <= (real'(value)/(32'hFFFFFFFF));
                    finish_item(m1);
                end
                
            end

             #100;
            
    endtask : body
    
endclass : BFM_Sequence
