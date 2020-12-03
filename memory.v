module memory(clock, tag_in, bus_in, bus_out);
    input clock;
    input [4:0] tag_in;
    input [11:0] bus_in;

    output reg [11:0] bus_out;
    
    reg [4:0] tag[5:0];
    reg [7:0] mem[5:0];

    reg [2:0] index_data;

    integer i;
    initial begin
        mem[0] = 20;
        mem[1] = 30;
        mem[2] = 40;
        mem[3] = 50;
        mem[4] = 60;
        mem[5] = 70;

        tag[0] = 8;
        tag[1] = 10;
        tag[2] = 12;
        tag[3] = 14;
        tag[4] = 16;
        tag[5] = 18;
    end

    always @(posedge clock) begin
        for (i=0; i<6; i=i+1) begin
            if (tag_in == tag[i]) begin
                index_data = i;
            end
        end    
        if (bus_in[11]) begin
            mem[index_data] = bus_in[7:0];
        end
        bus_out = {4'b0, mem[index_data]};
    end
endmodule