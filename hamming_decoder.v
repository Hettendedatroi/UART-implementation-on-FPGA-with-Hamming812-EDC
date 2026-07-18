`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/23/2026 09:45:56 AM
// Design Name: 
// Module Name: hamming_decoder
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


module hamming_decoder(
    input  [11:0] data_rx,       // 12 bit nhận được từ UART
    output reg [7:0] data_out,   // 8 bit dữ liệu đã được sửa lỗi
    output reg error_detected,   // Cờ báo hiệu có lỗi
    output reg error_corrected   // Cờ báo hiệu đã sửa lỗi thành công
);
    wire c1, c2, c4, c8;
    wire [3:0] syndrome;

    // Tính toán mã lỗi Syndrome
    assign c1 = data_rx[0] ^ data_rx[2] ^ data_rx[4] ^ data_rx[6] ^ data_rx[8] ^ data_rx[10];
    assign c2 = data_rx[1] ^ data_rx[2] ^ data_rx[5] ^ data_rx[6] ^ data_rx[9] ^ data_rx[10];
    assign c4 = data_rx[3] ^ data_rx[4] ^ data_rx[5] ^ data_rx[6] ^ data_rx[11];
    assign c8 = data_rx[7] ^ data_rx[8] ^ data_rx[9] ^ data_rx[10] ^ data_rx[11];

    assign syndrome = {c8, c4, c2, c1};

    always @(*) begin
        // Mặc định: Trích xuất 8 bit dữ liệu ra
        data_out = {data_rx[11:8], data_rx[6:4], data_rx[2]};
        error_detected = (syndrome != 4'd0);
        error_corrected = 0;

        // Nếu có lỗi, vị trí bit lỗi chính là giá trị của biến syndrome
        if (syndrome != 0) begin
            error_corrected = 1;
            // Sửa lỗi bằng cách đảo ngược (NOT) bit bị sai
            // Chỉ cần sửa nếu lỗi rơi vào các bit dữ liệu (bỏ qua nếu lỗi ở bit Parity)
            case(syndrome)
                3:  data_out[0] = ~data_out[0]; 
                5:  data_out[1] = ~data_out[1]; 
                6:  data_out[2] = ~data_out[2]; 
                7:  data_out[3] = ~data_out[3]; 
                9:  data_out[4] = ~data_out[4]; 
                10: data_out[5] = ~data_out[5]; 
                11: data_out[6] = ~data_out[6]; 
                12: data_out[7] = ~data_out[7]; 
                default: ; // Lỗi rơi vào bit Parity, dữ liệu data_out vẫn an toàn
            endcase
        end
    end
endmodule