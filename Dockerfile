# Dockerfile to build python3 images for scientific computing

# Set r_base to the base image
FROM dmccloskey/r-base:latest

# File Author / Maintainer
MAINTAINER Douglas McCloskey <dmccloskey87@gmail.com>

# switch to root for install
USER root

# Installation of debian-deps:latest #[and curl from debian-curl:latest]
# procps is very common in build systems, and is a reasonably small package
RUN apt-get update && apt-get upgrade -y \
	&& apt-get install -y --no-install-recommends \
		curl \
		bzr \
		git \
		mercurial \
		openssh-client \
		subversion \
		\
		procps \
	&& rm -rf /var/lib/apt/lists/*
	
# Install lapack and blas
RUN apt-get update && apt-get upgrade -y \
	&& apt-get install -y \
	libatlas-base-dev \
	#libjpeg62-dev \
	libfreetype6 \
	libpng12-dev \
	libagg-dev \
	pkg-config \
	gfortran \
	\
	libopenblas-dev \
	liblapack-dev \
	libzmq-dev \	
	\
	libreadline-gplv2-dev \
	libncursesw5-dev \
	libssl-dev \
	libsqlite3-dev \
	tk-dev \
	libgdbm-dev \
	libc6-dev \
	libbz2-dev \
	libhdf5-dev \
	libpq-dev \
	#libcupti-dev \
	--no-install-recommends \
	&& rm -rf /var/lib/apt/lists/*

# remove several traces of debian python
RUN apt-get purge -y python.*

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8

# # gpg: key F73C700D: public key "Larry Hastings <larry@hastings.org>" imported
# ENV GPG_KEY 97FC712E4C024BBEA48A61ED3A5CA953F73C700D

# ENV PYTHON_VERSION 3.5.1

# # if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
# ENV PYTHON_PIP_VERSION 7.1.2

ENV GPG_KEY 0D96DF4D4110E5C43FBFB17F2D347EA6AA65421D
ENV PYTHON_VERSION 3.6.0

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 9.0.1

RUN set -ex \
	&& gpg --keyserver ha.pool.sks-keyservers.net --recv-keys "$GPG_KEY" \
	&& curl -fSL "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz" -o python.tar.xz \
	&& curl -fSL "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" -o python.tar.xz.asc \
	&& gpg --verify python.tar.xz.asc \
	&& mkdir -p /usr/src/python \
	&& tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz \
	&& rm python.tar.xz* \
	&& rm -r ~/.gnupg \
	\
	&& cd /usr/src/python \
	&& ./configure --enable-shared --enable-unicode=ucs4 \
	&& make -j$(nproc) \
	&& make install \
	&& ldconfig \
	&& pip3 install --no-cache-dir --upgrade --ignore-installed pip==$PYTHON_PIP_VERSION \
	&& find /usr/local \
		\( -type d -a -name test -o -name tests \) \
		-o \( -type f -a -name '*.pyc' -o -name '*.pyo' \) \
		-exec rm -rf '{}' + \
	&& rm -rf /usr/src/python

# make some useful symlinks that are expected to exist
RUN cd /usr/local/bin \
	&& ln -s easy_install-3.5 easy_install \
	&& ln -s idle3 idle \
	&& ln -s pydoc3 pydoc \
	&& ln -s python3 python \
	&& ln -s python-config3 python-config
	
# Install python packages using pip3
# setuptools, numpy and scipy must be installed prior to other installations
#RUN pip3 install --upgrade pip \ #comment out to update pip3 to the newest version
RUN pip3 install --no-cache-dir \
		#distlib \ #generates an error
		setuptools \
		numpy \
		scipy \
		cython \
	&&pip3 install --upgrade

# Install python packages using pip3
RUN pip3 install --no-cache-dir \
		html5lib \
		urllib3 \
		matplotlib \
		ipython \
		ipywidgets \
		notebook \
		pandas \
		sympy \
		nose \
		h5py \
		biopython \
		six \
		tornado \
		jinja2 \
		sqlalchemy \
		psycopg2 \
		distlib \
		pykg-config \
		pyzmq \
		pytz \
		rpy2 \
		#scikit-bio \
		scikit-image \
		scikit-learn \
		scikit-neuralnetwork \
		statsmodels \
		pysam \
		#htseq  \#not yet supported on python3
		pytest \
		pytest_benchmark \
		sphinx \
		swiglpk \
		optlang \
	&&pip3 install --upgrade

# Cleanup
RUN apt-get clean

# create a python user
#ENV HOME /home/user
#RUN useradd --create-home --home-dir $HOME user \
#    && chmod -R u+rwx $HOME \
#    && chown -R user:user $HOME

# switch back to user
WORKDIR $HOME
USER user

# set the command
CMD ["python3"]
