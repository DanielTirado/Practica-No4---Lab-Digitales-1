module image 
    (
	 input logic [1:0] per,
	 input logic [10:0] POSX,
    input logic [10:0] POSY,
    input logic [10:0] pix_x,
    input logic [10:0] pix_y,
    output logic paint
	 
);

    // Declaración de señales internas
    logic [4:0] addRom_sig; //Row
    logic [31:0] dataRom_sig; //Col
	 logic [31:0] dataRom1_sig;
	 logic [31:0] dataRom2_sig;
	 logic [31:0] dataRom3_sig;
	 logic [31:0] dataRom4_sig;

    // Constantes para el tamaño de la ROM
    localparam int sizeColRom = 32;
    localparam int sizeRowRom = 32;

    // Instancia de la ROM (componente imageROM)
	imageROM img1 (addRom_sig,dataRom1_sig);
	
	imageROM2 img2 (addRom_sig,dataRom2_sig);
		
	imageROM4 img3 (addRom_sig,dataRom3_sig);
		
	imageROM3 img4 (addRom_sig,dataRom4_sig);
		
		
		always_comb begin
			case(per)
				2'd0:dataRom_sig=dataRom1_sig;
				2'd1:dataRom_sig=dataRom2_sig;
				2'd2:dataRom_sig=dataRom3_sig;
				2'd3:dataRom_sig=dataRom4_sig;
			endcase
		
		end

    // Proceso para dibujar la imagen almacenada en la ROM
    always_comb begin
		  addRom_sig = 5'b0000;
		  paint = 1'b0;
        if ((pix_y >= POSY) && (pix_y < (POSY + sizeRowRom)) && 
            (pix_x >= POSX) && (pix_x < (POSX + sizeColRom))) 
        begin
            addRom_sig = 5 '(pix_y - POSY);
            paint = dataRom_sig[~(pix_x - POSX)];
        end
    end

endmodule