# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit git-r3 linux-mod-r1

DESCRIPTION="Linux kernel driver for reading sensors of AMD Zen family CPUs"
HOMEPAGE="https://github.com/AliEmreSenel/zenpower3"
EGIT_REPO_URI="https://github.com/AliEmreSenel/zenpower3.git"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64"
IUSE=""

MODULE_NAMES="zenpower(misc:${S})"
BUILD_TARGETS="all"

RDEPEND="sys-apps/lm-sensors"

BLACKLIST_FILE="zenpower.conf"

src_install() {
	linux-mod-r1_src_install

	insinto /etc/modprobe.d
	newins - ${BLACKLIST_FILE} <<-EOF
		# Installed by sys-kernel/zenpower3
		# zenpower uses the same PCI device as k10temp
		blacklist k10temp
	EOF
}

pkg_postinst() {
	linux-mod-r1_pkg_postinst

	if lsmod | grep -q '^k10temp'; then
		ewarn "k10temp is currently loaded and conflicts with zenpower."
		ewarn "Attempting to unload k10temp now."
		modprobe -r k10temp 2>/dev/null || \
			ewarn "Failed to unload k10temp. A reboot may be required."
	fi

	elog "k10temp has been blacklisted via /etc/modprobe.d/${BLACKLIST_FILE}"
	elog "Load zenpower with:"
	elog "  modprobe zenpower"
}

pkg_prerm() {
	rm -f "${EROOT}/etc/modprobe.d/${BLACKLIST_FILE}"
}
