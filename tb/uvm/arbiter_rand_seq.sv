class arbiter_rand_seq extends uvm_sequence #(arbiter_seq_item);
    `uvm_object_utils(arbiter_rand_seq)

    function new(string name = "arbiter_rand_seq");
        super.new(name);
    endfunction

    task body();
        for (int i = 0; i < 300; i++) begin
            arbiter_seq_item item;
            item = arbiter_seq_item::type_id::create("item");
            start_item(item);
            if (!item.randomize() with { req != '0; })
                `uvm_fatal("SEQ", "Randomization failed")
            finish_item(item);
        end
    endtask
endclass