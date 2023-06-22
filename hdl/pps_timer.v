`timescale 1ns / 1ps

module pps_timer (
    input        clk,
    input        rstn,
    input        pps,
    input [93:0] timer_cnt_in,

    output [93:0] timer_cnt_out
    );

    reg [93:0] timer_cnt_reg;
    assign timer_cnt_out = timer_cnt_reg;

    reg pps_buf;
    wire pps_rising_edge = (pps_buf == 1'b0) & (pps == 1'b1);

    always @(posedge clk) begin
        if (~rstn) begin
            timer_cnt_reg <= 93'b0;
        end else begin
            if (pps_rising_edge) begin
                timer_cnt_reg <= timer_cnt_in;
            end
        end
    end

    always @(posedge clk) begin
        if (~rstn) begin
            pps_buf <= 1'b0;
        end else begin
            pps_buf <= pps;
        end
    end
endmodule
