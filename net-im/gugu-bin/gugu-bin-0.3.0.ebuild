# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker wrapper xdg

DESCRIPTION="Desktop chat client with AI assistants"
HOMEPAGE="https://gugu.nextmind.space/en/ https://github.com/OpenDCAI/gugu"
SRC_URI="https://download.gugu.nextmind.space/releases/linux/${PV}/gugu-${PV}-x86_64.AppImage"
S="${WORKDIR}/${P}"

LICENSE="Gugu-0.3.0 all-rights-reserved Apache-2.0 Artistic-2 BSD BSD-2 BlueOak-1.0.0 CC-BY-3.0 CC0-1.0 ISC LGPL-2.1+ MIT"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="bindist mirror strip"

BDEPEND="app-arch/7zip"
RDEPEND="
	app-accessibility/at-spi2-core:2
	dev-libs/dbus-glib
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/libdbusmenu[gtk]
	dev-libs/libevent:0/2.1-7
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/mesa[gbm(+)]
	net-misc/openssh
	net-print/cups
	sys-apps/dbus
	sys-apps/util-linux
	sys-libs/libutempter
	sys-libs/ncurses:0/6[tinfo]
	virtual/libudev:0/1
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:2
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/pango
	x11-misc/xdg-utils
"

QA_PREBUILT="
	opt/gugu/libvulkan.so.1
	opt/gugu/libvk_swiftshader.so
	opt/gugu/libffmpeg.so
	opt/gugu/gugu
	opt/gugu/chrome_crashpad_handler
	opt/gugu/chrome-sandbox
	opt/gugu/resources/tmux-bundle/tmux
	opt/gugu/resources/frpc-bundle/frpc
	opt/gugu/resources/app/node_modules/@agentclientprotocol/claude-agent-acp/node_modules/@anthropic-ai/claude-agent-sdk-linux-x64/claude
	opt/gugu/resources/app/node_modules/@parcel/watcher-linux-x64-glibc/watcher.node
	opt/gugu/resources/app/node_modules/better-sqlite3/bin/linux-x64-149/better-sqlite3.node
	opt/gugu/resources/app/node_modules/better-sqlite3/build/Release/test_extension.node
	opt/gugu/resources/app/node_modules/better-sqlite3/build/Release/better_sqlite3.node
	opt/gugu/resources/app/node_modules/node-pty/bin/linux-x64-149/node-pty.node
	opt/gugu/resources/app/node_modules/node-pty/build/Release/pty.node
	opt/gugu/resources/mise-bundle/mise/bin/mise
	opt/gugu/usr/lib/libnotify.so.4
	opt/gugu/usr/lib/libindicator.so.7
	opt/gugu/usr/lib/libgconf-2.so.4
	opt/gugu/usr/lib/libappindicator.so.1
	opt/gugu/usr/lib/libXtst.so.6
	opt/gugu/usr/lib/libXss.so.1
"

src_unpack() {
	mkdir "${S}" || die
	cd "${S}" || die
	unpack_7z "${DISTDIR}/gugu-${PV}-x86_64.AppImage"
}

src_prepare() {
	default

	rm -r resources/app/node_modules/@parcel/watcher-linux-arm64-glibc \
		resources/app/node_modules/@agentclientprotocol/claude-agent-acp/node_modules/@anthropic-ai/claude-agent-sdk-linux-arm64 \
		|| die

	sed -i 's/^Exec=.*/Exec=gugu %U/' gugu.desktop || die
}

src_install() {
	domenu gugu.desktop
	doicon -s 512 usr/share/icons/hicolor/512x512/apps/gugu.png

	dodir /opt/gugu
	cp -a . "${ED}/opt/gugu/" || die
	fowners root:root /opt/gugu/chrome-sandbox
	fperms 4755 /opt/gugu/chrome-sandbox
	make_wrapper gugu /opt/gugu/AppRun

	newdoc "${FILESDIR}/THIRD_PARTY_NOTICES-${PV}.md" THIRD_PARTY_NOTICES.md
	newdoc "${FILESDIR}/LICENSE-APACHE-2.0-${PV}" LICENSE-APACHE-2.0
	newdoc "${FILESDIR}/LICENSE-${PV}" LICENSE
}
