`include "defines.svh"

module CSR #(parameter 
            ADDR_WIDTH = 16, 
            DATA_WIDTH = 32
            )
(
    //Master side I/O
    input   logic                       pclk,
    input   logic                       preset_n,

    input   logic                       psel,       
    input   logic                       penable,
    input   logic                       pwrite, 
    input   logic     [ADDR_WIDTH-1:0]  paddr,
    input   logic     [DATA_WIDTH-1:0]  pwdata,
    output  logic     [DATA_WIDTH-1:0]  prdata,
    output  logic                       pready,
    output  logic                       pslverr,
    //Other side of CSR I/0
    output  logic                       Intr,            //Interupt pin
    input   logic                       Tx_done_i,      //For Status_reg
    input   logic                       Rx_done_i,
    input   logic                       Arb_done_i
);    
    //Remaining CSR Registers are declared in the "define.svh" file 
    localparam logic [ADDR_WIDTH-1:0]CFG_REG_ADDR[`CFG_REG_END:`CFG_REG_START] = '{16'h0010, 16'h0014, 16'h0018,                                                                           16'h001C, 16'h0020 };

    //Control and Status Registers
    reg [16:0]    config_reg0; 
    reg [20:0]    config_reg1; 
    reg [2:0]     status_reg;
    reg [2:0]     Interrupt_EN;
    reg [DATA_WIDTH-1:0]    config_reg[`CFG_REG_END:`CFG_REG_START];

    reg [DATA_WIDTH-1:0]   prdata_o;

//The read and write operations
    wire write_op = psel && penable && pwrite;
    wire read_op  = psel && penable && ~pwrite;
    wire pHigh;

    assign pready = psel && penable;
    assign Intr = |(status_reg[2:0] & Interrupt_EN[2:0]) ;      //Interrupt Signal generated by the CSR 
    assign prdata = prdata_o;
    assign pHigh = psel && penable && pready ;                  //with Intend to use for pslverr signal

    always @(posedge pclk or negedge preset_n) begin
        if(~preset_n) begin  
            config_reg0 <= 'b0;
            config_reg1 <= 'b0;
            status_reg  <= 'b0;      
            Interrupt_EN<= 'b0;
            for (int i = `CFG_REG_START; i <= `CFG_REG_END; i++) begin      //config_reg4 to config_reg8
                config_reg[i] <= 16'b0;
            end
        end

        else if(write_op) begin
                if(paddr == `CFG_REG0_ADDR) begin
                    config_reg0 <= {pwdata[24:16],pwdata[7:0]};
                end

                else if(paddr == `CFG_REG1_ADDR) begin
                    config_reg1 <= pwdata[20:0];
                end

                //write 1 clear
               /* else if(paddr == STATUS_REG_ADDR) begin
                    `ifdef WRITE_1_CLR            //clear those bits of the status_reg coresponding to the pwdata as 1
                        status_reg[2:0] <= status_reg[2:0] & ~pwdata[2:0];
                    `endif
                end*/

                else if(paddr == `INTR_EN_ADDR) begin
                    Interrupt_EN  <= pwdata[2:0];
                end

                else begin
                    for (int i = `CFG_REG_START; i <= `CFG_REG_END; i++) begin
                        if (paddr == CFG_REG_ADDR[i]) begin
                            config_reg[i] <= pwdata ;
                        end
                    end
                end
        end
       /* else if(read_op && (paddr == STATUS_REG_ADDR)) begin //For status register to Perform the Clear on Read
            status_reg[2:0]  <= 'b0;
        end*/
    end

    //For read Operation
    always @(*) begin
    prdata_o  = 'b0;
            case (paddr)
                `CFG_REG0_ADDR : begin prdata_o = {7'b0, config_reg0[16:8], 8'b0, config_reg0[7:0]}; end
               
                `CFG_REG1_ADDR : begin prdata_o = {11'b0, config_reg1[20:0]}; end
               
                `STATUS_REG_ADDR : begin prdata_o  = {29'b0, status_reg[2:0]} ; end
              
                `INTR_EN_ADDR : begin prdata_o = {29'b0, Interrupt_EN[2:0]}; end
                default : begin
                     for (int i = `CFG_REG_START; i <= `CFG_REG_END; i++) begin
                        if (paddr == CFG_REG_ADDR[i]) begin
                            prdata_o = config_reg[i];
                        end
                    end
                end                  
            endcase
    end

    //setting the Status Register bits
    always @(posedge pclk) begin
        status_reg  <= {Arb_done_i, Rx_done_i, Tx_done_i}; 
        if(paddr == `STATUS_REG_ADDR) begin
            if(write_op) begin
                `ifdef WRITE_1_CLR 
                    status_reg[2:0] <= status_reg[2:0] & ~pwdata[2:0];
                `endif
            end else if(read_op) begin
                status_reg[2:0] <= 'b0;     //in read operation by default the status register is cleared on Read
            end
        end
    end

    //Slave Error Logic 
    always @(*) begin
       if(pHigh && (paddr > 16'h0020)) begin
            pslverr = 1'b1;
        end
        else begin
            pslverr = 1'b0;
        end
    end
endmodule
