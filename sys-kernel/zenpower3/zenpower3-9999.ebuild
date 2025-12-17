# Copyright 2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

MODULE_NAME="zenpower"

inherit git-r3 linux-mod-r1

DESCRIPTION="Linux kernel driver for reading sensors of AMD Zen family CPUs"
HOMEPAGE="https://github.com/AliEmreSenel/zenpower3"
EGIT_REPO_URI="https://github.com/AliEmreSenel/zenpower3.git"

LICENSE="GPL-2"
SLOT="0"

CONFIG_CHECK="HWMON PCI AMD_NB"

RDEPEND="sys-apps/lm-sensors"

src_compile() {
	local modlist=(
		${MODULE_NAME}=kernel/drivers/hwmon:::all
	)
	linux-mod-r1_src_compile
}

src_install() {
	linux-mod-r1_src_install

	insinto /etc/modprobe.d
	newins - zenpower.conf <<-_EOF_
		# Installed by ${CATEGORY}/${PF}
		# zenpower uses the same PCI device as k10temp
		blacklist k10temp
	_EOF_
}

pkg_postinst() {
	linux-mod-r1_pkg_postinst

	if grep -q "^k10temp" /proc/modules; then
		ewarn "k10temp is currently loaded and conflicts with zenpower."
		ewarn "Attempting to unload k10temp now..."
		modprobe -r k10temp 2>/dev/null

		if grep -q "^k10temp" /proc/modules; then
			ewarn "Failed to unload k10temp. You must unload it manually or reboot"
			ewarn "before loading zenpower."
		else
			einfo "Successfully unloaded k10temp."
		fi
	fi

	elog "k10temp has been blacklisted in /etc/modprobe.d/zenpower.conf"
	elog "To use the driver immediately, run: modprobe zenpower"
}
