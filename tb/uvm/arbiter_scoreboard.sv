class arbiter_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(arbiter_scoreboard)

    int N = 4;
    int AGE_THRESHOLD = 4;
    int STARVATION_THRESHOLD = 8;

    uvm_analysis_imp #(arbiter_seq_item, arbiter_scoreboard) ap;

    int gnt_count[];
    int wait_count[];

    function new(string name = "arbiter_scoreboard", uvm_component parent = null);
        super.new(name, parent);
        ap = new("ap", this);
        gnt_count  = new[N];
        wait_count = new[N];
    endfunction

    function void write(arbiter_seq_item tr);
        if (!tr.rst_n)
            return;
        if ((tr.gnt & (tr.gnt - 1)) != 0) begin
            `uvm_error("GNT_ERROR", "Error: gnt should be one hot or empty")
        end
        if ((tr.gnt & tr.req) != tr.gnt) begin
            `uvm_error("GNT_ERROR", "Error: gnt should only assert for one active requestor")
        end

        for (int i = 0; i < N; i++) begin
            if (tr.gnt[i]) begin
                gnt_count[i] = gnt_count[i] + 1;
            end
        end

        for (int i = 0; i < N; i++) begin
            if (tr.req[i] && ~tr.gnt[i]) begin
                wait_count[i] = wait_count[i] + 1;
                if (tr.scheme == 0 && wait_count[i] > STARVATION_THRESHOLD)
                    `uvm_error("FAIRNESS", $sformatf("Requestor %0d starved for %0d cycles", i, wait_count[i]))
            end else if (tr.gnt[i]) begin
                wait_count[i] = '0;
            end else begin
                wait_count[i] = '0;
            end
        end

    endfunction
endclass