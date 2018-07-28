ifeq ($(PREFIX),)
    PREFIX := /usr/local
endif
ifeq ($(SYSCONFDIR),)
    SYSCONFDIR := /etc
endif

BINDIR := $(DESTDIR)$(PREFIX)/bin
DATADIR := $(DESTDIR)$(PREFIX)/share/brmgr
SYSTEMDUNITDIR := $(DESTDIR)$(PREFIX)/lib/systemd/system

all:
	$(shell for f in config/*.in; do sed "s|@bindir@|$(PREFIX)/bin|" "$${f}" >"$${f%%.in}"; done)

install: all
	install -m 755 -d $(DATADIR) $(BINDIR) $(DESTDIR)$(SYSCONFDIR)/brmgr \
		$(DESTDIR)$(SYSCONFDIR)/sv/brmgr-brmgr0 $(DESTDIR)$(SYSCONFDIR)/dnsmasq.d \
		$(DESTDIR)$(SYSCONFDIR)/init $(SYSTEMDUNITDIR)
	install -m 644 config/brmgr.upstart $(DESTDIR)$(SYSCONFDIR)/init/brmgr.conf
	install -m 755 config/brmgr.run $(DESTDIR)$(SYSCONFDIR)/sv/brmgr-brmgr0/run
	install -m 755 config/brmgr.finish $(DESTDIR)$(SYSCONFDIR)/sv/brmgr-brmgr0/finish
	install -m 644 -t $(DESTDIR)$(SYSCONFDIR)/brmgr config/brmgr/brmgr0.conf
	install -m 644 -t $(DESTDIR)$(SYSCONFDIR)/dnsmasq.d config/dnsmasq.d/brmgr.conf
	install -m 644 -t $(DATADIR) config/lxc.container.conf
	install -m 644 -t $(SYSTEMDUNITDIR) config/brmgr@.service
	install -m 755 -t $(BINDIR) src/*

clean:
	find config -maxdepth 1 -name 'brmgr*.*' ! -name '*.in' -delete
