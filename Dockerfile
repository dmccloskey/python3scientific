# Dockerfile to build python3 images for scientific computing

# Set r_base to the base image
FROM dmccloskey/r-base:latest

# File Author / Maintainer
MAINTAINER Douglas McCloskey <dmccloskey87@gmail.com>

# switch to root for install
USER root

## Comment out 'APT::Default-Release "testing"' from latest R installation
RUN echo '#APT::Default-Release "testing";' > /etc/apt/apt.conf.d/default

## Installation of debian-curl:latest
#RUN apt-get update && apt-get upgrade -y \
#	&& apt-get install -y --no-install-recommends \
#		ca-certificates \
#		curl \
#		wget \
#	&& rm -rf /var/lib/apt/lists/*

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

## From the official python docker image for Python 3.5:
##------------------------------------------------------

# remove several traces of debian python
RUN apt-get purge -y python.*

# http://bugs.python.org/issue19846
# > At the moment, setting "LANG=C" on a Linux system *fundamentally breaks Python 3*, and that's not OK.
ENV LANG C.UTF-8

# gpg: key F73C700D: public key "Larry Hastings <larry@hastings.org>" imported
ENV GPG_KEY 97FC712E4C024BBEA48A61ED3A5CA953F73C700D

ENV PYTHON_VERSION 3.5.1

# if this is called "PIP_VERSION", pip explodes with "ValueError: invalid truth value '<VERSION>'"
ENV PYTHON_PIP_VERSION 7.1.2

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
##------------------------------------------------------

# Install lapack and blas
# Install python packages
RUN apt-get update && apt-get upgrade -y \
	#&& apt-get build-dep -y python3-matplotlib \
	&& apt-get install -y libatlas-base-dev \
	libjpeg8-dev \
	libfreetype6 \
	libpng12-dev \
	libagg-dev \
	pkg-config \
	gfortran \
	python3-dev \
	python3-distlib \
	python3-html5lib \
	python3-urllib3 \
	python3-setuptools \
	python3-numpy \
	python3-scipy \
	python3-matplotlib \
	ipython3 \
	ipython3-notebook \
	python3-pandas \
	python3-sympy \
	python3-nose \
	python3-h5py \
	python3-biopython \
	python3-six \
	python3-tornado \
	python3-jinja2 \
	python3-sqlalchemy \
	python3-psycopg2 \
	python3-pip
	
# Install python packages using pip3
RUN pip3 install --upgrade pip
RUN pip3 install --no-cache-dir pykg-config
RUN pip3 install --no-cache-dir pyzmq
RUN pip3 install --no-cache-dir pytz
RUN pip3 install --no-cache-dir rpy2
#RUN pip3 install --no-cache-dir scikit-bio
RUN pip3 install --no-cache-dir scikit-image
RUN pip3 install --no-cache-dir scikit-learn
RUN pip3 install --no-cache-dir pysam
#RUN pip3 install --no-cache-dir htseq #not yet supported on python3
RUN pip3 install --upgrade

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
