// `define DEBUG_EN

`ifdef DEBUG_EN
    `define DEBUG (* mark_debug = "true" *)
`else
    `define DEBUG
`endif
