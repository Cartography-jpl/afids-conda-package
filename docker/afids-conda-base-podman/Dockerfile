FROM oraclelinux:8

ARG UID=1000
ARG GID=1000

MAINTAINER Mike Smyth Mike.M.Smyth@jpl.nasa.gov

# Right now, hardcoded to user smyth. Might be a way to make this more
# general, but we'll start with this.
RUN dnf install -y sudo tcsh
RUN echo '%wheel ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
# For podman, we run as root in docker, but this is mapped
# to our external UID automatically. So skip setting the user.
#RUN groupadd -o -g $GID afids-conda && \
#  useradd -l -u $UID -g afids-conda afids-conda
#USER afids-conda
RUN mkdir -p /home/afids-conda/workdir
WORKDIR /home/afids-conda
