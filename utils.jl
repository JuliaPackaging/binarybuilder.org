# Helper functions for the Franklin build of binarybuilder.org.
#
# The platform, toolchain, GPU and MPI data shown on the site is computed at build
# time, so it stays in sync with what BinaryBuilder and Yggdrasil offer instead of
# being maintained by hand.  See
# https://github.com/JuliaPackaging/binarybuilder.org/issues/2
#
# Sources:
# - BinaryBuilderBase: platforms and compiler toolchains
# - Yggdrasil's platforms/cuda.jl and platforms/mpi.jl: CUDA and MPI builds
# - The General registry: latest versions of GPU and MPI packages

using BinaryBuilderBase
using Base.BinaryPlatforms: AbstractPlatform, triplet, platforms_match, arch, os, tags
using Downloads, RegistryInstances

const BBB = BinaryBuilderBase

## HTML helpers
#
# Table cells are escaped unless wrapped in `Raw`, so text that comes from upstream
# data can't inject markup into the site.

struct Raw
    html::String
end

escape_html(x) = replace(string(x), '&' => "&amp;", '<' => "&lt;", '>' => "&gt;", '"' => "&quot;")
cell(x::Raw) = x.html
cell(x) = escape_html(x)

const CHECK = Raw("&check;")
const DASH = Raw("&mdash;")
code(s) = Raw("<code>$(escape_html(s))</code>")
link(href, text) = Raw("<a href=\"$(escape_html(href))\">$(cell(text))</a>")
jll_link(name) = link("https://github.com/JuliaBinaryWrappers/$(name).jl", code(name))

html_table(header, rows) = string(
    "<div class=\"table-scroll\"><table class=\"toolchains\">\n<thead><tr>",
    join("<th>$(cell(h))</th>" for h in header),
    "</tr></thead>\n<tbody>\n",
    join("<tr>" * join("<td>$(cell(c))</td>" for c in row) * "</tr>\n" for row in rows),
    "</tbody></table></div>\n")

# "a, b and c"
join_and(xs) = length(xs) <= 1 ? join(xs) : join(xs[1:end-1], ", ") * " and " * last(xs)

## Platforms

const PLATFORMS = supported_platforms()

# Display names, in the order they are listed on the site.
const OS_NAMES = ["linux" => "Linux", "macos" => "macOS", "windows" => "Windows",
                  "freebsd" => "FreeBSD"]
const ARCH_NAMES = ["x86_64" => "x86_64", "i686" => "i686", "armv6l" => "ARMv6",
                    "armv7l" => "ARMv7", "aarch64" => "AArch64", "powerpc64le" => "PPC64LE",
                    "riscv64" => "RISC-V"]
os_name(p) = get(Dict(OS_NAMES), os(p), os(p))

# Display names of the values `f` takes over the supported platforms, with any value
# missing from `names` listed last under its own name.
function display_names(f, names)
    present = unique(f.(PLATFORMS))
    return [[name for (key, name) in names if key in present];
            [key for key in present if !any(n -> first(n) == key, names)]]
end

"""
    {{platform_count}}

Number of platforms returned by `supported_platforms()`.
"""
hfun_platform_count() = string(length(PLATFORMS))

"""
    {{os_list}}

The operating systems of the supported platforms, e.g. "Linux, macOS, Windows and FreeBSD".
"""
hfun_os_list() = escape_html(join_and(display_names(os, OS_NAMES)))

"""
    {{cpu_list}}

The CPU architectures of the supported platforms, e.g. "x86_64, i686 and AArch64".
"""
hfun_cpu_list() = escape_html(join_and(display_names(arch, ARCH_NAMES)))

## Toolchains

all_versions(builds) = sort(unique(BBB.getversion.(builds)))

const COMPILERS = [
    (name = "GCC",        versions = all_versions(BBB.available_gcc_builds),
     note = "Cross-compiler and binutils built for each target platform."),
    (name = "LLVM/Clang", versions = all_versions(BBB.available_llvm_builds),
     note = "One build per version that targets every platform."),
    (name = "Rust",       versions = all_versions(BBB.available_rust_builds),
     note = "Standard library built for each target platform."),
    (name = "Go",         versions = all_versions(BBB.available_go_builds),
     note = "One build per version that targets every platform."),
    (name = "OCaml",      versions = all_versions(BBB.available_ocaml_builds),
     note = "Cross-compiler built for each target platform."),
]
versions_of(name) = only(c.versions for c in COMPILERS if c.name == name)

# Targets of each compiler shard, by shard name and version.  Only one archive type
# is looked at, otherwise every shard would be counted twice (squashfs and unpacked).
const SHARD_TARGETS = let targets = Dict{Tuple{String,VersionNumber},Vector{AbstractPlatform}}()
    for cs in BBB.all_compiler_shards()
        (cs.archive_type === :unpacked && cs.target !== nothing) || continue
        push!(get!(targets, (cs.name, cs.version), AbstractPlatform[]), cs.target)
    end
    targets
