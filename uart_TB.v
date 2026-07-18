 	`timescale 1ns / 1ps

	module uart_TB();

	// Khai báo tín hiệu đầu vào (reg) và đầu ra (wire)
	reg [7:0] data;
	reg clk;
	reg enable;
	reg clear;
	reg ready_clr;

	wire Tx_busy;
	wire ready;        
	wire [7:0] Rx_data;

	// Tín hiệu kết nối truyền-nhận (có chèn nhiễu)
	wire tx_serial;     
	wire rx_serial;
	reg noise; // Biến tạo nhiễu

	// Các tín hiệu mới từ module UART
	wire [7:0] LEDR;
	wire Tx2;
	wire err_detect;
	wire err_correct;

	// CƠ CHẾ TẠO NHIỄU VẬT LÝ: 
	// Kết nối chân Tx sang Rx qua cổng XOR. 
	// - Nếu noise = 0: rx = tx (truyền bình thường)
	// - Nếu noise = 1: rx = ~tx (cố tình lật 1 bit do nhiễu)
	assign rx_serial = tx_serial ^ noise;

	// Khởi tạo module UART (đã cập nhật đầy đủ các chân)
	uart test_uart (
		 .data_in(data),
		 .wr_en(enable),
		 .clk_50m(clk),
		 .clear(clear),
		 .Tx(tx_serial),
		 .Tx_busy(Tx_busy),
		 .Rx(rx_serial),
		 .ready(ready),
		 .ready_clr(ready_clr),
		 .data_out(Rx_data),
		 .LEDR(LEDR),
		 .Tx2(Tx2),
		 .err_detect(err_detect),
		 .err_correct(err_correct)
	);

	// 1. Tạo xung clock 50MHz
	initial begin
		 clk = 0;
		 noise = 0; // Ban đầu đường truyền sạch sẽ, không có nhiễu
	end
	always #10 clk = ~clk; 

	// 2. Khối khởi tạo
	initial begin
		 data = 8'h00;
		 enable = 0;
		 ready_clr = 0;
		 
		 clear = 1;      
		 #100;           
		 clear = 0;      
		 #100;

		 enable = 1;
		 #20;            
		 enable = 0;
	end

	// 3. Khối kiểm tra tự động
	always @(posedge ready) begin
		 #20 ready_clr = 1;
		 #20 ready_clr = 0;

		 // Kiểm tra dữ liệu: Nếu bộ Hamming hoạt động tốt, Rx_data vẫn phải bằng data gốc dù có nhiễu
		 if (Rx_data != data) begin
			  $display("FAIL: rx data %h does not match tx %h", Rx_data, data);
			  $finish; 
		 end 
		 else begin
			  if (Rx_data == 8'hFF) begin 
					$display("SUCCESS: all bytes from 0x00 to 0xFF verified (Including Error Correction!)");
					$finish; 
			  end
			  
			  data = data + 1;
			  wait(!Tx_busy);
			  
			  #20 enable = 1;
			  #20 enable = 0;
		 end
	end

	// 4. Kịch bản "Bơm Nhiễu" (Error Injection) để test tính năng sửa lỗi Hamming
	// Cứ mỗi khi gửi đến các byte đặc biệt (VD: 0x05, 0x0A, 0x0F), ta sẽ lật 1 bit ngẫu nhiên trên đường dây
	always @(posedge enable) begin
		 if (data == 8'h05 || data == 8'h0A || data == 8'h0F) begin
			  // Baudrate 115200 bps -> 1 bit mất khoảng 8680 ns.
			  // Đợi 35000ns để vượt qua Start bit và lọt vào giữa các bit Data
			  #35000; 
			  noise = 1;  // Kích hoạt nhiễu (lật bit)
			  #8680;      // Giữ nhiễu trong đúng 1 chu kỳ bit
			  noise = 0;  // Tắt nhiễu, đường truyền trở lại bình thường
			  
			  $display("--- INJECTED NOISE on transmission of data %h ---", data);
		 end
	end

	// 5. Cơ chế Timeout 50ms
	initial begin
		 #50000000; 
		 $display("TIMEOUT FAIL: Simulation took too long. Check your baudrate or logic!");
		 $finish;
	end

	endmodule