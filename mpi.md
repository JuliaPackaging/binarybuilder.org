@def title = "Yggdrasil MPI"
@def hasmath = false
@def hascode = false

# MPI

[Yggdrasil](https://github.com/JuliaPackaging/Yggdrasil/), the community build tree for BinaryBuilder recipes, builds packages that use MPI once for each of the {{mpi_count}} MPI implementations below, and tags each build with its implementation. Users choose an implementation with [MPIPreferences.jl](https://juliaparallel.org/MPI.jl/stable/configuration/); without a preference, Julia uses MPICH, or Microsoft MPI on Windows. Julia then installs the matching build of every package, so switching implementations doesn't require rebuilding anything.

Use MPI from Julia with [MPI.jl](https://github.com/JuliaParallel/MPI.jl), and start a recipe from the [`HelloWorldMPI`](https://github.com/JuliaPackaging/Yggdrasil/tree/master/H/HelloWorldMPI) example.

## Implementations

~~~
{{mpi_table}}
~~~

Compatible versions are the versions of each implementation that the builds work with. [`MPICH_CUDA_jll`](https://github.com/JuliaBinaryWrappers/MPICH_CUDA_jll.jl), a build of MPICH with CUDA support, can be selected in place of MPICH. Latest versions are the latest ones in Julia's General registry when the site was built.

## Platforms

~~~
{{mpi_platform_table}}
~~~

The implementations come from Yggdrasil's [`platforms/mpi.jl`](https://github.com/JuliaPackaging/Yggdrasil/blob/master/platforms/mpi.jl) each time the site is built.
