    module tb_apb_wrapper  #(parameter  ADDR_WIDTH = 16, DATA_WIDTH = 32 )();

         logic                     pclk;
         logic                     preset_n;
        
         logic                     tx_valid;
         logic[1:0]                tx_encode;
         logic[ADDR_WIDTH-1:0]     tx_addr;
         logic[DATA_WIDTH-1:0]     tx_wdata;

         logic[DATA_WIDTH-1:0]     tx_rdata;
         logic                     tx_rvalid;
         logic                     Intr;
         logic                     Tx_done_i;      //For Status_reg
         logic                     Rx_done_i;
         logic                     Arb_done_i;

        
         apb_wrapper wrapper(.pclk(pclk), .preset_n(preset_n), .tx_valid(tx_valid), .tx_encode(tx_encode),
                         .tx_addr(tx_addr), .tx_wdata(tx_wdata), .tx_rdata(tx_rdata), .tx_rvalid(tx_rvalid), .Intr(Intr),
                         .Tx_done_i (Tx_done_i), .Rx_done_i(Rx_done_i), .Arb_done_i(Arb_done_i));


     //   always #40 tx_valid = ~tx_valid ;
     //   always #40 tx_encode = $random;

        always #5  pclk = ~pclk;
        initial begin
            pclk = 1'b0;
            preset_n = 1'b0;
            tx_valid = 1'b0;
            tx_encode = 2'b11;
            tx_addr = 'b0;
            tx_wdata = 'b0;
            Tx_done_i = 1'b1;
            Rx_done_i = 1'b1;
            Arb_done_i = 1'b1;
        #15 preset_n = 1'b1;

        for (int i = 0; i < 'h2C; i=i+4) begin
            @(posedge pclk) ;
            tx_addr = i;
            tx_valid = 1'b1;
            tx_encode = 2'b01;
            tx_wdata = $random();
       

            @(posedge pclk) ;
            tx_valid = 1'b0;
        end

         for (int i = 0; i < 'h2C; i=i+4) begin
            @(posedge pclk) ;
            tx_addr = i;
            tx_valid = 1'b1;
            tx_encode = 2'b00;
            tx_wdata = $random();

            @(posedge pclk) ;
            tx_valid = 1'b0;
        end

    end

        initial begin
            $dumpfile("wave.vcd");
            $dumpvars(0, tb_apb_wrapper);
            #1000 $finish();
        end


    endmodule : tb_apb_wrapper
