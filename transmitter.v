module transmitter( 
    input wire [11:0] data_in,
    input wire wr_en,
    input wire clear,         
    input wire clk_50m,
    input wire clken,
    output reg Tx,
    output wire Tx_busy
);

    parameter TX_STATE_IDLE  = 2'b00;
    parameter TX_STATE_START = 2'b01;
    parameter TX_STATE_DATA  = 2'b10;
    parameter TX_STATE_STOP  = 2'b11;

    reg [11:0] data = 12'h000; 
    reg [3:0] bit_pos = 4'h0;  
    reg [1:0] state = TX_STATE_IDLE;

    always @(posedge clk_50m) begin
        if (clear) begin       // Logic Reset
            state <= TX_STATE_IDLE;
            Tx <= 1'b1;
            bit_pos <= 4'h0;
            data <= 12'h000;
        end else begin
            case (state)
            TX_STATE_IDLE: begin
                if (wr_en) begin
                    state <= TX_STATE_START;
                    data <= data_in;
                    bit_pos <= 4'h0;
                end
            end
            TX_STATE_START: begin
                if (clken) begin
                    Tx <= 1'b0;
                    state <= TX_STATE_DATA;
                end
            end
            TX_STATE_DATA: begin
                if (clken) begin
                    if (bit_pos == 4'd11) 
                        state <= TX_STATE_STOP;
                    else
                        bit_pos <= bit_pos + 4'd1;
                    Tx <= data[bit_pos];
                end
            end
            TX_STATE_STOP: begin
                if (clken) begin
                    Tx <= 1'b1;
                    state <= TX_STATE_IDLE;
                end
            end
            default: state <= TX_STATE_IDLE;
            endcase
        end
    end

    assign Tx_busy = (state != TX_STATE_IDLE);

endmodule