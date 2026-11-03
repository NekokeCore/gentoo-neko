# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop unpacker xdg

DESCRIPTION="Database management tool built with Tauri"
HOMEPAGE="https://dbxio.com/cn https://github.com/t8y2/dbx"
SRC_URI="
	amd64? ( https://github.com/t8y2/dbx/releases/download/v${PV}/DBX_${PV}_amd64.deb )
	arm64? ( https://github.com/t8y2/dbx/releases/download/v${PV}/DBX_${PV}_arm64.deb )
"
S="${WORKDIR}"

LICENSE="Apache-2.0 MIT OFL-1.1"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="strip"

RDEPEND="
	dev-libs/glib:2
	dev-libs/libayatana-appindicator
	dev-libs/wayland
	media-libs/fontconfig:1.0
	net-libs/libsoup:3.0
	net-libs/webkit-gtk:4.1/0
	sys-apps/dbus
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-misc/xdg-utils
"

QA_PREBUILT="usr/bin/dbx"

src_install() {
	dobin usr/bin/dbx
	newmenu usr/share/applications/DBX.desktop dbx.desktop

	insinto /usr/share/icons
	doins -r usr/share/icons/hicolor

	newdoc "${FILESDIR}/LICENSE-${PV}" LICENSE
	newdoc "${FILESDIR}/NOTICE-${PV}" NOTICE
	newdoc "${FILESDIR}/Geist-LICENSE-${PV}.txt" Geist-LICENSE.txt
	newdoc "${FILESDIR}/flags-LICENSE-${PV}" flags-LICENSE
}
