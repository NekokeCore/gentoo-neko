# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

PKG_PN="WindTerm"
PKG_ARCH="x86_64"
PKG_FILE="${PKG_PN}_${PV}_Linux_Portable_${PKG_ARCH}.zip"

DESCRIPTION="A professional cross-platform SSH/Sftp/Shell/Telnet/Serial terminal"
HOMEPAGE="https://github.com/kingToolbox/WindTerm"
SRC_URI="https://github.com/kingToolbox/WindTerm/releases/download/${PV}/${PKG_FILE}"

S="${WORKDIR}/${PKG_PN}_${PV}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
IUSE="wayland"
RESTRICT="strip mirror"

RDEPEND="
	x11-libs/libX11
	x11-libs/libXtst
	x11-libs/libxcb
	x11-libs/libXext
	x11-libs/libXau
	x11-libs/libXdmcp

	media-libs/libglvnd
	media-libs/libpulse

	dev-libs/glib:2
	virtual/krb5
	sys-apps/dbus
"
DEPEND="${RDEPEND}"

src_install() {
	local install_dir="/opt/${PN}"
	dodir "${install_dir}"

	cp -R . "${ED}/${install_dir}" || die "Install failed"

	rm -rf "${ED}/${install_dir}/temp"

	dosym /tmp "${install_dir}/temp"

	cat > "${ED}/${install_dir}/profiles.config" <<-EOF
		{
		    "path" : "~"
		}
	EOF

	fperms 0755 "${install_dir}/WindTerm"

	cat > "${T}/windterm" <<-EOF
		#!/bin/sh
		cd "${install_dir}"
	EOF

	if ! use wayland; then
        echo 'export QT_QPA_PLATFORM=xcb' >> "${T}/windterm"
    fi

	cat >> "${T}/windterm" <<-EOF
		export LD_LIBRARY_PATH="\${PWD}/lib:\${LD_LIBRARY_PATH}"
		exec ./WindTerm "\$@"
	EOF

	dobin "${T}/windterm"

	domenu "${ED}/${install_dir}/windterm.desktop"

	# 安装图标 (只要你的源码包里有 windterm.png)
	if [[ -f "windterm.png" ]]; then
		doicon -s 256 "windterm.png"
	fi
}
