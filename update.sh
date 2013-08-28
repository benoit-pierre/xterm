#! /bin/zsh

err()
{
  echo 1>&2 "$@"
}

if ! git is-tree-clean
then
  err "tree is not clean!"
  exit 1
fi

rm -rf archlinux/{pkg/,src/,xterm-*.pkg.tar.xz}

orig_branch="`git rev-parse --abbrev-ref HEAD`" &&
git checkout master &&

version="`git describe --tags --exact-match | cut -d- -f2; exit $pipestatus[1]`" &&
while true
do
  version="$(($version+1))" &&
  tagname="xterm-$version" &&
  archive="$tagname.tgz" &&
  wget -P .. -c "ftp://invisible-island.net/xterm/$archive" || break
  git tar-import "../$archive" &&
  {
    sed -n "/<a name=\"xterm_$version\"/{p;n;:_loop;n;/<a name/q;p;b_loop;}" xterm.log.html | elinks -dump -no-references -force-html;
    echo
    git --no-pager diff --staged
  } | less - +'set ft=diff' &&
  git commit -m "Update: $tagname." &&
  git tag "$tagname" &&
  rm "../$archive" &&
done &&

git checkout "$orig_branch" &&
git merge master

# vim: sw=2
