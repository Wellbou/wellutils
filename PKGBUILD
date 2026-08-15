# Maintainer: wellbou_ <wellbou@localhost>
# PKGBUILD for the wellutils suite of system/peripheral reporting tools.

pkgname=wellutils
pkgver=1.4.0
pkgrel=10
pkgdesc="Suite of colourful system and peripheral reporting tools (wellper, wellusb, wellpci, wellhw, wellmem, wellsensors, wellblock, wellcpu, wellgpu, wellmod, wellfetch, wellup)"
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
    'wellup'
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
    'wellup.1'
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
    'wellup.bash'
    'LICENSE'
)
sha256sums=('7f990e1a0ea11106e853e5ab5e555262d62a79bb5f0b9f9ee2be9b67a8976f78'
            'f8791e568ab4591cd9b49bded6782f0c2aac0993bbfa43d15540ca1d6d204ba9'
            'dd8cd38fa806d00b13e5216d999960f3267dc750f486734111e17c3558a08915'
            '9a82ced1e3b1392e8f5501b2ad75df3d2c2065529ffb7110549b1300a48a9c22'
            '01a66368b1deef8b0f8f7230313f53a02d58eb319e92406d4cd542a9ec3a5af3'
            '01ca7a424044b6392e609281f8eaa609736ad8ea845321de722212ad2b0bc269'
            '6fd22935540fa9e8e977297157bcda899d5583a40c1de6d19de9688f804f7b48'
            '1dc75596678dded5624113d8a572b46a1b12b2144625bb6d2084ef07a79a4791'
            '3297ac9c1b91770561e8e046cecb160cb1f78ff12929c92e08980947ba422340'
            '0dd457d02be8c3475ee8d7188a7e4997df4a984101a937793f850354d9f49492'
            'ca127cf49eb860b3feadaa28577055f19780d6e5bebfd23f50192439510062ca'
            'a55c8c60be3f7151071f166c897d39f220d4d0876f93d5805974465710c36823'
            '1cc0914fc02860048738d644ea026933e1423422235124828961c0dc2da9ecd5'
            'b69553f03508769cec75f4468ab6951df86bb3da4cd07c13febef22959fd2c0d'
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
            'f8477c0e1a173a342e478e16acfe3fab0763dad675dbc9ddcf9a30b98f553e33'
            '9b11f0c1ef936144bb6e98799dc65f04b9d7e1ed0c5c051275a5cf822e28d7bc'
            '4ca34440a3b3dfc793c95365c4146003f7ef7999ff793f353cb97d6630bfc69d'
            'b13837121b33361384d513383bc7db251de2850dc0ce870e8c4fec0656fd58e8'
            '569d43611edc057916cc5b40a6be15dfdd734c3a4ace1c09c090063a50c57875'
            '91e95e8dd7018494fb3fdd41a8e50da074d5ddff29bd391abea0dc26305d2022'
            '746d98adcb2a9310181133b77949b2aba6ec17e90ddb13a17c539488b351bbb9'
            '33529c31b6efcad7a7e1af1248d70700d652759b8b54c6ed3e8f7eaca10e9c28'
            '245848d45d95e52cf01ace2a0d0476de63113fd5c76e6241bbd262ba570e5c42'
            '746d38c18e8b1a9f406ee89a3c5d62809c681e1273ee908d17952377a308ea2e'
            '798b5b272270d4f81525da77d361780898404487a28cdd74d204518000907011'
            '3393fca3d9e8780042c6e6fd6990a147f25d23d52243441a90b43fe88a7e7162'
            '3a1fe25939dfeee0417b75b3d83daf9d7004ac534a5a68185372b9ebe57e9682'
            '618359c0b7abcb0c492902beded2c9955954e385e58ad5180801cad23cbff0cf'
            '6cc07239afd5782309ff4a4992a1bfbc90146fdcd56ea0d317ce842dd6e6737f'
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
        wellup \
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
    ln -s wellup       "${pkgdir}/usr/bin/wup"
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
        wellup.1 \
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
    install -m644 \
        LICENSE \
        "${pkgdir}/usr/share/licenses/wellutils/LICENSE"
}
