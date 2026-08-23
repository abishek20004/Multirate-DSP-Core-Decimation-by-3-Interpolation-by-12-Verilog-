`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 22.08.2026 20:41:40
// Design Name: 
// Module Name: combined_filter
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module combined_filter (

    // ============================================================
    // CLOCK
    // ============================================================
    input  wire         aclk,

    // ============================================================
    // INPUT AXI-STREAM
    // 16-bit signed Q1.15
    // ============================================================
    input  wire         s_axis_data_tvalid,
    output wire         s_axis_data_tready,
    input  wire [15:0]  s_axis_data_tdata,

    // ============================================================
    // OUTPUT
    //
    // tvalid : output data valid
    // tdata  : 64-bit packed output
    //
    // 64 bits = 4 x 16-bit Q1.15 samples
    // ============================================================
    output wire         m_axis_data_tvalid,
    output wire [63:0]  m_axis_data_tdata
);


    // ============================================================
    // DECIMATOR
    //
    // Input:
    //      16-bit Q1.15
    //
    // Output:
    //      24-bit FIR output
    // ============================================================

    wire        dec_valid;
    wire        dec_ready;
    wire [23:0] dec_data;

    dec_3 u_dec (
        .aresetn              (1'b1),
        .aclk                 (aclk),

        .s_axis_data_tvalid   (s_axis_data_tvalid),
        .s_axis_data_tready   (dec_ready),
        .s_axis_data_tdata    (s_axis_data_tdata),

        .m_axis_data_tvalid   (dec_valid),
        .m_axis_data_tdata    (dec_data)
    );


    // Input ready comes from decimator
    assign s_axis_data_tready = dec_ready;


    // ============================================================
    // DECIMATOR OUTPUT
    //
    // dec_3 output is 24 bits.
    //
    // Your dec_3 is configured to preserve 15 fractional bits,
    // so convert the result to the 16-bit Q1.15 format expected
    // by interp_12.
    // ============================================================

    wire signed [23:0] dec_data_signed;
    wire signed [15:0] interp_input;

    assign dec_data_signed = $signed(dec_data);

    // 24-bit Q2.15 -> 16-bit Q1.15
    //
    // No fractional-bit shift is required because both formats
    // have 15 fractional bits.
    //
    // This assumes the decimator result is within the 16-bit
    // Q1.15 range.

    assign interp_input = dec_data_signed[15:0];


    // ============================================================
    // INTERPOLATOR
    //
    // Input:
    //      16-bit Q1.15
    //
    // Output:
    //      64-bit packed data
    // ============================================================

    wire        interp_valid;
    wire        interp_ready;
    wire [63:0] interp_data;

    interp_12 u_interp (
        .aclk                 (aclk),

        .s_axis_data_tvalid   (dec_valid),
        .s_axis_data_tready   (interp_ready),
        .s_axis_data_tdata    (interp_input),

        .m_axis_data_tvalid   (interp_valid),
        .m_axis_data_tdata    (interp_data)
    );


    // ============================================================
    // UNPACK INTERPOLATOR OUTPUT
    //
    // Four 16-bit samples:
    //
    // [15:0]   = sample 0
    // [31:16]  = sample 1
    // [47:32]  = sample 2
    // [63:48]  = sample 3
    //
    // Raw interpolator output is 16-bit with 18 fractional bits
    // according to the IP configuration discussed.
    //
    // Q?.18 -> Q1.15
    // Remove 3 fractional bits.
    // ============================================================

    wire signed [15:0] interp_s0;
    wire signed [15:0] interp_s1;
    wire signed [15:0] interp_s2;
    wire signed [15:0] interp_s3;

    wire signed [15:0] q15_s0;
    wire signed [15:0] q15_s1;
    wire signed [15:0] q15_s2;
    wire signed [15:0] q15_s3;


    assign interp_s0 = $signed(interp_data[15:0]);
    assign interp_s1 = $signed(interp_data[31:16]);
    assign interp_s2 = $signed(interp_data[47:32]);
    assign interp_s3 = $signed(interp_data[63:48]);


    // Q18 -> Q15
    // 18 - 15 = 3 fractional bits

    assign q15_s0 = (interp_s0 >>> 3)*12;
    assign q15_s1 = (interp_s1 >>> 3)*12;
    assign q15_s2 = (interp_s2 >>> 3)*12;
    assign q15_s3 = (interp_s3 >>> 3)*12;


    // ============================================================
    // FINAL OUTPUT
    //
    // Four 16-bit Q1.15 samples packed into 64 bits
    // ============================================================

    assign m_axis_data_tdata = {
        q15_s3,
        q15_s2,
        q15_s1,
        q15_s0
    };

    assign m_axis_data_tvalid = interp_valid;


endmodule