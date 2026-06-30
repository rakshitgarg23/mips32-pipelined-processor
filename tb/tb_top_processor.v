`timescale 1ns/1ps

module tb_top_processor;

    reg clk;
    reg rst;
    
    top_processor dut(
        .clk(clk),
        .rst(rst)
    );
    
    // Clock generation
    always #5 clk = ~clk;
    
    initial begin
        $dumpfile("tb_top_processor.vcd");
        $dumpvars(0, tb_top_processor);
        
        // Initialize
        clk = 0;
        rst = 1;
        
        // Release reset
        #15 rst = 0;
        
        // Wait for enough cycles to complete the instructions
        #300;
        
        // Display some results
        $display("----------------------------------------");
        $display("Simulation finished.");
        $display("Register 1: %d (Expected: 5)", dut.reg_file_inst.registers[1]);
        $display("Register 2: %d (Expected: 10)", dut.reg_file_inst.registers[2]);
        $display("Register 3: %d (Expected: 15)", dut.reg_file_inst.registers[3]);
        $display("Register 4: %d (Expected: 15)", dut.reg_file_inst.registers[4]);
        $display("Memory[1] : %d (Expected: 15)", dut.dmem_inst.memory[1]);
        $display("----------------------------------------");
        
        $finish;
    end

endmodule
