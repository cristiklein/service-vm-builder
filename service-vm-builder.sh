#!/bin/sh

BASEDIR=`dirname $0`
ubuntu-vm-builder \
	qemu trusty \
	--verbose --overwrite \
	--dest rubis0 \
	--mirror http://se.archive.ubuntu.com/ubuntu \
	--mem 4096 \
	--part $BASEDIR/partitions.info \
	--addpkg linux-image-generic \
	--domain ds.cs.umu.se \
	--execscript $BASEDIR/post-install.sh

