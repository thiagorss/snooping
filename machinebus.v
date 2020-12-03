module machinebus(processor, mbus0, mbus1, mbus2, mbus);
    input [1:0] processor;
    input [2:0] mbus0, mbus1, mbus2;
    output reg [2:0] mbus;

    always @(mbus0, mbus1, mbus2) begin
        case (processor)
            2'b00: mbus = mbus0;
            2'b01: mbus = mbus1;
            2'b10: mbus = mbus2;
        endcase
    end
endmodule