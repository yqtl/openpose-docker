FROM nvidia/cuda:10.0-cudnn7-devel
#this version is Ubuntu 18
#FROM nvidia/cuda:8.0-cudnn7-devel
#FROM nvidia/cuda:8.0-cudnn6-devel-ubuntu16.04

#get deps
#a. Do not do anything if you set the WITH_flag to BUILD, CMake will automatically download Eigen. 
#b. Run sudo apt-get install libeigen3-dev if you prefer to set WITH_EIGEN to FIND
RUN apt-get update && \
DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
python3-dev python3-pip git g++ wget make libprotobuf-dev protobuf-compiler libopencv-dev \
libgoogle-glog-dev libboost-all-dev libcaffe-cuda-dev libhdf5-dev libatlas-base-dev \
build-essential freeglut3 freeglut3-dev libxmu-dev libxi-dev \
libsuitesparse-dev libavcodec57 libavformat57 libswscale4 libswresample2 libavutil55 libusb-1.0-0 libgtkmm-2.4-dev
#for python api
RUN pip3 install numpy opencv-python 
#replace cmake as old version has CUDA variable bugs
RUN wget https://github.com/Kitware/CMake/releases/download/v3.14.2/cmake-3.14.2-Linux-x86_64.tar.gz && \
tar xzf cmake-3.14.2-Linux-x86_64.tar.gz -C /opt && \
rm cmake-3.14.2-Linux-x86_64.tar.gz
ENV PATH="/opt/cmake-3.14.2-Linux-x86_64/bin:${PATH}"
#install eigen (wget)
RUN wget http://bitbucket.org/eigen/eigen/get/3.3.7.tar.gz && tar xzf 3.3.7.tar.gz && rm 3.3.7.tar.gz && cd eigen-eigen-323c052e1731/ && \
mkdir build && cd build && cmake .. && make install && make check
#install flir
RUN wget https://kth.box.com/shared/static/6olzu8c3n45thhdy4yx12cpkfqaadrc0.gz && \
tar xzf 6olzu8c3n45thhdy4yx12cpkfqaadrc0.gz && rm 6olzu8c3n45thhdy4yx12cpkfqaadrc0.gz && \
cd spinnaker-1.26.0.31-amd64/ && printf "Y\nY\n\n" | ./install_spinnaker.sh
#build Ceres
WORKDIR /ceres-solver
RUN git clone https://ceres-solver.googlesource.com/ceres-solver . 
WORKDIR /ceres-solver/ceres-bin
RUN cmake ../ && make -j3 && make test && make install
#get openpose
WORKDIR /openpose
RUN git clone https://github.com/CMU-Perceptual-Computing-Lab/openpose.git .

#build it, set WITH_EIGEN to FIND, since apt-get libeigen3-dev
WORKDIR /openpose/build
RUN cmake -DBUILD_PYTHON=ON .. && make -j8
WORKDIR /openpose
