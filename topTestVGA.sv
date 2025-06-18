//========================
// MÓDULO TOP
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

    // VGA y jugador
    logic [10:0] sig_pixel_x, sig_pixel_y;
    logic [10:0] player_x = 11'd100, player_y = 11'd100;
    logic [10:0] player_w = 11'd50,  player_h = 11'd100;
    logic [10:0] x_max = 11'd640, y_max = 11'd480;
    logic [11:0] rgb_color;
    logic        blank;
    logic        reset_tv;
    logic        rst_key;
    logic        clkout;

    // Bala
    logic [10:0] bullet_x;
    logic [10:0] bullet_y;
    logic        bullet_active;
    logic        paint_player, paint_bullet;
    logic [10:0] bullet_w = 11'd10;
    logic [10:0] bullet_h = 11'd5;

    // Mover
    logic [10:0] vel_p = 11'd10;
    logic [10:0] vel_b = 11'd1;

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

    // Movimiento jugador y disparo
    logic FLAG_d;
    always_ff @(posedge clkout) begin
        FLAG_d <= FLAG;

        if (FLAG && ~FLAG_d) begin
            case (TECLA)
                4'd5: if (player_y > 11'd10)              player_y <= player_y - vel_p;
                4'd0: if (player_y + player_h < y_max)    player_y <= player_y + vel_p;
            endcase
        end
    end

    // Movimiento y disparo de bala
    always_ff @(posedge clkout) begin
			if (bullet_active) begin
				 if (bullet_x + bullet_w >= x_max) begin
					  bullet_active <= 0;
				 end else begin
					  bullet_x <= bullet_x + vel_b;
				 end
			end
	
			if (FLAG && TECLA == 4'hA && !bullet_active) begin
				 bullet_active <= 1;
				 bullet_x <= player_x + player_w;
				 bullet_y <= player_y + player_h / 2;
			end
    end

    // Salida de color
    always_comb begin
        rgb_color = 12'h000;
        if (paint_player) rgb_color = {sw[9:8], sw};
        if (paint_bullet && bullet_active) rgb_color = 12'hF00;
    end

    // Dibujar jugador
    draw_square player1 (
        .pix_x(sig_pixel_x), .pix_y(sig_pixel_y),
        .x1_limit(player_x), .x2_limit(player_x + player_w),
        .y1_limit(player_y), .y2_limit(player_y + player_h),
        .PAINT(paint_player)
    );

    // Dibujar bala
    draw_square bullet1 (
        .pix_x(sig_pixel_x), .pix_y(sig_pixel_y),
        .x1_limit(bullet_x), .x2_limit(bullet_x + bullet_w),
        .y1_limit(bullet_y), .y2_limit(bullet_y + bullet_h),
        .PAINT(paint_bullet)
    );

endmodule
