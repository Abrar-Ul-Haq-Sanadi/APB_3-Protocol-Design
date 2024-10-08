module apb_wrapper #(parameter 

            ADDR_WIDTH = 16,
            DATA_WIDTH = 32 )

(
    input   logic                       pclk,
    input   logic                       preset_n,
    
    input   logic                       tx_valid,
    input   logic   [1:0]               tx_encode,
    input   logic   [ADDR_WIDTH-1:0]    tx_addr,
    input   logic   [DATA_WIDTH-1:0]    tx_wdata,

    output  logic   [DATA_WIDTH-1:0]    tx_rdata,
    output  logic                       tx_rvalid, 
    output  logic                       Intr ,           //Interrupt Pin
    input   logic                       Tx_done_i,      //For Status_reg
    input   logic                       Rx_done_i,
    input   logic                       Arb_done_i
    
    );
    
    reg                    psel;
    reg                    penable;
    reg                    pwrite;
    reg[ADDR_WIDTH-1:0]    paddr;
    reg[DATA_WIDTH-1:0]    pwdata;

    reg[DATA_WIDTH-1:0]    prdata;
    reg                    pready;
    reg                    pslverr;

    apb_master master(.pclk(pclk), .preset_n(preset_n) , .tx_valid(tx_valid), .tx_encode(tx_encode), .tx_addr(tx_addr),
        .tx_wdata (tx_wdata), .tx_rdata(tx_rdata), .tx_rvalid(tx_rvalid), .psel(psel), .penable(penable), 
        .pwrite(pwrite), .paddr(paddr), .pwdata(pwdata), .prdata(prdata), .pready(pready) , .pslverr(pslverr));



    CSR slave(.pclk(pclk), .preset_n(preset_n), .psel(psel), .penable(penable), .pwrite(pwrite), .paddr(paddr), 
        .pwdata(pwdata), .prdata(prdata), .pready(pready), .pslverr(pslverr), .Intr(Intr), .Tx_done_i(Tx_done_i),
        .Rx_done_i (Rx_done_i), .Arb_done_i(Arb_done_i) );
    

endmodule : apb_wrapper
