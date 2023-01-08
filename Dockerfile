FROM bids/base_fsl:6.0.1

ARG DEBIAN_FRONTEND="noninteractive"

# Install python, nibabel and numpy (nibabel>=2.1 requires python>=3.5, ubuntu trusty has only python 3.4)
RUN apt-get update -qq && \
    apt-get install -q -y --no-install-recommends \
        python3 \
        python3-pip \
        python3-numpy && \
    pip3 install nibabel==2.0 && \
    apt-get remove -y python3-pip && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV PYTHONPATH=""

COPY run.py /run.py

COPY version /version

ENTRYPOINT ["/run.py"]
