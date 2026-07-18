UART with Hamming (12,8) Error Detection and Correction

A Verilog-based UART implementation integrated with a Hamming (12,8) encoder and decoder for error detection and correction.

Features
- System Clock:50 MHz
- Baud Rate:Configurable (e.g., 9600, 115200 bps)
- **Error Control: Hamming (12,8) code (corrects 1-bit errors, detects errors)

Architecture
The system includes 5 main modules:
1. Baud Rate Generator (`uart_baud`):Generates timing flags for TX and RX.
2. Hamming Encoder (`h_enc`): Encodes 8-bit parallel input data into a 12-bit frame.
3. UART Transmitter (`uart_Tx`): Converts 12-bit parallel data into serial bits for transmission (TX).
4. UART Receiver (`uart_Rx`): Samples serial input bits (RX) and reconstructs the 12-bit parallel frame.
5. Hamming Decoder (`h_dec`): Calculates syndromes, automatically corrects single-bit errors, and outputs the original clean 8-bit data.

Tools/Program
- Language: Verilog HDL
- Synthesis: Intel Quartus Prime
- Simulation: ModelSim
