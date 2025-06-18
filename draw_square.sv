module draw_square (
    input logic [10:0] pix_x, pix_y,
	 input logic [10:0] x1_limit, x2_limit, y1_limit, y2_limit,
	 output logic PAINT
);

always_comb begin
	 PAINT = 1'b0;
    if ((pix_y >= y1_limit) && (pix_y <= y2_limit) 
	 && (pix_x >= x1_limit) && (pix_x <= x2_limit)) PAINT = 1'b1;
end

endmodule