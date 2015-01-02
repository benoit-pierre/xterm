#! /bin/bash

set -x

[ -r "$HOME/.makepkg.conf" ] && . "$HOME/.makepkg.conf"

cd "$(dirname "$0")" &&
. ./PKGBUILD &&
pkgver="$(git describe --tags | sed -n '/^xterm-\([0-9]\+\)-\([0-9]\+\)-\([0-9a-z]\+\)$/{s//\1.\2.\3/;p;Q0};Q1')" &&
src="src/$pkgname-$pkgver" &&
rm -rf src pkg &&
mkdir -p "$src" &&
cp LICENSE src/ &&
sed "s/^pkgver=.*\$/pkgver=$pkgver/" PKGBUILD >PKGBUILD.tmp &&
(cd "$OLDPWD" && git ls-files -z | xargs -0 cp -a --no-dereference --parents --target-directory="$OLDPWD/$src") &&
export PACKAGER="${PACKAGER:-`git config user.name` <`git config user.email`>}" &&
makepkg --noextract --force -p PKGBUILD.tmp &&
rm -rf src pkg PKGBUILD.tmp &&
sudo pacman -U --noconfirm "$pkgname-$pkgver-$pkgrel-`uname -m`${PKGEXT:-.pkg.tar.xz}"

