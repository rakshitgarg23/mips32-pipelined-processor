module data_memory(
    input clk,
    input mem_read,
    input mem_write,
    input [31:0] address,
    input [31:0] write_data,
    output [31:0] read_data
);
    reg [31:0] memory [0:63]; 
    integer i;
    
    initial begin
        for (i = 0; i < 64; i = i + 1) memory[i] = 32'b0;
    end
    
    always @(posedge clk) begin
        if (mem_write) begin
            memory[address[31:2]] <= write_data;
        end
    end
    
    assign read_data = mem_read ? memory[address[31:2]] : 32'b0;
endmodule
