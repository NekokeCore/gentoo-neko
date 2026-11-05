# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..15} )

inherit desktop optfeature python-single-r1 udev unpacker xdg

DESCRIPTION="NetEase UU Remote host for Linux with native Wayland capture"
HOMEPAGE="https://github.com/GaryOAO/UUWay"
SRC_URI="https://github.com/GaryOAO/UUWay/releases/download/v${PV}/uuway_${PV}_amd64.deb -> ${P}.deb"

S="${WORKDIR}"

PATCHES=( "${FILESDIR}"/${P}-gentoo-wine.patch )

LICENSE="AGPL-3+ MIT ZLIB"
SLOT="0"
KEYWORDS="-* ~amd64"
RESTRICT="strip"

REQUIRED_USE="${PYTHON_REQUIRED_USE}"

RDEPEND="${PYTHON_DEPS}
	$(python_gen_cond_dep 'dev-python/pygobject:3[${PYTHON_USEDEP}]')
	app-accessibility/at-spi2-core[introspection]
	app-emulation/wine-vanilla:11.0
	dev-libs/glib:2
	dev-libs/json-c
	media-libs/gst-plugins-base:1.0
	media-libs/gstreamer:1.0
	media-libs/libva
	media-libs/vulkan-loader
	media-video/ffmpeg-compat:6/58.60.60[vaapi]
	media-video/pipewire
	sys-apps/systemd
	x11-libs/gdk-pixbuf:2[introspection]
	x11-libs/gtk+:3[introspection]
	x11-libs/libX11
	x11-libs/libXfixes
	x11-libs/pango[introspection]
	x11-misc/xclip
	x11-misc/xvfb-run
"

BDEPEND="dev-util/patchelf"

QA_PREBUILT="
	usr/lib/uuway/build/*
	usr/lib/uuway/fcitx5/*
"

src_prepare() {
	default

	local binary
	for binary in uu-pipewire-native-probe uu-vaapi-probe uurb-nvenc-encode.dll.so; do
		patchelf --set-rpath "${EPREFIX}/usr/lib/ffmpeg6/$(get_libdir)" \
			"usr/lib/uuway/build/backends/amd/native-presenter/${binary}" || die
	done

	sed -i 's/"target": "ubuntu"/"target": "gentoo"/' usr/lib/uuway/package-info.json || die
}

src_install() {
	dodir /usr/lib
	cp -R usr/lib/uuway "${ED}"/usr/lib/ || die
	python_fix_shebang "${ED}"/usr/lib/uuway/scripts

	dosym ../lib/uuway/scripts/uuway_cli.py usr/bin/uuway
	dosym ../lib/uuway/scripts/uuway_console.py usr/bin/uuway-console

	domenu usr/share/applications/uuway.desktop
	doicon -s scalable usr/share/icons/hicolor/scalable/apps/uuway.svg
	udev_dorules usr/lib/udev/rules.d/70-uurb-native-input.rules

	dodoc usr/share/doc/uuway/{LICENSE,NOTICE,copyright}
	zcat usr/share/doc/uuway/changelog.gz > "${T}"/changelog || die
	dodoc "${T}"/changelog
}

pkg_postinst() {
	xdg_pkg_postinst
	udev_reload

	if [[ -z ${REPLACING_VERSIONS} ]]; then
		elog "UUWay runs the official Windows UU client under Wine and needs a"
		elog "GNOME Wayland or Hyprland session with systemd user services."
		elog
		elog "Finish the per-user setup as your normal user, not as root:"
		elog "  uuway setup"
		elog
		elog "The capture path is built against the Wine 11.0 server protocol,"
		elog "which =app-emulation/wine-vanilla-11.0 provides."
		elog
		elog "Built-in updates are disabled because the package manager owns these"
		elog "files; upgrade with emerge instead of 'uuway update'."
		elog
		elog "Run 'uuway uninstall' before unmerging, so the user units and the"
		elog "Wine prefix are removed as well."
	fi

	optfeature "NVIDIA NVENC capture backend" x11-drivers/nvidia-drivers
	optfeature "AMD VA-API capture backend" media-libs/mesa[vaapi]
	optfeature "Fcitx5 text input" app-i18n/fcitx:5
	optfeature "privilege escalation for the udev trigger" app-admin/sudo sys-auth/polkit
}

pkg_postrm() {
	xdg_pkg_postrm
	udev_reload
}
