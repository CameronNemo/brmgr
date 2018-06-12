# brmgr

This project leverages `dnsmasq`, `iproute2`, and `iptables` to manage bridge devices.

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

Configure a veth interface in your containers and link it to the bridge set up by this package by including the following keys:

    lxc.net.0.type = veth
    lxc.net.0.link = brmgr0
    lxc.net.0.name = eth0
    lxc.net.0.hwaddr = ee:ec:fa:e9:56:7d
    lxc.net.0.ipv4.gateway = auto
    lxc.net.0.flags = up
    # DHCP (default)
    lxc.net.0.ipv4.address = 0.0.0.0
    # Have LXC manage the dhclient
    #lxc.hook.start-host = /usr/share/lxc/hooks/dhclient
    #lxc.hook.stop = /usr/share/lxc/hooks/dhclient
    # Static configuration
    #lxc.net.0.ipv4.address = 10.0.1.2

Or simply:

    lxc.include = @install_prefix@/share/brmgr/lxc.container.conf

Where `@install_prefix@` should be `/usr/local` or the option used at install time.

Unless you chose to have LXC manage the `dhclient` or are using a static config, you will need to run the dhclient in the guest container. This is often done by network configuration services such as `ifupdown`, `systemd-networkd`, or `NetworkManager`, but in a lightweight container environment these may not be available. It would be best to manage the `dhclient` with a service manager such as runit, Upstart, or systemd, but you can run it from the command line if there is a need:

    /sbin/dhclient

The PID file is stored in `/run/dhclient.pid` by default.

## Running and using brmgr

`brmgr` provides configurations for Upstart and systemd.

Start the bridge, then start the containers:

    systemctl start brmgr
    lxc-start foo
    lxc-start bar

The containers, if configured correctly, will be assigned and IP address by dnsmasq and be able to access the bridge device's network.

Currently only systemd and Upstart have jobs / services written, but contributions for OpenRC, LSB init scripts, etc. are very welcome and probably simple to write (just take a look at the current files in config/init).
