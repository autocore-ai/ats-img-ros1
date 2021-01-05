FROM nvidia/cudagl:10.2-devel-ubuntu18.04

ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

ENV ROS_DISTRO melodic
ENV ROS1_DISTRO melodic
ENV ROS2_DISTRO eloquent

ENV DEBIAN_FRONTEND noninteractive

RUN echo 'Etc/UTC' > /etc/timezone \
    && ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime \
    && apt-get update \
    && apt-get install --no-install-recommends -q -y \
    dirmngr \
    gnupg2 \
    nano \
    net-tools \
    proxychains4 \
    tzdata \
    && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654 \
    && rm -rf /var/lib/apt \
    && echo "deb http://packages.ros.org/ros/ubuntu bionic main" > /etc/apt/sources.list.d/ros-latest.list \
    && echo "deb http://packages.ros.org/ros2/ubuntu bionic main" > /etc/apt/sources.list.d/ros2-latest.list

RUN apt-get update \
    && apt-get install --no-install-recommends -q -y \
    build-essential \
    python-pip \
    python-rosdep \
    python-rosinstall \
    python-rosinstall-generator \
    python-wstool \
    && rosdep init \
    && rosdep update \
    && rm -rf /var/lib/apt

RUN apt-get update \
    && apt-get install --no-install-recommends -q -y \
    ca-certificates \
    cmake \
    git \
    libcgal-dev \
    libcudnn7-dev=7.6.5.32-1+cuda10.2 \
    libfmt-dev \
    libgeographic-dev \
    libgoogle-glog-dev \
    libnl-3-dev \
    libnl-genl-3-dev \
    libnvinfer-dev=7.0.0-1+cuda10.2 \
    libnvinfer-plugin-dev=7.0.0-1+cuda10.2 \
    libnvinfer-plugin7=7.0.0-1+cuda10.2 \
    libnvinfer7=7.0.0-1+cuda10.2 \
    libnvonnxparsers-dev=7.0.0-1+cuda10.2 \
    libnvonnxparsers7=7.0.0-1+cuda10.2 \
    libnvparsers-dev=7.0.0-1+cuda10.2 \
    libnvparsers7=7.0.0-1+cuda10.2 \
    libpugixml-dev \
    python-catkin-tools \
    python3-colcon-common-extensions \
    ros-melodic-automotive-navigation-msgs \
    ros-melodic-automotive-platform-msgs \
    ros-melodic-can-msgs \
    ros-melodic-cv-bridge \
    ros-melodic-desktop-full \
    ros-melodic-grid-map-ros \
    ros-melodic-image-transport \
    ros-melodic-joy \
    ros-melodic-lanelet2 \
    ros-melodic-pacmod-msgs \
    ros-melodic-pacmod3 \
    ros-melodic-pcl-ros \
    ros-melodic-pointcloud-to-laserscan \
    ros-melodic-rosbridge-server \
    ros-melodic-roslint \
    ros-melodic-roswww \
    ros-melodic-tf2-geometry-msgs \
    ros-melodic-tf2-sensor-msgs \
    ros-melodic-unique-id \
    ros-melodic-uuid-msgs \
    ros-melodic-velodyne-description \
    ros-melodic-velodyne-pointcloud \
    ros-melodic-voxel-grid \
    software-properties-common \
    && apt-add-repository -y ppa:astuff/kvaser-linux \
    && apt install -y kvaser-canlib-dev \
    && rm -rf /var/lib/apt

RUN git clone -b release-0.6.0 --depth 1 --recursive https://github.com/oxfordcontrol/osqp.git /osqp \
    && mkdir -p /osqp/build \
    && cd /osqp/build \
    && cmake -G "Unix Makefiles" .. \
    && cmake --build . --target install \
    && rm -rf /osqp

RUN pip install wheel gdown future

RUN apt-get update \
    && apt-get install -q -y --no-install-recommends \
    ros-eloquent-desktop \
    ros-eloquent-ros-testing \
    && rm -rf /var/lib/apt/lists/*

RUN git clone -b foxy --depth 1 https://github.com/ros2/ros1_bridge.git /ros1_bridge