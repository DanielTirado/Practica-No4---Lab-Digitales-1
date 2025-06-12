module topTestVGA (
    input logic clk,
    input logic nreset_tv,
	 
    input logic [9:0] sw,
    output logic hsync,
    output logic vsync,
    output logic [11:0] rgb_out,
	 
	 // Keyboard Parameters
	 input logic nreset_key,
	 input  logic [3:0]  COLUMNAS,  // Entradas de columnas del teclado
    output logic [3:0]  FILAS,     // Filas activadas por el controlador
    output logic [3:0]  TECLA,     // Código de tecla detectada (0-F)
    output logic        FLAG,      // Flag alto cuando se detecta una tecla
	 output logic [7:0]  DISP		  // Salida al display de 7 segmentos. muestra valor de la tecla
);

// Internal signals
logic [10:0] sig_pixel_x, sig_pixel_y; // 11 bits for pixel counters
logic [10:0] height=11'd100, width=11'd50, pos_x = 11'd100, pos_y = 11'd100; // Player's dimentions and position
logic [10:0] pos_bul_x =  11'd150, pos_bul_y = 11'd150; // Bullet's dimentions and position
logic        bullet_active;
logic 		 FLAG_d;

logic [10:0] x_max=11'd640, y_max=11'd480, y_margin = 11'd50; // Display's dimentions and limits
logic [11:0] rgb_player, rgb_bullet ; // RGB Input
logic 		 black;
logic 		 reset_tv;
logic 		 rst_key;
logic 		 clkout;
logic [10:0] vel=8'd1; // Object's velocity
assign reset_tv = ~nreset_tv;
assign rst_key = ~nreset_key;

// Declare vga driver component
vga_ctrl_640x480_60Hz vga_ctrl_inst (reset_tv, clk,rgb_player | rgb_bullet,hsync, vsync, sig_pixel_x,sig_pixel_y,rgb_out,black);

// Clock divisor for keyboard
cntdiv_n clk_divisor(clk, rst_key, clkout);

// Declare component to detect key
Driver_Teclado teclado1 (clk, nreset_key, COLUMNAS, FILAS, TECLA, FLAG, DISP);

always_ff @(posedge clkout) begin
	if (FLAG) begin
		case(TECLA)
				 4'd5: if (pos_y > y_margin)          pos_y <= pos_y - vel; // arriba
				 4'd0: if (pos_y + height < y_max)  pos_y <= pos_y + vel; // abajo
				 4'hA: begin
					 // disparar bala solo si no hay ya una en vuelo
                    if (!bullet_active) begin
                        bullet_active <= 1;
                        // arranca en el centro-derecha del jugador
                        pos_bul_x <= pos_x + width;
                        pos_bul_y <= pos_y + height/2;
                    end
                end
                default: ;
		endcase
	end
end

    //–– MOVIMIENTO DE BALA ––
always_ff @(posedge clkout) begin
  if (bullet_active) begin
		pos_bul_x <= pos_bul_x + vel;
		// si sale de pantalla, desactiva
		if (pos_bul_x >= x_max) 
			 bullet_active <= 0;
  end
end


// Declare component to draw player
draw_square player1 (sig_pixel_x,sig_pixel_y,pos_x,pos_x+width,pos_y,pos_y+height,{sw[9:8],sw},rgb_player);


// Declare component to draw bullet
draw_square bullet1 (sig_pixel_x,sig_pixel_y,pos_bul_x,pos_bul_x+ width/10,pos_bul_y,pos_bul_y +height/10,{sw[9:8],sw},rgb_bullet);

endmodule
