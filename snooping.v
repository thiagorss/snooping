module snooping(clock, reset, instruction);
    input clock, reset;
    input [15:0] instruction;
    /*
    [15:14] processador
    [13] op
    [12:8] addr
    [7:0] data

    Mapeamento 31 posições
    8 : B0                       | 14: B2 
    10: B0                       | 16: B2
    12: B1                       | 18: B3
    */  
    reg cpu_action[2:0], cpu_listen[2:0], abort_mem_accs;
    reg [1:0] block;

    wire [2:0] mbus[3:0];
    wire [11:0] bus0, bus1, bus2, bus_mem, buswires;
    
    integer i;
    always @(posedge clock or posedge reset) begin
        if (reset) begin
            for (i=0; i<3; i=i+1) begin
                cpu_action[i] = 1'b0;
                cpu_listen[i] = 1'b0;
            end
        end
        else begin
            if(instruction[12:8] == 5'd8 || instruction[12:8] == 5'd10) begin
                block = 2'b00;
            end
            else if (instruction[12:8] == 5'd12) begin
                block = 2'b01;
            end
            else if (instruction[12:8] == 5'd14 || instruction[12:8] == 5'd16) begin
                block = 2'b10;
            end
            else begin
                block = 2'b11;
            end

            case (instruction[15:14])
                2'b00: begin
                    cpu_action[0] = 1'b1;
                    cpu_listen[1] = 1'b1;
                    cpu_listen[2] = 1'b1;
                end
                2'b01: begin
                    cpu_action[1] = 1'b1;
                    cpu_listen[0] = 1'b1;
                    cpu_listen[2] = 1'b1;
                end
                2'b10: begin
                    cpu_action[2] = 1'b1;
                    cpu_listen[0] = 1'b1;
                    cpu_listen[1] = 1'b1;
                end
            endcase
        end
    end
    //module processor0(processor_index, clock, reset, start, listen, p0, op, block, tag_in, wr_data, bus_m1_in, bus_in, bus_out, bus_m1);
    processor0 p0(2'b00, clock, reset, cpu_action[0], cpu_listen[0], instruction[15:14], instruction[13], block, instruction[12:8], instruction[7:0], mbus[3], buswires, bus0, mbus[0]);
    processor1 p1(2'b10, clock, reset, cpu_action[1], cpu_listen[1], instruction[15:14], instruction[13], block, instruction[12:8], instruction[7:0], mbus[3], buswires, bus1, mbus[1]);
    processor2 p2(2'b11, clock, reset, cpu_action[2], cpu_listen[2], instruction[15:14], instruction[13], block, instruction[12:8], instruction[7:0], mbus[3], buswires, bus2, mbus[2]);
    machinebus mb(instruction[15:14], mbus[0], mbus[1], mbus[2], mbus[3]);
    databus dab(bus0, bus1, bus2, bus_mem, buswires);
    memory m1(clock, instruction[12:8], buswires, bus_mem);
endmodule