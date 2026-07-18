module baudrate (
    input wire clk_50m,
    input wire clear,       
    output wire Rxclk_en,
    output wire Txclk_en
);

    parameter RX_ACC_MAX = 50000000 / (115200 * 16); 
    parameter RX_ACC_WIDTH = $clog2(RX_ACC_MAX);

    reg [RX_ACC_WIDTH - 1:0] rx_acc = 0;
    reg [3:0] tx_div = 0;

    // 1. Tao xung Rxclk_en
    always @(posedge clk_50m) begin
        if (clear) begin    // Reset b? ??m Rx
            rx_acc <= 0;
        end else begin
            if (rx_acc == RX_ACC_MAX[RX_ACC_WIDTH - 1:0] - 1'b1) 
                rx_acc <= 0;
            else
                rx_acc <= rx_acc + 1'b1;
        end
    end

    assign Rxclk_en = (rx_acc == 0);

    // 2. Tao xung Txclk_en
    always @(posedge clk_50m) begin
        if (clear) begin    // Reset b? chia Tx
            tx_div <= 0;
        end else if (Rxclk_en) begin
            tx_div <= tx_div + 1'b1;
        end
    end

    assign Txclk_en = (Rxclk_en && tx_div == 4'h0);

endmodule