end
has_shard(name, version, p) =
    any(t -> platforms_match(t, p), get(SHARD_TARGETS, (name, version), AbstractPlatform[]))

# Versions of `compiler` whose `shard` exists for platform `p`.
shard_versions(shard, compiler, p) = filter(v -> has_shard(shard, v, p), versions_of(compiler))

# `choose_shards` defaults to the newest LLVM.
const DEFAULT_LLVM = BBB.getversion(last(BBB.available_llvm_builds))

# Mirror `BinaryBuilderBase.choose_shards`: a GCC build is usable for a platform if
# its shard exists for that target and `gcc_version` doesn't filter it out, given the
# default LLVM (e.g. riscv64 needs GCC 14 or later, and FreeBSD needs GCC 6 or later
# with LLVM 12 or later).
function gcc_versions(p)
    builds = filter(b -> has_shard("GCCBootstrap", BBB.getversion(b), p), BBB.available_gcc_builds)
    return sort(BBB.gcc_version(p, builds, [:c]; llvm_version=DEFAULT_LLVM))
end

# Show a long list of versions as a range when it contains every version of `all`
# between its endpoints, so that gaps (e.g. a platform missing some GCC versions)
# stay visible.  Prerelease builds such as GCC 12.0.1-iains (which exists for
# aarch64-apple-darwin only) don't count as gaps.
function format_versions(vs, all)
    isempty(vs) && return DASH
    lo, hi = first(vs), last(vs)
    between = filter(v -> lo <= v <= hi && (isempty(v.prerelease) || v in vs), all)
    if length(vs) > 3 && between == vs
        return Raw("$(escape_html(lo)) &ndash; $(escape_html(hi)) ($(length(vs)))")
    end
    return join(string.(vs), ", ")
end

"""
    {{toolchain_count}}

Number of distinct compiler versions (GCC, LLVM, Rust, Go and OCaml) available.
"""
hfun_toolchain_count() = string(sum(length(c.versions) for c in COMPILERS))

"""
    {{bbb_version}}

Version of BinaryBuilderBase the toolchain data was generated from.
"""
hfun_bbb_version() = string(pkgversion(BinaryBuilderBase))

"""
    {{default_llvm}}

The LLVM version that recipes get by default.
"""
hfun_default_llvm() = string(DEFAULT_LLVM)

"""
    {{toolchain_table}}

One row per compiler, listing every available version.
"""
hfun_toolchain_table() = html_table(
    ["Compiler", "Versions", "Count", "Notes"],
    [[c.name, join(string.(c.versions), ", "), length(c.versions), c.note] for c in COMPILERS])

"""
    {{platform_table}}

One row per supported platform, with the GCC, Rust and OCaml versions available for it.
"""
function hfun_platform_table()
    rows = map(PLATFORMS) do p
        [code(triplet(p)), os_name(p), arch(p),
         format_versions(gcc_versions(p), versions_of("GCC")),
         format_versions(shard_versions("RustToolchain", "Rust", p), versions_of("Rust")),
         format_versions(shard_versions("OCaml", "OCaml", p), versions_of("OCaml"))]
    end
    return html_table(["Platform", "OS", "Architecture", "GCC", "Rust", "OCaml"], rows)
end

## Yggdrasil's CUDA and MPI helpers
#
# CUDA and MPI builds are defined by Yggdrasil's platforms/cuda.jl and
# platforms/mpi.jl, not by BinaryBuilderBase, so they are loaded from Yggdrasil's
# master branch at build time.  Set YGGDRASIL_DIR to read them from a local checkout
# instead.  If they can't be loaded, the build fails, so the deployed site keeps its
# last good version rather than publishing wrong data.

const YGGDRASIL_PLATFORMS_URL =
    "https://raw.githubusercontent.com/JuliaPackaging/Yggdrasil/master/platforms/"

function read_yggdrasil_file(file)
    dir = get(ENV, "YGGDRASIL_DIR", "")
    isempty(dir) || return read(joinpath(dir, "platforms", file), String)
    url = YGGDRASIL_PLATFORMS_URL * file
    for attempt in 1:3
        try
            return String(take!(Downloads.download(url, IOBuffer())))
        catch err
            attempt == 3 && error("Could not download $url: $(sprint(showerror, err))")
            sleep(5 * attempt)
        end
    end
end

