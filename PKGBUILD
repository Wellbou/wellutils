# Maintainer: wellbou_ <wellbou@localhost>
# PKGBUILD for the wellutils suite of system/peripheral reporting tools.

pkgname=wellutils
pkgver=1.4.0
pkgrel=21
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
    'VERSION'
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
sha256sums=('29eaca19ad30d0ca5e4d2f5daeb59fbdaf95cd811da430083148416f443e4b66'
            '3729c4c8a3cff79f1e401c05e1a7d925c248ff08798c1c4974f8715daec949c9'
            'd5ee529942782a03aa005dc3692045a5b1e6a433adb0ae8364a8c1f5dde9ed61'
            '36bec982a13fd742d7539abde4c27ed6e9cedb4f7e372338d70007e12e626208'
            '1e0143207c41121bc754d98324e001f66c0525c19ed5782f0b756902f03e1c72'
            '3154342e4817bfe520f8e3dfdac1836fe6549f5df278323cea7cef2c6992445e'
            '492981c16658908e0af10509ec99da30c98ef3022452e126f85430be25c98c1b'
            'ce96efaa0e895ed8c5cea79fd3d33d897d3522baab9830416d3a6ceec1918178'
            '97881bd59e363fb16ece4e9d26030ea2cd4da83bbcba7ab0781bd72eb3e69b39'
            'ceafd4176840e17b2e950a728b37617ca718ba6518b4b9e3d9ab0ff952b450c6'
            '7ad05307b38b5beccd3fc1ca90da31944124dcd0d0306b5eaaf0d2c877cfefc2'
            '7121c3943172e0c9f133d806a03e914ad1264d9208c5335ee393eaa2df65d6aa'
            'bdec4c02744972c8a2dda7375a69e94e81380e65e843391a624ee0d56cb98473'
            'f3a33c8a07eecad11193412e3a126af54e57f1f0cf85a6ccf1b4e9be48b45ebc'
            'b802e08e46831e9d243ec224b7f77faf752d0b695769bbb4ab288ec17e4da601'
            '022aba70374558791b86c7b7be86500c41f0e0df08495a029094170f22f5bc21'
            'd4d5cc0a866b6e733bd94bad0bef09206a11c00a30d8c14b8de7ce87a9375632'
            '408bca678af56ddb9f56aed9c9cb213f82608a781c27eb5adb91aca7cb731c35'
            'ace6f6475da188dd03a997e78e1728a1262da84e3d57d917193822d6db8650e4'
            '198da766cc327958ac59d9ed46883c80ecb066186d4a9e22851b8dc60d719502'
            '257e2402b4c68c31f18512845f8e030beaf715e1047d2477fc0abe241e5a605b'
            'f82235c4333a2a881b8151ef82180f2c8ba6001cbdcfd7bd812fa28db1df878e'
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
            '689d672bd03f8e9ee3d3684903dbf9f1ace6e1207db01e297894964a7e6228b0'
            '4ca34440a3b3dfc793c95365c4146003f7ef7999ff793f353cb97d6630bfc69d'
            'b13837121b33361384d513383bc7db251de2850dc0ce870e8c4fec0656fd58e8'
            '569d43611edc057916cc5b40a6be15dfdd734c3a4ace1c09c090063a50c57875'
            '91e95e8dd7018494fb3fdd41a8e50da074d5ddff29bd391abea0dc26305d2022'
            '746d98adcb2a9310181133b77949b2aba6ec17e90ddb13a17c539488b351bbb9'
            '33529c31b6efcad7a7e1af1248d70700d652759b8b54c6ed3e8f7eaca10e9c28'
            '87b8c600e61bfb12f293ea20b84a2cf747d78b716409a23b4099cec475100c38'
            '746d38c18e8b1a9f406ee89a3c5d62809c681e1273ee908d17952377a308ea2e'
            '798b5b272270d4f81525da77d361780898404487a28cdd74d204518000907011'
            '3393fca3d9e8780042c6e6fd6990a147f25d23d52243441a90b43fe88a7e7162'
            '3a1fe25939dfeee0417b75b3d83daf9d7004ac534a5a68185372b9ebe57e9682'
            '5432cbfe44efd22bcc16a6979c8b7c189de2c55fe8f044e132c1d33e770ee30b'
            'dc4197f41197b1dfc16ab51d92ba23a3187c7af2b275d91e326af3f6d5e9a07f'
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
