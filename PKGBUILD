# Maintainer: wellbou_ <wellbou@localhost>
# PKGBUILD for the wellutils suite of system/peripheral reporting tools.

pkgname=wellutils
pkgver=1.3.0
pkgrel=1
pkgdesc="Suite of colourful system and peripheral reporting tools (wellper, wellusb, wellpci, wellhw, wellmem, wellsensors, wellblock, wellmod, wellfetch)"
arch=('any')
license=('MIT')
depends=('bash' 'python' 'coreutils' 'procps-ng' 'hwdata')
optdepends=(
    'pciutils: PCI descriptions and listing (wellpci, wellhw)'
    'usbutils: USB device enumeration (wellusb)'
    'smartmontools: disk temperature monitoring (wellsensors)'
    'nvme-cli: NVMe temperature monitoring (wellsensors, wellblock)'
    'dmidecode: detailed memory info (wellhw)'
    'lm_sensors: temperature monitor (wellutils sensors)'
)
options=('!emptydirs')
source=(
    'wellper'
    'wellhw'
    'wellmem'
    'wellsensors'
    'wellusb'
    'wellpci'
    'wellblock'
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
    'wellmod.1'
    'wellsensors.1'
    'wellhw.bash'
    'wellmem.bash'
    'wellusb.bash'
    'wellblock.bash'
    'wellpci.bash'
    'wellmod.bash'
    'wellsensors.bash'
    'wellfetch.bash'
    'wellper.bash'
    'wellutils.bash'
    'LICENSE'
)
sha256sums=(    'de3b816de88312d86bd00f80e5b0edac3f3c4fc6bc2de2287fb6c76e468fa762'
    'bc078fcefa3aead96fc73fd18a63152d4fe383f93aa9629aa6547b53deeb5cbd'
    '0ac249c46d4bfeff95085abf92f443500ab84c252d978d82ee1ad5599704c93c'
    '7b391b150a16abd6599f8d3834f118c479482458c5d251b62d8338076baf55bb'
    '9ce3ee8c493bdba2ebe0b224da30cb346edc8a86e2db31a435591173ed99684e'
    'a65e84f48772596b99c8f3cb05e2f02d5744749c079ef6beeb87e1d257cc523d'
    '84b9103f0b9125178ba351729c97ecde37bb4ee15aba1a34c3d0fca5a576e35e'
    'f612c75bc485902067d7b47e9690cb1d1832562a170fff74a7802155c5eba524'
    'dfbda5d8633e345622cb7110b33962952fabedd62fb48f0236ff4d4c9be36894'
    'c16e0032e4aec21c09a712bd2dd212738ecbd7e99ea55874c93826bb804b6e73'
    '19355a153ad2bab231dda4e87f4903bfcd2b8fd73970e719b1579f369283ce7e'
    '8e21a1f517077ba7a1e687c743bf0f1801b8796118c6e2df0615ef7365740183'
    '97fe4c1cb9318628d4961e8f87031518cf76a3ff6ce3eeeff0dd86c7d2b07df6'
    '96bb91c3d311fa84534022784ce080dd1a1e5c7e28c6504227c0b9201e14562e'
    'e9cb3f5cf4720b556c724076631d565f328d8191f3c038db9cbcb1b0d444b515'
    'ace6f6475da188dd03a997e78e1728a1262da84e3d57d917193822d6db8650e4'
    '257e2402b4c68c31f18512845f8e030beaf715e1047d2477fc0abe241e5a605b'
    '91a1529b392c2f658fbebd880f395c85d76c86085357aecbb50685e2245d110f'
    'd66b40e93fde015182313cd53ae6ccf4149f7f70270cb58286479eccf08f8768'
    '7d368b936845e34ec55c0962f9fb607107912674103dca02a48971469f2011f1'
    '4ff2c133892f8246ec300a9c64c3c4982ea7f652d67ad8813dc213fcae86fdd8'
    '2100185f2889540ed4d2a493bdfafb5d0fbc6705f5c4e6538099e49914fcc6bf'
    'd49bc8bb69ecd439a7db061867d2d65162845c8390d5e9ee351350647f342abb'
    'f91dc1f470d69e0001d58e8352dbfc7f9c16c74ae56ad0dd0a2e8d6b27bfe902'
    '281f05744b419496774653924fda607943b08478d67a3ab9bb99964079cd5822'
    'fce62fbc31d268a9871aa4cc780a93c374fa25df3d427a268314ee32d6cc168c'
    'ea0b99ea63fd8c56da90fee6b2e868a219e3619ec7df6d8f4ed02626df4440de'
    'b06eaf83caa00f6ad9db76c864dc840b42f5278b7fa7795230c5e2c6fab2e0af'
    'aab92eb09c77bcb4264577924bfd085958deaf7ff000ea0f57cf95558f459bf6'
    '62f2089dd072a455c8c78fe3492be70e0e2d3ecfab617962ab8b4f2e3c30c778'
    '7c0eb0565dce2fb7adcd8e764b9bd37bac13c8034d1fdd01272de61440c4e872'
    '96e24d96006ad0b3405f01f3e5ad571039717224ab07781e2bff7a3c6f9e3fcf'
    '1882deedfe1ac5e6c85fd946b2f8bd22ba6915d0e385f966aab8e55cd9bd5ed0'
    'da959487fbfbfae6fa9d2e1609a977e7487ec813c39ae0644f790a452c1ed0df'
    '3a1fe25939dfeee0417b75b3d83daf9d7004ac534a5a68185372b9ebe57e9682'
    '618359c0b7abcb0c492902beded2c9955954e385e58ad5180801cad23cbff0cf'
    'cfc7e44e8406cf1d56916796d36832d4b8de8e1898f67be4158f0f6f0984fc70'
)
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
        wellmod \
        wellfetch \
        wellutils \
        "${pkgdir}/usr/bin/"
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
