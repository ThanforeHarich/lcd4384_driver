module ram_control (
    input               rd_clk,
    input               rst_n,

    output  reg         ram_rd_valid,
    input               ram_rd_ready,
    output      [15:0]  ram_rd_data
);

reg     [15:0]  bankA[0: 640*480-1];
reg     [20:0]  bankA_addr;

reg     [20:0]  i;
initial begin
    for (i = 0; i < 640 * 480; i = i + 1'b1)
        bankA[i] = i + 1'b1;
end

assign ram_rd_data = bankA[bankA_addr];
always @(posedge rd_clk, negedge rst_n) begin
    if (~rst_n) begin
        ram_rd_valid <= 0;
        bankA_addr <= 0;
    end
    else begin
        ram_rd_valid <= 1'b1;
        if (ram_rd_ready && ram_rd_valid) begin
            if (bankA_addr == 640 * 480 - 1)
                bankA_addr <= 0;
            else
                bankA_addr <= bankA_addr + 1'b1;
        end
    end
end

endmodule //ram_control