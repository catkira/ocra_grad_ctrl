//-----------------------------------------------------------------------------
// Title         : ocra1_model
// Project       : ocra_grad_ctrl
//-----------------------------------------------------------------------------
// File          : ocra1_model.v
// Author        :   <vlad@arch-ssd>
// Created       : 31.08.2020
// Last modified : 31.08.2020
//-----------------------------------------------------------------------------
// Description :
// Behavioural model of OCRA1 board, specifically its I/O and four AD5781 DACs
//-----------------------------------------------------------------------------
// Copyright (c) 2020 by OCRA developers This model is the confidential and
// proprietary property of OCRA developers and the possession or use of this
// file requires a written license from OCRA developers.
//------------------------------------------------------------------------------
// Modification history :
// 31.08.2020 : created
//-----------------------------------------------------------------------------

`ifndef _OCRA1_MODEL_
 `define _OCRA1_MODEL_

 `include "ad5781_model.v"

 `timescale 1ns/1ns

module ocra1_model(
		   input clk,
		   input syncn,
		   input ldacn,
		   input sdox,
		   input sdoy,
		   input sdoz,
		   input sdoz2
		   );


endmodule // ocra1_model
`endif //  `ifndef _OCRA1_MODEL_