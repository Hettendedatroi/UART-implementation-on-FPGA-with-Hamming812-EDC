`timescale 1 ns / 1 ps

module uart(
    input wire [7:0] data_in,    // Dữ liệu đầu vào (8-bit gốc)
    input wire wr_en,            // Lệnh ghi/truyền
    input wire clear,            // Tín hiệu Reset hệ thống (QUAN TRỌNG)
    input wire clk_50m,          // Clock hệ thống
    output wire Tx,              // Chân truyền UART
    output wire Tx_busy,         // Báo đang bận truyền
    input wire Rx,               // Chân nhận UART
    output wire ready,           // Báo đã nhận xong dữ liệu
    input wire ready_clr,        // Xóa cờ ready
    output wire [7:0] data_out,  // Dữ liệu đầu ra (8-bit đã sửa lỗi)
    output wire [7:0] LEDR,      // Hiển thị dữ liệu truyền lên LED
    output wire Tx2,             // Chân Tx phụ (Monitor)
    
    // Tín hiệu Hamming Status
    output wire err_detect,      // Phát hiện lỗi
    output wire err_correct      // Đã sửa lỗi thành công
);      

    // Gán tín hiệu trực tiếp
    assign LEDR = data_in;
    assign Tx2  = Tx;

    // Dây kết nối nội bộ
    wire Txclk_en;
    wire Rxclk_en;
    wire [11:0] encoded_data_tx; // Dữ liệu 12-bit sau khi mã hóa
    wire [11:0] raw_rx_data;     // Dữ liệu 12-bit thô nhận được

    // ---------------------------------------------------------
    // 1. Khởi tạo khối chia tần số Baudrate
    // ---------------------------------------------------------
    baudrate uart_baud (
        .clk_50m(clk_50m),
        .clear(clear),           // Đã nối: Reset bộ đếm baudrate
        .Rxclk_en(Rxclk_en),
        .Txclk_en(Txclk_en)
    );

    // ---------------------------------------------------------
    // 2. Khối Mã hóa (Hamming Encoder) - Thuần combinational (không cần clear)
    // ---------------------------------------------------------
    hamming_encoder h_enc (
        .data_in(data_in),
        .data_out(encoded_data_tx)
    );

    // ---------------------------------------------------------
    // 3. Khối Truyền (Transmitter)
    // ---------------------------------------------------------
    transmitter uart_Tx (
        .data_in(encoded_data_tx), 
        .wr_en(wr_en),
        .clear(clear),           // Đã nối: Reset máy trạng thái truyền
        .clk_50m(clk_50m),
        .clken(Txclk_en),    
        .Tx(Tx),
        .Tx_busy(Tx_busy)
    );

    // ---------------------------------------------------------
    // 4. Khối Nhận (Receiver)
    // ---------------------------------------------------------
    receiver uart_Rx (
        .Rx(Rx),
        .ready(ready),
        .ready_clr(ready_clr),
        .clear(clear),           // Đã nối: Reset máy trạng thái nhận
        .clk_50m(clk_50m),
        .clken(Rxclk_en),    
        .data(raw_rx_data)       
    );

    // ---------------------------------------------------------
    // 5. Khối Giải mã (Hamming Decoder) - Thuần combinational
    // ---------------------------------------------------------
    hamming_decoder h_dec (
        .data_rx(raw_rx_data),
        .data_out(data_out),
        .error_detected(err_detect),
        .error_corrected(err_correct)
    );

endmodule