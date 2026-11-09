# xcavate-ggml

The ggml libraries [Xcavate](https://github.com/cpdox-ceo/xcavate) nodes compute with: ggml from
[llama.cpp](https://github.com/ggml-org/llama.cpp), pinned to one version, with a small patch. Xcavate
downloads them when its owner chooses to earn, checking each file's SHA-256 fingerprint; you don't need
to install anything from here yourself.

**Current version:** `b12005-x1`: llama.cpp b12005 (commit `e0f142d5ddc1461ce721644d92af33db23545105`),
CUDA 13.2, NVIDIA RTX 30 series (Ampere).

## Why pinned and patched

Xcavate nodes check each other's work by recomputing it and comparing the results bit for bit. That
only works when every node computes identically:

- **Pinned:** every node uses these exact files. A newer ggml usually changes results slightly, so
  moving to one is a deliberate step, proven before nodes switch.
- **Patched** (`xcavate-ggml.patch`, 18 lines): some CUDA kernels split their work by the GPU's number
  of processors, which gives slightly different results on GPUs of different sizes. The patch makes
  every GPU plan its work as if it had 64 processors (`XCAVATE_FIXED_NSM`), so an RTX 3060 and an
  RTX 3090 produce the same bits. It also exports `xcavate_planning_nsm(device)`, which the engine
  reports, so only nodes that compute identically check each other. `GGML_CUDA_VIRTUAL_NSM` overrides
  the count, for experiments only.

## Releases

Each release is named `b<llama.cpp build>-x<our build number>` and holds the Windows DLLs, the Linux
shared libraries and `SHA256SUMS`. Its notes give the exact source and build settings. Old releases
stay up: installed nodes may still use them.

## Building

`build-windows.bat` and `build-linux.sh` build the four libraries (`ggml`, `ggml-base`, `ggml-cpu`,
`ggml-cuda`) from llama.cpp at the pinned commit with the patch applied. They need CMake, a C++
compiler (Visual Studio 2022 Build Tools on Windows) and CUDA 13.2. Settings that matter:

- `CMAKE_CUDA_ARCHITECTURES=86-real`: Ampere machine code only, with no PTX for a driver to compile
  itself, so results depend on nothing but these files;
- `GGML_NATIVE=OFF`: the CPU part is not tuned to the build machine, so it runs on other computers;
- `BUILD_SHARED_LIBS=ON`, flash attention and CUDA graphs on, compression `size`.

## License

MIT, as ggml is: see `LICENSE`. The patch and build scripts are also MIT.
