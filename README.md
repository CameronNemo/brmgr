# lxc-net

This is a set of shell scripts to set up and tear down the bridge inteface, as well as run dnsmasq on the interface for routing purposes.

## Installation

To install, just run `./install.sh`.

In Debian and Ubuntu, the packages required during runtime are:

    bridge-utils iptables dnsmasq-base

If you are also running dnsmasq as a system service, you need to make sure that it is running with the config dir of `/etc/dnsmasq.d` (or install the lxc-net dnsmasq conf to whatever other directory you are using).

## Configuring containers to use the bridge

Configure your containers to use the bridge set up by this package by including the following keys:

    lxc.net.0.type = veth
    lxc.net.0.link = lxcbr0
    lxc.net.0.flags = up
    lxc.net.0.name = eth0
    lxc.net.0.hwaddr = ee:ec:fa:e9:56:7d
    # dhcp! override for static configuration
    lxc.net.0.ipv4.address = 0.0.0.0
    lxc.net.0.ipv4.gateway = auto

Or simply:

    lxc.include = /usr/local/share/lxc-net/lxc-net.conf

Then, in the guest containers, configure your network interface management for the `eth0` interface.

Here is an `ifupdown` snippet for reference:

    iface eth0 inet dhcp

## Running and using the bridge

Start the bridge, then start the containers:

    systemctl start lxc-net
    lxc-start foo
    lxc-start bar

Currently only systemd and Upstart have jobs / services written, but contributions for OpenRC, LSB init scripts, etc. are very welcome and probably simple to write (just take a look at the current files in config/init).
