
unameOut="$(uname -s)"
case "${unameOut}" in
    Linux*)     machine=Linux;;
    Darwin*)    machine=Mac;;
    #CYGWIN*)    machine=Cygwin;;
    #MINGW*)     machine=MinGw;;
    #*)          machine="UNKNOWN:${unameOut}"
esac
echo "type : ${machine}"


#mkdir -p sycl_workspace
#cd sycl_workspace

mkdir -p sycl_cpl_src


if [ ! "$machine" == "Mac" ]
then 
    mkdir -p sycl_cpl_src/dpcpp
fi

mkdir -p sycl_cpl/hipSYCL

if [ ! "$machine" == "Mac" ]
then 
    mkdir -p sycl_cpl/dpcpp
    cd sycl_cpl_src/dpcpp

    echo "$(pwd)"


    if [ -d "llvm" ] 
    then
        echo "dpcpp folder found -> git pull"
        cd llvm 
        git pull
        cd ..
    else
        echo "dpcpp folder not found -> git clone"
        git clone https://github.com/intel/llvm -b sycl
    fi

    cd ../..

fi


cd sycl_cpl_src

if [ -d "OpenSYCL" ] 
then
    echo "OpenSYCL folder found -> git pull"
    cd OpenSYCL 
    git pull
    cd ..
else
    echo "OpenSYCL folder not found -> git clone"
    git clone --recurse-submodules https://github.com/OpenSYCL/OpenSYCL.git
fi

cd ..



echo "$(pwd)"

rm -r sycl_cpl

echo "compiling OpenSYCL"
cd sycl_cpl_src/OpenSYCL
cmake -DCMAKE_INSTALL_PREFIX=../../sycl_cpl/OpenSYCL .
make -j install
cd ..

if [ ! "$machine" == "Mac" ]
then 
    echo "compiling dpcpp"
    cd dpcpp/llvm
    echo "$(pwd)"

    if ! type nvcc > /dev/null; then
        echo "CUDA=false"
        python3 buildbot/configure.py --llvm-external-projects compiler-rt --cmake-opt="-DCMAKE_INSTALL_PREFIX=../../../../sycl_cpl/dpcpp"
    else
        echo "CUDA=true"
        python3 buildbot/configure.py --llvm-external-projects compiler-rt --cuda --cmake-opt="-DCMAKE_INSTALL_PREFIX=../../../../sycl_cpl/dpcpp"
    fi

    cd build
    ninja all\
        lib/libsycl-cmath-fp64.o               \
        lib/libsycl-fallback-cstring.spv\
        lib/libsycl-cmath.o                    \
        lib/libsycl-fallback-imf-fp64.o\
        lib/libsycl-complex-fp64.o             \
        lib/libsycl-fallback-imf-fp64.spv\
        lib/libsycl-complex.o                  \
        lib/libsycl-fallback-imf.o\
        lib/libsycl-crt.o                      \
        lib/libsycl-fallback-imf.spv\
        lib/libsycl-fallback-cassert.o         \
        lib/libsycl-imf-fp64.o\
        lib/libsycl-fallback-cassert.spv       \
        lib/libsycl-imf.o\
        lib/libsycl-fallback-cmath-fp64.o      \
        lib/libsycl-itt-compiler-wrappers.o\
        lib/libsycl-fallback-cmath-fp64.spv    \
        lib/libsycl-itt-stubs.o\
        lib/libsycl-fallback-cmath.o           \
        lib/libsycl-itt-user-wrappers.o\
        lib/libsycl-fallback-cmath.spv         \
        lib/libsycl_pi_trace_collector.so\
        lib/libsycl-fallback-complex-fp64.o    \
        lib/libsycl_profiler_collector.so\
        lib/libsycl-fallback-complex-fp64.spv  \
        lib/libsycl_sanitizer_collector.so\
        lib/libsycl-fallback-complex.o         \
        lib/libsycl.so\
        lib/libsycl-fallback-complex.spv       \
        lib/libsycl.so.6\
        lib/libsycl-fallback-cstring.o         \
        lib/libsycl.so.6.2.0-0\
        tools/libdevice/libsycldevice\
        install

fi




