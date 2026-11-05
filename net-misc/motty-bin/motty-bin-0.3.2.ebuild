# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit desktop xdg

DESCRIPTION="Native SSH, SFTP, port forwarding and remote desktop client"
HOMEPAGE="https://motty.page https://github.com/t8y2/motty"
SRC_URI="
	amd64? ( https://github.com/t8y2/motty/releases/download/v${PV}/motty-${PV}-linux-amd64.tar.gz )
	arm64? ( https://github.com/t8y2/motty/releases/download/v${PV}/motty-${PV}-linux-arm64.tar.gz )
"
S="${WORKDIR}"

LICENSE="Apache-2.0 BSD BSD-2 CC-BY-4.0 CC0-1.0 ISC MIT Unicode-3.0"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="strip"

RDEPEND="
	dev-libs/glib:2
	media-libs/fontconfig:1.0
	media-libs/vulkan-loader
	sys-apps/dbus
	x11-libs/cairo
	x11-libs/libxcb
	x11-libs/pango
	x11-misc/xdg-utils
"

QA_PREBUILT="usr/bin/motty"

src_install() {
	local release_arch
	case ${ARCH} in
		amd64|arm64) release_arch=${ARCH} ;;
		*) die "Unsupported architecture: ${ARCH}" ;;
	esac
	cd "motty-${PV}-linux-${release_arch}" || die

	dobin motty
	domenu motty.desktop
	doicon -s 256 motty.png

	newdoc "${FILESDIR}/LICENSE-${PV}" LICENSE
	newdoc "${FILESDIR}/NOTICE-${PV}" NOTICE
	newdoc "${FILESDIR}/icons-NOTICE-${PV}" icons-NOTICE
	newdoc "${FILESDIR}/rdpcore-LICENSE-${PV}" rdpcore-LICENSE
	newdoc "${FILESDIR}/rdpcore-NOTICE-${PV}.md" rdpcore-NOTICE.md
	newdoc "${FILESDIR}/carapace-LICENSE-${PV}" carapace-LICENSE
	newdoc "${FILESDIR}/go-THIRD_PARTY_NOTICES-${PV}.txt" go-THIRD_PARTY_NOTICES.txt
	newdoc "${FILESDIR}/modernc-THIRD_PARTY_NOTICES-${PV}.txt" modernc-THIRD_PARTY_NOTICES.txt
	newdoc "${FILESDIR}/viva-NOTICE-${PV}" viva-NOTICE
	newdoc "${FILESDIR}/viva-THIRD_PARTY_NOTICES-${PV}.md" viva-THIRD_PARTY_NOTICES.md
}
