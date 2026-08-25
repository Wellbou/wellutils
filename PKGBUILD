# Maintainer: wellbou_ <wellbou@localhost>
# PKGBUILD for the wellutils suite of system/peripheral reporting tools.

pkgname=wellutils
pkgver=1.4.0
pkgrel=39
pkgdesc="Suite of colourful system and peripheral reporting tools (wellper, wellusb, wellpci, wellhw, wellmem, wellsensors, wellblock, wellcpu, wellgpu, wellmod, wellfetch, wellup)"
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
    'wellnet'
    'wellpower'
    'welldoctor'
    'lang.sh'
    'box.sh'
    'cli.sh'
    'bootstrap.sh'
    'jedec.sh'
    'distro_art.sh'
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
    'wellnet.1'
    'wellpower.1'
    'welldoctor.1'
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
    'wellnet.bash'
    'wellpower.bash'
    'welldoctor.bash'
    'LICENSE'
)
sha256sums=('09af0acb00048d36c53a6a970fd257b52a5aedf4f900be32a970191b6fdf554e'
            '5ca150ac06dd89f04074541e526efd74804b5a71b9ea9f41effb301e3222e1fe'
            '1f68c19b6bdcb29285207c2cac169328ba7467b3dd2ac309955cbda12b0262d4'
            '6726fe109010b9a15aae94b27a9a0721fdf58690c3aeabf3aef31200c25b742b'
            '5de825953f6529808af488724aab18f2a3befbc019e467fee1ed45ec0d802aba'
            '5b439e8a05efa0467ff93743b942c9e38e015e614431a4770a4e06d363b95db0'
            '9bdc9f13da9787cee00ec89b641b1355fe9ccb13fa6a9efb407a8a60aab334a1'
            '5322a61960cfe371fbeec5ba779ddda85f802e991308dfd362be5b589b621885'
            '1839bab6e5546ca21e101f02097e5510e9bb8e3880fa49f44f8d7a34f503d135'
            '7fe5b66c37986b3c59e5efa231a37b68a6a9d8892bca5ba6fd9e7edbfed51fc1'
            '80382340cdb495d235f07968c7e6b3684b47817a25783be7089c5ef5c0a4ffc3'
            'b83ce0b1945fc324c7b4c26c9f48380b040681c40b234725a88e65d68fb020c5'
            '48d1ca902c51c489571fa8c83877f14b34455e1a8505c49ec33fb2e5b34778f8'
            '99a170d3613b858396e8c3e4384e35e792090789c9c180a85dc74d58ee02cdbf'
            '1e60c81c08ec6c3964e02796b9035f3adc6f988ce62260fd0658cf824f49a6de'
            'bc8dfdb399ddee8601d838b6bfe679393e37f9a8655984c80bddf9874f343fe7'
            'd611a822862af35da19dc21c45592bffa9c372559814d498770037b0e5308035'
            'a5cf0f7cb24ed1492db04818fb91e42cc2f168d18fc506f3eaa7f048fcc28fe1'
            '13eeb961d8f469e78bbe3412f948faf8a2e27c60c2b19c213c8a086495cdf2e9'
            '4dbe77cd7af164d5628fddd03197328f503ece8e9f10f92e167df6ff49ab5f75'
            'd4d5cc0a866b6e733bd94bad0bef09206a11c00a30d8c14b8de7ce87a9375632'
            '89eab1f9c247469d3194864e2eb90b28c6969714f8588e6a1c251b365ecfc0e8'
            '4cb6e71ce5e063efceb3a5ff8c41dd35768804628a7a044c46580207f5cdd1bb'
            'ace6f6475da188dd03a997e78e1728a1262da84e3d57d917193822d6db8650e4'
            '609a18b03b0830c31c4f2e9b3faa0b1434cda6ce83935a9413f814427da38166'
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
            'af28cb8f0f4e150bac69d3acdb7ac49cff80771b80f55a093143db5480e00ac6'
            'f02817f6dfc2a4fff06e60d889a852890062b90a74a5a107abc293c45d048efb'
            '36bf4d6cc3b3a9529d457bf0ad37525349b768a9ee967830443cde67fdb182c2'
            '70788a2cb82cb06c8e486db22477f898722b71f04b85cc43bb7364569c8b6a5b'
            '92a5a7028f16e14cfef073d1e9c9a51288dccd75866ad812dfe62f9f3d3352ba'
            '580c8dc6b421c0155495140949789ad7c75e81386cde0fe24bb119caabcb84f1'
            '78b26b9f2a536ba47bda892cf4a275752afdf3ad52d9c80a57278e02b93a5825'
            '7ab23851e1efccd611863bceb2d72c949332eadab5ccfbca1bbbd5608cee34d1'
            '9894753603b9e7b281765d884da93cb88b444360d86ff75795a8e19ad92b6234'
            '7ad9765b0ed85cc1bf3f9b3f03fc923916dfb98073c941ab0177825a658bf553'
            '9f3a8fb6a4a3b13c22bbec320ec071e1d7f7c4f29fa62192690cd92a001715c8'
            '92c157099a704716146682c50d454d8a9bddc2d807ca5fd9c0e7cc389c6a1b2c'
            '018a0990743e0711adc4cf82849e2fe7d92baf5f6204ac1b456a14633482af4e'
            '3ceb68d2790c4fa70e07fd86c1fe69b99c2dae238a3a94b38c6f63f9ec0dc4e4'
            '0cff155695e7c4aa467e7dfdd701e91931260dc43cd238d11be25577edb22719'
            '2d853f85ccb49948ba586aa306800b9def4780379b9b897b96a08693fa09eb40'
            'eba459a638ab9fa6216d39c26a51e1a6580a833e6577da014b4a9b787bd41119'
            '74541555b9a5dcd0470218dca3feda8ccbdc7c51a76e1ddbb3bc4ac1f0397806'
            'e1352fa132b1781ae67453796fe40577e149bd6a23884444e398d6ed3b28eac7'
            '258886d8c95f19c5aa462cc93b5d5b7b4884db692bb752262c671220f4261456'
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
        wellnet \
        wellpower \
        welldoctor \
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
    for _bc in wellnet wellpower welldoctor; do
        install -m644 "${startdir}/$_bc.bash" \
            "${pkgdir}/usr/share/bash-completion/completions/$_bc"
    done
    install -d "${pkgdir}/usr/share/zsh/site-functions" \
               "${pkgdir}/usr/share/fish/vendor_completions.d"
    for _zc in "${startdir}"/completions/zsh/_*; do install -m644 "$_zc" "${pkgdir}/usr/share/zsh/site-functions/"; done
    for _fc in "${startdir}"/completions/fish/*.fish; do install -m644 "$_fc" "${pkgdir}/usr/share/fish/vendor_completions.d/"; done
    install -m644 \
        LICENSE \
        "${pkgdir}/usr/share/licenses/wellutils/LICENSE"
}
