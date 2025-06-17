module main #(FPGAFREQ = 50_000_000)(
	input logic CLK,
	input logic nRST,
	input logic nPBTON,
	output logic hsync,
	output logic vsync,
	output logic [11:0] rgb_out);
	
	logic RST;
	logic PBTON;
	logic clkdiv0;
	logic [9:0] counter;
	logic [3:0] units, tens, hundreds;
	
	logic PAINTU;
	logic PAINTD;
	logic PAINTC;
	logic PAINT34SEG;
	logic PAINT_1;
	logic PAINT_2;
	logic PAINT_3;
	logic PAINT_4;
	logic PAINT_5;
	
	//Señales de driver VGA
	logic [10:0] sig_pixel_x, sig_pixel_y; // 11 bits for pixel counters
	logic [11:0] color;
	logic black;
	
	assign RST = ~nRST;
	assign PBTON = ~nPBTON;
	
	///////////Bloque N1 ///////////////////////
	cntdiv_n #(FPGAFREQ) cntDiv0(CLK,RST,clkdiv0);
   // Instancia driver VGA
   vga_ctrl_640x480_60Hz vga_ctrl_inst (RST, CLK,color,hsync, vsync, sig_pixel_x,sig_pixel_y,rgb_out,black);
	// Display 7 segmentos
	display #(5,20,30,60,10) displayU(sig_pixel_x,sig_pixel_y,units,PAINTU);  //unidades 
	display #(5,20,30,35,10) displayD(sig_pixel_x,sig_pixel_y,tens,PAINTD);  // decenas
	display #(5,20,30,10,10) displayC(sig_pixel_x,sig_pixel_y,hundreds,PAINTC);  //centenas
	// Display 34 segmentos                 34'b111111_111111111111_11111111_11111111
	display34segm #(5,32) display34a(100,10,34'b111100_111100001111_00000000_00000000,sig_pixel_x,sig_pixel_y,PAINT34SEG);
	display34segm #(5,32) display34b(125,10,34'b100010_111100000110_01000000_00000001, sig_pixel_x, sig_pixel_y, PAINT_1);   // H
	display34segm #(5,32) display34c(150,10,34'b111100_111100001100_00001001_00000000, sig_pixel_x, sig_pixel_y, PAINT_2);  // O
	display34segm #(5,32) display34d(175,10,34'b110011_000011110000_00000000_00000000, sig_pixel_x, sig_pixel_y, PAINT_3);  // L
	display34segm #(5,32) display34e(200,10,34'b111100_111100001111_00000000_00000000, sig_pixel_x, sig_pixel_y, PAINT_4);  // A
	display34segm #(5,32) display34f(225,10,34'b000000_111101101111_10000001_00000000, sig_pixel_x, sig_pixel_y, PAINT_5);  // A
	//Pintando los displays de un color  
	always_comb begin
		color = 12'h000;
		if (PAINTC) begin
		  color = 12'h00F;
		end else if (PAINTD) begin
		  color = 12'h00F; //azul
		end else if (PAINTU) begin
		  color = 12'h00F;
		end 
		if (PAINT34SEG) begin
			color = 12'h8F0;
		end else if (PAINT_1) begin
			color = 12'h8F0;
		end else if (PAINT_2) begin
			color = 12'h8F0;
		end else if (PAINT_3) begin
			color = 12'h8F0;
		end else if (PAINT_4) begin
			color = 12'h8F0;
		end else if (PAINT_5) begin
			color = 12'h8F0;
		end 
	end

	
	/////////// Bloque N2////////////////////
	always_ff @(posedge clkdiv0, posedge RST) begin
		if(RST)begin
			counter <= 10'b00_0000_0000;
		end else begin
			if(PBTON)begin
				if(counter == 999)
					counter <= 10'b00_0000_0000;
				else
					counter <= counter + 1'b1;
			end else 
				counter <= counter;
		end
	end
	
	/////////// Bloque N3////////////////////
	always_comb begin
		units = 4'(counter % 10'd10);
		tens = 4'((counter / 10'd10)%10'd10);
		hundreds = 4'(counter / 10'd100);
	end
		
endmodule