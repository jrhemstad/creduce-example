#! /bin/bash

# Return 0 if "interesting" (i.e., reproduces desired condition), non-zero otherwise

SCRIPT_PATH=$(cd $(dirname ${0}); pwd -P)

TEST=test
TEST_VARIANT=1
TEST_SUFFIX=cu
#TEST_SOURCE=${PWD}/${TEST}__${TEST_VARIANT}.${TEST_SUFFIX}
TEST_SOURCE=${PWD}/${TEST}.${TEST_SUFFIX}

NVCC=/usr/local/cuda/bin/nvcc
HOST_COMPILER=g++

DIAGNOSTIC=$(${NVCC} --std=c++14 -ccbin ${HOST_COMPILER} -c ${TEST_SOURCE} -o /dev/null 2>&1)
if [ ${?} -eq 0 ]; then exit 1; fi

echo ${DIAGNOSTIC} | grep 'error: expression must have a constant value' > /dev/null
if [ ${?} -ne 0 ]; then exit 1; fi

# "-x c++"" is required because g++ doesn't recognize the "*.cu" file extension
${HOST_COMPILER} -x c++ --std=c++14 ${TEST_SOURCE} -o /dev/null > /dev/null 2>&1

exit ${?}
