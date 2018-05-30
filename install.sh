#!/bin/sh -e

test -n "$install_prefix" || install_prefix=/usr/local
test -n "$systemdunitdir" || systemdunitdir=/lib/systemd/system
test -n "$sysconfdir" || sysconfdir=/etc

bindir="${install_prefix}/lib/lxc-net"
lxcconfdir="${install_prefix}/share/lxc-net"

ensure_dir() {
	local dir="$1"
	test -e "$dir" || mkdir -p "$dir"
	test -d "$dir" || { echo "ERROR: $dir is not a directory"; exit 1; }
}

ensure_dir "$bindir"
ensure_dir "$lxcconfdir"
ensure_dir "$systemdunitdir"
ensure_dir "$sysconfdir"/init
ensure_dir "$sysconfdir"/dnsmasq.d

cp src/dnsmasq-wrapper "$bindir"/dnsmasq
cp src/bridge-up "$bindir"/bridge-up
cp src/bridge-down "$bindir"/bridge-down

cp config/lxc.container.conf "$lxcconfdir"/lxc-net.conf

cp config/init/systemd "$systemdunitdir"/lxc-net.service

cp config/init/upstart "$sysconfdir"/init/lxc-net.conf
cp config/lxc-net "$sysconfdir"/
cp config/dnsmasq.d/lxc-net "$sysconfdir"/dnsmasq.d/

useradd --system --user-group --shell /bin/false --home-dir /nonexistent lxc-dnsmasq
