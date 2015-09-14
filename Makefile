NASM 		= nasm
QEMU 		= qemu-system-i386
QEMU_DRIVE 	= a
# QEMU_SPEAKER = -soundhw pcspk

NAME 		 = floppybird
FILENAME 	 = $(NAME).img
COM_FILENAME = flpybird.com

IMAGE 		= build/$(FILENAME)
ISO_IMAGE 	= build/iso/$(FILENAME)
ISO 		= build/$(NAME).iso
ISO_DIR 	= build/iso

COM_TARGET  = build/$(COM_FILENAME)

BOOT 		= src/boot.asm
COM 		= src/com.asm
KERNEL 		= src/sys/rnd.asm \
			  src/sys/snd.asm \
			  src/sys/tmr.asm \
			  src/sys/txt.asm \
			  src/sys/vga.asm
GAME 		= src/main.asm  \
			  src/game/background.asm \
			  src/game/bird.asm \
			  src/game/bushes.asm \
			  src/game/clouds.asm \
			  src/game/data.asm \
			  src/game/flats.asm \
			  src/game/ground.asm \
			  src/game/pipes.asm \
			  src/game/score.asm

all: $(IMAGE)

$(IMAGE): $(BOOT) $(KERNEL) $(GAME)
	$(NASM) -isrc/ -f bin -o $(IMAGE) $(BOOT)

$(COM_TARGET): $(COM) $(KERNEL) $(GAME)
	$(NASM) -isrc/ -DCOM -f bin -o $(COM_TARGET) $(COM)

com: $(COM_TARGET)

usb:
	sudo dd if=$(IMAGE) of=/dev/sdb

floppy:
	dd bs=512 count=2880 if=/dev/zero of=$(ISO_IMAGE)
	dd status=noxfer conv=notrunc if=$(IMAGE) of=$(ISO_IMAGE)

iso:
	$(MAKE) floppy
	mkisofs -quiet -V 'FLOPPYBIRD' -input-charset iso8859-1 -o $(ISO) -b $(FILENAME) $(ISO_DIR)

qemu:
	$(QEMU) $(QEMU_SPEAKER) -boot $(QEMU_DRIVE) -fd$(QEMU_DRIVE) $(IMAGE)

bochs:
	bochs -q -n 'boot:floppy' 'floppy$(QEMU_DRIVE): 1_44=$(IMAGE), status=inserted'

dosbox:
	dosbox -conf dosbox.conf $(COM_TARGET)

clean:
	rm $(IMAGE)
	rm $(ISO_IMAGE)
	rm $(ISO)
	rm $(COM_TARGET)

.PHONY: usb floppy iso qemu bochs dosbox clean
