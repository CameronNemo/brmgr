#!/bin/sh -e

test -n "$install_prefix" || install_prefix=/usr/local
test -n "$systemdunitdir" || systemdunitdir=/lib/systemd/system
test -n "$sysconfdir" || sysconfdir=/etc

bindir="${install_prefix}/lib/brmgr"
lxcconfdir="${install_prefix}/share/brmgr"

install -m 755 -d "$bindir" "$lxcconfdir" "$systemdunitdir" \
	"$sysconfdir"/init "$sysconfdir"/dnsmasq.d \
	"$sysconfdir"/brmgr "$sysconfdir"/sv/brmgr-brmgr0
install -m 755 -t "$bindir" src/*

for f in config/*.in; do
	sed "s|@bindir@|${bindir}|" "$f" >"${f%%.in}"
done

install -m 644 -t "$lxcconfdir" config/lxc.container.conf
install -m 644 -t "$sysconfdir"/dnsmasq.d config/dnsmasq.d/brmgr.conf
install -m 644 -t "$sysconfdir"/brmgr config/brmgr/brmgr0.conf
install -m 644 config/brmgr@.service	"$systemdunitdir"/brmgr@.service
install -m 644 config/brmgr.upstart	"$sysconfdir"/init/brmgr-brmgr0.conf
install -m 755 config/brmgr.run 	"$sysconfdir"/sv/brmgr-brmgr0/run
install -m 755 config/brmgr.finish	"$sysconfdir"/sv/brmgr-brmgr0/finish
