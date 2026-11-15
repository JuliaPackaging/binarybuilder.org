@def title = "BinaryBuilder"
@def hasmath = false
@def hascode = false

~~~


<div class="pure-g images watdis">
  <div class="pure-u-1-2 pure-u-md-1-4 img-small">
    <img class="pure-img" src="/assets/toolchain.svg" alt=""/>
    <h3>Toolchains</h3>
    <p><a href="/toolchains/">{{toolchain_count}} well maintained toolchains</a> for major platforms</p>
  </div>
  <div class="pure-u-1-2 pure-u-md-1-4 img-small">
    <img class="pure-img" src="/assets/sandbox.svg" alt=""/>
    <h3>Sandbox</h3>
    <p>All the tools you need in one <a href="https://docs.binarybuilder.org/stable/#How-does-this-all-work?">isolated Linux environment</a></p>
  </div>
  <div class="pure-u-1-2 pure-u-md-1-4 img-small">
    <img class="pure-img" src="/assets/audit.svg" alt=""/>
    <h3>Audit</h3>
    <p>Automated analysis finds and fixes common mistakes</p>
  </div>
  <div class="pure-u-1-2 pure-u-md-1-4 img-small">
    <img class="pure-img" src="/assets/wizard.svg" alt=""/>
    <h3>Wizard</h3>
    <p>An <a href="https://docs.binarybuilder.org/stable/#Wizard-interface">interactive environment</a> simplifies authoring</p>
  </div>
</div>

<hr/>

<div class="pure-g features">
    <div class="pure-u-1-2 pure-u-md-1-3">
        <h3>OS Support</h3>
        <p>BinaryBuilder produces binaries for <a href="/toolchains/">{{os_list}}</a> with a <a href="https://docs.binarybuilder.org/stable/building/">single script</a>.</p>
    </div>
    <div class="pure-u-1-2 pure-u-md-1-3">
        <h3>CPU support</h3>
        <p>BinaryBuilder supports {{cpu_list}}. <a href="https://docs.binarybuilder.org/stable/building/#Platforms">Automatically!</a></p>
    </div>
    <div class="pure-u-1-2 pure-u-md-1-3">
        <h3>Language support</h3>
        <p>Build native binaries for your C, <a href="https://docs.binarybuilder.org/stable/build_tips/#C-builds">C++</a>, <a href="https://docs.binarybuilder.org/stable/building/#Expanding-C-string-ABIs-or-libgfortran-versions">Fortran</a>, <a href="https://docs.binarybuilder.org/stable/build_tips/#Rust-builds">Rust</a>, <a href="https://docs.binarybuilder.org/stable/build_tips/#Go-builds">Go</a> and <a href="https://docs.binarybuilder.org/stable/build_tips/#OCaml-builds">OCaml</a> packages.</p>
    </div>
    <div class="pure-u-1-2 pure-u-md-1-3">
        <h3>Just tarballs</h3>
        <p>BinaryBuilder output is <a href="https://docs.binarybuilder.org/stable/jll/">just a tarball</a>. Grab the one for your ABI and go. No root or special tools required!</p>
    </div>
    <div class="pure-u-1-2 pure-u-md-1-3">
        <h3>Hints</h3>
        <p><a href="https://docs.binarybuilder.org/stable/build_tips/#Autoconfigure-builds">Common build systems</a> are automatically detected. The wizard will give you the right command.</p>
    </div>
    <div class="pure-u-1-2 pure-u-md-1-3">
        <h3>Cross-platform consistency</h3>
        <p>You can build for several platforms using the <a href="/toolchains/">same toolchain</a>, getting consistent binaries across all target systems.</p>
    </div>
</div>

<hr/>

<div class="section-head">
  <img src="/assets/yggdrasil.svg" alt=""/>
  <h2>Yggdrasil</h2>
  <p><a href="https://github.com/JuliaPackaging/Yggdrasil/">Yggdrasil</a> is the community build tree for BinaryBuilder recipes, where the binary packages of the Julia ecosystem are built.</p>
</div>

<div class="pure-g features">
    <div class="pure-u-1-2 pure-u-md-1-3">
        <h3>Community-driven</h3>
        <p>Build recipes for thousands of packages are already available, contributed by the community.</p>
    </div>
    <div class="pure-u-1-2 pure-u-md-1-3">
        <h3>JLL packages</h3>
        <p>Every merged recipe is built, uploaded and registered as a <a href="https://docs.binarybuilder.org/stable/jll/">JLL package</a>, so Julia users get the binaries with <code>using LibFoo_jll</code>.</p>
    </div>
    <div class="pure-u-1-2 pure-u-md-1-3">
        <h3>Contributing</h3>
        <p>Add or update a package by <a href="https://github.com/JuliaPackaging/Yggdrasil/blob/master/CONTRIBUTING.md">opening a pull request</a> with its recipe. CI builds it for every platform it targets.</p>
    </div>
    <div class="pure-u-1-2 pure-u-md-1-3">
        <h3>GPUs</h3>
        <p>Build code for <a href="/gpus/">NVIDIA, AMD, Intel and Apple GPUs</a>. For CUDA, Julia automatically installs the build that matches the user's CUDA version.</p>
    </div>
    <div class="pure-u-1-2 pure-u-md-1-3">
        <h3>Parallelism</h3>
        <p>Build <a href="/mpi/">MPI</a> and OpenMP code for parallel computing. Users can switch between MPI implementations, such as MPICH and Open MPI, without rebuilding.</p>
    </div>
    <div class="pure-u-1-2 pure-u-md-1-3">
        <h3>Agents</h3>
        <p>Agents simplify authoring, guided by <a href="https://github.com/JuliaPackaging/Yggdrasil/blob/master/AGENTS.md">Yggdrasil's agent guide</a>.</p>
    </div>
</div>

~~~
