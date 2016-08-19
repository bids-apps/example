FROM ubuntu:16.04

# Common for all BIDS Apps

## Install the validator
RUN apt-get update && apt-get install -y curl
RUN curl -sL https://deb.nodesource.com/setup_4.x | bash -
RUN apt-get install -y nodejs
RUN npm install -g bids-validator

## Install strace
RUN apt-get install -y build-essential wget
RUN  wget "http://downloads.sourceforge.net/project/strace/strace/4.13/strace-4.13.tar.xz?r=https%3A%2F%2Fsourceforge.net%2Fprojects%2Fstrace%2F&ts=1471646564&use_mirror=pilotfiber" -O strace.tar.xz && \
	tar xvf strace.tar.xz && \
	cd strace-4.13 && \
	./configure &&\
	make &&\
	make install &&\
	rm -rf \strace-4.13

## Create copy the validation_and_provenance_wrapper wrapper
RUN mkdir -p /code
COPY validation_and_provenance_wrapper.sh /code/validation_and_provenance_wrapper.sh

# Specific to each BIDS App
## Install FSL
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
       NEURODEBIAN_ENABLE=yes NEURODEBIAN_MIRROR=origin NEURODEBIAN_FLAVOR=full NEURODEBIAN_UPDATE=0 \
       apt-get install -y neurodebian
RUN apt-get update \
    && apt-get install -y fsl-5.0-core

## Configure FSL
ENV FSLDIR=/usr/share/fsl/5.0
ENV FSLOUTPUTTYPE=NIFTI_GZ
ENV PATH=/usr/lib/fsl/5.0:$PATH
ENV FSLMULTIFILEQUIT=TRUE
ENV POSSUMDIR=/usr/share/fsl/5.0
ENV LD_LIBRARY_PATH=/usr/lib/fsl/5.0
ENV FSLTCLSH=/usr/bin/tclsh
ENV FSLWISH=/usr/bin/wish
ENV FSLOUTPUTTYPE=NIFTI_GZ

## Isntall nibabel
RUN apt-get install -y python3 python3-pip
RUN pip3 install nibabel

## Copy your entrypoint script
COPY run.py /code/run.py
RUN chmod +x /code/run.py

## Define
ENTRYPOINT ["/code/validation_and_provenance_wrapper.sh", "/code/run.py"]
