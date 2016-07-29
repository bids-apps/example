FROM ubuntu:16.04

RUN apt-get update \
    && apt-get install -y wget
RUN wget -O /etc/apt/sources.list.d/neurodebian.sources.list http://neuro.debian.net/lists/xenial.us-ca.full
RUN apt-key adv --recv-keys --keyserver hkp://pgp.mit.edu:80 0xA5D32F012649A5A9

# Run apt-get calls
RUN apt-get update \
    && apt-get install -y fsl-5.0-core

# Configure environment
ENV FSLDIR=/usr/share/fsl/5.0
ENV FSLOUTPUTTYPE=NIFTI_GZ
ENV PATH=/usr/lib/fsl/5.0:$PATH
ENV FSLMULTIFILEQUIT=TRUE
ENV POSSUMDIR=/usr/share/fsl/5.0
ENV LD_LIBRARY_PATH=/usr/lib/fsl/5.0
ENV FSLTCLSH=/usr/bin/tclsh
ENV FSLWISH=/usr/bin/wish
ENV FSLOUTPUTTYPE=NIFTI_GZ

RUN apt-get install -y python3
RUN apt-get install -y python3-pip
RUN pip3 install nibabel
RUN mkdir -p /code

RUN mkdir /scratch
RUN mkdir /local-scratch
COPY run.py /code/run.py

ENTRYPOINT ["/code/run.py"]
