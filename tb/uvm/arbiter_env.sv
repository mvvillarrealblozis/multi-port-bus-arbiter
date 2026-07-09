class arbiter_env extends uvm_env;
    `uvm_component_utils(arbiter_env)

    arbiter_agent agent;
    arbiter_scoreboard scoreboard;

    function new (string name = "arbiter_env", uvm_component parent = null);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent = arbiter_agent::type_id::create("agent", this);
        scoreboard = arbiter_scoreboard::type_id::create("scoreboard", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        super.connect_phase(phase);
        agent.monitor.ap.connect(scoreboard.ap);
    endfunction
endclass