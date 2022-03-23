#!/bin/bash
pj_pwd=$(pwd)
pj_source=$pj_pwd/source
pj_zlibpath=$pj_pwd/zlib
pj_opensslpath=$pj_pwd/openssl
pj_opensshpath=$pj_pwd/openssh
pj_usr=$pj_pwd/usr
pj_lib=$pj_pwd/lib 
cross_complie=arm-ca9-linux-gnueabihf
cross_gcc=$cross_complie-gcc
pj_dropbearpath=$pj_pwd/dropbear
#creat build path
if [ ! -d "$pj_zlibpath" ]; then
	mkdir $pj_zlibpath
	tar -xzvf $pj_source/zlib-1.2.8.tar.gz -C $pj_zlibpath
fi

if [ ! -d "$pj_opensslpath" ]; then
	mkdir $pj_opensslpath
	tar -xzvf $pj_source/openssl-1.1.1g.tar.gz -C $pj_opensslpath
fi

if [ ! -d "$pj_opensshpath" ]; then
	mkdir $pj_opensshpath
	tar -xzvf $pj_source/openssh-8.4p1.tar.gz -C $pj_opensshpath
fi

if [ ! -d "$pj_dropbearpath" ]; then
	mkdir $pj_dropbearpath
	tar -jxvf $pj_source/dropbear-2020.81.tar.bz2 -C $pj_dropbearpath
fi

if [ ! -d "$pj_usr" ]; then
	mkdir $pj_usr
fi

if [ ! -d "$pj_lib" ]; then
	mkdir $pj_lib
fi

cd $pj_zlibpath/zlib-1.2.8
if [ -f $pj_zlibpath/zlib-1.2.8/Makefile ]; then
	make distclean
fi
CHOST=$cross_complie ./configure --prefix=$pj_usr
make 
make install

cd $pj_dropbearpath/dropbear-2020.81
if [ -f $pj_dropbearpath/dropbear-2020.81/Makefile ]; then
	make distclean
fi
./configure --with-zlib=$pj_lib CC=$gcc_complie --host=$cross_complie --enable-shared=yes --enable-static=yes --prefix=$pj_usr CFLAGS=-I$pj_usr/include LDFLAGS=-L$pj_usr/lib
make
make scp
make install
cd $pj_opensslpath/openssl-1.1.1g
if [ -f $pj_opensslpath/openssl-1.1.1g/Makefile ]; then
	make distclean
fi
./Configure linux-generic32 no-asm shared no-async --prefix=$pj_usr CROSS_COMPILE=$cross_complie-
make
make install

cd $pj_opensshpath/openssh-8.4p1
if [ -f $pj_opensshpath/openssh-8.4p1/Makefile ]; then
	make distclean
fi
./configure CC=$gcc_complie --disable-strip --prefix=$pj_usr --host=$cross_complie CFLAGS=-I$pj_usr/include LDFLAGS=-L$pj_usr/lib --with-privsep-path=$pj_usr/var/empty --with-pid-dir=$pj_usr/var/run
make
make install-nokeys

rm $pj_zlibpath -rf
rm $pj_opensslpath -rf
rm $pj_opensshpath -rf
rm $pj_dropbearpath -rf
