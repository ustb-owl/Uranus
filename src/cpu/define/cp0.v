// coprocessor instructions
`define CP0_MFC0                 5'b00000
`define CP0_MTC0                 5'b00100
`define CP0_ERET                 5'b10000

// coprocessor 0 register address definitions
`define CP0_REG_BADVADDR         5'b01000
`define CP0_REG_COUNT            5'b01001
`define CP0_REG_COMPARE          5'b01011
`define CP0_REG_STATUS           5'b01100
`define CP0_REG_CAUSE            5'b01101
`define CP0_REG_EPC              5'b01110
`define CP0_REG_PRID             5'b01111   // unused?
`define CP0_REG_CONFIG           5'b10000   // unused?

// coprocessor 0 register value & write mask
`define CP0_REG_BADVADDR_VALUE   32'h00000000
`define CP0_REG_BADVADDR_MASK    32'h00000000
`define CP0_REG_STATUS_VALUE     32'h0040ff00
`define CP0_REG_STATUS_MASK      32'h0000ff03
`define CP0_REG_CAUSE_VALUE      32'h00000000
`define CP0_REG_CAUSE_MASK       32'h00000300
`define CP0_REG_EPC_VALUE        32'h00000000
`define CP0_REG_EPC_MASK         32'hffffffff
// NOTE: 0x55 -> U -> USTB, 0x0000 -> Uranus Zero
`define CP0_REG_PRID_VALUE       32'h00550000
`define CP0_REG_PRID_MASK        32'h00000000
`define CP0_REG_CONFIG_VALUE     32'h00008000
`define CP0_REG_CONFIG_MASK      32'h00000000

// Coprocessor 0 segment definitions
`define CP0_SEG_HWI              15:10
`define CP0_SEG_SWI              9:8
`define CP0_SEG_EXCCODE          6:2

// ExcCode definitions
`define CP0_EXECODE_INT          5'h00
`define CP0_EXECODE_ADEL         5'h04
`define CP0_EXECODE_ADES         5'h05
`define CP0_EXECODE_SYS          5'h08
`define CP0_EXECODE_BP           5'h09
`define CP0_EXECODE_RI           5'h0a
`define CP0_EXECODE_OV           5'h0c
