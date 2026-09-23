module ecc_memory_controller (
    input        clk,
    input        reset,
    input        write_enable,
    input        read_enable,
    input  [7:0]  data_in,

    output reg [7:0] data_out,
    output reg       single_error,
    output reg       valid
);

    reg [11:0] memory;
    reg [11:0] codeword;

    reg p1, p2, p4, p8;
    reg [3:0] syndrome;

    // Encode 8-bit data into 12-bit Hamming code
    function [11:0] encode_ecc;
        input [7:0] d;
        reg [11:0] c;
        begin
            c = 12'b0;

            // Data bits
            c[2]  = d[0];
            c[4]  = d[1];
            c[5]  = d[2];
            c[6]  = d[3];
            c[8]  = d[4];
            c[9]  = d[5];
            c[10] = d[6];
            c[11] = d[7];

            // Even parity bits
            c[0] = c[2] ^ c[4] ^ c[6] ^ c[8] ^ c[10];
            c[1] = c[2] ^ c[5] ^ c[6] ^ c[9] ^ c[10];
            c[3] = c[4] ^ c[5] ^ c[6] ^ c[11];
            c[7] = c[8] ^ c[9] ^ c[10] ^ c[11];

            encode_ecc = c;
        end
    endfunction

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            memory       <= 12'b0;
            data_out     <= 8'b0;
            single_error <= 1'b0;
            valid        <= 1'b0;
        end
        else begin
            valid        <= 1'b0;
            single_error <= 1'b0;

            if (write_enable) begin
                memory <= encode_ecc(data_in);
            end

            if (read_enable) begin
                codeword = memory;

                // Calculate syndrome
                p1 = codeword[0] ^ codeword[2] ^
                     codeword[4] ^ codeword[6] ^
                     codeword[8] ^ codeword[10];

                p2 = codeword[1] ^ codeword[2] ^
                     codeword[5] ^ codeword[6] ^
                     codeword[9] ^ codeword[10];

                p4 = codeword[3] ^ codeword[4] ^
                     codeword[5] ^ codeword[6] ^
                     codeword[11];

                p8 = codeword[7] ^ codeword[8] ^
                     codeword[9] ^ codeword[10] ^
                     codeword[11];

                syndrome = {p8, p4, p2, p1};

                // Correct single-bit error
                if (syndrome != 4'b0000) begin
                    codeword[syndrome - 1] =
                        ~codeword[syndrome - 1];

                    single_error <= 1'b1;
                end

                // Extract corrected data
                data_out[0] <= codeword[2];
                data_out[1] <= codeword[4];
                data_out[2] <= codeword[5];
                data_out[3] <= codeword[6];
                data_out[4] <= codeword[8];
                data_out[5] <= codeword[9];
                data_out[6] <= codeword[10];
                data_out[7] <= codeword[11];

                valid <= 1'b1;
            end
        end
    end

endmodule