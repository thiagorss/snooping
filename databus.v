module databus(bus0, bus1, bus2, bus_mem, bus_out);
    input [11:0] bus0, bus1, bus2, bus_mem;
    output reg [11:0] bus_out;

    always @(*) begin
        if (bus0[10] == 1'b1 && bus0[9:8] != 2'b00) begin
            bus_out = bus0;
        end
        else if (bus1[10] == 1'b1 && bus1[9:8] != 2'b00) begin
            bus_out = bus1;
        end
        else if (bus2[10] == 1'b1 && bus2[9:8] != 2'b00) begin
            bus_out = bus2;
        end
        else begin
            bus_out = bus_mem;
        end
    end
endmodule