# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop multilib pax-utils unpacker xdg

DESCRIPTION="An elegant Apple Music desktop client"
HOMEPAGE="https://github.com/wimpysworld/sidra"

SRC_URI="
	amd64? (
		https://github.com/wimpysworld/sidra/releases/download/${PV}/Sidra-${PV}-linux-amd64.deb
			-> ${P}-amd64.deb
	)
	arm64? (
		https://github.com/wimpysworld/sidra/releases/download/${PV}/Sidra-${PV}-linux-arm64.deb
			-> ${P}-arm64.deb
	)
"
S="${WORKDIR}"

LICENSE="BlueOak-1.0.0 MIT"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="mirror strip"

RDEPEND="
	app-accessibility/at-spi2-core:2
	app-crypt/libsecret
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/libayatana-appindicator
	dev-libs/libdbusmenu:0[gtk3]
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/libglvnd
	media-libs/libpulse
	media-libs/mesa
	net-print/cups
	sys-apps/dbus
	sys-apps/util-linux
	virtual/libudev
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/libdrm
	x11-libs/libnotify
	x11-libs/libX11
	x11-libs/libXScrnSaver
	x11-libs/libXcomposite
	x11-libs/libXdamage
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXrandr
	x11-libs/libXtst
	x11-libs/libxcb
	x11-libs/libxkbcommon
	x11-libs/pango
	x11-misc/xdg-utils
"

QA_PREBUILT="*"

src_prepare() {
	default

	# The upstream entry only lists Audio, but the freedesktop specification
	# requires AudioVideo to be present alongside it.
	sed -i 's/^Categories=Audio;$/Categories=AudioVideo;Audio;/' \
		usr/share/applications/sidra.desktop || die "failed to fix Categories"
}

src_install() {
	dodir /opt
	mv opt/Sidra "${ED}/opt/" || die "failed to install Sidra"

	# Electron's SUID sandbox helper must be owned by root.
	fowners root:root /opt/Sidra/chrome-sandbox
	fperms 4755 /opt/Sidra/chrome-sandbox

	# Allow V8's JIT to run under PaX/hardened kernels.
	pax-mark m "${ED}/opt/Sidra/sidra" "${ED}/opt/Sidra/chrome_crashpad_handler"

	dosym /opt/Sidra/sidra /usr/bin/sidra

	# Electron looks for the Debian libappindicator name for tray support.
	dosym "../../usr/$(get_libdir)/libayatana-appindicator3.so.1" /opt/Sidra/libappindicator3.so.1
	dosym libappindicator3.so.1 /opt/Sidra/libappindicator3.so

	domenu usr/share/applications/sidra.desktop

	insinto /usr/share/icons
	doins -r usr/share/icons/hicolor

	gzip -dc usr/share/doc/sidra/changelog.gz > "${T}/changelog" || die
	dodoc "${T}/changelog"
}

pkg_postinst() {
	xdg_pkg_postinst
}

pkg_postrm() {
	xdg_pkg_postrm
}
