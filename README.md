# brmgr

This project leverages `dnsmasq`, `bridge-utils`, and `iptables` to manage bridge devices.

The `brmgr-pre` and `brmgr-post` tools are responsible for creating and tearing down the bridges. The `brmgr` tool is a wrapper around `dnsmasq`, which offers DHCP and DNS services to virtual interfaces connected to the bridge.

## Installation

To install, just run `./install.sh`.

Accepted configuration options, provided through environment variables, are:

    install_prefix	default: /usr/local
    sysconfdir		default: /etc
    systemdunitdir	default: /lib/systemd/system

Runtime dependencies include: `bridge-utils`, `iptables`, and `dnsmasq-base`.

If you are also running dnsmasq as a system service, you need to make sure that it is not bound to brmgr's interface. We install a config snippet to achieve this in `/etc/dnsmasq.d`. Make sure your system dnsmasq instance is configured to use the snippet.

## Configuring containers to use the bridge

Configure your containers to use the bridge set up by this package by including the following keys:

    lxc.net.0.type = veth
    lxc.net.0.link = brmgr0
    lxc.net.0.flags = up
    lxc.net.0.name = eth0
    lxc.net.0.hwaddr = ee:ec:fa:e9:56:7d
    # dhcp! override for static configuration
    lxc.net.0.ipv4.address = 0.0.0.0
    lxc.net.0.ipv4.gateway = auto

Or simply:

    lxc.include = @install_prefix@/share/brmgr/lxc.container.conf

Where `@install_prefix@` should be `/usr/local` or the option used at install time.

Then, in the guest containers, configure your network interface management for the `eth0` interface. Here is an `ifupdown` snippet for reference:

    iface eth0 inet dhcp

## Running and using brmgr

`brmgr` provides configurations for Upstart and systemd.

Start the bridge, then start the containers:

    systemctl start brmgr
    lxc-start foo
    lxc-start bar

The containers, if configured correctly, will be assigned and IP address by dnsmasq and be able to access the bridge device's network.

Currently only systemd and Upstart have jobs / services written, but contributions for OpenRC, LSB init scripts, etc. are very welcome and probably simple to write (just take a look at the current files in config/init).
