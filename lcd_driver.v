module lcd_driver (
    input               lcd_clk,
    input               rst_n,

    input               ram_rd_valid,
    output              ram_rd_ready,
    input       [15:0]  pixel_data,
    output              lcd_hs,
    output              lcd_vs,
    output  reg         lcd_de,
    output      [23:0]  lcd_rgb
);
// ATK4384 800*480, lcd_clk: 20MHz
// 1056 * 525 = 554_400 p_clk/frame
// 554_400 * 50ns/clk_period = 27_720_000ns/frame
// 1s / 27_720_000ns/frame = 36.075fps
parameter LinePeriod     = 11'd1056;
parameter H_SyncPulse    = 11'd128;
parameter H_BackPorch    = 11'd88;
parameter H_ActivePix    = 11'd800;
parameter H_FrontPorch   = 11'd40;
parameter Hde_start      = 11'd216;
parameter Hde_end        = 11'd1016;

parameter FramePeriod    = 11'd525;        
parameter V_SyncPulse    = 11'd2;         
parameter V_BackPorch    = 11'd33;            
parameter V_ActivePix    = 11'd480;        
parameter V_FrontPorch   = 11'd10;        
parameter Vde_start      = 11'd35;
parameter Vde_end        = 11'd515;

reg     [10:0]  x_cnt;
reg     [10:0]  y_cnt;
wire            lcd_en;
wire            lcd_req;
wire    [23:0]  lcd_rgb_o;

assign lcd_en = ((x_cnt >= Hde_start) && (x_cnt < Hde_end)
                && (y_cnt >= Vde_start) && (y_cnt < Vde_end))
                ? 1'b1: 1'b0;
assign lcd_req = ((x_cnt >= Hde_start + 11'd80) && (x_cnt < Hde_end - 11'd80)
                && (y_cnt >= Vde_start) && (y_cnt < Vde_end))
                ? 1'b1: 1'b0;
assign ram_rd_ready = ram_rd_valid && lcd_req;
assign lcd_rgb_o = {pixel_data[15:11], 3'd0, pixel_data[10:5], 2'd0, pixel_data[4:0], 3'd0};
assign lcd_rgb = ram_rd_ready? lcd_rgb_o: 0;

assign lcd_hs = ((rst_n == 1'b1) && (x_cnt < H_SyncPulse))? 1'b0: 1'b1;
assign lcd_vs = ((rst_n == 1'b1) && (y_cnt < V_SyncPulse))? 1'b0: 1'b1;

always @(posedge lcd_clk, negedge rst_n) begin
    if (~rst_n)
        lcd_de <= 0;
    else 
        lcd_de <= lcd_en;
end

always @(posedge lcd_clk, negedge rst_n) begin
    if (~rst_n) begin
        x_cnt <= 0;
        y_cnt <= 0;
    end
    else begin
        if (x_cnt == LinePeriod - 1'b1) begin
            x_cnt <= 0;
            if (y_cnt == FramePeriod - 1'b1) 
                y_cnt <= 0;
            else
                y_cnt <= y_cnt + 1'b1;
        end
        else
            x_cnt <= x_cnt + 1'b1;
    end
end

endmodule //lcd_driver