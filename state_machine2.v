module state_machine2(reset, active_m2, cache_hit, i_state, processor, bus, data_in, writeback_block, abort_mem_accs, hit, f_state, processor_index, data_out);
    input reset, active_m2, cache_hit;
    input [1:0] i_state, processor;
    input [2:0] bus;
    input [7:0] data_in;

    output reg writeback_block, abort_mem_accs, hit;
    output reg [1:0] f_state, processor_index;
    output reg [7:0] data_out;

    initial begin
        writeback_block = 1'b0;
        abort_mem_accs = 1'b0;
    end

    always @(*) begin
        if (reset) begin
            writeback_block = 1'b0;
            abort_mem_accs = 1'b0;
            hit = 1'b0;
            f_state = 2'bxx;
            processor_index = 2'bxx;
            data_out = 7'bx;
        end
        if (active_m2) begin
            processor_index = processor;
            case (i_state)
                //invalid
                2'b00: begin
                    //nao sai desse estado
                    writeback_block = 1'b0;
                    abort_mem_accs = 1'b0;
                end
                //shared
                2'b01: begin
                    if (cache_hit) begin
                        case (bus)
                            3'b001: begin
                                hit = 1'b1;
                                f_state = 2'b01;
                                writeback_block = 1'b0;
                                abort_mem_accs = 1'b0;
                                data_out = data_in;
                            end
                            3'b010: begin
                                hit = 1'b1;
                                f_state = 2'b0;
                                writeback_block = 1'b0;
                                abort_mem_accs = 1'b0;
                                data_out = data_in;
                            end
                            3'b011: begin
                                f_state = 2'b0;
                                writeback_block = 1'b0;
                                abort_mem_accs = 1'b0;
                            end
                        endcase
                    end
                end
                //exclusive
                2'b10: begin
                    if (cache_hit) begin
                        case (bus)
                            3'b001: begin
                                hit = 1'b1;
                                f_state = 2'b01;
                                writeback_block = 1'b1;
                                abort_mem_accs = 1'b1;
                                data_out = data_in;
                            end
                            3'b010: begin
                                f_state = 2'b0;
                                writeback_block = 1'b1;
                                abort_mem_accs = 1'b1;
                            end
                        endcase
                    end
                end
            endcase
        end
    end
endmodule