FROM ubuntu:14.04
MAINTAINER Daniel Reuter <daniel.robin.reuter@googlemail.com>

ENV mirror "deb http://packages.ros.org/ros/ubuntu trusty main"

# -- Basic stuff --

# Avoids annoying warnings from debconf
RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections

RUN sudo apt-get update && sudo apt-get install -y build-essential wget

# -- Install ROS --

# TODO: find a nifty way to support mirrors
RUN sudo sh -c "echo ${mirror} > /etc/apt/sources.list.d/ros-latest.list"
RUN wget https://raw.githubusercontent.com/ros/rosdistro/master/ros.key -q -O - | sudo apt-key add -
RUN sudo apt-get update && sudo apt-get install -y ros-indigo-desktop-full

# -- Add a non-root user --

RUN adduser --disabled-password --gecos '' user
RUN adduser user sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Run all further steps as non-root user (we can still use sudo)
USER user

# -- Initialize rosdep --

RUN sudo rosdep init && rosdep update

# -- Environment Setup --

RUN echo "source /opt/ros/indigo/setup.bash" >> ~/.bashrc

# Restores default behavior of debconf
RUN sudo su -c "echo 'debconf debconf/frontend select Dialog' | debconf-set-selections"
