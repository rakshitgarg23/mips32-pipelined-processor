module top_processor(
    input clk,
    input rst
);
    // ---------------- IF Stage ---------------- //
    wire [31:0] pc_in, pc_out, instr, pc_plus_4;
    wire pc_src;
    wire [31:0] branch_target_ex_mem;
    
    assign pc_in = pc_src ? branch_target_ex_mem : pc_plus_4;
    
    program_counter pc_inst (
        .clk(clk), .rst(rst), .pc_in(pc_in), .pc_out(pc_out)
    );
    
    assign pc_plus_4 = pc_out + 4;
    
    instruction_memory imem_inst (
        .pc(pc_out), .instruction(instr)
    );
    
    // ---------------- IF/ID Register ---------------- //
    wire [31:0] if_id_pc_plus_4, if_id_instr;
    if_id_reg if_id (
        .clk(clk), .rst(rst),
        .pc_plus_4_in(pc_plus_4), .instr_in(instr),
        .pc_plus_4_out(if_id_pc_plus_4), .instr_out(if_id_instr)
    );
    
    // ---------------- ID Stage ---------------- //
    wire reg_dst, alu_src, mem_to_reg, reg_write, mem_read, mem_write, branch;
    wire [1:0] alu_op;
    wire [31:0] reg1_data, reg2_data, sign_ext_imm;
    
    control_unit ctrl_inst (
        .opcode(if_id_instr[31:26]),
        .reg_dst(reg_dst), .alu_src(alu_src), .mem_to_reg(mem_to_reg),
        .reg_write(reg_write), .mem_read(mem_read), .mem_write(mem_write),
        .branch(branch), .alu_op(alu_op)
    );
    
    wire [4:0] wb_write_reg;
    wire [31:0] wb_write_data;
    wire wb_reg_write;
    
    register_file reg_file_inst (
        .clk(clk), .rst(rst),
        .reg_write(wb_reg_write),
        .read_reg1(if_id_instr[25:21]), .read_reg2(if_id_instr[20:16]),
        .write_reg(wb_write_reg), .write_data(wb_write_data),
        .read_data1(reg1_data), .read_data2(reg2_data)
    );
    
    assign sign_ext_imm = {{16{if_id_instr[15]}}, if_id_instr[15:0]};
    
    // ---------------- ID/EX Register ---------------- //
    wire id_ex_reg_write, id_ex_mem_to_reg, id_ex_branch, id_ex_mem_read, id_ex_mem_write;
    wire id_ex_reg_dst, id_ex_alu_src;
    wire [1:0] id_ex_alu_op;
    wire [31:0] id_ex_pc_plus_4, id_ex_reg1, id_ex_reg2, id_ex_sign_ext;
    wire [4:0] id_ex_rt, id_ex_rd;
    
    id_ex_reg id_ex (
        .clk(clk), .rst(rst),
        .reg_write_in(reg_write), .mem_to_reg_in(mem_to_reg), .branch_in(branch),
        .mem_read_in(mem_read), .mem_write_in(mem_write), .reg_dst_in(reg_dst),
        .alu_src_in(alu_src), .alu_op_in(alu_op),
        .pc_plus_4_in(if_id_pc_plus_4), .reg1_data_in(reg1_data), .reg2_data_in(reg2_data),
        .sign_ext_in(sign_ext_imm), .rt_in(if_id_instr[20:16]), .rd_in(if_id_instr[15:11]),
        
        .reg_write_out(id_ex_reg_write), .mem_to_reg_out(id_ex_mem_to_reg), .branch_out(id_ex_branch),
        .mem_read_out(id_ex_mem_read), .mem_write_out(id_ex_mem_write), .reg_dst_out(id_ex_reg_dst),
        .alu_src_out(id_ex_alu_src), .alu_op_out(id_ex_alu_op),
        .pc_plus_4_out(id_ex_pc_plus_4), .reg1_data_out(id_ex_reg1), .reg2_data_out(id_ex_reg2),
        .sign_ext_out(id_ex_sign_ext), .rt_out(id_ex_rt), .rd_out(id_ex_rd)
    );
    
    // ---------------- EX Stage ---------------- //
    wire [31:0] alu_in2;
    wire [4:0] ex_write_reg;
    wire [31:0] alu_result;
    wire alu_zero;
    wire [31:0] branch_target;
    reg [2:0] alu_ctrl;
    
    assign alu_in2 = id_ex_alu_src ? id_ex_sign_ext : id_ex_reg2;
    assign ex_write_reg = id_ex_reg_dst ? id_ex_rd : id_ex_rt;
    assign branch_target = id_ex_pc_plus_4 + (id_ex_sign_ext << 2);
    
    always @(*) begin
        case(id_ex_alu_op)
            2'b00: alu_ctrl = 3'b000; // ADD (LW/SW/ADDI)
            2'b01: alu_ctrl = 3'b001; // SUB (BEQ)
            2'b10: begin // R-type
                case(id_ex_sign_ext[5:0])
                    6'b100000: alu_ctrl = 3'b000; // ADD
                    6'b100010: alu_ctrl = 3'b001; // SUB
                    6'b100100: alu_ctrl = 3'b010; // AND
                    6'b100101: alu_ctrl = 3'b011; // OR
                    default: alu_ctrl = 3'b000;
                endcase
            end
            default: alu_ctrl = 3'b000;
        endcase
    end
    
    alu alu_inst (
        .a(id_ex_reg1), .b(alu_in2), .alu_control(alu_ctrl),
        .result(alu_result), .zero(alu_zero)
    );
    
    // ---------------- EX/MEM Register ---------------- //
    wire ex_mem_reg_write, ex_mem_mem_to_reg, ex_mem_branch, ex_mem_mem_read, ex_mem_mem_write;
    wire ex_mem_zero;
    wire [31:0] ex_mem_alu_result, ex_mem_reg2;
    wire [4:0] ex_mem_write_reg;
    
    ex_mem_reg ex_mem (
        .clk(clk), .rst(rst),
        .reg_write_in(id_ex_reg_write), .mem_to_reg_in(id_ex_mem_to_reg), .branch_in(id_ex_branch),
        .mem_read_in(id_ex_mem_read), .mem_write_in(id_ex_mem_write),
        .branch_target_in(branch_target), .zero_in(alu_zero), .alu_result_in(alu_result),
        .reg2_data_in(id_ex_reg2), .write_reg_in(ex_write_reg),
        
        .reg_write_out(ex_mem_reg_write), .mem_to_reg_out(ex_mem_mem_to_reg), .branch_out(ex_mem_branch),
        .mem_read_out(ex_mem_mem_read), .mem_write_out(ex_mem_mem_write),
        .branch_target_out(branch_target_ex_mem), .zero_out(ex_mem_zero), .alu_result_out(ex_mem_alu_result),
        .reg2_data_out(ex_mem_reg2), .write_reg_out(ex_mem_write_reg)
    );
    
    // ---------------- MEM Stage ---------------- //
    wire [31:0] mem_read_data;
    
    assign pc_src = ex_mem_branch & ex_mem_zero;
    
    data_memory dmem_inst (
        .clk(clk),
        .mem_read(ex_mem_mem_read), .mem_write(ex_mem_mem_write),
        .address(ex_mem_alu_result), .write_data(ex_mem_reg2),
        .read_data(mem_read_data)
    );
    
    // ---------------- MEM/WB Register ---------------- //
    wire mem_wb_mem_to_reg;
    wire [31:0] mem_wb_read_data, mem_wb_alu_result;
    
    mem_wb_reg mem_wb (
        .clk(clk), .rst(rst),
        .reg_write_in(ex_mem_reg_write), .mem_to_reg_in(ex_mem_mem_to_reg),
        .read_data_in(mem_read_data), .alu_result_in(ex_mem_alu_result), .write_reg_in(ex_mem_write_reg),
        
        .reg_write_out(wb_reg_write), .mem_to_reg_out(mem_wb_mem_to_reg),
        .read_data_out(mem_wb_read_data), .alu_result_out(mem_wb_alu_result), .write_reg_out(wb_write_reg)
    );
    
    // ---------------- WB Stage ---------------- //
    assign wb_write_data = mem_wb_mem_to_reg ? mem_wb_read_data : mem_wb_alu_result;
    
endmodule
