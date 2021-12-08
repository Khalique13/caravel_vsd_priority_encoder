// SPDX-FileCopyrightText: 2020 Efabless Corporation
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// SPDX-License-Identifier: Apache-2.0

`default_nettype none
/*
 *-------------------------------------------------------------
 *
 * user_proj_example
 *
 * This is an example of a (trivially simple) user project,
 * showing how the user project can connect to the logic
 * analyzer, the wishbone bus, and the I/O pads.
 *
 * This project generates an integer count, which is output
 * on the user area GPIO pads (digital output only).  The
 * wishbone connection allows the project to be controlled
 * (start and stop) from the management SoC program.
 *
 * See the testbenches in directory "mprj_counter" for the
 * example programs that drive this user project.  The three
 * testbenches are "io_ports", "la_test1", and "la_test2".
 *
 *-------------------------------------------------------------
 */

module user_proj_example #(
    parameter BITS = 32
)(
`ifdef USE_POWER_PINS
    inout vccd1,	// User area 1 1.8V supply
    inout vssd1,	// User area 1 digital ground
`endif

    // Wishbone Slave ports (WB MI A)
    input wb_clk_i,
    input wb_rst_i,
    input wbs_stb_i,
    input wbs_cyc_i,
    input wbs_we_i,
    input [3:0] wbs_sel_i,
    input [31:0] wbs_dat_i,
    input [31:0] wbs_adr_i,
    output wbs_ack_o,
    output [31:0] wbs_dat_o,

    // Logic Analyzer Signals
    input  [127:0] la_data_in,
    output [127:0] la_data_out,
    input  [127:0] la_oenb,

    // IOs
    input  [`MPRJ_IO_PADS-1:0] io_in,
    output [`MPRJ_IO_PADS-1:0] io_out,
    output [`MPRJ_IO_PADS-1:0] io_oeb,

    // IRQ
    output [2:0] irq
);

    wire [`MPRJ_IO_PADS-1:0] io_in;
    wire [`MPRJ_IO_PADS-1:0] io_out;
    wire [`MPRJ_IO_PADS-1:0] io_oeb;

    wire [7:0] in;
    reg [2:0] out;
    wire enable;
    reg eno, gs;
        
    assign {in, enable} = io_in[8:0];
    assign {out, eno, gs} = io_out[4:0]; 
    
        
    dvsd_pe dvsd_pe (.in(in), .out(out), .eno(eno), .gs(gs), .en(enable), .clk(wb_clk_i));
    

endmodule

module dvsd_pe (in, out, en, eno, gs, clk);

	input en, clk;
	input [7:0] in;
	output reg [2:0] out;
	output reg eno, gs;
	reg _a_;
			
	always @ (posedge clk)
		begin
			_a_ = ~& in ;
 			eno = ~(_a_ & en);
 			gs = ~eno & en;
		end			
	always @ (posedge clk)
		begin
			if (en)
			casex (in)
				// Highest Priority
				8'bxxxxxxx1: out = 3'b000;
				8'bxxxxxx1x: out = 3'b001;
				8'bxxxxx1xx: out = 3'b010;
				8'bxxxx1xxx: out = 3'b011;
				8'bxxx1xxxx: out = 3'b100;
				8'bxx1xxxxx: out = 3'b101;
				8'bx1xxxxxx: out = 3'b110;
				8'b1xxxxxxx: out = 3'b111;
				// Lowest Priority
				default : out = 1'bxxx;
			endcase
		end
		
endmodule
  
`default_nettype wire
