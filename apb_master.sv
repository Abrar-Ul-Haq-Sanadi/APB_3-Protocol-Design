module apb_master #(parameter 

			ADDR_WIDTH = 16,
			DATA_WIDTH = 32 )
(
	input 	logic						pclk,
	input 	logic						preset_n,
	
	input 	logic						tx_valid,
	input 	logic	[1:0] 				tx_encode,
	input 	logic	[ADDR_WIDTH-1:0] 	tx_addr,
	input 	logic	[DATA_WIDTH-1:0] 	tx_wdata,

	output 	logic	[DATA_WIDTH-1:0] 	tx_rdata,
	output 	logic						tx_rvalid,
	

	output 	logic						psel,
	output 	logic						penable,
	output 	logic						pwrite,
	output 	logic	[ADDR_WIDTH-1:0] 	paddr,
	output 	logic	[DATA_WIDTH-1:0] 	pwdata,
	input  	logic	[DATA_WIDTH-1:0] 	prdata,
    input  	logic						pready,
	input  	logic						pslverr
	
	);
	
	//FSM States
	typedef enum logic [1:0] {IDLE, SETUP, ACCESS} states;
	states state; 
	wire tx_bit;		
	assign tx_bit = (tx_valid && (tx_encode == 2'b01 || tx_encode==2'b00)) ;

	always @(posedge pclk or negedge preset_n)
	begin
		if(~preset_n) begin
			state 	<= IDLE;
			psel  	<= 1'b0;
			penable	<= 1'b0;
			pwrite 	<= 1'b0;
			paddr 	<= 'b0;
			pwdata 	<= 'b0;
			tx_rdata <= 'b0;
			tx_rvalid <= 1'b0;
		end
		else begin
			case(state)
			IDLE: begin
				psel	<= 1'b0;
				penable <= 1'b0;
				paddr	<= tx_addr;
				tx_rvalid <= 1'b0;

				if(tx_bit) begin
					state	<= SETUP;
					psel	<= 1'b1;
					penable	<= 1'b0;
					
					if(tx_encode==2'b00) begin
						pwrite <= 1'b0;		//Read
					end
					else begin
						pwrite <= 1'b1;		//Write
						pwdata <= tx_wdata;
					end
				end
			end

			SETUP: begin
				psel	<= 1'b1;
				penable	<= 1'b1;
				tx_rvalid <= 1'b0;			
				state	<= ACCESS;				//setup state--------> ACCESS state
			end

			ACCESS: begin
				if(pready) begin				//wait in the ACCESS state till pready is asserted	
					if (~pwrite && ~pslverr) begin			//For Read operation
						tx_rdata	<= prdata;
						tx_rvalid	<= 1'b1;
					end
					penable <= 1'b0;
									
					if(tx_bit) begin
						state	<= SETUP;		//if we have further valid transfers go to -----> SETUP state
						paddr <= tx_addr;		//then once again sample the current address (tx_addr)

						if(tx_encode==2'b00) begin		//If read transfer arrives next
							pwrite <= 1'b0;
						end
						else if(tx_encode == 2'b01) begin	//if there is write transfer arrving next
							pwrite 	<= 1'b1;
							pwdata <= tx_wdata;
						end
					end
					else begin
						state	<= IDLE;		//else if there is no valid transfer go to -----> IDLE state
						psel 	<= 1'b0;
					end	
				end
				else begin
					state	<= ACCESS;
				end	
			end
			
			default: state	<= IDLE;
			endcase
		end
	end
endmodule
