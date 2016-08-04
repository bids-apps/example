FROM ubuntu:16.04

# Enable NeuroDebian repository (if needed)
RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive \
       NEURODEBIAN_ENABLE=yes NEURODEBIAN_MIRROR=origin NEURODEBIAN_FLAVOR=full NEURODEBIAN_UPDATE=0 \
       apt-get install -y neurodebian

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

RUN mkdir /oasis
RUN mkdir /projects
RUN mkdir /scratch
RUN mkdir /local-scratch
COPY run.py /code/run.py

ENTRYPOINT ["/code/run.py"]
