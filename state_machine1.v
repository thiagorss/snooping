module state_machine1(clock, active_m1, cpu_action, i_state, processor, writeback_block, f_state, bus, processor_index);
    input clock, active_m1;
    input [2:0] cpu_action;
    input [1:0] i_state, processor; 

    output reg writeback_block;
    output reg [1:0] f_state, processor_index;
    output reg [2:0] bus;

    initial 
        writeback_block = 1'b0;

    always @(*) begin
        if (active_m1) begin   
            processor_index = processor;
            case (i_state)
                //invalid
                2'b00: begin
                    case(cpu_action)
                        3'b010: begin
                            bus = 3'b001;
                            f_state = 3'b01;
                            writeback_block = 1'b0;
                        end
                        3'b100: begin
                            bus = 3'b010;
                            f_state = 3'b10;
                            writeback_block = 1'b0;
                        end
                    endcase
                end
                //shared
                2'b01: begin
                    case (cpu_action)
                        //read hit
                        3'b001: begin
                            bus = 3'b0;
                            f_state = 2'b01;
                            writeback_block = 1'b0;
                        end
                        //read miss
                        3'b010: begin
                            bus = 3'b001;
                            f_state = 2'b01;
                            writeback_block = 1'b0;
                        end
                        //write hit
                        3'b011: begin
                            bus = 3'b011;
                            f_state = 2'b10;
                            writeback_block = 1'b0;
                        end
                        //write miss
                        3'b100: begin
                            bus = 3'b010;
                            f_state = 2'b10;
                            writeback_block = 1'b0;
                        end
                    endcase
                end
                //exclusive
                2'b10: begin
                    case (cpu_action)
                        //cpu read hit
                        3'b001: begin
                            bus = 3'b0;
                            f_state = 2'b10;
                            writeback_block = 1'b0;
                        end
                        //cpu read miss
                        3'b010: begin
                            bus = 3'b001;
                            f_state = 2'b01;
                            writeback_block = 1'b1;
                        end
                        //cpu write hit
                        3'b011: begin
                            bus = 3'b0;
                            f_state = 2'b10;
                            writeback_block = 1'b0;
                        end
                        //cpu write miss
                        3'b100: begin
                            bus = 3'b010;
                            f_state = 2'b10;
                            writeback_block = 1'b1;
                        end
                    endcase    
                end
            endcase
        end
    end
endmodule