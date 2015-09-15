Floppy Bird
===========
Floppy Bird is a `clone` of the infamous Flappy Bird written in 
16 bit (x86) assembly. 

In other words it *works* on **RAW METAL** and doesn't require an underlying
operating system, it is an *operating system* on its own.

![Floppy Bird](demo.gif?raw=true "Floppy Bird")

Getting Started
---------------
If you just want to try it out there's no need to install the
development tools because you can use one of the provided
'disk images'.

However, if you really want to 'compile' it yourself then you'll
need to install the following tools:

* NASM (required)
* QEMU (optional, needed for testing)
* GIMP (optional, needed for altering "graphics")

To build it just type in any terminal:

```bash
make
make iso
```

##### Versions

* `build/floppybird.img` - Image for Floppy / USB Drives
* `build/floppybird.iso` - for CD-ROM Drives (with Floppy Emulation)

##### Virtual Machines
QEMU and VirtualBox have been tested and fully supported.

```bash
qemu-system-i386 -boot a -fda build/floppybird.img
```

#### WARNING
I am not responsible for any direct or indirect data loss after 
performing any of the destructive operations presented below.

BE SURE TO BACKUP THE CONTENTS OF YOUR FLOPPY/USB DRIVE.

##### Linux/Mac (in other words *unix)
You can use the `dd` utility or your favorite CD Burner like 
[Brasero](http://wiki.gnome.org/Apps/Brasero).

```bash
dd if=build/floppybird.img of=/dev/sdb
```

In the example above, `/dev/sdb` is your USB Drive.

##### Windows
You can use the [Raw Write 32](http://www.netbsd.org/~martin/rawrite32/)
utility or your favorite CD Burner like [CDBurnerXP](https://cdburnerxp.se/en/home).

##### M$-DOS (BONUS)
It is also possible to run `Floppy Bird` as a regular `.COM` executable in any
`DOS-like` environment, like DOSBox for instance.

To build it type:

```bash
make com
```

And then to run it type:

```
dosbox build/flpybird.com
```

**Note**: Make sure to set the **cycles** to a reasonable value like **10000** for
an enjoyable experience.

Contribute
----------
* Fork the project.
* Make your feature addition or bug fix.
* Do **not** bump the version number.
* Send me a pull request. Bonus points for topic branches.

License
-------
Copyright (c) 2014, Mihail Szabolcs

Floppy Bird is provided **as-is** under the **MIT** license. 
For more information see LICENSE.
