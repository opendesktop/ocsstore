SHELL = /bin/sh

TARGET = opendesktop-app
srcdir = .

build_tmpdir = ./build_tmp
ocsmanager_bin = default
ocsmanager_tree_ish = master

DESTDIR =
prefix = /usr/local
exec_prefix = $(prefix)
bindir = $(exec_prefix)/bin
libdir = $(exec_prefix)/lib
datadir = $(prefix)/share

INSTALL = install
INSTALL_PROGRAM = $(INSTALL) -D -m 755
INSTALL_DATA = $(INSTALL) -D -m 644
MKDIR = mkdir -p
CP = cp -Rpf
RM = rm -rf

.PHONY: all rebuild build clean install uninstall

all: rebuild ;

rebuild: clean build ;

build: $(TARGET) ;

clean:
	$(RM) $(build_tmpdir)
	$(RM) $(srcdir)/node_modules
	$(RM) $(srcdir)/dist
	$(RM) $(srcdir)/bin

install:
	$(INSTALL_PROGRAM) $(srcdir)/launcher/$(TARGET) $(DESTDIR)$(bindir)/$(TARGET)
	$(INSTALL_PROGRAM) $(srcdir)/launcher/$(TARGET)-appimage $(DESTDIR)$(bindir)/$(TARGET)-appimage
	$(MKDIR) $(DESTDIR)$(libdir)
	$(CP) $(srcdir)/dist/$(TARGET)-linux-x64 $(DESTDIR)$(libdir)
	$(INSTALL_DATA) $(srcdir)/desktop/$(TARGET).desktop $(DESTDIR)$(datadir)/applications/$(TARGET).desktop
	$(INSTALL_DATA) $(srcdir)/desktop/$(TARGET).svg $(DESTDIR)$(datadir)/icons/hicolor/scalable/apps/$(TARGET).svg

uninstall:
	$(RM) $(DESTDIR)$(bindir)/$(TARGET)
	$(RM) $(DESTDIR)$(bindir)/$(TARGET)-appimage
	$(RM) $(DESTDIR)$(libdir)/$(TARGET)-linux-x64
	$(RM) $(DESTDIR)$(datadir)/applications/$(TARGET).desktop
	$(RM) $(DESTDIR)$(datadir)/icons/hicolor/scalable/apps/$(TARGET).svg

$(TARGET): $(TARGET)-linux-x64 ;

$(TARGET)-linux-x64: ocs-manager_$(ocsmanager_bin)
	cd $(srcdir) ; \
		npm install ; \
		npm run package

ocs-manager_default:
	mkdir -p $(build_tmpdir)
	git clone https://github.com/opendesktop/ocs-manager.git -b $(ocsmanager_tree_ish) --single-branch --depth=1 $(build_tmpdir)/ocs-manager
	cd $(build_tmpdir)/ocs-manager ; \
		./scripts/prepare ; \
		qmake ; \
		make
	install -D -m 755 $(build_tmpdir)/ocs-manager/ocs-manager $(srcdir)/bin/ocs-manager

ocs-manager_appimage:
	mkdir -p $(build_tmpdir)
	git clone https://github.com/opendesktop/ocs-manager.git -b $(ocsmanager_tree_ish) --single-branch --depth=1 $(build_tmpdir)/ocs-manager
	cd $(build_tmpdir)/ocs-manager ; \
		./scripts/package build_appimage
	install -D -m 755 `find "$(build_tmpdir)/ocs-manager" -type f -name "ocs-manager*.AppImage"` $(srcdir)/bin/ocs-manager
