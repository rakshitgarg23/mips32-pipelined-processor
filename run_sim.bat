@echo off
echo Compiling Verilog files...
iverilog -o sim.vvp rtl/program_counter.v rtl/instruction_memory.v rtl/register_file.v rtl/alu.v rtl/control_unit.v rtl/data_memory.v rtl/pipeline_registers.v rtl/top_processor.v tb/tb_top_processor.v
if %errorlevel% neq 0 (
    echo Compilation Failed!
    exit /b %errorlevel%
)
echo Running simulation...
vvp sim.vvp
echo Opening waveform in GTKWave...
gtkwave tb_top_processor.vcd
