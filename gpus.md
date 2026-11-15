@def title = "Yggdrasil GPUs"
@def hasmath = false
@def hascode = false

# GPUs

[Yggdrasil](https://github.com/JuliaPackaging/Yggdrasil/), the community build tree for BinaryBuilder recipes, builds packages for NVIDIA, AMD, Intel and Apple GPUs, and for the cross-vendor OpenCL, Vulkan and SPIR-V standards. Library versions on this page are the latest ones in Julia's General registry when the site was built.

## NVIDIA

Yggdrasil recipes that use CUDA are built for {{cuda_default_count}} of the {{cuda_count}} CUDA toolkits below by default. Each build is tagged with its CUDA version, and Julia installs the one that works with the user's CUDA runtime: a build for CUDA 12.2 works with any CUDA 12 runtime from 12.2 onwards. Program NVIDIA GPUs from Julia with [CUDA.jl](https://github.com/JuliaGPU/CUDA.jl), and start a recipe from the [`HelloWorldCUDA`](https://github.com/JuliaPackaging/Yggdrasil/tree/master/H/HelloWorldCUDA) example.

~~~
{{cuda_table}}
~~~

From CUDA 13, a single aarch64 build covers both ARM servers and Jetson. Toolkits marked opt-in or preview are left out of `CUDA.supported_platforms()` by default; recipes include them with its `min_version` and `prereleases` keywords.

~~~
{{gpu_packages NVIDIA}}
~~~

## AMD

Program AMD GPUs from Julia with [AMDGPU.jl](https://github.com/JuliaGPU/AMDGPU.jl).

~~~
{{gpu_packages AMD}}
~~~

## Intel

Program Intel GPUs from Julia with [oneAPI.jl](https://github.com/JuliaGPU/oneAPI.jl).

~~~
{{gpu_packages Intel}}
~~~

## Apple

Program Apple GPUs from Julia with [Metal.jl](https://github.com/JuliaGPU/Metal.jl).

~~~
{{gpu_packages Apple}}
~~~

## OpenCL, Vulkan and SPIR-V

Use OpenCL from Julia with [OpenCL.jl](https://github.com/JuliaGPU/OpenCL.jl) and Vulkan with [Vulkan.jl](https://github.com/JuliaGPU/Vulkan.jl).

~~~
{{gpu_packages Cross-vendor}}
~~~

The CUDA toolkits come from Yggdrasil's [`platforms/cuda.jl`](https://github.com/JuliaPackaging/Yggdrasil/blob/master/platforms/cuda.jl) each time the site is built.