function load_yggdrasil_helper(file, modname)
    src = read_yggdrasil_file(file)
    # The helpers only use types that BinaryBuilder re-exports from BinaryBuilderBase,
    # so load them against BinaryBuilderBase instead of installing all of BinaryBuilder.
    pattern = r"^(\s*)(using|import) BinaryBuilder\b"m
    occursin(pattern, src) ||
        error("Yggdrasil's platforms/$file no longer loads BinaryBuilder as utils.jl expects")
    src = replace(src, pattern =>
        s"\1using BinaryBuilderBase; const BinaryBuilder = BinaryBuilderBase; \2 BinaryBuilderBase")
    m = Module()
    try
        Base.include_string(m, src, "Yggdrasil/platforms/$file")
        return Base.invokelatest(getglobal, m, modname)
    catch err
        error("Could not load Yggdrasil's platforms/$file: $(sprint(showerror, err))")
    end
end

const CUDA_HELPER = load_yggdrasil_helper("cuda.jl", :CUDA)
const MPI_HELPER = load_yggdrasil_helper("mpi.jl", :MPI)

## Registry

const GENERAL = let regs = filter(r -> r.name == "General", RegistryInstances.reachable_registries())
    isempty(regs) && error("The General registry isn't installed; add it with `Pkg.Registry.add(\"General\")`")
    first(regs)
end

# Latest registered version of a package, without its build number.
function latest_version(name)
    uuids = RegistryInstances.uuids_from_name(GENERAL, name)
    if isempty(uuids)
        @warn "$name is not registered in the General registry"
        return nothing
    end
    info = RegistryInstances.registry_info(GENERAL[first(uuids)])
    versions = [v for (v, vinfo) in info.version_info if !vinfo.yanked]
    isempty(versions) && return nothing
    v = maximum(versions)
    return VersionNumber(v.major, v.minor, v.patch, v.prerelease)
end
format_version(v) = v === nothing ? DASH : string(v)

## CUDA

cuda_series(v::VersionNumber) = "$(v.major).$(v.minor)"
const CUDA_VERSIONS = sort([CUDA_HELPER.cuda_full_versions; CUDA_HELPER.cuda_prerelease_versions])
const CUDA_ALL_PLATFORMS = CUDA_HELPER.supported_platforms(; min_version=nothing, prereleases=true)
const CUDA_DEFAULT_SERIES = Set(tags(p)["cuda"] for p in CUDA_HELPER.supported_platforms())
is_default_cuda(v) =
    !(v in CUDA_HELPER.cuda_prerelease_versions) && cuda_series(v) in CUDA_DEFAULT_SERIES

# The columns of the CUDA table that a build counts for.  Before CUDA 13, aarch64
# builds are split into ARM servers (SBSA) and Jetson by the `cuda_platform` tag;
# from CUDA 13 a single aarch64 build without that tag covers both.
const CUDA_COLUMNS = ["x86_64", "ARM servers (SBSA)", "Jetson"]
const CUDA_PLATFORM_NAMES = Dict("sbsa" => "ARM servers (SBSA)", "jetson" => "Jetson")
function cuda_columns(p)
    Sys.islinux(p) && arch(p) == "x86_64" && return ["x86_64"]
    if Sys.islinux(p) && arch(p) == "aarch64"
        cp = get(tags(p), "cuda_platform", nothing)
        return cp === nothing ? ["ARM servers (SBSA)", "Jetson"] : [get(CUDA_PLATFORM_NAMES, cp, cp)]
    end
    return ["$(os(p)) $(arch(p))"]
end
cuda_columns(ps::Vector) = reduce(vcat, cuda_columns.(ps); init=String[])

"""
    {{cuda_count}}

Number of CUDA toolkits that Yggdrasil can build against.
"""
hfun_cuda_count() = string(length(CUDA_VERSIONS))

"""
    {{cuda_default_count}}

Number of CUDA toolkits that Yggdrasil builds against by default.
"""
hfun_cuda_default_count() = string(count(is_default_cuda, CUDA_VERSIONS))

"""
    {{cuda_table}}

One row per CUDA toolkit, showing which platforms it is built for.
"""
function hfun_cuda_table()
    # Show any new kind of platform as an extra column rather than dropping it.
    columns = unique([CUDA_COLUMNS; cuda_columns(CUDA_ALL_PLATFORMS)])
    rows = map(CUDA_VERSIONS) do v
        built = Set(cuda_columns(filter(p -> tags(p)["cuda"] == cuda_series(v), CUDA_ALL_PLATFORMS)))
        status = v in CUDA_HELPER.cuda_prerelease_versions ? "Preview" :
                 is_default_cuda(v) ? "Yes" : "Opt-in"
        [string(v), (c in built ? CHECK : DASH for c in columns)..., status]
    end
    return html_table(["CUDA toolkit", columns..., "Built by default"], rows)
end

## GPU libraries
#
# The names and descriptions are curated; the versions come from the registry.

