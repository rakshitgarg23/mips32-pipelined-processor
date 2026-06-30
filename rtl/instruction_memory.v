module instruction_memory(
    input [31:0] pc,
    output [31:0] instruction
);
    reg [31:0] mem [0:63]; 
    integer i;
    
    initial begin
        for (i = 0; i < 64; i = i + 1) mem[i] = 32'b0; // NOP
        
        // Program with manually inserted NOPs for data hazards
        
        // 1. ADDI r1, r0, 5  (pc = 0)
        mem[0] = {6'b001000, 5'd0, 5'd1, 16'd5};
        // NOPs at pc=4, 8, 12
        mem[1] = 32'b0;
        mem[2] = 32'b0;
        mem[3] = 32'b0;
        
        // 2. ADDI r2, r0, 10 (pc = 16)
        mem[4] = {6'b001000, 5'd0, 5'd2, 16'd10};
        // NOPs at pc=20, 24, 28
        mem[5] = 32'b0;
        mem[6] = 32'b0;
        mem[7] = 32'b0;
        
        // 3. ADD r3, r1, r2  (pc = 32)
        mem[8] = {6'b000000, 5'd1, 5'd2, 5'd3, 5'd0, 6'b100000};
        // NOPs at pc=36, 40, 44
        mem[9] = 32'b0;
        mem[10] = 32'b0;
        mem[11] = 32'b0;
        
        // 4. SW r3, 4(r0)    (pc = 48)
        mem[12] = {6'b101011, 5'd0, 5'd3, 16'd4};
        // NOPs at pc=52, 56, 60
        mem[13] = 32'b0;
        mem[14] = 32'b0;
        mem[15] = 32'b0;
        
        // 5. LW r4, 4(r0)    (pc = 64)
        mem[16] = {6'b100011, 5'd0, 5'd4, 16'd4};
    end
    
    assign instruction = mem[pc[31:2]];
endmodule
