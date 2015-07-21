# Dockerfile to build python3 images for scientific computing
# Based on Ubuntu

# Set the base image to Ubuntu
FROM ubuntu:latest

# Add python and r_base to the base image
FROM python:latest
FROM dmccloskey/r-base:latest

USER root

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
RUN pip3 install --no-cache-dir scikit-bio
RUN pip3 install --no-cache-dir scikit-image
RUN pip3 install --no-cache-dir scikit-learn
RUN pip3 install --no-cache-dir pysam
#RUN pip3 install --no-cache-dir htseq #not yet supported on python3
RUN pip3 install --upgrade

# Cleanup
RUN apt-get clean

# create a python user
ENV HOME /home/user
RUN useradd --create-home --home-dir $HOME user \
    && chmod -R u+rwx $HOME \
    && chown -R user:user $HOME

WORKDIR $HOME
USER user

# set the command
CMD ["python3"]
