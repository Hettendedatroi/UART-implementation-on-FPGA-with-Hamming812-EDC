module hamming_encoder(
    input  [7:0] data_in,     // 8 bit dữ liệu gốc (d1 đến d8)
    output [11:0] data_out    // 12 bit đã mã hóa
);
    wire p1, p2, p4, p8;

    // Tính toán các bit Parity (Chẵn - Even Parity)
    // XOR các bit dữ liệu tương ứng theo quy tắc Hamming
    assign p1 = data_in[0] ^ data_in[1] ^ data_in[3] ^ data_in[4] ^ data_in[6];
    assign p2 = data_in[0] ^ data_in[2] ^ data_in[3] ^ data_in[5] ^ data_in[6];
    assign p4 = data_in[1] ^ data_in[2] ^ data_in[3] ^ data_in[7];
    assign p8 = data_in[4] ^ data_in[5] ^ data_in[6] ^ data_in[7];

    // Sắp xếp các bit vào đúng vị trí (p nằm ở các vị trí lũy thừa của 2: 1, 2, 4, 8)
    assign data_out[0]  = p1;
    assign data_out[1]  = p2;
    assign data_out[2]  = data_in[0]; // d1
    assign data_out[3]  = p4;
    assign data_out[4]  = data_in[1]; // d2
    assign data_out[5]  = data_in[2]; // d3
    assign data_out[6]  = data_in[3]; // d4
    assign data_out[7]  = p8;
    assign data_out[8]  = data_in[4]; // d5
    assign data_out[9]  = data_in[5]; // d6
    assign data_out[10] = data_in[6]; // d7
    assign data_out[11] = data_in[7]; // d8

endmodule