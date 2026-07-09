class arbiter_agent extends uvm_agent;
    `uvm_component_utils(arbiter_agent)

    arbiter_sequencer sequencer;
    arbiter_driver driver;
    arbiter_monitor monitor; 

    function new(string name = "arbiter_agent", uvm_component parent =  null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        sequencer = arbiter_sequencer::type_id::create("sequencer", this);
        driver = arbiter_driver::type_id::create("driver", this);
        monitor = arbiter_monitor::type_id::create("monitor", this);
    endfunction

    function void connect_phase(uvm_phase phase); 
        super.connect_phase(phase);
        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction
endclass