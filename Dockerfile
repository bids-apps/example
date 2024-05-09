FROM bids/base_fsl:6.0.1@sha256:b92b9b4a0642dfbe011c3827384f781ba7d377686e82edaf14f406d3eb906783

ARG DEBIAN_FRONTEND="noninteractive"

COPY requirements.txt /requirements.txt

RUN apt-get update -qq && \
    apt-get install -q -y --no-install-recommends \
        python3 \
        python3-pip && \
    pip3 install -r /requirements.txt && \
    apt-get remove -y python3-pip && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV PYTHONPATH=""

COPY run.py /run.py

COPY version /version

ENTRYPOINT ["/run.py"]
