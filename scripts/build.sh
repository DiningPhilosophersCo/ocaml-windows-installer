#! /bin/bash

build_compiler() {
    # Build OCaml compiler
    ocaml_prefix="$1"
    git clone https://github.com/ocaml/ocaml --recurse-submodules
    cd ocaml || exit 1
    mkdir _ocaml-prefix
    export PATH="/usr/bin:$PATH"
    eval "$(tools/msvs-promote-path)"
    ./configure --build=x86_64-pc-cygwin --host=x86_64-pc-windows --prefix="$ocaml_prefix"
    make -j8 world.opt
    make install
}


build_dune() {
    # Build Dune
    git clone https://github.com/ocaml/dune
    cd dune || exit 1
    env PATH="$1/bin:$PATH" ocaml ./boot/bootstrap.ml
    env PATH="$1/bin:$PATH" ./_boot/dune.exe build dune.install --release --profile dune-bootstrap -j8
}

get_ocaml_prefix() {
    desired_len=128
    desired_len=$(echo "$(($desired_len-1))")
    working_dir_len="${#1}"
    num_underscores=$(echo "$(($desired_len-$working_dir_len))")
    unders=$(printf "%-${num_underscores}s" "_")
    prefix_dir_name="_ocaml-prefix"
    prefix_dir_name_len="${#prefix_dir_name}"
    num_underscores=$(echo "$(($num_underscores-$prefix_dir_name_len))")
    prefix_path="$(printf "%-${num_underscores}s" "_")$prefix_dir_name"
    prefix_path="${prefix_path// /_}"
    echo "$1/$prefix_path"
}


ocaml_prefix=$(get_ocaml_prefix "$PWD") # "${#GITHUB_WORKSPACE}"
build_compiler "$ocaml_prefix"
cd ..
build_dune "$ocaml_prefix"
