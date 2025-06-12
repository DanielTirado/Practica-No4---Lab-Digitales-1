module draw_square (
    input logic [10:0] pix_x, pix_y,
	 input logic [10:0] x1_limit, x2_limit, y1_limit, y2_limit,
    input logic [11:0] sw,
    output logic [11:0] rgb_out
);

always_comb begin
    if ((pix_y >= y1_limit) && (pix_y <= y2_limit) 
	 && (pix_x >= x1_limit) && (pix_x <= x2_limit)) begin
        rgb_out = sw;
    end else begin
        rgb_out = ~sw;
    end
end

endmodule