class arbiter_base_test extends uvm_test;
    `uvm_component_utils(arbiter_base_test)

    arbiter_env env;
    
    function new(string name = "arbiter_base_test", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = arbiter_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        arbiter_rand_seq seq;

        phase.raise_objection(this);

        seq = arbiter_rand_seq::type_id::create("seq");
        seq.start(env.agent.sequencer);

        phase.drop_objection(this);
    endtask
endclass