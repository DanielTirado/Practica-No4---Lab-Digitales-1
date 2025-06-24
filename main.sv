module main #(FPGAFREQ = 50_000_000)(
	input logic CLK,
	input logic nRST,
	input logic nPBTON,
	input logic [9:0] sw,
	input  logic [3:0]  COLUMNAS,
   output logic [3:0]  FILAS,
   output logic [3:0]  TECLA,
   output logic        FLAG,
   output logic [7:0]  DISP,
	output logic hsync,
	output logic vsync,
	output logic [11:0] color,
   output logic [11:0] rgb_out);
	
	 
	logic RST;
	logic PBTON;
	logic clkdiv0;
	logic [9:0] counter;
	logic [3:0] units, tens, hundreds;
	logic PAINTU;logic PAINTD;logic PAINTC;
	logic PAINTU2;logic PAINTD2;logic PAINTC2;
	logic PAINT34SEG;logic PAINT_1;logic PAINT_2;logic PAINT_3;logic PAINT_4;logic PAINT_5;
	logic PAINT_6;logic PAINT_7;logic PAINT_8;logic PAINT_9;logic PAINT_10;logic PAINT_11;
	
	assign RST = ~nRST;
	assign PBTON = ~nPBTON;
	
	///////////Bloque N1 ///////////////////////
	cntdiv_n #(FPGAFREQ) cntDiv0(CLK,RST,clkdiv0);
   // Instancia driver VGA
   vga_ctrl_640x480_60Hz vga_ctrl_inst (RST, CLK,color,hsync, vsync, sig_pixel_x,sig_pixel_y,rgb_out,blanck);
	// Display 7 segmentos
	display #(5,20,30,35,10) displayU(sig_pixel_x,sig_pixel_y,units,PAINTU);  //unidades 
	display #(5,20,30,10,10) displayD(sig_pixel_x,sig_pixel_y,tens,PAINTD);  // decenas
	
	// Display 34 segmentos                 34'b111111_111111111111_11111111_11111111  //horizontal_Vertical_diag/_ Diag2
	display34segm #(3,32) display34g(60,10,34'b111100_111100001111_00000000_00000000,sig_pixel_x,sig_pixel_y,PAINT34SEG);//A
	display34segm #(3,32) display34h(85,10,34'b100010_111100000110_01000000_00000001, sig_pixel_x, sig_pixel_y, PAINT_7);//D 
	display34segm #(3,32) display34i(110,10,34'b111100_111100001100_00001001_00000000, sig_pixel_x, sig_pixel_y, PAINT_8);//R
	display34segm #(3,32) display34j(135,10,34'b110011_000011110000_00000000_00000000, sig_pixel_x, sig_pixel_y, PAINT_9);//I
	display34segm #(3,32) display34k(160,10,34'b111100_111100001111_00000000_00000000, sig_pixel_x, sig_pixel_y, PAINT_10);//A
	display34segm #(3,32) display34l(185,10,34'b000000_111100000111_01000000_10000000, sig_pixel_x, sig_pixel_y, PAINT_11);//n
	
	display #(5,20,30,460,10) displayU2(sig_pixel_x,sig_pixel_y,units,PAINTU2);  //unidades 
	display #(5,20,30,435,10) displayD2(sig_pixel_x,sig_pixel_y,tens,PAINTD2);  // decenas
	
	display34segm #(3,32) display34a(490,10,34'b100010_111100000110_01000000_00000001, sig_pixel_x, sig_pixel_y, PAINT_1);//D
	display34segm #(3,32) display34b(515,10,34'b111100_111100001111_00000000_00000000, sig_pixel_x, sig_pixel_y, PAINT_2);//A
	display34segm #(3,32) display34c(540,10,34'b000000_111100000111_01000000_10000000, sig_pixel_x, sig_pixel_y, PAINT_3);//n
	display34segm #(3,32) display34d(565,10,34'b110011_000011110000_00000000_00000000, sig_pixel_x, sig_pixel_y, PAINT_4);//I
	display34segm #(3,32) display34e(590,10,34'b111011_111100000000_00000000_00000000, sig_pixel_x, sig_pixel_y, PAINT_5);//E
	display34segm #(3,32) display34f(615,10,34'b000011_111100000000_00000000_00000000, sig_pixel_x, sig_pixel_y, PAINT_6);//L
	//Pintando los displays de un color 
	
	always_comb begin
		color = 12'h000;
		if (PAINTD) color = 12'h00F;
		else if (PAINTU)color = 12'h00F; //azul
		
		if (PAINT_1)color = 12'h8F0;
		else if (PAINT_2)color = 12'h8F0;
		else if (PAINT_3)color = 12'h8F0;
		else if (PAINT_4)color = 12'h8F0;
		else if (PAINT_5)color = 12'h8F0;
		else if (PAINT_6)color = 12'h8F0;
		
		if (PAINTD2)color = 12'h00F;
		else if (PAINTU2)color = 12'h00F; //azul
		
		if (PAINT34SEG)color = 12'h8F0;
		else if (PAINT_7)color = 12'h8F0;
		else if (PAINT_8)color = 12'h8F0;
		else if (PAINT_9)color = 12'h8F0;
		else if (PAINT_10)color = 12'h8F0;
		else if (PAINT_11)color = 12'h8F0; 
		
	end

	
	/////////// Bloque N2////////////////////
	
	
	///PRUEBA DE PUNTUACION JUGADOR1
	//if(posxbala1<=320 && (posxbala2==(posxbala1+anchoBala1)) && (posyBala1+==posyBala2)) counterJ1+1;//agregar los altos de las balas
	//else if(posxbala1==(625-(anchoBala1))counterJ1+2; //golpa en el muro
	
	
	always_ff @(posedge clkdiv0, posedge RST) begin
		if(RST)begin
			counter <= 10'b00_0000_0000;
		end else begin
			if(PBTON)begin
				if(counter == 99)
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
		//hundreds = 4'(counter / 10'd100);
	end
		
endmodule