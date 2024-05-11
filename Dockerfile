##########################################
# Dockerfile to change from root to 
# non-root privilege
###########################################
FROM ros:humble-ros-base

ENV RMW_IMPLEMENTATION=rmw_fastrtps_cpp

# Setup non-root admin user
ARG USERNAME=admin
# UID=1202 for batman user, UID=1200 for birdsoperator user
ARG USER_UID=1000
# GID=777 for simopt group
ARG USER_GID=1000

# Install prerequisites
RUN apt-get update && apt-get install -y \
    sudo \
    udev \
    psmisc \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Create the 'admin' user if not already exists
RUN if [ ! $(getent passwd ${USERNAME}) ]; then \
    groupadd --gid ${USER_GID} ${USERNAME} ; \
    useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} ; \
    fi

# Create the group 993(gpio),994(i2c),995(spi)
ARG GPIO_GID=993
ARG I2C_GID=994
ARG SPI_GID=995
RUN groupadd --gid ${GPIO_GID} gpio ; \
    groupadd --gid ${I2C_GID} i2c ; \
    groupadd --gid ${SPI_GID} spi ; \
    adduser ${USERNAME} gpio ; \
    adduser ${USERNAME} i2c ; \
    adduser ${USERNAME} spi

# Update 'admin' user
RUN echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME} \
    && chmod 0440 /etc/sudoers.d/${USERNAME} \
    && adduser ${USERNAME} video && adduser ${USERNAME} plugdev && adduser ${USERNAME} sudo \
    && adduser ${USERNAME} dialout

# Copy scripts
RUN mkdir -p /usr/local/bin/scripts
COPY scripts/*entrypoint.sh /usr/local/bin/scripts/
RUN  chmod 775 /usr/local/bin/scripts/*.sh

# Copy middleware profiles
RUN mkdir -p /usr/local/share/middleware_profiles
COPY middleware_profiles/*profile.xml /usr/local/share/middleware_profiles/
RUN chmod 775 /usr/local/share/middleware_profiles/*.xml

ENV USERNAME=${USERNAME}
ENV USER_GID=${USER_GID}
ENV USER_UID=${USER_UID}

# Install gdb (c++ debugger)
RUN apt-get update && apt-get install -y \
    gdb \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

RUN apt-get update && apt-get install -y \
    python3-gpiozero \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Install pip3
RUN apt-get update && apt-get install -y \
    python3-pip \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

RUN python3 -m pip install \
    smbus \
    numpy \
    easydict \
    RPi.GPIO