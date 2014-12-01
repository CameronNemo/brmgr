IMPORTANT: upstream development has made this obsolete, please use the upstart jobs, systemd services, etc. from github.com/lxc/lxc

#lxc-net

This is a set of shell scripts to set up and tear down the bridge inteface, as well as run dnsmasq on the interface for routing purposes.

Serge Hallyn originally authored this code as the lxc-net Upstart job in the lxc ubuntu package, however it has been highly adapted to be init system agnostic and slightly simpler.

##Installation

The lxc package in Ubuntu has all of this built in to the Upstart job, this is not needed there unless you want to use systemd.

To install, just run `./install.sh`, optionally setting the BINDIR env variable to control where the binaries go (default is /usr/local/bin).

You will also have to add the system user `lxc-dnsmasq`:

    adduser --system --home /nonexistent --no-create-home --shell /bin/false --disabled-password --disabled-login lxc-dnsmasq

In Debian and Ubuntu, the packages required are: bridge-utils, iptables, dnsmasq-base. (lxc is technically not required, but lxc-net is useless otherwise)

If you are running dnsmasq as a system service, you need to make sure that it is running with the config dir of `/etc/dnsmasq.d` (or install the lxc-net dnsmasq conf to whatever other directory you are using).

Currently only systemd and Upstart have jobs / services written, but contributions for OpenRC, LSB init scripts, etc. are very welcome and probably simple to write (just take a look at the current files in config/init).
