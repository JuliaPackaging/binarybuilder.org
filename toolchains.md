@def title = "BinaryBuilder Toolchains"
@def hasmath = false
@def hascode = false

# Toolchains

BinaryBuilder provides {{toolchain_count}} compiler versions for {{platform_count}} platforms. All of them run in the same [sandboxed Linux environment](https://docs.binarybuilder.org/stable/rootfs/), so one build recipe produces binaries for every platform.

A recipe chooses its compilers with the `compilers` keyword of `build_tarballs` and their versions with `preferred_gcc_version`, `preferred_llvm_version`, `preferred_rust_version`, `preferred_go_version` and `preferred_ocaml_version`. By default you get the oldest GCC that supports the platform, because older GCC versions produce binaries that run on more systems, and the newest LLVM, Rust, Go and OCaml. See [Building Packages](https://docs.binarybuilder.org/stable/building/) and the [build tips for each language](https://docs.binarybuilder.org/stable/build_tips/).

## Compilers

~~~
{{toolchain_table}}
~~~

## Platforms

These are the platforms returned by `supported_platforms()`, the default set that recipes build for. The table shows which GCC, Rust and OCaml versions are available for each one; the GCC versions are those usable with the default LLVM, {{default_llvm}}. LLVM/Clang and Go are not listed here because each version is a single build that targets every platform, although older releases can predate newer targets such as Apple silicon or RISC-V. See [Platforms](https://docs.binarybuilder.org/stable/building/#Platforms) in the documentation to choose which platforms a recipe builds for.

~~~
{{platform_table}}
~~~

This page is generated from [BinaryBuilderBase](https://github.com/JuliaPackaging/BinaryBuilderBase.jl) v{{bbb_version}} each time the site is built. The toolchains themselves are built by the recipes in [`Yggdrasil/0_RootFS`](https://github.com/JuliaPackaging/Yggdrasil/tree/master/0_RootFS).
