FROM ubuntu:20.04
# Set environment variables to disable prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install tzdata and configure timezone
RUN apt-get update && apt-get install -y tzdata && \
    ln -fs /usr/share/zoneinfo/Europe/Berlin /etc/localtime && \
    dpkg-reconfigure -f noninteractive tzdata

# Reset DEBIAN_FRONTEND to default
ENV DEBIAN_FRONTEND=dialog

# Install dependencies
RUN apt update && apt install -y git build-essential \
 liblapack-dev \
 mesa-common-dev \
 libeigen3-dev \
 freeglut3-dev \
 libf2c2-dev \
 libjsoncpp-dev \
 libqhull-dev \
 libann-dev \
 libassimp-dev \
 libglew-dev \
 libglfw3-dev \
 libgtest-dev \
 libopencv-dev \
 libboost-all-dev \
 cmake
    
WORKDIR /tamp
COPY requirements.txt .

# Clone projects
RUN git clone https://github.com/cambyse/trajectory_tree_tamp.git trajectory_tree_tamp && cd trajectory_tree_tamp
WORKDIR /tamp/trajectory_tree_tamp
RUN git submodule update --init --recursive

# Build Rai
WORKDIR /tamp/trajectory_tree_tamp/rai
RUN make

# Build TAMP lib and examples
WORKDIR /tamp/trajectory_tree_tamp/share/projects
RUN mkdir 17-camille-obsTask_build
WORKDIR /tamp/trajectory_tree_tamp/share/projects/17-camille-obsTask_build
RUN cmake ../17-camille-obsTask -DMLR_LIBRARIES_DIR=/tamp/trajectory_tree_tamp/rai/lib -DMLR_INCLUDE_DIR=/tamp/trajectory_tree_tamp/rai/rai -DCMAKE_BUILD_TYPE=Release
RUN make

