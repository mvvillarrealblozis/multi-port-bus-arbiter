interface arbiter_if #(
    parameter int N = 4
) (
    input logic clk,
    input logic rst_n
);
    logic [N-1:0] req;
    logic scheme;
    logic [N-1:0] gnt;
    logic gnt_valid;
endinterface