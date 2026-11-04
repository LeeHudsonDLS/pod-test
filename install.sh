#!/bin/bash
# Install pod-test.
#
#   ./install.sh            into ~/bin
#   ./install.sh DIR        into DIR
#
# Replaces any previous install, stamping the Git tag or commit into the
# installed copy so `pod-test --version` says what was installed. Run it again
# after pulling or editing pod-test.
set -euo pipefail

here=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
dest=${1:-$HOME/bin}

version=$(git -C "$here" describe --tags --always --dirty 2>/dev/null || echo unknown)

# The old install goes first, so a failed install cannot leave it looking current.
rm -f "$dest/pod-test"
mkdir -p "$dest"
sed "s|^version=unknown\$|version=${version}|" "$here/pod-test" > "$dest/pod-test.tmp"
chmod 755 "$dest/pod-test.tmp"
mv "$dest/pod-test.tmp" "$dest/pod-test"
echo "installed $("$dest/pod-test" --version) to $dest/pod-test"

# Compare against PATH as given; a ~/bin that is on it under another spelling
# (a symlinked home, say) gets a needless warning, which is harmless.
case ":$PATH:" in
    *":$dest:"*) ;;
    *) echo "warning: $dest is not on your PATH" >&2 ;;
esac
