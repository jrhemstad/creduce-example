#!/bin/bash

nvcc --std=c++14 test.cu 2>&1 | grep "error: expression must have a constant value" >/dev/null
