import subprocess

IVERILOG = "iverilog"
VVP = "vvp"

#compile testbenches and generate waveforms
subprocess.call(
    [IVERILOG, "-o", "./created_modules/tests/bin/load_mask_tb", "./created_modules/tests/load_mask_tb.v",
        "&&",
    VVP, "./created_modules/tests/bin/load_mask_tb"],
    shell=True
)

subprocess.call(
    [IVERILOG, "-o", "./created_modules/tests/bin/store_mask_tb", "./created_modules/tests/store_mask_tb.v",
        "&&",
    VVP, "./created_modules/tests/bin/store_mask_tb"],
    shell=True
)