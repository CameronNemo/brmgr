lxc-net
=======

This is a set of shell scripts to set up and tear down the bridge inteface, as well as run dnsmasq on the interface for routing purposes.

Serge Hallyn originally authored this code as the lxc-net Upstart job in the lxc ubuntu package, however it has been highly adapted to be init system agnostic and slightly simpler.

=Installation=

In Debian and Ubuntu, the packages required are: bridge-utils, iptables, dnsmasq-base. (lxc is technically not recquired, but lxc-net is useless otherwise)

If you are running dnsmasq as a system service, you need to make sure that it is running with the config dir of `/etc/dnsmasq.d` (or install the lxc-net dnsmasq conf to whatever other directory you are using).
