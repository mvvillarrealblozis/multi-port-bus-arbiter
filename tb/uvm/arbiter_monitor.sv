class arbiter_monitor extends uvm_monitor;
    `uvm_component_utils(arbiter_monitor)

    virtual arbiter_if vif;
    uvm_analysis_port #(arbiter_seq_item) ap;

    function new(string name = "arbiter_monitor", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db #(virtual arbiter_if)::get(this, "", "vif", vif))
            `uvm_fatal("MONITOR", "Could not get vif from config_db")
    endfunction

    task run_phase(uvm_phase phase);
        forever begin
            @(posedge vif.clk);
            #1;
            arbiter_seq_item tr;
            tr = arbiter_seq_item::type_id::create("tr");
            tr.req = vif.req;
            tr.scheme = vif.scheme;
            tr.rst_n = vif.rst_n;
            tr.gnt = vif.gnt;
            tr.gnt_valid = vif.gnt_valid;
            ap.write(tr);
        end
    endtask
endclass