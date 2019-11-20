#!/usr/bin/env bash
if [[ "$OSTYPE" == "linux-gnu" ]]; then
    echo 'Not implemented yet'
elif [[ "$OSTYPE" == "darwin"* ]]; then
    # Mac OSX
    sh mac/runner.sh
elif [[ "$OSTYPE" == "cygwin" ]]; then
    # POSIX compatibility layer and Linux environment emulation for Windows
    echo 'Not implemented yet'
elif [[ "$OSTYPE" == "msys" ]]; then
    # Lightweight shell and GNU utilities compiled for Windows (part of MinGW)
    echo 'Not implemented yet'
elif [[ "$OSTYPE" == "win32" ]]; then
    # I'm not sure this can happen.
    echo 'Not implemented yet'
elif [[ "$OSTYPE" == "freebsd"* ]]; then
    # ...
    echo 'Not implemented yet'
else
    echo "Unkown os $OSTYPE"
fi