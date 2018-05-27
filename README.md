# lxc-net

This is a set of shell scripts to set up and tear down the bridge inteface, as well as run dnsmasq on the interface for routing purposes.

## Installation

The lxc package in Ubuntu has all of this built in to the Upstart job, this is not needed there unless you want to use systemd.

To install, just run `./install.sh`.

You will also have to add the system user `lxc-dnsmasq`:

    adduser --system --home /nonexistent --no-create-home --shell /bin/false --disabled-password --disabled-login lxc-dnsmasq

In Debian and Ubuntu, the packages required are: `bridge-utils iptables dnsmasq-base`.

If you are running dnsmasq as a system service, you need to make sure that it is running with the config dir of `/etc/dnsmasq.d` (or install the lxc-net dnsmasq conf to whatever other directory you are using).

## Use

Configure your containers to use the bridge set up by this package by including the following keys:

    lxc.net.0.type = veth
    lxc.net.0.link = lxcbr0
    lxc.net.0.flags = up
    lxc.net.0.name = eth0
    lxc.net.0.hwaddr = ee:ec:fa:e9:56:7d

Or simply:

    lxc.include = /usr/local/share/lxc-net/lxc-net.conf

## Misc

Currently only systemd and Upstart have jobs / services written, but contributions for OpenRC, LSB init scripts, etc. are very welcome and probably simple to write (just take a look at the current files in config/init).
