# brmgr

This project leverages `dnsmasq`, `iproute2`, and `iptables` to manage bridge devices.

The `brmgr-pre` and `brmgr-post` tools are responsible for creating and tearing down the bridges. The `brmgr` tool is a wrapper around `dnsmasq`, which offers DHCP and DNS services to virtual interfaces connected to the bridge.

## Installation

To install, just run `make install`. You may wish to change the install prefix, `/usr/local` by default, with the `$PREFIX` environmental variable.

Runtime dependencies include: `iproute2`, `iptables`, and `dnsmasq-base`.

If you are also running dnsmasq as a system service, you need to make sure that it is not bound to brmgr's interface. We install a config snippet to achieve this in `/etc/dnsmasq.d`. Make sure your system dnsmasq instance is configured to use the snippet.

## Configuring the bridge

The default configuration is found at `$sysconfdir/brmgr/brmgr0.conf`. After reviewing it, enable the service:

    $ vim /etc/brmgr/brmgr0.conf
    # systemd
    $ systemctl enable brmgr@brmgr0.service
    # Runit
    $ ln -s /etc/sv/brmgr-brmgr0 /var/service

> Note: The default subnet is `10.0.1.0/24`; you may wish to change this and/or add an IPV6 subnet.

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

Where `@install_prefix@` is `/usr/local` or the option used at install time.

### DHCP

Unless you chose to have LXC manage the `dhclient` or are using a static config, you will need to run the dhclient in the guest container. This is often done by network configuration services such as `ifupdown`, `systemd-networkd`, or `NetworkManager`, but in a lightweight container environment these may not be available. It would be best to manage the `dhclient` with a service manager such as runit, Upstart, or systemd, but you can run it from the command line if there is a need:

    /sbin/dhclient

The PID file is stored in `/run/dhclient.pid` by default. You may also need to add a nameserver to `/etc/resolv.conf`:

    echo "nameserver [addr]" >> /etc/resolv.conf

Replace `[addr]` with the gateway address.

## Starting brmgr

Current supported service managers are systemd, Runit, and Upstart. Contributions for OpenRC, LSB init scripts, etc. are very welcome and probably simple to write.

    # systemd
    systemctl start brmgr@brmgr0.service
    # Runit
    sv up brmgr-brmgr0
    # Upstart
    start brmgr MATCH=/etc/brmgr/brmgr0.conf
