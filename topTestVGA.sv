//========================
// MÓDULO TOP - CON 2 JUGADORES
//========================
module topTestVGA #(FPGAFREQ = 50_000_000) (
    input  logic clk,
    input  logic nreset_tv,
    input  logic [9:0] sw,
    output logic hsync,
    output logic vsync,
    output logic [11:0] rgb_out,

    // Teclado
    input  logic nreset_key,
    input  logic [3:0] COLUMNAS,
    output logic [3:0] FILAS,
    output logic [3:0] TECLA,
    output logic       FLAG,
    output logic [7:0] DISP
);

   // VGA y parámetros de pantalla
   logic [10:0] sig_pixel_x, sig_pixel_y;
   logic [10:0] x_max = 11'd640, y_max = 11'd480, margin_top = 11'd60;
   logic [11:0] rgb_color;
   logic        blank;
   logic        reset_tv;
   logic        rst_key;
   logic        clkout;

   // JUGADOR 1 (original - teclas 5, 0, A)
   logic [10:0] player1_x = 11'd25, player1_y = 11'd80;
   logic [10:0] player1_w = 11'd50, player1_h = 11'd50;
   logic        paint_player1;
	 
	// MURO JUGADOR 1
	logic [10:0] wall1_x = 11'd5;
   logic [10:0] wall_w = 11'd10, wall_h = 11'd500, wall_y = 11'd60;
   logic paint_wall1;
	 
	// MURO JUGADOR 2
	logic [10:0] wall2_x = 11'd625;
   logic paint_wall2;
	 
	// JUGADOR 2 (nuevo - teclas 3, 9, B)
   logic [10:0] player2_x = 11'd565, player2_y = 11'd80;  // Lado derecho
   logic [10:0] player2_w = 11'd50,  player2_h = 11'd50;
   logic        paint_player2;

   // BALA JUGADOR 1
   logic [10:0] bullet1_x;
   logic [10:0] bullet1_y;
   logic        bullet1_active;
   logic        paint_bullet1;
   logic [10:0] bullet_w = 11'd5;
   logic [10:0] bullet_h = 11'd5;

   // BALA JUGADOR 2
   logic [10:0] bullet2_x;
   logic [10:0] bullet2_y;
   logic        bullet2_active;
   logic        paint_bullet2;
	logic 		  CHOQUE_B1 = 1'd0;
	logic 		  CHOQUE_B2 = 1'd0;

   // Velocidades
   logic [10:0] vel_p = 11'd10;  // Velocidad jugadores
   logic [10:0] vel_b = 11'd1;   // Velocidad balas
	
	// Displays
	logic clkdiv0;
	logic [7:0] score1 = 8'd0;
	logic [7:0] score2 = 8'd0;	 
	logic [3:0] units_1, units_2, tens_1, tens_2;
	logic PAINTU;logic PAINTD;logic PAINTC;
	logic PAINTU2;logic PAINTD2;logic PAINTC2;
	logic PAINT34SEG;logic PAINT_1;logic PAINT_2;logic PAINT_3;logic PAINT_4;logic PAINT_5;
	logic PAINT_6;logic PAINT_7;logic PAINT_8;logic PAINT_9;logic PAINT_10;logic PAINT_11;
	
	
   assign reset_tv = ~nreset_tv;
   assign rst_key = ~nreset_key;

   // VGA Driver
   vga_ctrl_640x480_60Hz vga_ctrl_inst (
       .rst(reset_tv), .clk(clk), .rgb_in(rgb_color),
       .HS(hsync), .VS(vsync),
       .hcount(sig_pixel_x), .vcount(sig_pixel_y),
       .rgb_out(rgb_out), .blank(blank)
   );
	 
	cntdiv_n #(FPGAFREQ) cntDiv0(CLK,RST,clkdiv0);
	 
	// Display 7 segmentos
	display #(5,20,30,35,10) displayU(sig_pixel_x,sig_pixel_y,units_1,PAINTU);  //unidades 
	display #(5,20,30,10,10) displayD(sig_pixel_x,sig_pixel_y,tens_1,PAINTD);  // decenas
	
	// Display 34 segmentos                 34'b111111_111111111111_11111111_11111111  //horizontal_Vertical_diag/_ Diag2
	display34segm #(3,32) display34g(60,10,34'b111100_111100001111_00000000_00000000,sig_pixel_x,sig_pixel_y,PAINT34SEG);//A
	display34segm #(3,32) display34h(85,10,34'b100010_111100000110_01000000_00000001, sig_pixel_x, sig_pixel_y, PAINT_7);//D 
	display34segm #(3,32) display34i(110,10,34'b111100_111100001100_00001001_00000000, sig_pixel_x, sig_pixel_y, PAINT_8);//R
	display34segm #(3,32) display34j(135,10,34'b110011_000011110000_00000000_00000000, sig_pixel_x, sig_pixel_y, PAINT_9);//I
	display34segm #(3,32) display34k(160,10,34'b111100_111100001111_00000000_00000000, sig_pixel_x, sig_pixel_y, PAINT_10);//A
	display34segm #(3,32) display34l(185,10,34'b000000_111100000111_01000000_10000000, sig_pixel_x, sig_pixel_y, PAINT_11);//n
	
	display #(5,20,30,460,10) displayU2(sig_pixel_x,sig_pixel_y,units_2,PAINTU2);  //unidades 
	display #(5,20,30,435,10) displayD2(sig_pixel_x,sig_pixel_y,tens_2,PAINTD2);  // decenas
	
	display34segm #(3,32) display34a(490,10,34'b100010_111100000110_01000000_00000001, sig_pixel_x, sig_pixel_y, PAINT_1);//D
	display34segm #(3,32) display34b(515,10,34'b111100_111100001111_00000000_00000000, sig_pixel_x, sig_pixel_y, PAINT_2);//A
	display34segm #(3,32) display34c(540,10,34'b000000_111100000111_01000000_10000000, sig_pixel_x, sig_pixel_y, PAINT_3);//n
	display34segm #(3,32) display34d(565,10,34'b110011_000011110000_00000000_00000000, sig_pixel_x, sig_pixel_y, PAINT_4);//I
	display34segm #(3,32) display34e(590,10,34'b111011_111100000000_00000000_00000000, sig_pixel_x, sig_pixel_y, PAINT_5);//E
	display34segm #(3,32) display34f(615,10,34'b000011_111100000000_00000000_00000000, sig_pixel_x, sig_pixel_y, PAINT_6);//L
	//Pintando los displays de un color 
	 
    // Clock lento para teclado
    cntdiv_n #(100_000) clk_divisor(clk, rst_key, clkout);

    // Driver teclado
    Driver_Teclado teclado1 (clk, nreset_key, COLUMNAS, FILAS, TECLA, FLAG, DISP);

    // Movimiento de jugadores
    logic FLAG_d;
    always_ff @(posedge clkout) begin
        FLAG_d <= FLAG;

        if (FLAG && ~FLAG_d) begin
            case (TECLA)
                // JUGADOR 1 - Controles originales
                4'd5: if (player1_y > margin_top)				player1_y <= player1_y - vel_p;  // Subir
                4'd0: if (player1_y + player1_h < y_max)		player1_y <= player1_y + vel_p;  // Bajar
                
                // JUGADOR 2 - Nuevos controles
                4'd3: if (player2_y > margin_top)				player2_y <= player2_y - vel_p;  // Subir (tecla 3)
                4'd9: if (player2_y + player2_h < y_max)		player2_y <= player2_y + vel_p;  // Bajar (tecla 9)
            endcase
        end
    end

    // Movimiento y disparo de balas
    always_ff @(posedge clkout) begin
        // BALA JUGADOR 1 (se mueve hacia la derecha)
        if (bullet1_active) begin
            if (bullet1_x + bullet_w >= x_max || CHOQUE_B1) begin
                bullet1_active <= 0;
            end else begin
                bullet1_x <= bullet1_x + vel_b;
            end
        end

        // BALA JUGADOR 2 (se mueve hacia la izquierda)
        if (bullet2_active) begin
            if (bullet2_x <= 11'd0 || CHOQUE_B2) begin
                bullet2_active <= 0;
            end else begin
                bullet2_x <= bullet2_x - vel_b;
            end
        end

        // Disparos
        if (FLAG && ~FLAG_d) begin
            case (TECLA)
                // DISPARO JUGADOR 1 (tecla A)
                4'hA: if (!bullet1_active) begin
                    bullet1_active <= 1;
                    bullet1_x <= player1_x + player1_w;
                    bullet1_y <= player1_y + player1_h / 2;
                end
                
                // DISPARO JUGADOR 2 (tecla B)
                4'hB: if (!bullet2_active) begin
                    bullet2_active <= 1;
                    bullet2_x <= player2_x;
                    bullet2_y <= player2_y + player2_h / 2;
                end
            endcase
        end
		  
		  if (CHOQUE_B2) begin
				if (bullet2_x <= wall1_x+wall_w) begin
					score2 <= score2 + 2;
				end else if ((bullet2_x < player2_x) && (bullet2_x > x_max/2) ) score2 <= score2+1;
			end
			
		  if (CHOQUE_B1) begin
				if (bullet1_x+bullet_w >= wall2_x) begin
					score1 <= score1 + 2;
				end else if ((bullet1_x > player1_x) && (bullet1_x < x_max/2) ) score1 <= score1+1;  
		  end
	end

	
	// DETECCIÓN DE COLISIONES - LÓGICA COMBINACIONAL
    always_comb begin
        CHOQUE_B1 = 0;  // Por defecto no hay choque
        CHOQUE_B2 = 0;  // Por defecto no hay choque        
		  
        if (bullet1_active && bullet2_active) begin
				// Detección de colisión rectangular
            if ((bullet1_x < bullet2_x + bullet_w) &&           // Bala1 izquierda < Bala2 derecha
                (bullet1_x + bullet_w > bullet2_x) &&           // Bala1 derecha > Bala2 izquierda
                (bullet1_y < bullet2_y + bullet_h) &&           // Bala1 arriba < Bala2 abajo
                (bullet1_y + bullet_h > bullet2_y)) begin       // Bala1 abajo > Bala2 arriba
                CHOQUE_B1 = 1;
					 CHOQUE_B2 = 1;
//				if (bullet2_x > y_max/2) begin 
//					score2 <= score2+1;
//				end else if(bullet2_x < y_max/2) score1 <= score1+1;
            end
		  end
			
			if (bullet1_active) begin
				// Detección de colisión bala 1 con jugador 2
				if ((bullet1_x+bullet_w == player2_x) && 
						 (bullet1_y >= player2_y)    && 
						 (bullet1_y <= player2_y+player2_h)) begin
						 CHOQUE_B1 = 1;
				// Detección de colisión bala 1 con muro 2
				end else if (bullet1_x+bullet_w == wall2_x) CHOQUE_B1 = 1;
			end
			
			if (bullet2_active) begin
				// Detección de colisión bala 2 con jugador 1
				if ((bullet2_x == player1_x+player1_w) && 
					 (bullet2_y >= player1_y)    				&& 
					 (bullet2_y <= player1_y+player1_h)) begin
					 CHOQUE_B2 = 1;
				// Detección de colisión bala 2 con muro 1
				end else if (bullet2_x == wall1_x+wall_w) CHOQUE_B2 = 1;
			end
    end
	 
	 
    // Salida de color
    always_comb begin
        rgb_color = 12'h000;  // Fondo negro
        
		if (PAINTD) rgb_color = 12'h00F;
		else if (PAINTU)rgb_color = 12'h00F; //azul
		
		if (PAINT_1)rgb_color = 12'h8F0;
		else if (PAINT_2)rgb_color = 12'h8F0;
		else if (PAINT_3)rgb_color = 12'h8F0;
		else if (PAINT_4)rgb_color = 12'h8F0;
		else if (PAINT_5)rgb_color = 12'h8F0;
		else if (PAINT_6)rgb_color = 12'h8F0;
		
		if (PAINTD2)rgb_color = 12'h00F;
		else if (PAINTU2)rgb_color = 12'h00F; //azul
		
		if (PAINT34SEG)rgb_color = 12'h8F0;
		else if (PAINT_7)rgb_color = 12'h8F0;
		else if (PAINT_8)rgb_color = 12'h8F0;
		else if (PAINT_9)rgb_color = 12'h8F0;
		else if (PAINT_10)rgb_color = 12'h8F0;
		else if (PAINT_11)rgb_color = 12'h8F0; 
		
		  
		  // Muro 1 - Color azul
        if (paint_wall1) 
            rgb_color = 12'h00F;
        
		  // Muro 2 - Color verde
        if (paint_wall2) 
            rgb_color = 12'h0F0;
        
        // Jugador 1 - Color azul
        if (paint_player1) 
            rgb_color = 12'h00F;
        
        // Jugador 2 - Color verde
        if (paint_player2) 
            rgb_color = 12'h0F0;
        
        // Bala jugador 1 - Color rojo
        if (paint_bullet1 && bullet1_active) 
            rgb_color = 12'hF00;
        
        // Bala jugador 2 - Color amarillo
        if (paint_bullet2 && bullet2_active) 
            rgb_color = 12'hFF0;
    end
	
	
	always_comb begin
		
		units_1 = 4'(score1 % 10'd10);
		tens_1  = 4'((score1 / 10'd10)%10'd10);
		
		units_2 = 4'(score2 % 10'd10);
		tens_2  = 4'((score2 / 10'd10)%10'd10);

	end
		
    // Dibujar jugador 1
    draw_square player1_draw (
        .pix_x(sig_pixel_x), .pix_y(sig_pixel_y),
        .x1_limit(player1_x), .x2_limit(player1_x + player1_w),
        .y1_limit(player1_y), .y2_limit(player1_y + player1_h),
        .PAINT(paint_player1)
    );

    // Dibujar jugador 2
    draw_square player2_draw (
        .pix_x(sig_pixel_x), .pix_y(sig_pixel_y),
        .x1_limit(player2_x), .x2_limit(player2_x + player2_w),
        .y1_limit(player2_y), .y2_limit(player2_y + player2_h),
        .PAINT(paint_player2)
    );

    // Dibujar bala jugador 1
    draw_square bullet1_draw (
        .pix_x(sig_pixel_x), .pix_y(sig_pixel_y),
        .x1_limit(bullet1_x), .x2_limit(bullet1_x + bullet_w),
        .y1_limit(bullet1_y), .y2_limit(bullet1_y + bullet_h),
        .PAINT(paint_bullet1)
    );

    // Dibujar bala jugador 2
    draw_square bullet2_draw (
        .pix_x(sig_pixel_x), .pix_y(sig_pixel_y),
        .x1_limit(bullet2_x), .x2_limit(bullet2_x + bullet_w),
        .y1_limit(bullet2_y), .y2_limit(bullet2_y + bullet_h),
        .PAINT(paint_bullet2)
    );
	 
	 
    // Dibujar muro jugador 1
    draw_square wall1_draw (
        .pix_x(sig_pixel_x), .pix_y(sig_pixel_y),
        .x1_limit(wall1_x), .x2_limit(wall1_x + wall_w),
        .y1_limit(wall_y), .y2_limit(wall_y + wall_h),
        .PAINT(paint_wall1)
    );
	 
	 
    // Dibujar muro jugador 2
    draw_square wall2_draw (
        .pix_x(sig_pixel_x), .pix_y(sig_pixel_y),
        .x1_limit(wall2_x), .x2_limit(wall2_x + wall_w),
        .y1_limit(wall_y), .y2_limit(wall_y + wall_h),
        .PAINT(paint_wall2)
    );

endmodule