module state_machine2(clock, reset, i_state, bus, writeback_block, abort_mem_accs, f_state);
    input clock, reset;
    input [1:0] i_state;
    input [2:0] bus;

    output reg writeback_block, abort_mem_accs;
    output reg [1:0] f_state;

    initial begin
        writeback_block = 1'b0;
        abort_mem_accs = 1'b0;
    end

    always @(posedge clock or posedge reset) begin
        if (reset) begin
            f_state = i_state;
            writeback_block = 1'b0;
            abort_mem_accs = 1'b0;
        end
        else begin
            case (f_state)
                //invalid
                2'b00: begin
                    //nao sai desse estado
                    writeback_block = 1'b0;
                    abort_mem_accs = 1'b0;
                end
                //shared
                2'b01: begin
                    case (bus)
                        3'b001: begin
                            f_state = 2'b01;
                            writeback_block = 1'b0;
                            abort_mem_accs = 1'b0;
                        end
                        3'b010: begin
                            f_state = 2'b0;
                            writeback_block = 1'b0;
                            abort_mem_accs = 1'b0;
                        end
                        3'b011: begin
                            f_state = 2'b0;
                            writeback_block = 1'b0;
                            abort_mem_accs = 1'b0;
                        end
                    endcase
                end
                //exclusive
                2'b10: begin
                    case (bus)
                        3'b001: begin
                            f_state = 2'b01;
                            writeback_block = 1'b1;
                            abort_mem_accs = 1'b1;
                        end
                        3'b010: begin
                            f_state = 2'b0;
                            writeback_block = 1'b1;
                            abort_mem_accs = 1'b1;
                        end
                    endcase
                end
            endcase
        end
    end
endmodule