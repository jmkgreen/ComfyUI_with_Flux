#!/bin/bash

cd /workspace && \
    git clone https://github.com/thu-ml/SageAttention.git && \
    cd SageAttention && \
    export EXT_PARALLEL=4 NVCC_APPEND_FLAGS="--threads 8" MAX_JOBS=32 # parallel compiling (Optional) && \
    python setup.py install  # or pip install -e .