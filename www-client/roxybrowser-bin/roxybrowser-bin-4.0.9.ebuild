# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit chromium-2 desktop unpacker xdg

DESCRIPTION="Browser profile manager with isolated browsing environments"
HOMEPAGE="https://roxybrowser.cn/"
SRC_URI="https://dl.roxybrowser.com/app-download/Linux-64-latest?version=${PV} -> RoxyBrowser_x64_${PV}.deb"
S="${WORKDIR}"

LICENSE="RoxyBrowser-20260512 Apache-2.0 BSD ISC LGPL-2.1+ MIT MPL-2.0 OFL-1.1"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="bindist mirror strip"

RDEPEND="
	app-accessibility/at-spi2-core:2
	app-crypt/libsecret
	dev-libs/expat
	dev-libs/glib:2
	dev-libs/nspr
	dev-libs/nss
	media-libs/alsa-lib
	media-libs/fontconfig
	media-libs/mesa[gbm(+)]
	net-print/cups
	sys-apps/dbus
	sys-apps/util-linux
	virtual/libudev:0/1
	x11-libs/cairo
	x11-libs/gtk+:3
	x11-libs/libnotify
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
	opt/RoxyBrowser/roxybrowser
	opt/RoxyBrowser/chrome-sandbox
	opt/RoxyBrowser/chrome_crashpad_handler
	opt/RoxyBrowser/libEGL.so
	opt/RoxyBrowser/libGLESv2.so
	opt/RoxyBrowser/libffmpeg.so
	opt/RoxyBrowser/libvk_swiftshader.so
	opt/RoxyBrowser/libvulkan.so.1
	opt/RoxyBrowser/resources/rg/rg
	opt/RoxyBrowser/resources/roxynet-seed/roxynet
	opt/RoxyBrowser/resources/node_modules/@napi-rs/canvas/skia.linux-x64-gnu.node
"

pkg_setup() {
	chromium_suid_sandbox_check_kernel_config
}

src_prepare() {
	default

	sed -i 's|^Exec=.*|Exec=roxybrowser %U|' \
		usr/share/applications/roxybrowser.desktop || die

	# The upstream updater installs Debian packages through pkexec.
	rm opt/RoxyBrowser/resources/com.roxybrowser.policy \
		opt/RoxyBrowser/resources/roxybrowser-update-wrapper.sh || die
}

src_install() {
	dodir /opt
	cp -a opt/RoxyBrowser "${ED}/opt/" || die
	fowners root:root /opt/RoxyBrowser/chrome-sandbox
	fperms 4755 /opt/RoxyBrowser/chrome-sandbox
	dosym -r /opt/RoxyBrowser/roxybrowser /usr/bin/roxybrowser

	domenu usr/share/applications/roxybrowser.desktop
	local size
	for size in 16 32 48 64 128 256 512 1024; do
		doicon -s ${size} usr/share/icons/hicolor/${size}x${size}/apps/roxybrowser.png
	done

	dodoc opt/RoxyBrowser/LICENSE.electron.txt
	dodoc opt/RoxyBrowser/LICENSES.chromium.html
}

pkg_postinst() {
	xdg_pkg_postinst
	elog "Use Portage to update Roxy Browser; its Debian package updater is unsupported."
	elog "Browser profiles download their browser engines into your user data directory."
}
