class arbiter_seq_item #(
    parameter int N = 4
) extends uvm_sequence_item;
    `uvm_object_utils(arbiter_seq_item)

    rand logic [N-1:0] req;
    rand logic rst_n;
    rand logic scheme;
    
    logic [N-1:0] gnt;
    logic gnt_valid; 

    constraint valid_op {
        req != '0;
    }

    function new(string name = "arbiter_seq_item");
        super.new(name);
    endfunction 
endclass