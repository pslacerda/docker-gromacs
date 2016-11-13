FROM ubuntu:16.04
MAINTAINER Léo Biscassi, <leo.biscassi@gmail.com>

ENV GROMACS_VERSION=4.6.5 \
GROMACS_USER=gromacs \
GROMACS_UID=1450 \
GROMACS_GID=1450 \
GROMACS_HOME=/home/gromacs \
DATA=/data \
LC_ALL=en_US.UTF-8 \
LANG=en_US.UTF-8

ENV PROGRAMS_ROOT=$GROMACS_HOME/programs \
GROMACS_LINK=ftp://ftp.gromacs.org/pub/gromacs/gromacs-$GROMACS_VERSION.tar.gz

RUN locale-gen en_US.UTF-8 && dpkg-reconfigure locales

RUN apt-get update && apt-get -y install wget tar gcc gfortran cmake libpng-dev zlib1g-dev libfreetype6-dev

RUN groupadd -r $GROMACS_USER -g $GROMACS_GID && \
	useradd -u $GROMACS_UID -r -g $GROMACS_USER -d $GROMACS_HOME -c "Gromacs User" $GROMACS_USER && \
	mkdir $GROMACS_HOME $DATA $PROGRAMS_ROOT && \
	chown -R $GROMACS_USER:$GROMACS_USER $GROMACS_HOME $PROGRAMS_ROOT $DATA

WORKDIR $PROGRAMS_ROOT

USER gromacs

RUN wget -q $GROMACS_LINK && tar -xf gromacs-$GROMACS_VERSION.tar.gz && \
	rm -rf gromacs-$GROMACS_VERSION.tar.gz && cd gromacs-$GROMACS_VERSION && mkdir build && cd build && \
	cmake .. -DSHARED_LIBS_DEFAULT=OFF -DBUILD_SHARED_LIBS=OFF \
	-DGMX_PREFER_STATIC_LIBS=YES -DGMX_BUILD_OWN_FFTW=ON \
	-DGMX_GSL=OFF -DGMX_DEFAULT_SUFFIX=ON -DGMX_GPU=OFF \
	-DGMX_MPI=OFF -DGMX_DOUBLE=OFF \
	-DGMX_INSTALL_PREFIX=$PREFIX -DCMAKE_INSTALL_PREFIX=$PROGRAMS_ROOT/gromacs-$GROMACS_VERSION && \
	make -j 8 && make install

VOLUME ["/data/"]

WORKDIR $DATA