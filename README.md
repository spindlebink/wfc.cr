# Wave Function Collapse bindings in Crystal

Crystal bindings to [a single-file WFC library in C](https://github.com/krychu/wfc).

If you've not heard of WFC, know that it's a super cool and surprisingly simple algorithm to generate locally similar textures from a small sample texture.

The Crystal API on top of the bindings is highly minimal. It defines an abstract `Texture` type which can be inherited, instanced, and passed to the module's `generate` function. The API works this way because WFC isn't a strictly image-based algorithm and can technically run on any information you pass to it, providing it's in the right layout. I use WFC for roguelike map generation, and hence I've implemented a `CharTexture` in this API that uses regular 0-255 codepoints in place of pixels.

```crystal
string = <<-TEXTURE
.................
..####..####.....
.###########.....
.#####..####.....
..###...####.....
.........##......
...##########....
...###########...
...###########...
.................
TEXTURE

texture = WFC::CharTexture.new string
new_texture = WFC.generate texture, 32, 32
# or: `new_texture = texture.generate 32, 32`
```

Since I'm binding to this library for my own purposes of roguelike map generation, I probably won't be personally supporting more texture types right now, but if you're interested in improving these bindings, writing a texture wrapper is a cinch: it just requires that you define how to transfer the instance's data to and from a byte array, and that's pretty much it. Binding to an image library for image support shouldn't be too much trouble.

## Usage

You'll need to build the `wfc` library that the Crystal bindings bind to. The
below instructions are reproduced verbatim in `build_wfc.sh`, so you can just
call `./build_wfc.sh` from this directory for a one-liner.

```sh
# Download the WFC library & remove stb support from makefile
git clone https://github.com/krychu/wfc
cd wfc
sed -i 's/\-DWFC_USE_STB//' Makefile

# Build
make wfc.o
mv wfc.o ../src/wfc.o

# Or, if you *do* want stb support (limited usage, since the bindings only
# marginally bind to the stb functionality):
# 1. Download the stb header files to the WFC directory
# curl https://raw.githubusercontent.com/nothings/stb/master/stb_image.h > stb_image.h
# curl https://raw.githubusercontent.com/nothings/stb/master/stb_image_write.h > stb_image_write.h
# 2. Remove the lines in `wfc.h` that undef the stb implementation--WFC assumes
#    you'll be including it in a C library rather than binding so its makefile
#    doesn't by default build stb fully
# sed -i 's/#undef STB_IMAGE_IMPLEMENTATION//g' wfc.h
# sed -i 's/#undef STB_IMAGE_WRITE_IMPLEMENTATION//g' wfc.h
# 3. Set the preprocessor defines to build the stb implementation
# sed -i 's/\-DWFC_USE_STB/-DWFC_USE_STB -DSTB_IMAGE_IMPLEMENTATION -DSTB_IMAGE_WRITE_IMPLEMENTATION/g' Makefile
# 4. Make and move `.o` file normally
```

Now you can `require` the library and use it from Crystal.

## Documentation

```
crystal docs
```

## License

```
Copyright © 2022 Stanaforth (@spindlebink)

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the “Software”), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
```
