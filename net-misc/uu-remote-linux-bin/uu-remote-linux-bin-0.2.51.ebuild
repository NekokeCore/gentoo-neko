# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop optfeature systemd udev xdg

DESCRIPTION="Unofficial native Linux host for NetEase UU Remote"
HOMEPAGE="https://github.com/VallierDev/uu-remote-linux"
SRC_URI="
	amd64? ( https://github.com/VallierDev/uu-remote-linux/releases/download/v${PV}/uu-remote-linux-v${PV}-x86_64-linux.tar.gz )
	arm64? ( https://github.com/VallierDev/uu-remote-linux/releases/download/v${PV}/uu-remote-linux-v${PV}-aarch64-linux.tar.gz )
"

case ${ARCH} in
	amd64) MY_ARCH=x86_64 ;;
	arm64) MY_ARCH=aarch64 ;;
esac
S="${WORKDIR}/uu-remote-linux-v${PV}-${MY_ARCH}-linux"

# GPL-3 for the package itself; the rest is the union of the Cargo.lock crates
# that upstream links into the release binaries.
LICENSE="
	0BSD
	Apache-2.0
	Apache-2.0-with-LLVM-exceptions
	BSD
	BSD-1
	BSD-2
	Boost-1.0
	CDLA-Permissive-2.0
	GPL-3
	ISC
	LGPL-2.1
	MIT
	Unicode-3.0
	Unlicense
	WTFPL-2
	ZLIB
"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="strip"

RDEPEND="
	app-accessibility/at-spi2-core
	dev-libs/glib:2
	>=dev-libs/libei-1.1
	dev-libs/wayland
	media-libs/libsdl2
	media-video/ffmpeg[x264]
	media-video/pipewire
	x11-apps/xrandr
	x11-libs/cairo
	x11-libs/gdk-pixbuf:2
	x11-libs/gtk+:3
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXfixes
	x11-libs/libXtst
	x11-libs/libxkbcommon
	x11-libs/pango
"

QA_PREBUILT="
	usr/bin/uuremote-server
	usr/bin/uuremote-viewer
	usr/lib/uu-remote-linux/libuu-portal.so
	usr/lib/uu-remote-linux/libuu-wayland.so
"

src_install() {
	dobin uuremote-server uuremote-viewer

	insinto /usr/lib/uu-remote-linux
	doins libuu-portal.so libuu-wayland.so

	systemd_douserunit "${FILESDIR}/uuremote-native.service"
	udev_dorules "${FILESDIR}/60-uu-remote-linux-uinput.rules"

	domenu contrib/desktop/uu-remote-linux.desktop contrib/desktop/uu-remote-linux-viewer.desktop
	doicon -s scalable contrib/desktop/uu-remote-linux.svg

	dodoc LICENSE README.md README.en.md config.example.json
}

pkg_postinst() {
	xdg_pkg_postinst
	udev_reload

	elog "Log in as your desktop user, then start the host inside the graphical session:"
	elog "  uuremote-server login"
	elog "  systemctl --user enable --now uuremote-native.service"
	elog "GNOME and KDE pass DISPLAY and WAYLAND_DISPLAY to the user manager; other"
	elog "desktops need a drop-in with Environment=DISPLAY=:0."
	elog "The udev rule grants the seat user access to /dev/uinput; the host falls back"
	elog "to the desktop portal or XTest when the kernel lacks CONFIG_INPUT_UINPUT."

	optfeature "Wayland clipboard sync" gui-apps/wl-clipboard
	optfeature "GPU name in the login information" sys-apps/pciutils
}

pkg_postrm() {
	xdg_pkg_postrm
	udev_reload
}
