ARG FROM_SRC_ROS1=ghcr.io/autocore-ai/src-ros1:latest
ARG FROM_SRC_ROS2=ghcr.io/autocore-ai/src-ros2:latest
ARG FROM_DEVEL=autocore/ats-devel

FROM ${FROM_SRC_ROS1} as src_ros1
FROM ${FROM_SRC_ROS2} as src_ros2
FROM ${FROM_DEVEL} as devel

COPY --from=src_ros1 /AutowareArchitectureProposal /ros1_workspace
COPY --from=src_ros2 /AutowareArchitectureProposal /ros2_workspace

RUN /bin/bash -c \
    'cd /ros1_workspace \
    && source /opt/ros/melodic/setup.bash \
    && colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release \
    --merge-install \
    --catkin-skip-building-tests \
    --packages-up-to \
    autoware_control_msgs \
    autoware_lanelet2_msgs \
    autoware_perception_msgs \
    autoware_planning_msgs \
    autoware_system_msgs \
    autoware_vehicle_msgs \
    lidar_apollo_instance_segmentation \
    livox_ros_driver \
    tensorrt_yolo3 \
    traffic_light_classifier \
    traffic_light_ssd_fine_detector'

RUN /bin/bash -c \
    'cd /ros2_workspace \
    && source /opt/ros/eloquent/setup.bash \
    && colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release \
    --merge-install \
    --catkin-skip-building-tests \
    --packages-up-to \
    autoware_control_msgs \
    autoware_lanelet2_msgs \
    autoware_perception_msgs \
    autoware_planning_msgs \
    autoware_system_msgs \
    autoware_vehicle_msgs'

RUN /bin/bash -c \
    'cd /ros1_bridge \
    && source /opt/ros/melodic/setup.bash \
    && source /opt/ros/eloquent/setup.bash \
    && source /ros1_workspace/install/setup.bash \
    && source /ros2_workspace/install/setup.bash \
    && colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release --packages-select ros1_bridge --cmake-force-configure'

RUN /bin/bash -c \
    'cd /ros1_workspace \
    && source /opt/ros/melodic/setup.bash \
    && colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release \
    --merge-install \
    --catkin-skip-building-tests \
    --packages-skip-build-finished'

FROM alpine

COPY --from=devel /ros1_workspace/install /ros1_workspace/install
COPY --from=devel /ros2_workspace/install /ros2_workspace/install
COPY --from=devel /ros1_bridge/install /ros1_bridge/install