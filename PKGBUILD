# Maintainer: wellbou_ <wellbou@localhost>
# PKGBUILD for the wellutils suite of system/peripheral reporting tools.
#
# Builds from the tagged GitHub tarball, never from ./src of the checkout.
# makepkg puts $srcdir at $BUILDDIR/src, and BUILDDIR defaults to the PKGBUILD
# directory -- i.e. this repo, whose sources live in ./src. `makepkg -c/-C`
# would then `rm -rf` the real sources. makepkg derives $srcdir only after
# sourcing this file, so redirect the build dir when it is the repo itself.
# To build the working tree instead: git tag the commit, or run ./install.sh.
if [[ -z "${BUILDDIR:-}" || "${BUILDDIR:-}" -ef "${startdir:-$PWD}" ]]; then
    BUILDDIR="${startdir:-$PWD}/.makepkg"
fi

pkgname=wellutils
_tag=1.4.0-55
pkgver=${_tag//-/.}
pkgrel=1
pkgdesc="Colourful system and peripheral reporting tools (wellper, wellhw, wellmem, wellusb, wellpci, wellblock, wellcpu, wellgpu, wellmod, wellsensors, wellfetch, wellup, wellnet, wellpower, welldoctor, whtml)"
url="https://github.com/Wellbou/wellutils"
arch=('any')
license=('MIT' 'GPL-2.0-only')
depends=('bash' 'coreutils' 'procps-ng' 'util-linux')
optdepends=(
    'python: whtml HTML report and the PNG logo of wellfetch'
    'hwdata: PCI/USB ID database (wellusb, wellpci, wellper)'
    'pciutils: PCI descriptions and listing (wellpci, wellhw, wellgpu)'
    'lm_sensors: extra sensor readings (wellsensors)'
    'smartmontools: disk temperature (wellsensors) and S.M.A.R.T. health (wellblock, welldoctor)'
    'nvme-cli: NVMe temperature monitoring (wellsensors)'
    'dmidecode: detailed memory and board info (wellhw)'
    'i2c-tools: decode-dimms SPD fallback for RAM detail (wellhw)'
    'iproute2: interfaces, routes and listening ports (wellnet)'
    'iw: Wi-Fi SSID and signal info (wellnet)'
)
options=('!debug' '!strip')
source=("$pkgname-$_tag.tar.gz::https://github.com/Wellbou/wellutils/archive/refs/tags/v${_tag}.tar.gz")
# Fill in with `updpkgsums` once the v${_tag} tag is published.
sha256sums=('SKIP')

package() {
    cd "$srcdir/$pkgname-$_tag/src"
    local f name

    install -d "$pkgdir/usr/bin" "$pkgdir/usr/share/wellutils" \
        "$pkgdir/usr/share/man/man1" \
        "$pkgdir/usr/share/bash-completion/completions" \
        "$pkgdir/usr/share/zsh/site-functions" \
        "$pkgdir/usr/share/fish/vendor_completions.d" \
        "$pkgdir/usr/share/licenses/$pkgname"

    # executables: every extension-less script with a shebang
    for f in *; do
        [[ -f "$f" && "$f" != *.* ]] || continue
        head -c2 "$f" | grep -q '^#!' || continue
        install -m755 "$f" "$pkgdir/usr/bin/$f"
    done

    # shared libraries and data
    install -m644 ./*.sh wfetch_art.py logo.png VERSION "$pkgdir/usr/share/wellutils/"

    install -m644 ./*.1 "$pkgdir/usr/share/man/man1/"

    for f in ./*.bash; do
        name="${f##*/}"
        install -m644 "$f" "$pkgdir/usr/share/bash-completion/completions/${name%.bash}"
    done
    install -m644 completions/zsh/_* "$pkgdir/usr/share/zsh/site-functions/"
    install -m644 completions/fish/*.fish "$pkgdir/usr/share/fish/vendor_completions.d/"

    install -m644 LICENSE "$pkgdir/usr/share/licenses/$pkgname/LICENSE"

    local a
    for a in wellutils=well wellutils=wutils wellusb=wusb wellpci=wpci \
             wellblock=wblock wellcpu=wcpu wellgpu=wgpu wellmem=wmem wellmem=wram \
             wellmem=wellram wellmod=wmod wellsensors=wsensors wellsensors=wtemp \
             wellhw=whw wellper=wper wellfetch=wfetch wellup=wup wellnet=wnet \
             wellpower=wpower wellpower=wbatt welldoctor=wdoc welldoctor=wdoctor; do
        ln -s "${a%%=*}" "$pkgdir/usr/bin/${a#*=}"
    done
}
