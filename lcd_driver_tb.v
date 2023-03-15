`timescale 1ns/1ps
`define clk_period 20
`include "lcd_driver.v"
`include "ram_control.v"
module lcd_driver_tb ();

reg             lcd_clk;
reg             rst_n;

wire            ram_rd_valid;
wire            ram_rd_ready;
wire    [15:0]  pixel_data;
wire            lcd_hs;
wire            lcd_vs;
wire            lcd_de;
wire    [23:0]  lcd_rgb;

reg             lcd_vs_d0;
reg             lcd_vs_d1;
wire            lcd_vs_negedge;
reg     [1:0]   frame_cnt;

always @(posedge lcd_clk, negedge rst_n) begin
    if (~rst_n) begin
        lcd_vs_d0 <= 1'b1;
        lcd_vs_d1 <= 1'b1;
    end
    else begin
        lcd_vs_d0 <= lcd_vs;
        lcd_vs_d1 <= lcd_vs_d0;
    end
end
assign lcd_vs_negedge = (~lcd_vs_d0) & lcd_vs_d1;
always @(posedge lcd_clk, negedge rst_n) begin
    if (~rst_n)
        frame_cnt <= 0;
    else begin
        if (lcd_vs_negedge)
            frame_cnt <= frame_cnt + 1'b1;
    end
end

lcd_driver u_lcd_driver(
    .lcd_clk(lcd_clk),
    .rst_n(rst_n),

    .ram_rd_valid(ram_rd_valid),
    .ram_rd_ready(ram_rd_ready),
    .pixel_data(pixel_data),
    .lcd_hs(lcd_hs),
    .lcd_vs(lcd_vs),
    .lcd_de(lcd_de),
    .lcd_rgb(lcd_rgb)
);

ram_control u_ram_control(
    .rd_clk(lcd_clk),
    .rst_n(rst_n),

    .ram_rd_valid(ram_rd_valid),
    .ram_rd_ready(ram_rd_ready),
    .ram_rd_data(pixel_data)
);

initial begin
    lcd_clk = 1'b1;
    rst_n = 1'b0;

    #(`clk_period * 10 + 5);
    rst_n = 1'b1;

    @(frame_cnt == 2'b11) #(`clk_period * 10);
    $finish;
end

always #(`clk_period/2) lcd_clk = ~lcd_clk;

initial begin            
    $dumpfile("wave.vcd");        //生成的vcd文件名称
    $dumpvars(0, lcd_driver_tb);    //tb模块名称
end

endmodule //lcd_driver_tb