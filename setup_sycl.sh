
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

if [ -d "hipSYCL" ] 
then
    echo "hipSYCL folder found -> git pull"
    cd hipSYCL 
    git pull
    cd ..
else
    echo "hipSYCL folder not found -> git clone"
    git clone --recurse-submodules https://github.com/illuhad/hipSYCL
fi

cd ..



echo "$(pwd)"

rm -r sycl_cpl

echo "compiling hipSYCL"
cd sycl_cpl_src/hipSYCL
cmake -DCMAKE_INSTALL_PREFIX=../../sycl_cpl/hipSYCL .
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
    ninja all
    ninja install

fi




