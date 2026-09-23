`timescale 1ns/1ps

module ecc_memory_controller_tb;

    reg        clk;
    reg        reset;
    reg        write_enable;
    reg        read_enable;
    reg [7:0]  data_in;

    wire [7:0] data_out;
    wire       single_error;
    wire       valid;

    ecc_memory_controller uut (
        .clk(clk),
        .reset(reset),
        .write_enable(write_enable),
        .read_enable(read_enable),
        .data_in(data_in),
        .data_out(data_out),
        .single_error(single_error),
        .valid(valid)
    );

    always #5 clk = ~clk;

    initial begin
        $monitor("Time=%0t | Write=%b | Read=%b | Data In=%h | Data Out=%h | Error=%b | Valid=%b",
                 $time, write_enable, read_enable,
                 data_in, data_out, single_error, valid);

        clk = 0;
        reset = 1;
        write_enable = 0;
        read_enable = 0;
        data_in = 8'h00;

        #10;
        reset = 0;

        // Write data
        #10;
        data_in = 8'hA5;
        write_enable = 1;

        #10;
        write_enable = 0;

        // Normal read
        #10;
        read_enable = 1;

        #10;
        read_enable = 0;

        // Introduce a single-bit error
        #10;
        uut.memory[5] = ~uut.memory[5];

        // Read corrupted data
        #10;
        read_enable = 1;

        #10;
        read_enable = 0;

        #10;
        $finish;
    end

endmodule