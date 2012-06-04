---
title: Building Mapnik using PIP
author: Donald Ephraim Curtis
tags: linux
---
I wanted to install mapnik on Mac OSX using [homebrew](http://github.com/mxcl/homebrew), but I wanted to install the Python module in my local virtualenv.  So I needed to set a few settings before running `pip`.

1. use homebrew to install mapnik2
2. fix the boost python library name
3. pass `LDFLAGS` to pip

<!-- break -->

    brew install mapnik
    export MAPNIK2_BOOST_PYTHON="libboost_python-mt.dylib"
    LDFLAGS="-L/usr/X11/lib" pip install mapnik2
