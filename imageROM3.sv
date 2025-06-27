module imageROM3 (
    input logic [4:0] addRom,
    output logic [31:0] dataRom
);

    // Definición de la ROM como un array de 16 entradas de 32 bits
    logic [31:0] rom [31:0];

    // Inicializar los datos directamente en el bloque initial
    initial begin
		// Diseño de un mago con túnica y bastón
		rom[0]  = 32'b00100000000000000000000000000000;
		rom[1]  = 32'b01110000000000000000001100000000;
		rom[2]  = 32'b11111111111111111111111100000000;
		rom[3]  = 32'b01110000000000000000001100000000;
		rom[4]  = 32'b00100000000000000000000000000000;
		

    end

    // Asignación de la salida a partir de la dirección
    assign dataRom = rom[addRom];

endmodule