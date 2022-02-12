#/bin/sh

git clone https://github.com/krychu/wfc
cd wfc
sed -i 's/\-DWFC_USE_STB//' Makefile
make wfc.o
mv wfc.o ../src/wfc.o
cd ..
