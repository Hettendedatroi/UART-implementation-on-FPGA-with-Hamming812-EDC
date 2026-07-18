module receiver (
    input wire Rx,
    output reg ready,
    input wire ready_clr,
    input wire clear,          
    input wire clk_50m,        
    input wire clken,
    output reg [11:0] data
);

    parameter RX_STATE_START = 2'b00;
    parameter RX_STATE_DATA  = 2'b01;
    parameter RX_STATE_STOP  = 2'b10;

    reg [1:0] state = RX_STATE_START;
    reg [3:0] sample = 0;
    reg [3:0] bit_pos = 0;
    reg [11:0] scratch = 12'b0;

    always @(posedge clk_50m) begin
        if (clear) begin       // Logic Reset cao nh?t
            state <= RX_STATE_START;
            ready <= 1'b0;
            sample <= 0;
            bit_pos <= 0;
            scratch <= 12'b0;
            data <= 12'b0;
        end else begin
            if (ready_clr)
                ready <= 1'b0;

            if (clken) begin
                case (state)
                RX_STATE_START: begin 
                    if (!Rx || sample != 0) begin
                        if (sample == 4'h8 && Rx == 1'b1)
                            sample <= 0;
                        else
                            sample <= sample + 4'b1;
                    end
                    if (sample == 15) begin 
                        state <= RX_STATE_DATA;
                        bit_pos <= 0;
                        sample <= 0; 
                        scratch <= 0;
                    end
                end
                RX_STATE_DATA: begin
                    sample <= sample + 4'b1;
                    if (sample == 4'h8) begin
                        scratch[bit_pos] <= Rx;
                        bit_pos <= bit_pos + 4'b1;
                    end
                    if (bit_pos == 12 && sample == 15) 
                        state <= RX_STATE_STOP;
                end
                RX_STATE_STOP: begin
                    if (sample == 15 || (sample >= 8 && !Rx)) begin
                        state <= RX_STATE_START;
                        data <= scratch;
                        ready <= 1'b1;
                        sample <= 0;
                    end else begin
                        sample <= sample + 4'b1;
                    end
                end
                default: state <= RX_STATE_START;
                endcase
            end
        end
    end
endmodule