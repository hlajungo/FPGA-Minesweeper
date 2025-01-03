module divfreq_1(input CLK, output reg CLK_1Hz);
  reg [24:0] Count;
  always @(posedge CLK) begin
    if (Count > 25000000) begin
      Count <= 25'b0;
      CLK_1Hz <= ~CLK_1Hz;
    end else begin
      Count <= Count + 1'b1;
    end
  end
endmodule

module divfreq_100(input CLK, output reg CLK_100Hz);
  reg [24:0] Count;
  always @(posedge CLK) begin
    if (Count > 250000) begin
      Count <= 25'b0;
      CLK_100Hz <= ~CLK_100Hz;
    end else begin
      Count <= Count + 1'b1;
    end
  end
endmodule

module divfreq_1000(input CLK, output reg CLK_1000Hz);
  reg [24:0] Count;
  always @(posedge CLK) begin
    if (Count > 25000) begin
      Count <= 25'b0;
      CLK_1000Hz <= ~CLK_1000Hz;
    end else begin
      Count <= Count + 1'b1;
    end
  end
endmodule

module divfreq_10000(input CLK, output reg CLK_10000Hz);
  reg [24:0] Count;
  always @(posedge CLK) begin
    if (Count > 2500) begin
      Count <= 25'b0;
      CLK_10000Hz <= ~CLK_10000Hz;
    end else begin
      Count <= Count + 1'b1;
    end
  end
endmodule