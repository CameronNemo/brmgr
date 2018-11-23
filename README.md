# brmgr

This project leverages `dnsmasq`, `iproute2`, and `iptables` to manage virtual
bridge devices for use with containers or virtual machines.

The `brmgr-pre` and `brmgr-post` tools are responsible for creating and tearing
down the bridges. The `brmgr` tool is a wrapper around `dnsmasq`, which offers
DHCP and DNS services to hosts connected to the bridge.

## Installation

To install, just run `make install`. You may wish to change the install prefix,
which is `/usr/local` by default, by setting the `$PREFIX` variable.

    # make install PREFIX=/usr

Runtime dependencies include: `iproute2`, `iptables`, and `dnsmasq`.

If you are also running dnsmasq as a system service, you need to ensure that it
does not conflict with brmgr. A config snippet is installed in `/etc/dnsmasq.d`
to achieve this. Verify that the system dnsmasq instance is configured to use
the snippet.

## Configuring the bridge

The default configuration is found at `$sysconfdir/brmgr/brmgr0.conf`. Review
and edit it as necessary.

    # vim /etc/brmgr/brmgr0.conf

> Note: The default subnet is `10.0.1.0/24`; you may wish to change this and/or
> add an IPV6 subnet.

When you are ready, enable the service.

With systemd:

    # systemctl enable brmgr@brmgr0.service

Or with runit:

    # ln -s /etc/sv/brmgr-brmgr0 /var/service

## Configuring containers to use the bridge

Configure a veth interface in your containers and link it to the bridge set up
by this package by including the following keys:

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
    #lxc.net.0.ipv4.address = 10.0.1.2/24

Or simply:

    lxc.include = @install_prefix@/share/brmgr/lxc.container.conf

Where `@install_prefix@` is `/usr/local` or the option used at install time.

## Configuring QEMU/KVM to use the bridge

To use the bridge with QEMU, add the following to the command arguments:

    -netdev bridge,id=lan0,br=brmgr0 -device virtio-net-pci,netdev=lan0

If you are running your VMs as an unprivileged user, you must add the line

    allow brmgr0

to `/etc/qemu/bridge.conf`.

Replace `brmgr0` with the name of the bridge you configured, if necessary.

### DHCP

Unless LXC is managing `dhclient` or a static IP is in use, a DHCP client will
need to run in the guest. This is often done by network configuration services
such as `dhcpcd`, `ifupdown`, `systemd-networkd`, or `NetworkManager`, but in a
lightweight container environment these may not be available.

It would be best to manage the `dhclient` with a service manager such as
systemd or runit, but you can run it from the command line if necessary.

    # dhclient

You may also need to add a nameserver to `/etc/resolv.conf`:

    # echo "nameserver [addr]" >> /etc/resolv.conf

Replace `[addr]` with the gateway address (address of the bridge).

## Starting brmgr

Current supported service managers are systemd, OpenRC, Runit, and Upstart.
Contribution of an LSB init script is quite welcome and likely simple to write.

With systemd:

    # systemctl start brmgr@brmgr0.service

With runit:

    # sv up brmgr-brmgr0

With Upstart:

    # start brmgr MATCH=/etc/brmgr/brmgr0.conf
