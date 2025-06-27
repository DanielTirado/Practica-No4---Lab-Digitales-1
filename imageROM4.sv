module imageROM4 (
    input logic [4:0] addRom,
    output logic [31:0] dataRom
);

    // Definición de la ROM como un array de 16 entradas de 32 bits
    logic [31:0] rom [50:0];

    // Inicializar los datos directamente en el bloque initial
    initial begin
		// Diseño de un mago con túnica y bastón
		rom[0]  = 32'b00000000000000000000000000000100;
		rom[1]  = 32'b00000000110000000000000000001110;
		rom[2]  = 32'b00000000111111111111111111111111;
		rom[3]  = 32'b00000000110000000000000000001110;
		rom[4]  = 32'b00000000000000000000000000000100;
		

    end

    // Asignación de la salida a partir de la dirección
    assign dataRom = rom[addRom];

endmodule