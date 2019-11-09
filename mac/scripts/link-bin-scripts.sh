#!/usr/bin/env bash

find $(pwd)/misc-bin-scripts -type f -exec ln -sf {} /usr/local/bin/ \;
