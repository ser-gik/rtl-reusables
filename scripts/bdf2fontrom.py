#!/usr/bin/env python3
#
# Script to generate Verilog model of a bitmap font ROM based on user-supplied
# BDF (Bitmap Distribution Format) file.
# Generated ROM will contain glyphs for ASCII only (i.e. Unicode Basic Latin, codepoints 0-127).
#
# BDF is expected to be monospaced and with no glyphs that may occupy adjacent cells.
#
# BDF is read from stdin, Verilog model is written to stdout. Name of a Verilog module is
# derived from a "FONT" BDF' record.
#
# See https://www.adobe.com/content/dam/acom/en/devnet/font/pdfs/5005.BDF_Spec.pdf
#

import sys
from dataclasses import dataclass

def bin_str(val, width):
    return format(val, 'b').zfill(width)

def verilog_bin_literal(components):
    total_width = 0
    parts = []
    for val, width in components:
        parts.append(bin_str(val, width))
        total_width += width
    return f"{total_width}'b" + "_".join(parts)

@dataclass
class BoundingBox:
    width: int
    height: int
    x: int
    y: int

    def __str__(self):
        return f"[{self.x} {self.y}] - [{self.width} {self.height}]"

def bounding_box_from_bdf_str(bdfDesc):
    bbx = list(map(lambda s: int(s), bdfDesc.split()))
    if len(bbx) != 4:
        raise Exception(f"Bad bounding box: {bdfDesc}")
    return BoundingBox(width = bbx[0], height = bbx[1], x = bbx[2], y = bbx[3])

def read_line(stream):
    while True:
        line = stream.readline()
        if not line:
            raise Exception("Premature end-of-file")
        line = line.strip()
        if line:
            return line

def read_bdf_item(bdf_stream, required_name = ""):
    tokens = read_line(bdf_stream).split(maxsplit = 1)
    if required_name and tokens[0] != required_name:
        raise Exception(f"Expected item {required_name} but got {tokens[0]}")
    if len(tokens) == 1:
        return tokens[0], ""
    else:
        return tokens[0], tokens[1]

def read_bdf_bitmap_line(bdf_stream, line_width):
    hex_string = read_line(bdf_stream)
    num_padded_bits = len(hex_string) * 4
    bits = (int(hex_string, base = 16)) >> (num_padded_bits - line_width)
    return bits

def read_bdf_bitmap(bdf_stream, font_bounding_box, glyph_bounding_box, dwidth):
    bitmap_y0 = font_bounding_box.y
    bitmap_y1 = bitmap_y0 + font_bounding_box.height
    bitmap_x0 = 0
    bitmap_x1 = bitmap_x0 + dwidth

    src_bitmap_y0 = glyph_bounding_box.y
    src_bitmap_y1 = src_bitmap_y0 + glyph_bounding_box.height
    src_bitmap_x0 = glyph_bounding_box.x
    src_bitmap_x1 = src_bitmap_x0 + glyph_bounding_box.width

    if src_bitmap_y0 < bitmap_y0 \
            or src_bitmap_y1 > bitmap_y1 \
            or src_bitmap_x0 < bitmap_x0 \
            or src_bitmap_x1 > bitmap_x1:
        raise Exception("Glyph doesn't fit into font bounding box")

    lines = []
    cur_line = bitmap_y1 - 1
    while cur_line >= bitmap_y0:
        if cur_line >= src_bitmap_y0 and cur_line < src_bitmap_y1:
            src_line = read_bdf_bitmap_line(bdf_stream, glyph_bounding_box.width)
            line = src_line << (bitmap_x1 - src_bitmap_x1)
            lines.append(line)
        else:
            lines.append(0)
        cur_line -= 1
    return lines

def read_custom_properties(bdf_stream, num_properties):
    props = {}
    while True:
        key, val = read_bdf_item(bdf_stream)
        if key == "ENDPROPERTIES":
            if num_properties != 0:
                raise Exception("Properties count mismatch")
            else:
                return props
        else:
            if num_properties > 0:
                props[key] = val
                num_properties -= 1
            else:
                raise Exception("Properties count mismatch")

def read_glyphs(bdf_stream, num_glyphs, font_bounding_box):
    glyphs = {}
    dwidth_horz = None
    while num_glyphs > 0:
        key, name = read_bdf_item(bdf_stream, required_name = "STARTCHAR")
        while True:
            key, val = read_bdf_item(bdf_stream)
            if key == "ENCODING":
                encoding = int(val)
            elif key == "SWIDTH":
                pass
            elif key == "DWIDTH":
                dx, dy = tuple(map(lambda s: int(s), val.split()))
                if dwidth_horz is None:
                    dwidth_horz = dx
                elif dx != dwidth_horz:
                    raise Exception("Only monospaced fonts are supported")
                if dy != 0:
                    raise Exception("Only horizontal fonts are supported")
                pass
            elif key == "SWIDTH1":
                raise Exception("Unsupported item")
            elif key == "DWIDTH1":
                raise Exception("Unsupported item")
            elif key == "VVECTOR":
                raise Exception("Unsupported item")
            elif key == "BBX":
                bbx = bounding_box_from_bdf_str(val)
            elif key == "BITMAP":
                bitmap_lines = read_bdf_bitmap(bdf_stream, font_bounding_box, bbx, dwidth_horz)
                break
        read_bdf_item(bdf_stream, required_name = "ENDCHAR")
        glyphs[encoding] = name, bitmap_lines
        num_glyphs -= 1
    return dwidth_horz, font_bounding_box.height, glyphs

