################################################################################
## This script installs manga_ocr on termux
## It can be accessed via: https://tmx.6a67.de/mocri
##
## manga_ocr works on ARM64 devices, but has some dependencies that have to be
## installed manually or built from source.
## This script builds and installs `mecab` and `safetensors_rust` from source,
## `numpy` and `tokenizers` from the tur-repo, `pytorch` from the x-11 repo
## and `meacab-python3` and `maturin` from binary wheels provided for
## manylinux2014_aarch64.
##
## IMPORTANT: Before running the script, run `termux-chage-repo` at least once
## and make sure to have at least ~4.5GB of space available on the device.
## The script builds multiple dependencies from source and therefore might
## take a while to complete (on my device it took a bit over 10min).
################################################################################


# Update and upgrade the system
yes "" | pkg up
# x-11 repo is needed for python-torch (the version in the main repo does not work)
# tur-repo is needed numpy and tokenizers
yes "" | pkg install x11-repo tur-repo
yes "" | pkg install python python-pip git python-numpy ninja python-torch python-tokenizers
# rust is needed for safetensors
yes "" | pkg install rust binutils
# They are probably not neded, but just for good measure
yes "" | pkg install build-essential autoconf automake libtool

# Temporary directory for building
TMP_DIR=$(mktemp -d)
cd $TMP_DIR

################################################################################
## Installing mecab-python3 and maturin
################################################################################

# manga_ocr requires mecab-python3 and maturin that have binary arm64 wheels
# but only for 'manylinux', which pip won't install on termux
# by default, but still works if installed manually.
# This is not really a proper solution to the problem

pip download --platform=manylinux2014_aarch64 --only-binary=:all: mecab-python3 maturin

# Rename the wheels to linux_aarch64
for file in *manylinux2014_aarch*; do
    mv "$file" "$(echo "$file" | sed 's/manylinux2014_aarch/linux_aarch/')"
done

# Install the wheels
pip install *.whl


################################################################################
## Building and installing safetensors
## See https://docs.rs/safetensors/latest/safetensors/
################################################################################

git clone https://github.com/huggingface/safetensors
cd safetensors
cd safetensors/bindings/python
pip install setuptools_rust
pip install -e .

################################################################################
## Building and installing mecab
## See https://github.com/Homebrew/homebrew-core/blob/master/Formula/m/mecab.rb
################################################################################

curl https://deb.debian.org/debian/pool/main/m/mecab/mecab_0.996.orig.tar.gz -o mecab_0.996.orig.tar.gz
tar -xvf mecab_0.996.orig.tar.gz
cd mecab-0.996

# Updating the configure script
# Should probably use stable versions of these scripts
curl "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.guess;hb=HEAD" -o config.guess
curl "http://git.savannah.gnu.org/gitweb/?p=config.git;a=blob_plain;f=config.sub;hb=HEAD" -o config.sub

# Fixing compilation errors
# This is just a quick find-and-replace-all, not a proper fix
find . -type f -exec sed -i 's/register //g' {} +
find . -type f -exec sed -i 's/binary_function/__binary_function/g' {} +


# Configure

# Fixing the configure script
# See https://muc.lists.freebsd.ports.narkive.com/yIuMIajZ/undefined-symbol-aarch64-ldadd8-acq-rel-since-llvm12-mongodb44
# This is a quick fix and for this to work, the files have to look exactly as expected
sed -i '/CFLAGS="[^"]*"/s/"$/ -mno-outline-atomics"/' configure
sed -i '/CXXFLAGS="[^"]*"/s/"$/ -mno-outline-atomics"/' configure
sed -i '/CFLAGS="[^"]*"/s/"$/ -mno-outline-atomics"/' configure.in
sed -i '/CXXFLAGS="[^"]*"/s/"$/ -mno-outline-atomics"/' configure.in

# See https://old.reddit.com/r/termux/comments/1b4wlcu/libiconv_prevents_me_from_building_the_dillo_web/kt4j1cs/
LDFLAGS=-liconv ./configure --disable-dependency-tracking --prefix=$PREFIX --sysconfdir=$PREFIX/etc

# Compile and install
make
make install

################################################################################
## Installing manga_ocr
################################################################################

pip install manga_ocr

################################################################################
## Cleaning up
################################################################################
rm -rf $TMP_DIR

echo "Installation complete"
echo "You can now run 'manga_ocr'"
