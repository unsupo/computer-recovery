#!/usr/bin/env bash

find $(pwd)/bin-scripts -type f -exec ln -sf {} /usr/local/bin/ \;
