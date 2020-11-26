FROM nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04

ARG APT_INSTALL="apt-get install -y --no-install-recommends"
## Python3
# Install python3
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive ${APT_INSTALL} \
        python3.7 \
        python3.7-dev \
        python3-distutils-extra \
        wget && \
    apt-get clean && \
    rm /var/lib/apt/lists/*_*

ENV DEBIAN_FRONTEND=noninteractive
RUN apt-get update
RUN apt-get install -y nano git

# Link python to python3
RUN ln -s /usr/bin/python3.7 /usr/local/bin/python3 && \
    ln -s /usr/bin/python3.7 /usr/local/bin/python

# Setuptools
RUN wget https://bootstrap.pypa.io/get-pip.py
RUN python get-pip.py
RUN rm get-pip.py

## Locale
ENV LANG C.UTF-8
ENV LC_ALL C.UTF-8

WORKDIR /root
RUN git clone https://github.com/dartrevan/NLPDatasetIO.git
WORKDIR /root/NLPDatasetIO
RUN pip install .

ADD ./ /root/pipeline_entity_linker
WORKDIR /root/pipeline_entity_linker
RUN pip install -r requirements.txt
RUN python -c "import nltk; nltk.download('punkt')"
CMD run.sh