const GPU_PACKAGES = Dict(
    "NVIDIA" => [
        ("CUDNN_jll", "cuDNN: deep neural network primitives"),
        ("CUTENSOR_jll", "cuTENSOR: tensor operations"),
        ("CUDSS_jll", "cuDSS: sparse direct solvers"),
        ("cuSolverMp_jll", "cuSOLVERMp: distributed dense linear algebra"),
        ("cuQuantum_jll", "cuQuantum: quantum circuit simulation"),
        ("NCCL_jll", "NCCL: communication between GPUs"),
        ("TensorRT_jll", "TensorRT: deep learning inference"),
        ("NVTX_jll", "NVTX: annotations for profilers"),
    ],
    "AMD" => [
        ("AMDGPU_LLVM_Backend_jll", "LLVM code generator for AMD GPUs"),
        ("ROCmDeviceLibs_jll", "ROCm device libraries"),
        ("hsa_rocr_jll", "ROCm runtime (HSA)"),
        ("HIP_jll", "HIP runtime"),
        ("rocBLAS_jll", "rocBLAS: dense linear algebra"),
        ("rocSPARSE_jll", "rocSPARSE: sparse linear algebra"),
        ("rocRAND_jll", "rocRAND: random number generation"),
        ("MIOpen_jll", "MIOpen: deep learning primitives"),
        ("rocminfo_jll", "rocminfo: device information tool"),
    ],
    "Intel" => [
        ("NEO_jll", "Compute runtime for Intel GPUs (NEO)"),
        ("libigc_jll", "Intel Graphics Compiler"),
        ("gmmlib_jll", "Intel graphics memory management library"),
        ("oneAPI_Level_Zero_Loader_jll", "oneAPI Level Zero loader"),
        ("oneAPI_Level_Zero_Headers_jll", "oneAPI Level Zero headers"),
        ("oneAPI_Support_jll", "Support library for oneAPI.jl"),
    ],
    "Apple" => [
        ("Metal_LLVM_Tools_jll", "LLVM tools for generating Metal code"),
        ("Metal_Shader_Converter_jll", "Metal shader converter"),
    ],
    "Cross-vendor" => [
        ("OpenCL_jll", "OpenCL ICD loader"),
        ("OpenCL_Headers_jll", "OpenCL headers"),
        ("pocl_jll", "PoCL: portable OpenCL implementation for CPUs"),
        ("intel_opencl_rt_jll", "Intel OpenCL runtime for x86_64 CPUs"),
        ("Vulkan_Loader_jll", "Vulkan loader"),
        ("Vulkan_Headers_jll", "Vulkan headers"),
        ("SPIRV_Tools_jll", "SPIR-V tools"),
        ("SPIRV_LLVM_Translator_jll", "Translator between LLVM IR and SPIR-V"),
        ("SPIRV_LLVM_Backend_jll", "LLVM code generator for SPIR-V"),
    ],
)

"""
    {{gpu_packages vendor}}

Table of the GPU libraries for `vendor` (a key of `GPU_PACKAGES`) with the latest
version of each in the General registry.
"""
function hfun_gpu_packages(params::Vector{String})
    rows = [[jll_link(name), desc, format_version(latest_version(name))]
            for (name, desc) in GPU_PACKAGES[only(params)]]
    return html_table(["Package", "Description", "Latest version"], rows)
end

## MPI

const MPI_ABIS = [(abi = abi, jll = pkg.name, compat = compat, platforms = filter(f, PLATFORMS))
                  for (abi, pkg, compat, f) in MPI_HELPER.mpi_abis]

# Show a Pkg compat entry such as "4.1.11, 5.0.14" as "4.x (≥ 4.1.11), 5.x (≥ 5.0.14)";
# anything more complex is shown as it is.
function format_compat(compat)
    parts = strip.(split(compat, ','))
    all(p -> occursin(r"^[1-9]\d*(\.\d+){0,2}$", p), parts) || return compat
    return Raw(join(("$(first(split(p, '.'))).x (&ge; $p)" for p in parts), ", "))
end

"""
    {{mpi_count}}

Number of MPI implementations that recipes are built for.
"""
hfun_mpi_count() = string(length(MPI_ABIS))

"""
    {{mpi_table}}

One row per MPI implementation that recipes are built for.
"""
hfun_mpi_table() = html_table(
    ["Implementation", "Package", "Compatible versions", "Latest version", "Platforms"],
    [[m.abi, jll_link(m.jll), format_compat(m.compat), format_version(latest_version(m.jll)),
      "$(length(m.platforms)) of $(length(PLATFORMS))"] for m in MPI_ABIS])

"""
    {{mpi_platform_table}}

One row per supported platform, showing which MPI implementations are built for it.
"""
hfun_mpi_platform_table() = html_table(
    ["Platform", (m.abi for m in MPI_ABIS)...],
    [[code(triplet(p)), (p in m.platforms ? CHECK : DASH for m in MPI_ABIS)...] for p in PLATFORMS])
