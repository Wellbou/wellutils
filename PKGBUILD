# Maintainer: wellbou_ <wellbou@localhost>
# PKGBUILD for the wellutils suite of system/peripheral reporting tools.

pkgname=wellutils
pkgver=1.4.0
pkgrel=1
pkgdesc="Suite of colourful system and peripheral reporting tools (wellper, wellusb, wellpci, wellhw, wellmem, wellsensors, wellblock, wellcpu, wellgpu, wellmod, wellfetch)"
url="https://github.com/Wellbou/wellutils"
arch=('any')
license=('MIT')
depends=('bash' 'python' 'coreutils' 'procps-ng' 'hwdata')
optdepends=(
    'pciutils: PCI descriptions and listing (wellpci, wellhw, wellgpu)'
    'usbutils: USB device enumeration (wellusb)'
    'smartmontools: disk temperature monitoring (wellsensors) and S.M.A.R.T. health (wellblock)'
    'nvme-cli: NVMe temperature monitoring (wellsensors)'
    'dmidecode: detailed memory info (wellhw)'
    'i2c-tools: decode-dimms SPD fallback for RAM detail (wellhw)'
    'util-linux: lscpu topology info (wellcpu)'
)
source=(
    'wellper'
    'wellhw'
    'wellmem'
    'wellsensors'
    'wellusb'
    'wellpci'
    'wellblock'
    'wellcpu'
    'wellgpu'
    'wellmod'
    'wellutils'
    'wellfetch'
    'lang.sh'
    'box.sh'
    'cli.sh'
    'jedec.sh'
    'wfetch_art.py'
    'logo.png'
    'wellper.1'
    'wellutils.1'
    'wellfetch.1'
    'wellhw.1'
    'wellmem.1'
    'wellusb.1'
    'wellblock.1'
    'wellpci.1'
    'wellcpu.1'
    'wellgpu.1'
    'wellmod.1'
    'wellsensors.1'
    'wellhw.bash'
    'wellmem.bash'
    'wellusb.bash'
    'wellblock.bash'
    'wellcpu.bash'
    'wellgpu.bash'
    'wellpci.bash'
    'wellmod.bash'
    'wellsensors.bash'
    'wellfetch.bash'
    'wellper.bash'
    'wellutils.bash'
    'LICENSE'
)
sha256sums=('30f7fc7e4c0623e67cec30ef6fa31295dfb1304f40f6c49fc599cfa4cd2bab4d'
            'a73aed1a546a2b51a75e0c72a6089ffb1c78836cd6f27fcae97f2e13e06a4425'
            '6d6c56a71f6f2e3833093563bb2611741735abfda0871a96a3f73ac5d821b154'
            'e91a39ca47f26168a496e3215623a24319bc2950b1b35ead005ae9046dfff112'
            'd4c6666a05bf43dfac0251c5bbbd83006d8c1022d6b3956de3f18dc38309188e'
            '48aa5bc2a06c38de6b5e45e51a12a58dc41bfa3a9498fa3a859478a4ef8173d0'
            'ca055d13b045b10da0951d5e5739d49eb3d3b0f6803463832e5918031d68c9b6'
            '0f10842ae346cd1a07c7dfbf97bb52d4b8fba952d3f26f600237a3a123342001'
            'c42ef9d21089fe9dc78508c8b90346f7c2a5d08142998c653bbf37cdab6ac7e4'
            '76bc517a6cc2282b3d2ee3db5d27ee6833a5e038a7eea39d107b9ddcd6351b25'
            'fbc608dd26da8359c3067607bafd29754f9bd3840ebbb9cb5eb3e335eaea6c6e'
            '992be100d7f06a8af730a4f37f42a8750ee83de009cd40a13152e7a080820547'
            'adbe6f5566c186ccff46d7ce3c5e7e490589370939c034c49eb866a2136c49ff'
            '5f96872a83f8da1023dd968699a55ab86ef9ed7dbafb91125f968a0d459e1254'
            '4a424185c31cda2e2ae63c28cef637adcf9985c640c0659ae41400cceb08e38f'
            '96bb91c3d311fa84534022784ce080dd1a1e5c7e28c6504227c0b9201e14562e'
            '0494269aa998bc49758e28d2017baf2544ef39a052e4cf2e1633389fe233cb2c'
            'ace6f6475da188dd03a997e78e1728a1262da84e3d57d917193822d6db8650e4'
            '257e2402b4c68c31f18512845f8e030beaf715e1047d2477fc0abe241e5a605b'
            '91a1529b392c2f658fbebd880f395c85d76c86085357aecbb50685e2245d110f'
            'd66b40e93fde015182313cd53ae6ccf4149f7f70270cb58286479eccf08f8768'
            '7d368b936845e34ec55c0962f9fb607107912674103dca02a48971469f2011f1'
            '4ff2c133892f8246ec300a9c64c3c4982ea7f652d67ad8813dc213fcae86fdd8'
            '2100185f2889540ed4d2a493bdfafb5d0fbc6705f5c4e6538099e49914fcc6bf'
            '32f7144315656138ecf5464ff169b3cd52f5f5069628ac7c3e3f08a72e129294'
            'f91dc1f470d69e0001d58e8352dbfc7f9c16c74ae56ad0dd0a2e8d6b27bfe902'
            '0de35fc9d0b771a062411c7f507724b90bdb4a261fdb5a348b207e500fe7a689'
            '7b40dd117e69c4fa414807384cf64ba8d32c12ba2aec29d216bc53db26c53ec3'
            '281f05744b419496774653924fda607943b08478d67a3ab9bb99964079cd5822'
            'fce62fbc31d268a9871aa4cc780a93c374fa25df3d427a268314ee32d6cc168c'
            'ea0b99ea63fd8c56da90fee6b2e868a219e3619ec7df6d8f4ed02626df4440de'
            'b06eaf83caa00f6ad9db76c864dc840b42f5278b7fa7795230c5e2c6fab2e0af'
            'aab92eb09c77bcb4264577924bfd085958deaf7ff000ea0f57cf95558f459bf6'
            'd637658e8823bb5428d5ce2213d2e0baa89f9df8b289d1818d2bdc5134199c8c'
            '62e5b7f7e34b13bd8dba954d13ef0d1622c11996aa4ea6e081340690e70cde7c'
            '0dac243abc47816451304b27c7a3befd4c05f97b0c92ca2d291de77181b5ac59'
            '7c0eb0565dce2fb7adcd8e764b9bd37bac13c8034d1fdd01272de61440c4e872'
            '96e24d96006ad0b3405f01f3e5ad571039717224ab07781e2bff7a3c6f9e3fcf'
            '1882deedfe1ac5e6c85fd946b2f8bd22ba6915d0e385f966aab8e55cd9bd5ed0'
            'da959487fbfbfae6fa9d2e1609a977e7487ec813c39ae0644f790a452c1ed0df'
            '3a1fe25939dfeee0417b75b3d83daf9d7004ac534a5a68185372b9ebe57e9682'
            '618359c0b7abcb0c492902beded2c9955954e385e58ad5180801cad23cbff0cf'
            'cfc7e44e8406cf1d56916796d36832d4b8de8e1898f67be4158f0f6f0984fc70')
package() {
    cd "${srcdir}"
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
        wellutils \
        "${pkgdir}/usr/bin/"
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
    install -m644 \
        lang.sh \
        box.sh \
        cli.sh \
        jedec.sh \
        wfetch_art.py \
        logo.png \
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
        LICENSE \
        "${pkgdir}/usr/share/licenses/wellutils/LICENSE"
}