def read_bdf(bdf_stream):
    key, val = read_bdf_item(bdf_stream, required_name = "STARTFONT")
    if val != "2.1" and val != "2.2":
        raise Exception("Unsupported BDF format version")

    name = None
    boundingbox = None
    properties = None
    while True:
        key, val = read_bdf_item(bdf_stream)
        if key == "COMMENT":
            pass
        elif key == "CONTENTVERSION":
            pass
        elif key == "FONT":
            name = val
        elif key == "SIZE":
            pass
        elif key == "FONTBOUNDINGBOX":
            boundingbox = bounding_box_from_bdf_str(val)
            if boundingbox.x < 0:
                raise Exception("Overlapping fonts are not supported")
        elif key == "METRICSSET":
            if int(val) != 0:
                raise Exception("Only horizontal fonts are supported")
        elif key == "SWIDTH":
            raise Exception("Unsupported item")
        elif key == "DWIDTH":
            raise Exception("Unsupported item")
        elif key == "SWIDTH1":
            raise Exception("Unsupported item")
        elif key == "DWIDTH1":
            raise Exception("Unsupported item")
        elif key == "VVECTOR":
            raise Exception("Unsupported item")
        elif key == "STARTPROPERTIES":
            properties = read_custom_properties(bdf_stream, int(val))
        elif key == "CHARS":
            if boundingbox is None:
                raise Exception("Font bounding box is missing")
            bitmap_width, bitmap_height, glyphs = read_glyphs(bdf_stream, int(val), boundingbox)
            read_bdf_item(bdf_stream, required_name = "ENDFONT")
            if (bdf_stream.readline()):
                raise Exception("Extra data after end-of-font")
            break

    if name is None:
        raise Exception("Font name is missing")
    if properties is None:
        properties = {}
    return name, properties, bitmap_width, bitmap_height, glyphs

def print_rom_header(printer, name, bitmap_width, bitmap_height, properties):
    printer(f"//")
    printer(f"// THIS FILE WAS GENERATED BY {sys.argv[0]}")
    printer(f"// DO NOT EDIT MANUALLY")
    printer(f"//")
    printer(f"// Font: {name}")
    printer(f"// Bitmap size: {bitmap_width}x{bitmap_height}")
    printer(f"// Extra properties:")
    for name, prop in properties.items():
        printer(f"//   {name}: {prop}")
    printer(f"//")
    printer(f"")

def print_rom_module(printer, name, bitmap_width, bitmap_height, glyphs):
    puts = lambda level, s: printer("    " * level + s)

    name = name.replace("-", "_")
    line_idx_signal_width = (bitmap_height - 1).bit_length()

    puts(0, f"module fontrom_{bitmap_width}x{bitmap_height}_{name}(")
    puts(1, f"codepoint,")
    puts(1, f"glyph_line_idx,")
    puts(1, f"clk,")
    puts(1, f"glyph_line")
    puts(0, f");")
    puts(1, f"input [6:0] codepoint;")
    puts(1, f"input [{line_idx_signal_width - 1}:0] glyph_line_idx;")
    puts(1, f"input clk;")
    puts(1, f"output [{bitmap_width - 1}:0] glyph_line;")
    puts(1, f"reg [{bitmap_width - 1}:0] glyph_line;")
    puts(0, f"")
    puts(1, f"always @(posedge clk) begin")
    puts(2, f"case ({{{{glyph_line_idx}}, {{codepoint}}}})")

    for cp in range(128):
        glyph_name = "<unknown>" if cp not in glyphs else glyphs[cp][0]
        bitmap = [0] * bitmap_height if cp not in glyphs else glyphs[cp][1]
        puts(3, f"// {hex(cp)} - {glyph_name}")
        for glyph_line in range(bitmap_height):
            addr = verilog_bin_literal([(glyph_line, line_idx_signal_width), (cp, 7)])
            value = verilog_bin_literal([(bitmap[glyph_line], bitmap_width)])
            puts(3, f"{addr}: glyph_line <= {value};")

    puts(3, f"default: glyph_line <= {{{bitmap_width}{{1'bx}}}};")
    puts(2, f"endcase")
    puts(1, f"end")
    puts(0, f"")
    puts(0, f"endmodule")

def main():
    in_stream = sys.stdin
    name, properties, bitmap_width, bitmap_height, glyphs = read_bdf(in_stream)
    out_stream = sys.stdout
    printer = lambda s: print(s, file = out_stream)
    print_rom_header(printer, name, bitmap_width, bitmap_height, properties)
    print_rom_module(printer, name, bitmap_width, bitmap_height, glyphs)

if __name__ == "__main__":
    main()

