# Maintainer: wellbou_ <wellbou@localhost>
# PKGBUILD for the wellutils suite of system/peripheral reporting tools.

pkgname=wellutils
pkgver=1.4.0
pkgrel=53
pkgdesc="Suite of colourful system and peripheral reporting tools (wellper, wellusb, wellpci, wellhw, wellmem, wellsensors, wellblock, wellcpu, wellgpu, wellmod, wellfetch, wellup, whtml)"
url="https://github.com/Wellbou/wellutils"
arch=('any')
license=('MIT')
depends=('bash' 'python' 'coreutils' 'procps-ng' 'hwdata')
optdepends=(
    'pciutils: PCI descriptions and listing (wellpci, wellhw, wellgpu)'
    'hwdata: USB device identification database (wellusb, wellper)'
    'smartmontools: disk temperature monitoring (wellsensors) and S.M.A.R.T. health (wellblock)'
    'nvme-cli: NVMe temperature monitoring (wellsensors)'
    'dmidecode: detailed memory info (wellhw)'
    'i2c-tools: decode-dimms SPD fallback for RAM detail (wellhw)'
    'util-linux: lscpu topology info (wellcpu)'
    'iproute2: interfaces, routes and listening ports (wellnet)'
    'iw: Wi-Fi SSID and signal info (wellnet)'
)
# This package builds from a full git checkout (packaging reads files out of
# ./src and ./completions via ${startdir}). makepkg cannot resolve local
# source() entries that live in subdirectories, so there is no source/checksum
# array here; the pkgfile is inherently checkout-only (see also compdir globs).

build() {
    true
}

package() {
    cd "${startdir}/src"
    install -d "${pkgdir}/usr/bin" \
        "${pkgdir}/usr/share/wellutils" \
        "${pkgdir}/usr/share/man/man1" \
        "${pkgdir}/usr/share/bash-completion/completions" \
        "${pkgdir}/usr/share/licenses/wellutils"
    install -m755 \
        wellper \
        wellhw \
        wellmem \
        wellsensors \
        wellusb \
        wellpci \
        wellblock \
        wellcpu \
        wellgpu \
        wellmod \
        wellfetch \
        wellup \
        wellnet \
        wellpower \
        welldoctor \
        whtml \
        wellutils \
        "${pkgdir}/usr/bin/"
    ln -s wellutils    "${pkgdir}/usr/bin/well"
    ln -s wellutils    "${pkgdir}/usr/bin/wutils"
    ln -s wellusb      "${pkgdir}/usr/bin/wusb"
    ln -s wellpci      "${pkgdir}/usr/bin/wpci"
    ln -s wellblock    "${pkgdir}/usr/bin/wblock"
    ln -s wellcpu      "${pkgdir}/usr/bin/wcpu"
    ln -s wellgpu      "${pkgdir}/usr/bin/wgpu"
    ln -s wellmem      "${pkgdir}/usr/bin/wmem"
    ln -s wellmem      "${pkgdir}/usr/bin/wram"
    ln -s wellmem      "${pkgdir}/usr/bin/wellram"
    ln -s wellmod      "${pkgdir}/usr/bin/wmod"
    ln -s wellsensors  "${pkgdir}/usr/bin/wsensors"
    ln -s wellsensors  "${pkgdir}/usr/bin/wtemp"
    ln -s wellhw       "${pkgdir}/usr/bin/whw"
    ln -s wellper      "${pkgdir}/usr/bin/wper"
    ln -s wellfetch    "${pkgdir}/usr/bin/wfetch"
    ln -s wellup       "${pkgdir}/usr/bin/wup"
    ln -s wellnet      "${pkgdir}/usr/bin/wnet"
    ln -s wellpower    "${pkgdir}/usr/bin/wpower"
    ln -s wellpower    "${pkgdir}/usr/bin/wbatt"
    ln -s welldoctor   "${pkgdir}/usr/bin/wdoc"
    ln -s welldoctor   "${pkgdir}/usr/bin/wdoctor"
    install -m644 \
        lang.sh \
        box.sh \
        cli.sh \
        bootstrap.sh \
        jedec.sh \
        parse.sh \
        distro_art.sh \
        wfetch_art.py \
        logo.png \
        VERSION \
        "${pkgdir}/usr/share/wellutils/"
    install -m644 \
        wellper.1 \
        wellutils.1 \
        wellfetch.1 \
        wellhw.1 \
        wellmem.1 \
        wellusb.1 \
        wellblock.1 \
        wellpci.1 \
        wellcpu.1 \
        wellgpu.1 \
        wellmod.1 \
        wellsensors.1 \
        wellup.1 \
        wellnet.1 \
        wellpower.1 \
        welldoctor.1 \
        whtml.1 \
        "${pkgdir}/usr/share/man/man1/"
    install -m644 \
        wellper.bash \
        "${pkgdir}/usr/share/bash-completion/completions/wellper"
    install -m644 \
        wellutils.bash \
        "${pkgdir}/usr/share/bash-completion/completions/wellutils"
    install -m644 \
        wellhw.bash \
        "${pkgdir}/usr/share/bash-completion/completions/wellhw"
    install -m644 \
        wellmem.bash \
        "${pkgdir}/usr/share/bash-completion/completions/wellmem"
    install -m644 \
        wellusb.bash \
        "${pkgdir}/usr/share/bash-completion/completions/wellusb"
    install -m644 \
        wellblock.bash \
        "${pkgdir}/usr/share/bash-completion/completions/wellblock"
    install -m644 \
        wellcpu.bash \
        "${pkgdir}/usr/share/bash-completion/completions/wellcpu"
    install -m644 \
        wellgpu.bash \
        "${pkgdir}/usr/share/bash-completion/completions/wellgpu"
    install -m644 \
        wellpci.bash \
        "${pkgdir}/usr/share/bash-completion/completions/wellpci"
    install -m644 \
        wellmod.bash \
        "${pkgdir}/usr/share/bash-completion/completions/wellmod"
    install -m644 \
        wellsensors.bash \
        "${pkgdir}/usr/share/bash-completion/completions/wellsensors"
    install -m644 \
        wellfetch.bash \
        "${pkgdir}/usr/share/bash-completion/completions/wellfetch"
    install -m644 \
        wellup.bash \
        "${pkgdir}/usr/share/bash-completion/completions/wellup"
    for _bc in wellnet wellpower welldoctor whtml; do
        install -m644 "${startdir}/src/$_bc.bash" \
            "${pkgdir}/usr/share/bash-completion/completions/$_bc"
    done
    install -d "${pkgdir}/usr/share/zsh/site-functions" \
               "${pkgdir}/usr/share/fish/vendor_completions.d"
    for _zc in "${startdir}"/src/completions/zsh/_*; do install -m644 "$_zc" "${pkgdir}/usr/share/zsh/site-functions/"; done
    for _fc in "${startdir}"/src/completions/fish/*.fish; do install -m644 "$_fc" "${pkgdir}/usr/share/fish/vendor_completions.d/"; done
    install -m644 \
        LICENSE \
        "${pkgdir}/usr/share/licenses/wellutils/LICENSE"
}
