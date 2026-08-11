# Maintainer: wellbou_ <wellbou@localhost>
# PKGBUILD for the wellutils suite of system/peripheral reporting tools.

pkgname=wellutils
pkgver=1.4.0
pkgrel=9
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
sha256sums=('d3b1bbe9e56af9057be71292b1fe091cb1da0fe602c01b4714426a7a7c2549d6'
            '764ae4c910eea8f5d38c006e9c46bf0f6d65fa144af5d09884cdcef29b0a349b'
            '1e2b0a4ca3974398841f5408c9de67c274a0956406d8a4aca3d58ce230a1806c'
            'c38051b36cdc0b84c4ad31d20b01fbe61a70bb34aafa8ac81e7026584b54ef48'
            'a461a1632861469ca05d66cb37e555631554d25b8006cd29176c9d320bd62261'
            '9818d0c304c11d810118735879f111282ae85093134d31900aecdd1cdead8267'
            '92d2ae8decb69b26a32491267a375751c23b520f2f25900f5a64033cf3f3ddc6'
            '494177e394f3f8ca047262db5991229feee5d7266b25028b9428098520c72171'
            '8c54ed04f0ef929e312d0a775b592cb3cf580fb955b703ad4e1332294474e58d'
            'e1041a6900484844dcd27522d20706c9e39777fdd75616cfccbdd9d658106b91'
            'b4841081df4201195e4497810dac3ee0f5dd1679c5970ae2415b155da3b5540b'
            '8bef429525f709b8604dab8aeab05dc65f6c4e91e418d088dd73d80f1221c9d1'
            'fa98859e9b791e0b0acc2a6930e6ba6af1c293264a48b9d9f038a3cee883d192'
            '5f96872a83f8da1023dd968699a55ab86ef9ed7dbafb91125f968a0d459e1254'
            '68f1558f8c9b95c09f56eebb57a62dd4f0f604ee5171422831a9250a8bc1b6d1'
            '96bb91c3d311fa84534022784ce080dd1a1e5c7e28c6504227c0b9201e14562e'
            '408bca678af56ddb9f56aed9c9cb213f82608a781c27eb5adb91aca7cb731c35'
            'ace6f6475da188dd03a997e78e1728a1262da84e3d57d917193822d6db8650e4'
            '257e2402b4c68c31f18512845f8e030beaf715e1047d2477fc0abe241e5a605b'
            'e346333f6c481e084b5abc87848eb2e5b1eef1f89317b2599b9055df681f2f50'
            '22726538a1aff9e16c89e397d7f3d2d1c01de4c0f189d7ad78286d2720e46d5c'
            '8045690348b25f1e82a9c54e7a07ff4547fb59f46ba545ab7e5b48fc545985a6'
            'cbe9d8815ef5d017a594a334bd1a617453ceda2ce39ce72d0b6666eee54441b5'
            '4d2a425a15ea5af3040e6bd8419aa972b1475f6ce9f56b71418683fe99a30a9d'
            '67f5d4772d225f2e6421dd4518551dc35fef267b66c5f7aa4e6da9ab7c9aa6a9'
            'a85b832ba5b4421d1ad75dde6b3385fa608ef539afd7f34341c6a3f270efd03c'
            '80e5d27f83e5e9459ce2f4a0afbf328f10e5e2d67743be7b3292a22a0c959bc3'
            '0dc8a89375fae2e1b498c918c69845c9e411d1dfc13959a23755c185ed7f42b1'
            '2611aa9507fb9219f543c23b6ba9cff8d970caedf1c4c87ff32a62086a9f63cc'
            'cd5de21999bbb1d137554d6f2bd081bf2282d922d3d5c663ee78f430f1e5f938'
            '4ca34440a3b3dfc793c95365c4146003f7ef7999ff793f353cb97d6630bfc69d'
            'b13837121b33361384d513383bc7db251de2850dc0ce870e8c4fec0656fd58e8'
            '569d43611edc057916cc5b40a6be15dfdd734c3a4ace1c09c090063a50c57875'
            '91e95e8dd7018494fb3fdd41a8e50da074d5ddff29bd391abea0dc26305d2022'
            '746d98adcb2a9310181133b77949b2aba6ec17e90ddb13a17c539488b351bbb9'
            '33529c31b6efcad7a7e1af1248d70700d652759b8b54c6ed3e8f7eaca10e9c28'
            '245848d45d95e52cf01ace2a0d0476de63113fd5c76e6241bbd262ba570e5c42'
            '746d38c18e8b1a9f406ee89a3c5d62809c681e1273ee908d17952377a308ea2e'
            '8801369c1b8e6c7794432565d25e9708a3453eca4e3287dc33a3936181b8b1e2'
            '3393fca3d9e8780042c6e6fd6990a147f25d23d52243441a90b43fe88a7e7162'
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
