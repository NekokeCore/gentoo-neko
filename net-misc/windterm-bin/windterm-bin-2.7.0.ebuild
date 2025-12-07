# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

PKG_PN="WindTerm"
PKG_ARCH="x86_64"
PKG_FILE="${PKG_PN}_${PV}_Linux_Portable_${PKG_ARCH}.tar.gz"

DESCRIPTION="A quicker and better SSH/Telnet/Serial/Shell/Sftp client"
HOMEPAGE="https://github.com/kingToolbox/WindTerm"
SRC_URI="https://github.com/kingToolbox/WindTerm/releases/download/${PV}/${PKG_FILE}"

S="${WORKDIR}/${PKG_PN}_${PV}_Linux_Portable_${PKG_ARCH}"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="~amd64"
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

	fperms 0755 "${install_dir}/WindTerm"

	cat > "${T}/windterm" <<-EOF
		#!/bin/sh
		cd "${install_dir}"
		# Force use XWayland
		# export QT_QPA_PLATFORM=xcb
		export LD_LIBRARY_PATH="\${PWD}/lib:\${LD_LIBRARY_PATH}"
		exec ./WindTerm "\$@"
	EOF
	dobin "${T}/windterm"

	if [[ -f "windterm.png" ]]; then
		doicon -s 256 "windterm.png"
		make_desktop_entry "windterm" "WindTerm" "windterm" "System;TerminalEmulator;Network;"
	else
		make_desktop_entry "windterm" "WindTerm" "" "System;TerminalEmulator;Network;"
	fi
}
