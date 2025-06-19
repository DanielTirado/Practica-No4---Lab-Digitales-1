//========================
// MÓDULO TOP - CON 2 JUGADORES
//========================
module topTestVGA (
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
    logic [10:0] x_max = 11'd640, y_max = 11'd480;
    logic [11:0] rgb_color;
    logic        blank;
    logic        reset_tv;
    logic        rst_key;
    logic        clkout;

    // JUGADOR 1 (original - teclas 5, 0, A)
    logic [10:0] player1_x = 11'd25, player1_y = 11'd80;
    logic [10:0] player1_w = 11'd50, player1_h = 11'd100;
    logic        paint_player1;

    // JUGADOR 2 (nuevo - teclas 3, 9, B)
    logic [10:0] player2_x = 11'd565, player2_y = 11'd80;  // Lado derecho
    logic [10:0] player2_w = 11'd50,  player2_h = 11'd100;
    logic        paint_player2;

    // BALA JUGADOR 1
    logic [10:0] bullet1_x;
    logic [10:0] bullet1_y;
    logic        bullet1_active;
    logic        paint_bullet1;
    logic [10:0] bullet_w = 11'd10;
    logic [10:0] bullet_h = 11'd30;

    // BALA JUGADOR 2
    logic [10:0] bullet2_x;
    logic [10:0] bullet2_y;
    logic        bullet2_active;
    logic        paint_bullet2;
	 logic 		  CHOQUE = 1'd0;

    // Velocidades
    logic [10:0] vel_p = 11'd10;  // Velocidad jugadores
    logic [10:0] vel_b = 11'd1;   // Velocidad balas

    assign reset_tv = ~nreset_tv;
    assign rst_key = ~nreset_key;

    // VGA Driver
    vga_ctrl_640x480_60Hz vga_ctrl_inst (
        .rst(reset_tv), .clk(clk), .rgb_in(rgb_color),
        .HS(hsync), .VS(vsync),
        .hcount(sig_pixel_x), .vcount(sig_pixel_y),
        .rgb_out(rgb_out), .blank(blank)
    );

    // Clock lento para teclado
    cntdiv_n clk_divisor(clk, rst_key, clkout);

    // Driver teclado
    Driver_Teclado teclado1 (clk, nreset_key, COLUMNAS, FILAS, TECLA, FLAG, DISP);

    // Movimiento de jugadores
    logic FLAG_d;
    always_ff @(posedge clkout) begin
        FLAG_d <= FLAG;

        if (FLAG && ~FLAG_d) begin
            case (TECLA)
                // JUGADOR 1 - Controles originales
                4'd5: if (player1_y > 11'd10)                player1_y <= player1_y - vel_p;  // Subir
                4'd0: if (player1_y + player1_h < y_max)     player1_y <= player1_y + vel_p;  // Bajar
                
                // JUGADOR 2 - Nuevos controles
                4'd3: if (player2_y > 11'd10)                player2_y <= player2_y - vel_p;  // Subir (tecla 3)
                4'd9: if (player2_y + player2_h < y_max)     player2_y <= player2_y + vel_p;  // Bajar (tecla 9)
            endcase
        end
    end

    // Movimiento y disparo de balas
    always_ff @(posedge clkout) begin
        // BALA JUGADOR 1 (se mueve hacia la derecha)
        if (bullet1_active) begin
            if (bullet1_x + bullet_w >= x_max || CHOQUE) begin
                bullet1_active <= 0;
            end else begin
                bullet1_x <= bullet1_x + vel_b;
            end
        end

        // BALA JUGADOR 2 (se mueve hacia la izquierda)
        if (bullet2_active) begin
            if (bullet2_x <= 11'd0 || CHOQUE) begin
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
	end

	
	// DETECCIÓN DE COLISIONES - LÓGICA COMBINACIONAL
    always_comb begin
        CHOQUE = 0;  // Por defecto no hay choque
        
        if (bullet1_active && bullet2_active) begin
            // Detección de colisión rectangular (AABB - Axis Aligned Bounding Box)
            if ((bullet1_x < bullet2_x + bullet_w) &&           // Bala1 izquierda < Bala2 derecha
                (bullet1_x + bullet_w > bullet2_x) &&           // Bala1 derecha > Bala2 izquierda
                (bullet1_y < bullet2_y + bullet_h) &&           // Bala1 arriba < Bala2 abajo
                (bullet1_y + bullet_h > bullet2_y)) begin       // Bala1 abajo > Bala2 arriba
                CHOQUE = 1;
            end
        end
    end
	 
	 
    // Salida de color
    always_comb begin
        rgb_color = 12'h000;  // Fondo negro
        
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

endmodule