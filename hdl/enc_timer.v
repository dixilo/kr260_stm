`timescale 1ns / 1ps

module enc_timer (
    input        clk,
    input        rstn,
    input [1:0]  enc_in,
    input [93:0] timer_cnt_in,

    output [93:0] timer_cnt_out,
    output [1:0]  enc_out,
    output        valid,
    

    output [95:0] m_axis_tdata,
    output        m_axis_tvalid,
    input         m_axis_tready
    );

    reg [93:0] timer_cnt_reg;
    reg [1:0]  enc_reg;
    reg        valid_reg;

    wire enc_change = (enc_reg != enc_in);

    // valid_reg
    always @(posedge clk) begin
        if (~rstn) begin
            valid_reg <= 1'b0;
        end else begin
            if (enc_change) begin
                valid_reg <= 1'b1;
            end else begin
                valid_reg <= 1'b0;
            end
        end
    end

    assign valid = valid_reg;

    // timer_cnt_reg
    always @(posedge clk) begin
        if (~rstn) begin
            timer_cnt_reg <= 93'b0;
        end else begin
            if (enc_change) begin
                timer_cnt_reg <= timer_cnt_in;
            end
        end
    end
    assign timer_cnt_out = timer_cnt_reg;

    // enc_reg
    always @(posedge clk) begin
        if (~rstn) begin
            enc_reg <= 2'b00;
        end else begin
            enc_reg <= enc_in;
        end
    end
    assign enc_out = enc_reg;

    // AXIS
    assign m_axis_tdata = {enc_reg, timer_cnt_reg};
    assign m_axis_tvalid = {valid_reg};

endmodule
