; Uncompressed TGA with origin set to Top-Left and 256 color map
%define TGA_HEADER_COLORMAP 18 + 1028 ; 18 bytes header + 1028 bytes 256 colormap

bird:		incbin	"../data/bird.tga",		TGA_HEADER_COLORMAP, 96 * 24
grass:		incbin	"../data/grass.tga",	TGA_HEADER_COLORMAP, 16 * 10
pipe:		incbin	"../data/pipe.tga",		TGA_HEADER_COLORMAP, 64 * 4
pipe_top:	incbin	"../data/pipe_top.tga", TGA_HEADER_COLORMAP, 68 * 8

flats:		incbin	"../data/flats.tga",	TGA_HEADER_COLORMAP, 40 * 50
clouds:		incbin	"../data/cloud.tga",	TGA_HEADER_COLORMAP, 40 * 16
font:		incbin	"../data/font.tga",		TGA_HEADER_COLORMAP, 80 * 8
