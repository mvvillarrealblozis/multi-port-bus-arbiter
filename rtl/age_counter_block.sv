module age_counter_block #(
    parameter int N = 4,
    parameter int AGE_THRESHOLD = 4
) (
    input logic clk,
    input logic rst_n,
    input logic [N-1:0] req,
    input logic [N-1:0] gnt,
    
    output logic [N-1:0] aging_flags
);
    logic [$clog2(AGE_THRESHOLD+1)-1:0] age_counters [N];

    always_ff @(posedge clk) begin
        if (~rst_n) begin
            age_counters <= '0;
        end else begin 
            for (int i = 0; i < N; i++) begin
                // Curr req has BUS 
                if (gnt[i]) begin
                    age_counters[i] <= 0;
                end else if (req[i]) begin
                    if (age_counters[i] < AGE_THRESHOLD)begin
                        age_counters[i] <= age_counters[i] + 1;
                    end
                end else if (~req[i]) begin
                    // Req is not requesting 
                    age_counters[i] <= 0;
                end
            end
        end
    end

    always_comb begin
        for (int i = 0; i < N; i++) begin
            aging_flags[i] = (age_counters[i] >= AGE_THRESHOLD);
        end
    end
    
endmodule