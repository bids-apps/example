FROM bids/base_fsl:6.0.1

ARG DEBIAN_FRONTEND="noninteractive"


RUN apt-get update -qq && \
    apt-get install -q -y --no-install-recommends \
        python3 \
        python3-pip && \
    pip3 install nibabel==5.1.0 && \
    apt-get remove -y python3-pip && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV PYTHONPATH=""

COPY run.py /run.py

COPY version /version

ENTRYPOINT ["/run.py"]
