//-----------------------------------------------------------------------------
// Title         : gpa_fhdo_iface
// Project       : ocra
//-----------------------------------------------------------------------------
// File          : gpa_fhdo_iface.v
// Author        :   <vlad@arch-ssd>
// Created       : 03.09.2020
// Last modified : 03.09.2020
//-----------------------------------------------------------------------------
// Description :
//
// Interface between gradient BRAM module and the GPA-FHDO board, with
// an SPI serialiser for the 4-channel DAC and associated FSM logic.
//
//-----------------------------------------------------------------------------
// Copyright (c) 2020 by OCRA developers This model is the confidential and
// proprietary property of OCRA developers and the possession or use of this
// file requires a written license from OCRA developers.
//------------------------------------------------------------------------------
// Modification history :
// 03.09.2020 : created
//-----------------------------------------------------------------------------

`ifndef _GPA_FHDO_IFACE_
 `define _GPA_FHDO_IFACE_

 `timescale 1ns/1ns

module gpa_fhdo_iface(
		   input 	clk,

		   // data words from gradient memory core
		   input [23:0] datax_i,
		   input [23:0] datay_i,
		   input [23:0] dataz_i,
		   input [23:0] dataz2_i,

		   // data valid flag, should be held high for 1 cycle to initiate a transfer		   
		   input 	valid_i,

		   // GPA-FHDO interface
		   output reg 	fhd_clk_o,
		   output reg 	fhd_sdo_o,
		   output reg 	fhd_csn_o,
		   input 	fhd_sdi_i, // not used yet, but will add an SPI readback feature later

		   output reg 	busy_o // should be held high while module is carrying out an SPI transfer
		   );
		   
	reg [23:0] 			spi_output = 0;
    wire [15:0] 	    spi_payload = spi_output[15:0];	
	wire [3:0] 			spi_addr = spi_output[19:16];
	reg [5:0] 			spi_counter = 0;
	
	parameter			num_transfer = 4;
	reg [2:0]			current_transfer = 0;
	/*
		nr		data
		0		sync_reg
		1		dac_channel_0
		2		dac_channel_1
		3		dac_channel_2
		4		dac_channel_3
	*/
	
	parameter			SIZE = 5;
	parameter 			IDLE = 3'b001,START_SPI = 3'b010,OUTPUT_SPI = 3'b011,END_SPI = 3'b100;
						
	reg [SIZE-1:0]			state = IDLE;
	wire [SIZE-1:0]			next_state;
	assign next_state = fsm_function(state,spi_counter);
	
	// State Logic
	function [SIZE-1:0] fsm_function;
		input [SIZE-1:0] state;
		input [5:0] spi_counter;
		case(state)
			START_SPI: begin
				// load data for current transfer into spi_output
				spi_output[23:20] = 4'b0000;
				if (current_transfer == 0) begin
					spi_output[19:16] = 4'b0010; // sync_reg
					spi_output[15:0] = 16'h0000; // broadcast off, sync (from ldac) off for all channels
				end
				if (current_transfer > 0 && current_transfer < 5) begin
					// select dac_channel
					spi_output[19] = 1'b1;
					spi_output[18:16] = current_transfer - 1;
					case(current_transfer)
						1: spi_output[15:0] = datax_i[15:0];
						2: spi_output[15:0] = datay_i[15:0];
						3: spi_output[15:0] = dataz_i[15:0];
						4: spi_output[15:0] = dataz2_i[15:0];
					endcase
				end
				fsm_function = OUTPUT_SPI;
			    end
			OUTPUT_SPI: begin
				// $display("state_logic spi_counter %d",spi_counter);
				if (spi_counter == 23) begin
					fsm_function = END_SPI;
				end
				else begin
					fsm_function = OUTPUT_SPI;
				end
			   end
			END_SPI: begin
				if (current_transfer < num_transfer) begin
					current_transfer = current_transfer + 1;
					fsm_function = START_SPI;
				end
				else begin
					fsm_function = IDLE;
				end
			   end
			default:fsm_function=IDLE;
		endcase
	endfunction

	// Sequence Logic
   always @(posedge clk) begin
      if(valid_i == 1) begin
		current_transfer <= 0;
		state <= START_SPI;
	  end 
	  else begin
		state <= next_state;
	  end
   end


	// Output Logic
   always @(posedge clk) begin
		case(state)
			IDLE: begin
				busy_o <= 0;
				fhd_csn_o <= 1;
				spi_counter <= 0;
				fhd_csn_o <= 1;
				end
			START_SPI: begin
				busy_o <= 1;
				fhd_csn_o <= 1;
				spi_counter <= 0;
				fhd_clk_o <= 1;
			   end
			OUTPUT_SPI: begin
				fhd_clk_o <= 1;
				fhd_csn_o <= 0;
				if (spi_counter < 24) begin
					fhd_sdo_o <= spi_output[23-spi_counter];
					spi_counter <= spi_counter + 1;
				end
				else begin
					fhd_sdo_o <= 0;
				end
			   end
			END_SPI: begin
				fhd_sdo_o <= 0;
				fhd_csn_o <= 1;
			end
		  endcase
   end

   always @(negedge clk) begin
		case(state)
			START_SPI: 	fhd_clk_o <= 0;
			OUTPUT_SPI:	fhd_clk_o <= 0;
			END_SPI:	fhd_clk_o <= 0;
		  endcase
   end


endmodule // gpa_fhdo_iface
`endif //  `ifndef _GPA_FHDO_IFACE_
