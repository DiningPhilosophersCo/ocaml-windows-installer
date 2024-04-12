#! /bin/bash

# Build OCaml compiler
git clone https://github.com/ocaml/ocaml --recurse-submodules
cd ocaml || exit 1
mkdir _ocaml-prefix
export PATH="/usr/bin:$PATH"
eval "$(tools/msvs-promote-path)"
export OCAML_PREFIX=$PWD/_ocaml-prefix
./configure --build=x86_64-pc-cygwin --host=x86_64-pc-windows --prefix="$OCAML_PREFIX"
make -j8 world.opt
make install

cd ..

# Build Dune
git clone https://github.com/ocaml/dune
export PATH=$OCAML_PREFIX/bin:$PATH
cd dune || exit 1
ocaml ./boot/bootstrap.ml
./_boot/dune.exe build dune.install --release --profile dune-bootstrap -j8
