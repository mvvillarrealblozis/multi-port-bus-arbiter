`timescale 1ns/1ps
import uvm_pkg::*;

`include "uvm_macros.svh"

`include "arbiter_if.sv"
`include "arbiter_seq_item.sv"
`include "arbiter_sequencer.sv"
`include "arbiter_driver.sv"
`include "arbiter_monitor.sv"
`include "arbiter_scoreboard.sv"
`include "arbiter_agent.sv"
`include "arbiter_env.sv"
`include "arbiter_rand_seq.sv"
`include "arbiter_test.sv"

module arbiter_tb_top;
    parameter int N = 4;
    parameter int MAX_HOLD = 8;
    parameter int AGE_THRESHOLD = 4;

    logic clk;

    arbiter_if #(.N(N)) vif_inst(
        .clk(clk)
    );

    arbiter_top #(
        .N(N),
        .MAX_HOLD(MAX_HOLD),
        .AGE_THRESHOLD(AGE_THRESHOLD)
    ) dut (
        .clk            (vif_inst.clk),
        .rst_n          (vif_inst.rst_n),
        .req            (vif_inst.req),
        .scheme         (vif_inst.scheme),
        .gnt            (vif_inst.gnt),
        .gnt_valid      (vif_inst.gnt_valid)
    );

    initial begin
        $dumpfile("dump.vcd");
        $dumpvars(0, arbiter_tb_top);
	end

    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        vif_inst.rst_n = 0;
        #20;
        vif_inst.rst_n = 1;
    end

    initial begin
        uvm_config_db #(virtual arbiter_if)::set(null, "*", "vif", vif_inst);
        run_test("arbiter_base_test");
    end
endmodule