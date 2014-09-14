#!/bin/sh -e

test -n "$BINDIR" || BINDIR=/usr/local/bin

test -e "$BINDIR" || mkdir -p $BINDIR
test -e /lib/systemd/system || mkdir -p /lib/systemd/system
test -e /etc/init || mkdir -p /etc/init
test -e /etc/dnsmasq.d || mkdir -p /etc/dnsmasq.d

test -d "$BINDIR || { echo "ERROR: $BINDIR is not a directory"; exit 1; }

cp src/dnsmasq-wrapper $BINDIR/lxc-dnsmasq
cp src/bridge-up $BINDIR/lxc-bridge-up
cp src/bridge-down $BINDIR/lxc-bridge-down

cp config/init/upstart /etc/init/
cp config/init/systemd /lib/systemd/system/
cp config/lxc-net /etc/
cp config/dnsmasq.d/lxc-net /etc/dnsmasq.d/
