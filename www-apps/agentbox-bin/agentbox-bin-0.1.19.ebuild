# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{12..15} )

inherit python-single-r1 systemd

DESCRIPTION="Web console for containerized Claude Code and Codex workspaces"
HOMEPAGE="https://github.com/devilcoolyue/agentbox"
SRC_URI="
	amd64? (
		https://github.com/devilcoolyue/agentbox/releases/download/v${PV}/agentbox_v${PV}_linux_amd64.tar.gz
			-> ${P}.amd64.tar.gz
	)
	arm64? (
		https://github.com/devilcoolyue/agentbox/releases/download/v${PV}/agentbox_v${PV}_linux_arm64.tar.gz
			-> ${P}.arm64.tar.gz
	)
"
S="${WORKDIR}/${P}"

LICENSE="Apache-2.0 BSD BSD-2 ISC MIT MPL-2.0 OFL-1.1"
SLOT="0"
KEYWORDS="-* ~amd64 ~arm64"
RESTRICT="strip"

RDEPEND="${PYTHON_DEPS}
	app-containers/docker
	app-misc/ca-certificates
	dev-vcs/git
	net-misc/curl
	sys-libs/timezone-data
"
REQUIRED_USE="${PYTHON_REQUIRED_USE}"

QA_PREBUILT="
	opt/agentbox/agentbox
	opt/agentbox/clients/abox-link-darwin-amd64
	opt/agentbox/clients/abox-link-darwin-arm64
	opt/agentbox/clients/abox-link-linux-amd64
	opt/agentbox/clients/abox-link-linux-arm64
	opt/agentbox/clients/abox-link-windows-amd64.exe
"

src_unpack() {
	local arch
	arch=$(usex amd64 amd64 arm64)

	unpack "${P}.${arch}.tar.gz"
	mv "agentbox_v${PV}_linux_${arch}" "${P}" || die
}

src_install() {
	dodir /opt/agentbox
	cp -a . "${ED}/opt/agentbox/" || die

	# Upstream's installer, in-app updater and release retention manage
	# /opt/agentbox/releases, which Portage owns here.
	rm -r "${ED}"/opt/agentbox/{install.sh,uninstall.sh,deploy} || die
	dosym -r /opt/agentbox/agentbox /usr/bin/agentbox
	python_fix_shebang "${ED}"/opt/agentbox/scripts/tool-storage.py

	insinto /etc/agentbox
	newins "${FILESDIR}"/config-${PV}.json config.json
	fperms 0600 /etc/agentbox/config.json

	keepdir /var/lib/agentbox
	fperms 0700 /var/lib/agentbox

	systemd_newunit "${FILESDIR}"/agentbox.service agentbox.service
	newinitd "${FILESDIR}"/agentbox.initd agentbox

	dodoc LICENSE NOTICE README.md
	dodoc -r third_party
}

pkg_postinst() {
	if [[ -z ${REPLACING_VERSIONS} ]]; then
		elog "Before the first start, set auth_token in /etc/agentbox/config.json to a"
		elog "secret of at least 8 characters. It is the initial password of the"
		elog "boxadmin administrator account. The service refuses to start without it."
		elog
		elog "Then build the workspace image, which needs network access and Docker:"
		elog "  bash /opt/agentbox/scripts/build-image.sh"
		elog
		elog "Start the service with systemctl enable --now agentbox, or with"
		elog "rc-update add agentbox default && rc-service agentbox start."
	fi

	elog "Upgrade this package with Portage. The in-app updater, install.sh and"
	elog "deploy/release.py are not installed because Portage owns /opt/agentbox."
}
