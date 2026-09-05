# Maintainer: wellbou_ <wellbou@localhost>
# PKGBUILD for the wellutils suite of system/peripheral reporting tools.

pkgname=wellutils
pkgver=1.4.0
pkgrel=51
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
    'whtml'
    'lang.sh'
    'box.sh'
    'cli.sh'
    'bootstrap.sh'
    'jedec.sh'
    'parse.sh'
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
    'whtml.1'
    'whtml.bash'
    'LICENSE'
)
sha256sums=('ebabd2fe1fdda33cb2643f5aa9b425a9053136d6ffb26e1bf698c2396ebec84f'
            '73ebdaa38aadcddf1995f3b48995a8f494a8eb4a77c93c68c15eb6107da6b227'
            'da80c76b1548d0b3b65490cbfb74d5ff586adf2d21d7c60755d39d31e3bb636b'
            '18a8be093cd3b60376a88e1e6cc15e52bd77efb86ce4fd8871a955b631ef7593'
            '616f80e57e3a1aa1fa5cf80c61643fad10658be04bc70c15441b876f33d177e9'
            '3cd5eabbf9de30966c4e89cde83eced46f14571c59fd120eccec055fee8a375b'
            '3d2ead6d06fd85769ec0241d86da808c2d871e87a855ff7f7b813d71a3275241'
            '13c0f6c0cdc8750cd7d26ca795d384d21bc0541adfdf991561148c45c4a81ae4'
            '2a771851ddba7e46867510d3d2f50dc1bbcf50b35101d99830b9ef990cf769cd'
            'f16d64db4f7212f8f6567cb5a94bac5c5dcc05d89f37ad4c71da5c36d84a3200'
            '6105b6a3b8a3d3f3bd8511935644e2b9c853f1c1fc487cbfc31b21a9f16b2a56'
            '05d1e4bddb9b3c42b1f74a4d65aa4741420773a27a1b2a4fe55989bfa39332c2'
            '72db3299e0ee3b0bee39e3400327bdc126de89cba454e9efcfaa2ec971615538'
            'c1b21f2f71e47852f800f5bdb76ce06fe47c2b30c982559a2e41a1bed25ee756'
            '7b0ac75225fc68681b643de7fbf7e9be8d65f150c0f7933d2d26633e7454edf0'
            '7270f85b5ce19234b6525fc41dfd4b154f7a24839837d655663a3fca31bfce48'
            'ffdaa032880cb8aa83bdb8fc4715e85627319c4088338cc2b303e773face2759'
            '3c724b4d1cae3a120c279bf406ae806ee585b89022dc7f583108c41d88f827ed'
            '6fc10546d7e40402089b92e8b0750cf5a28d0c19ed12486b779f8e0c2c7bf6b7'
            '15c297c2be9369bc5693e8960206084f735f3bf1a190468e08e58670149bf0f8'
            '80eb4ab0772bf509adaec25d553f345e657465b41677d6f229d392ac6ff09997'
            'a55dc713d8ab16d46345954c785b6cbff7a1c5901b85d0f469c16a3270bc2e34'
            '3c078d810efe021194c770fe84f3d19d4f87d769d6672c3bcb178f214bd267e0'
            '89eab1f9c247469d3194864e2eb90b28c6969714f8588e6a1c251b365ecfc0e8'
            '4cb6e71ce5e063efceb3a5ff8c41dd35768804628a7a044c46580207f5cdd1bb'
            'ace6f6475da188dd03a997e78e1728a1262da84e3d57d917193822d6db8650e4'
            '9ca68e2c2b43368edf16253bc0e01221322915e1125429dd453fe38bead3ecf5'
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
            '562a8f5fbb95dcaf1cbde3f127ddd3b2dc127b4d6c880b743d49442f9da04cb8'
            'cd4c4a3dd00ed2818612c49c14bb904670d58e2f89e8f8eb2e89cf818fae62e7'
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
