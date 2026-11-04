# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Tunnel client that exposes a local network to agentbox workspaces"
HOMEPAGE="https://github.com/devilcoolyue/agentbox"
SRC_URI="
	amd64? (
		https://github.com/devilcoolyue/agentbox/releases/download/v${PV}/abox-link_v${PV}_linux_amd64.tar.gz
			-> ${P}.amd64.tar.gz
	)
	arm64? (
		https://github.com/devilcoolyue/agentbox/releases/download/v${PV}/abox-link_v${PV}_linux_arm64.tar.gz
			-> ${P}.arm64.tar.gz
	)
"
S="${WORKDIR}/${P}"

LICENSE="Apache-2.0 BSD BSD-2 ISC MIT MPL-2.0 OFL-1.1"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="strip"

QA_PREBUILT="usr/bin/abox-link"

src_unpack() {
	local arch
	arch=$(usex amd64 amd64 arm64)

	unpack "${P}.${arch}.tar.gz"
	mv "abox-link_v${PV}_linux_${arch}" "${P}" || die
}

src_install() {
	dobin abox-link

	dodoc LICENSE NOTICE README.md
	dodoc -r third_party
}

pkg_postinst() {
	elog "Run abox-link without arguments to open its control panel on"
	elog "http://127.0.0.1:7801, then pair it with a code from agentbox."
	elog "Run abox-link --help for the headless --server mode."
}
