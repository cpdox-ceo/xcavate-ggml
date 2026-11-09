@echo off
rem Builds Xcavate's ggml for Windows: llama.cpp b12005 (e0f142d) plus xcavate-ggml.patch.
rem Needs: Visual Studio 2022 Build Tools, Ninja, CMake, CUDA 13.2 (set CUDA to its folder), and
rem SRC: a llama.cpp checkout at e0f142d with the patch applied (git apply xcavate-ggml.patch).
rem Writes the four libraries to %SRC%\build\bin.
if "%CUDA%"=="" set CUDA=C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v13.2
if "%SRC%"=="" ( echo set SRC to the patched llama.cpp checkout & exit /b 1 )
call "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat" || exit /b 1
set CUDA_PATH=%CUDA%
set PATH=%CUDA%\bin;%PATH%
cd /d "%SRC%"
rem 86-real: Ampere machine code only, no PTX a driver would compile itself (results then depend on
rem nothing but these files). GGML_NATIVE=OFF with AVX2: runs on any CPU since 2013.
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DGGML_CUDA=ON ^
  -DCMAKE_CUDA_ARCHITECTURES=86-real -DCMAKE_CUDA_COMPILER="%CUDA%/bin/nvcc.exe" ^
  -DGGML_NATIVE=OFF -DGGML_AVX2=ON -DGGML_FMA=ON -DGGML_F16C=ON ^
  -DGGML_CUDA_FA=ON -DGGML_CUDA_GRAPHS=ON -DGGML_CUDA_COMPRESSION_MODE=size ^
  -DLLAMA_BUILD_TESTS=OFF -DLLAMA_BUILD_EXAMPLES=OFF -DLLAMA_BUILD_SERVER=OFF -DLLAMA_CURL=OFF || exit /b 1
cmake --build build --config Release -j 10 --target ggml ggml-base ggml-cpu ggml-cuda || exit /b 1
echo BUILD OK
