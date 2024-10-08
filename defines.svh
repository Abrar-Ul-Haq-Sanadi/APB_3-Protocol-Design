//This file contains all the macros related to the CSR(control and shift Registers)

    `define WRITE_1_CLR

    //Addresses of the CSR Registers
    `define CFG_REG0_ADDR    16'h0000
    `define CFG_REG1_ADDR    16'h0004  
    `define STATUS_REG_ADDR  16'h0008
    `define INTR_EN_ADDR     16'h000C

    //for the CSR Register from 4 to 8
    `define CFG_REG_START 4
    `define CFG_REG_END   8    