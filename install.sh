#!/bin/sh -e

test -n "$install_prefix" || install_prefix=/usr/local
test -n "$systemdunitdir" || systemdunitdir=/lib/systemd/system
test -n "$sysconfdir" || sysconfdir=/etc

bindir="${install_prefix}/lib/brmgr"
lxcconfdir="${install_prefix}/share/brmgr"

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

for f in src/*; do
	cp "$f" "$bindir"
done

for f in config/brmgr.service config/brmgr.upstart; do
	sed "s|@bindir@|${bindir}|" "$f" >"${f}.out"
done

cp config/lxc.container.conf "$lxcconfdir"
cp config/brmgr.service.out "$systemdunitdir"/brmgr.service
cp config/brmgr.upstart.out "$sysconfdir"/init/brmgr.conf
cp config/brmgr.conf "$sysconfdir"
cp config/dnsmasq.d/brmgr.conf "$sysconfdir"/dnsmasq.d/
