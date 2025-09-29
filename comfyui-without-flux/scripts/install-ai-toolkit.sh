#!/usr/bin/env bash
echo "Installing ai-toolkit to /workspace/ai-toolkit"
cd /workspace && \
    git clone https://github.com/ostris/ai-toolkit.git && \
    cd ai-toolkit && \
    git submodule update --init --recursive && \
    pip3 install -r requirements.txt
echo "AI-Toolkit installed to /workspace/ai-toolkit"
