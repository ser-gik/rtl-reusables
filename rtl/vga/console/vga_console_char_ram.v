
//
// Character RAM
//
module vga_console_char_ram #(
    parameter CHAR_COUNT = 100,
    parameter CHAR_BITS = 8
    // Internal, do not override
    parameter _VGA_ADDR_WIDTH = $clog2(CHAR_COUNT),
    parameter _RAM_ADDR_WIDTH = $clog2($rtoi($ceil($itor(CHAR_COUNT * CHAR_BITS) / 32)))
) (
    // VGA read-only port
    input vga_clk,
    input [_VGA_ADDR_WIDTH-1:0] vga_char_address,
    output [CHAR_BITS-1:0] vga_char,

    // Global system control
    input clk,
    input reset_n,

    // Main RAM port
    // Operates on 32-bit granules. Writes are byte-wide, where strobe signal
    // selects octets that will be written
    input [29:0] char_word_address,
    input [31:0] char_wdata,
    output [31:0] char_rdata,
    input [3:0] char_write_strobe,

    // Character scrolling. Allows to cyclically shift characters on screen
    // grid by specified number of positions.
    input [31:0] scroll_offset_in,
    output [31:0] scroll_offset_out,
    input scroll_offset_write,
    // Upper limit for scroll offset, writing a value that exceeds this limit
    // has undefined result.
    output [31:0] scroll_offset_max
);
    // VGA section.
    localparam [_VGA_ADDR_WIDTH-1:0] MAX_CHAR_ADDR = CHAR_COUNT - 1;

    reg [_VGA_ADDR_WIDTH-1:0] vga_scroll_offset;    // Current scroll offset value
    wire [_VGA_ADDR_WIDTH:0] vga_addr_with_offset;  // User provided address with offset added
                                                    // Use extra bit to not loose carry
    wire [_VGA_ADDR_WIDTH-1:0] vga_addr_effective;  // An address of a character to read (VGA view)
    wire [_RAM_ADDR_WIDTH-1:0] vga_addr_ram;        // An address of a RAM word that contains
                                                    // current character (system view)
    wire [31:0] vga_ram_word;                       // Last read RAM word

    assign vga_addr_with_offset = vga_char_address + vga_scroll_offset;
    assign vga_addr_effective =
        vga_addr_with_offset <= MAX_CHAR_ADDR
            ? vga_addr_with_offset[_VGA_ADDR_WIDTH-1:0]
            : (vga_addr_with_offset - (MAX_CHAR_ADDR + 1'b1))[_VGA_ADDR_WIDTH-1:0];

    reg [CHAR_BITS-1:0] vga_char,
    generate
        if (CHAR_BITS == 8) begin : char_8
            assign vga_addr_ram = vga_addr_effective[_VGA_ADDR_WIDTH-1:2];
            reg [1:0] lane;
            always @(posedge vga_clk) lane <= vga_addr_effective[1:0];
            always @(*) begin
                case (lane)
                    2'b00: vga_char = vga_ram_word[7:0];
                    2'b01: vga_char = vga_ram_word[15:8];
                    2'b10: vga_char = vga_ram_word[23:16];
                    2'b11: vga_char = vga_ram_word[31:24];
                endcase
            end
        end
        else if (CHAR_BITS == 16) begin : char_16
        assign vga_addr_ram = vga_addr_effective[_VGA_ADDR_WIDTH-1:1];
            reg lane;
            always @(posedge vga_clk) lane <= vga_addr_effective[0];
            always @(*) begin
                vga_char = lane ? vga_ram_word[31:16] : vga_ram_word[15:0];
            end
        end
        else if (CHAR_BITS == 32) begin : char_32
            assign vga_addr_ram = vga_addr_effective[_VGA_ADDR_WIDTH-1:0];
            always @(*) begin
                vga_char = vga_ram_word;
            end
        end
        else begin
            error_char_bits_must_be_one_of_8_16_32 u_error;
        end
    endgenerate

    // Scroll control
    // It is done in main clock domain. Synchronization might be needed if VGA
    // scroll glitches are noticeable.

    always @(posedge clk or negedge reset_n) begin
        if (~reset_n) begin
            vga_scroll_offset <= {_VGA_ADDR_WIDTH{1'b0}};
        end
        else if (scroll_offset_write) begin
            vga_scroll_offset <= scroll_offset_in[_VGA_ADDR_WIDTH-1:0];
        end
    end

    assign scroll_offset_out = {(32 - _VGA_ADDR_WIDTH){1'b0}, vga_scroll_offset};
    assign scroll_offset_max = CHAR_COUNT;

    // RAM instance

    vga_ram32 #(
        .ADDR_WIDTH(_RAM_ADDR_WIDTH)
    ) u_vga_ram(
        .clkA(vga_clk),
        .addrA(vga_addr_ram),
        .rdataA(vga_ram_word),
        .clkB(clk),
        .addrB(char_word_address[_RAM_ADDR_WIDTH-1:0]),
        .rdataB(char_rdata),
        .wstrobeB(char_write_strobe),
        .wdataB(char_wdata)
    );

endmodule

