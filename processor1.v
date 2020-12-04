module processor1(processor_index, clock, reset, start, listen, p1, op, block, tag_in, wr_data, bus_m1_in, bus_in, bus_out, bus_m1);
    input clock, reset, start, listen, op;
    input [1:0] processor_index, block, p1;
    input [2:0] bus_m1_in;
    input [4:0] tag_in;
    input [7:0] wr_data;
    input [11:0] bus_in;

    output [2:0] bus_m1;
    output reg [11:0] bus_out;
    
    wire hit, wb_m1, wb_m2;
    wire [1:0] state_m1, state_m2, processor_m1, processor_m2;
    wire [7:0] data_m2;

    reg w, wb, active_m1, active_m2, cache_hit;
    reg [1:0] step, state_p1[3:0], state_out;
    reg [2:0] cpu_action;
    reg [4:0] tag_p1 [3:0];
    reg [7:0] data_p1[3:0], data_out;

    initial begin
        state_p1[0] = 2'd0;
        tag_p1[0] = 5'd8;
        data_p1[0] = 8'd10;

        state_p1[1] = 2'd0;
        tag_p1[1] = 5'd12;
        data_p1[1] = 8'd40;
        
        state_p1[2] = 2'd2;
        tag_p1[2] = 5'd16;
        data_p1[2] = 8'd77;
        
        state_p1[3] = 2'd1;
        tag_p1[3] = 5'd18;
        data_p1[3] = 8'd70;
    end

    integer i;
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            w = 1'b0;
            wb = 1'b0;
            step = 1'b0;
            cache_hit = 1'b0;
            active_m1 = 1'b0;
            active_m2 = 1'b0;
            bus_out = 0;
        end
        else if (start || listen) begin
            case (step)
                2'b00: begin        
                    //manda ação para a maquina1
                    if (start) begin
                        active_m1 = 1'b1;
                        case (op)
                            //read
                            1'b0: begin
                                //read hit
                                if (tag_p1[block] == tag_in && state_p1[block] != 2'b00) begin
                                    cpu_action = 3'b001;
                                    w = 1'b1;
                                end
                                //read miss
                                else begin
                                    cpu_action = 3'b010;
                                end
                            end
                            //write
                            1'b1: begin
                                //write hit
                                if (tag_p1[block] == tag_in && state_p1[block] != 2'b00) begin
                                    cpu_action = 3'b011;
                                end
                                //write miss
                                else begin
                                    cpu_action = 3'b100;
                                end
                                w=1'b1;
                            end
                        endcase
                    end
                    //Analisa se a cache tem o dado atualizado
                    if (listen) begin
                        if (tag_p1[block] == tag_in && state_p1[block] != 2'b00) begin
                            active_m2 = 1'b1;
                            cache_hit = 1'b1;                                           //Indica à maquina2 que existe o dado na cache compartilhada
                            bus_out = {wb, cache_hit, state_p1[block], data_p1[block]};
                        end
                    end
                    step = 2'b01;
                end
                2'b01: begin
                    //mudança de estado do processador que gera a ação
                    if(processor_index == processor_m1) begin
                        active_m1 = 1'b0;
                        wb = wb_m1;
                        state_p1[block] = state_m1;
                        tag_p1[block] = (cpu_action == 3'b010 && bus_in[10] == 1'b1) ? tag_in : tag_p1[block];
                        data_p1[block] = (cpu_action == 3'b011 || cpu_action == 3'b100) ? wr_data : data_p1[block];
                        data_p1[block] = (cpu_action == 3'b010 && bus_in[10] == 1'b1 && w != 1'b1) ? bus_in[7:0] : data_p1[block];
                        bus_out = {wb, w, state_p1[block], data_p1[block]};
                        step = 2'b10;
                    end
                    //mudança de estado dos processadores que escutam o barramento
                    if (processor_index != processor_m2) begin
                        wb = wb_m2;
                        cache_hit = 1'b0;
                        active_m2 = 1'b0;
                        state_p1[block] = state_m2;
                        bus_out = {wb, hit, state_p1[block], data_p1[block]};
                        step = 2'b10;
                    end
                end
                2'b10: begin
                    //nada
                end
            endcase
        end
    end
    state_machine1 sm1(reset, active_m1, cpu_action, state_p1[block], p1, wb_m1, state_m1, bus_m1, processor_m1);
    state_machine2 sm2(reset, active_m2, cache_hit, state_p1[block], p1, bus_m1_in, data_p1[block], wb_m2, abort_mem_accs, hit, state_m2, processor_m2, data_m2);
endmodule