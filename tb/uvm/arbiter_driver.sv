class arbiter_driver extends uvm_driver #(arbiter_seq_item);
    `uvm_component_utils(arbiter_driver)

    virtual arbiter_if vif;

    function new(string name = "arbiter_driver", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual arbiter_if)::get(this, "", "vif", vif))
            `uvm_fatal("DRIVER", "Could not get vif from config_db")
    endfunction

    task run_phase(uvm_phase phase);
        wait (vif.rst_n);
        forever begin
            arbiter_seq_item item;
            seq_item_port.get_next_item(item);
            vif.req <= item.req;
            vif.scheme <= item.scheme;
            @(posedge vif.clk);
            #1;
            seq_item_port.item_done();
        end
    endtask
endclass