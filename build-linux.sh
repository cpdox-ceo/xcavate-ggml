#!/bin/sh
# Builds Xcavate's ggml for Linux x86_64: llama.cpp b12005 (e0f142d) plus xcavate-ggml.patch.
#
#   SRC=/path/to/llama.cpp CUDA=/usr/local/cuda-13.2 sh build-linux.sh
#
# Needs CMake, a C++ compiler and CUDA 13.2. SRC: a llama.cpp checkout; it is put at e0f142d and the
# patch applied. Writes the four libraries to $SRC/build/bin.
set -eu
: "${SRC:?set SRC to a llama.cpp checkout}"
CUDA=${CUDA:-/usr/local/cuda-13.2}
HERE=$(cd "$(dirname "$0")" && pwd)
cd "$SRC"
git checkout -q e0f142d5ddc1461ce721644d92af33db23545105
git apply --check "$HERE/xcavate-ggml.patch" 2>/dev/null && git apply "$HERE/xcavate-ggml.patch"
# 86-real: Ampere machine code only, no PTX a driver would compile itself. GGML_NATIVE=OFF: the CPU
# part runs on any x86_64 CPU (the GPU does the work).
PATH="$CUDA/bin:$PATH" cmake -B build -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DGGML_CUDA=ON \
    -DCMAKE_CUDA_ARCHITECTURES=86-real -DCMAKE_CUDA_COMPILER="$CUDA/bin/nvcc" -DGGML_NATIVE=OFF \
    -DGGML_CUDA_FA=ON -DGGML_CUDA_GRAPHS=ON -DGGML_CUDA_COMPRESSION_MODE=size -DLLAMA_CURL=OFF \
    -DLLAMA_BUILD_TESTS=OFF -DLLAMA_BUILD_EXAMPLES=OFF -DLLAMA_BUILD_SERVER=OFF
cmake --build build -j "$(nproc)" --target ggml ggml-base ggml-cpu ggml-cuda
echo BUILD OK
