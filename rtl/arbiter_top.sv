module arbiter_top #(
    parameter int N             = 4,
    parameter int MAX_HOLD      = 8,
    parameter int AGE_THRESHOLD = 4
)(
    input  logic            clk,
    input  logic            rst_n,
    input  logic [N-1:0]    req,
    input  logic            scheme,
    output logic [N-1:0]    gnt,
    output logic            gnt_valid
);
    logic [N-1:0] aging_flags;

    logic [N-1:0] gnt_reg;

    logic [$clog2(N)-1:0] winner_idx_next;
    
    logic [$clog2(N)-1:0] winner_idx_reg;
    
    logic gnt_active;

    logic [$clog2(MAX_HOLD+1)-1:0] hold_cnt;

    logic winner_found;

    age_counter_block #(
        .N(N),
        .AGE_THRESHOLD(AGE_THRESHOLD)
    ) u_age_counter_block (
        .clk(clk),
        .rst_n(rst_n),
        .req(req),
        .gnt(gnt_reg),
        .aging_flags(aging_flags)
    );

    priority_resolver #(
        .N(N)
    ) u_priority_resolver (
        .scheme(scheme),
        .req(req),
        .last_winner(winner_idx_reg),
        .aging_flags(aging_flags),
        .next_winner(winner_idx_next),
        .valid(winner_found)
    );

    always_ff @(posedge clk) begin
    if (~rst_n) begin
        winner_idx_reg <= '0;
        hold_cnt <= '0;
        gnt_reg <= '0;
    end else if (gnt_active) begin
        if (hold_cnt == MAX_HOLD - 1) begin
            hold_cnt <= '0;
            gnt_reg <= '0;
        end else begin
            hold_cnt <= hold_cnt + 1;
        end
    end else begin
        hold_cnt <= '0;
        if (winner_found) begin
            gnt_reg <= (1 << winner_idx_next);
            winner_idx_reg <= winner_idx_next;
        end
    end
end
    
    assign gnt_active = |gnt;
    assign gnt = gnt_reg;
    assign gnt_valid = gnt_active;

endmodule