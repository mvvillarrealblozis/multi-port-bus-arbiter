module priority_resolver #(
    parameter int N = 4
)(
    input  logic                     scheme,
    input  logic [N-1:0]             req,
    input  logic [$clog2(N)-1:0]     last_winner,
    input  logic [N-1:0]             aging_flags,
    
    output logic [$clog2(N)-1:0]     next_winner,
    output logic                     valid
);  
    logic winner_found;
    int idx;

    always_comb begin
        if (scheme == 0) begin
            // Fixed priority
            next_winner = '0;
            winner_found = '0;
            for (int i = 0; i < N; i++) begin
                if (aging_flags[i] && ~winner_found) begin
                    winner_found = 1;
                    next_winner = i;
                end
            end
            if (~winner_found) begin
                for (int i = 0; i < N; i++) begin
                    if (req[i] && ~winner_found) begin
                        winner_found = 1;
                        next_winner = i;
                    end
                end
            end 
        end else begin
            // Round-robin
            next_winner = '0;
            winner_found = '0;
            idx = '0;

            for (int i = 0; i < N; i++) begin
                // Rotate scan start to last_winner+1, wrapping around with modulo N
                idx = (last_winner + 1 + i) % N;
                if (req[idx] && ~winner_found) begin
                    winner_found = 1;
                    next_winner = idx;
                end
            end
        end
    end 
    
    assign valid = winner_found;

endmodule