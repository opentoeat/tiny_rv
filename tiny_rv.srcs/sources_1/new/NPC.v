module NPC(
    input   wire    [31:0]  current_pc,
    input   wire    [31:0]  branch_pc,
    input   wire            PCSel,
    input                   stop_IF,
    output  wire     [31:0] npc,
    output  wire    [31:0]  pc4
);

assign pc4 = stop_IF ? current_pc : current_pc + 32'd4;

//判断下一个程序的流向
assign npc = PCSel ? branch_pc : pc4;



endmodule 