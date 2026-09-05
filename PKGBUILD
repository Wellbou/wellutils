# Maintainer: wellbou_ <wellbou@localhost>
# PKGBUILD for the wellutils suite of system/peripheral reporting tools.

pkgname=wellutils
pkgver=1.4.0
pkgrel=49
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
            'b0af2c4341a3268f5569874d43097e4e86e73d4452d7b76f5b4d4cdb91d14ecd'
            '626834b82bfa46dfb32f7a3bde7ba8f957d86b9172fe1cfebc37a441722c9309'
            '80eb70b80cd12b60f566d46351a5fa0fdf04ca810c4a9c9e16c99f73ccae08b0'
            '616f80e57e3a1aa1fa5cf80c61643fad10658be04bc70c15441b876f33d177e9'
            '359da687520e34eaf4efb4af81a7cf07a5f0ce46f048fe570ae86a81e59d88ec'
            'c994e679bde58c37d2259da83045674ff663c201a77daa8cbfc6de2d27aa2588'
            '6221c0ad83933b51beac62a81f8e279a933c10dae8eb956575704c0ba58a9f60'
            '789456400d59ca03841a9c142021ca632d251970104670a4c880daee0a525756'
            '74b50131c2ccb1a7571446758e6a211083f0f727eb6677358ae252c25cae8be5'
            '6105b6a3b8a3d3f3bd8511935644e2b9c853f1c1fc487cbfc31b21a9f16b2a56'
            '50af387a5bf0386c17643fa5b3938313d89cf884b6d24cb79311062396381052'
            'f59a30136933349d8550c7f44ce2257a897db7213d35a969df18fe5bf820dd48'
            'dee23bb69a736a737c5b070dfc6d95dbea8ffcc05a9277d983e7719aab8292ba'
            'f1d4703f4ed70947aeb8a085072cb82c657ba1bc63c61c3cb2a7f81f5eb440c8'
            '95cbe242506729de38b17e781b129988adb19ad6a2bb2d84e31810fea89cbbfe'
            '3a25757f54700481f806affac725b22681b555017bf09b58224468e675a60ee9'
            '735af990ea0d17051f136de0e9d4d9da800d50ffd97f828255d216c240d6cff3'
            '6fc10546d7e40402089b92e8b0750cf5a28d0c19ed12486b779f8e0c2c7bf6b7'
            '15c297c2be9369bc5693e8960206084f735f3bf1a190468e08e58670149bf0f8'
            '80eb4ab0772bf509adaec25d553f345e657465b41677d6f229d392ac6ff09997'
            'a55dc713d8ab16d46345954c785b6cbff7a1c5901b85d0f469c16a3270bc2e34'
            '89eab1f9c247469d3194864e2eb90b28c6969714f8588e6a1c251b365ecfc0e8'
            '4cb6e71ce5e063efceb3a5ff8c41dd35768804628a7a044c46580207f5cdd1bb'
            'ace6f6475da188dd03a997e78e1728a1262da84e3d57d917193822d6db8650e4'
            'bc5c1fc5eb9aee1e7dceeb85a22aad18cb73d64c5fae747176c4c5b6efafbff9'
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
