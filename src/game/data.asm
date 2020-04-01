; Uncompressed TGA with origin set to Top-Left and 256 color map ( + ./data/rgb/palette/ ! )
%define TGA_HEADER_COLORMAP 18 + 1028 ; 18 bytes header + 1028 bytes 256 colormap

bird:		incbin	"../data/bird_small.tga",	TGA_HEADER_COLORMAP, 48 * 12
grass:		incbin	"../data/grass.tga",		TGA_HEADER_COLORMAP,  8 * 4
pipe:		incbin	"../data/pipe_small.tga",	TGA_HEADER_COLORMAP, 16 * 4
pipe_top:	incbin	"../data/pipe_top_small.tga",	TGA_HEADER_COLORMAP, 18 * 8

flats:		incbin	"../data/flats.tga",		TGA_HEADER_COLORMAP, 40 * 50
clouds:		incbin	"../data/cloud.tga",		TGA_HEADER_COLORMAP, 40 * 16
font:		incbin	"../data/font.tga",		TGA_HEADER_COLORMAP, 80 * 8
