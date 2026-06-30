module if_id_reg(
    input clk, rst,
    input [31:0] pc_plus_4_in, instr_in,
    output reg [31:0] pc_plus_4_out, instr_out
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            pc_plus_4_out <= 0; instr_out <= 0;
        end else begin
            pc_plus_4_out <= pc_plus_4_in; instr_out <= instr_in;
        end
    end
endmodule

module id_ex_reg(
    input clk, rst,
    input reg_write_in, mem_to_reg_in, branch_in, mem_read_in, mem_write_in, reg_dst_in, alu_src_in,
    input [1:0] alu_op_in,
    output reg reg_write_out, mem_to_reg_out, branch_out, mem_read_out, mem_write_out, reg_dst_out, alu_src_out,
    output reg [1:0] alu_op_out,
    input [31:0] pc_plus_4_in, reg1_data_in, reg2_data_in, sign_ext_in,
    input [4:0] rt_in, rd_in,
    output reg [31:0] pc_plus_4_out, reg1_data_out, reg2_data_out, sign_ext_out,
    output reg [4:0] rt_out, rd_out
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            reg_write_out <= 0; mem_to_reg_out <= 0; branch_out <= 0; mem_read_out <= 0;
            mem_write_out <= 0; reg_dst_out <= 0; alu_src_out <= 0; alu_op_out <= 0;
            pc_plus_4_out <= 0; reg1_data_out <= 0; reg2_data_out <= 0; sign_ext_out <= 0;
            rt_out <= 0; rd_out <= 0;
        end else begin
            reg_write_out <= reg_write_in; mem_to_reg_out <= mem_to_reg_in; branch_out <= branch_in;
            mem_read_out <= mem_read_in; mem_write_out <= mem_write_in; reg_dst_out <= reg_dst_in;
            alu_src_out <= alu_src_in; alu_op_out <= alu_op_in;
            pc_plus_4_out <= pc_plus_4_in; reg1_data_out <= reg1_data_in; reg2_data_out <= reg2_data_in;
            sign_ext_out <= sign_ext_in; rt_out <= rt_in; rd_out <= rd_in;
        end
    end
endmodule

module ex_mem_reg(
    input clk, rst,
    input reg_write_in, mem_to_reg_in, branch_in, mem_read_in, mem_write_in,
    output reg reg_write_out, mem_to_reg_out, branch_out, mem_read_out, mem_write_out,
    input [31:0] branch_target_in, alu_result_in, reg2_data_in,
    input zero_in,
    input [4:0] write_reg_in,
    output reg [31:0] branch_target_out, alu_result_out, reg2_data_out,
    output reg zero_out,
    output reg [4:0] write_reg_out
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            reg_write_out <= 0; mem_to_reg_out <= 0; branch_out <= 0; mem_read_out <= 0; mem_write_out <= 0;
            branch_target_out <= 0; zero_out <= 0; alu_result_out <= 0; reg2_data_out <= 0; write_reg_out <= 0;
        end else begin
            reg_write_out <= reg_write_in; mem_to_reg_out <= mem_to_reg_in; branch_out <= branch_in;
            mem_read_out <= mem_read_in; mem_write_out <= mem_write_in;
            branch_target_out <= branch_target_in; zero_out <= zero_in; alu_result_out <= alu_result_in;
            reg2_data_out <= reg2_data_in; write_reg_out <= write_reg_in;
        end
    end
endmodule

module mem_wb_reg(
    input clk, rst,
    input reg_write_in, mem_to_reg_in,
    output reg reg_write_out, mem_to_reg_out,
    input [31:0] read_data_in, alu_result_in,
    input [4:0] write_reg_in,
    output reg [31:0] read_data_out, alu_result_out,
    output reg [4:0] write_reg_out
);
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            reg_write_out <= 0; mem_to_reg_out <= 0;
            read_data_out <= 0; alu_result_out <= 0; write_reg_out <= 0;
        end else begin
            reg_write_out <= reg_write_in; mem_to_reg_out <= mem_to_reg_in;
            read_data_out <= read_data_in; alu_result_out <= alu_result_in; write_reg_out <= write_reg_in;
        end
    end
endmodule
