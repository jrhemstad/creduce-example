#!/bin/bash
#export LIBCXX_SITE_CONFIG=/home/jhemstad/libcudacxx/build/libcxx/test/lit.site.cfg
#lit -sv /home/jhemstad/libcudacxx/test/std/utilities/time/time.cal/time.cal.ymwd/time.cal.ymwd.members/plus_minus_equal_year.pass.cpp  >out.txt 2>&1 &&\
#  grep 'internal compiler error' out.txt >/dev/null 2>&1

nvcc --std=c++14 test.cu 2>&1 | grep "error: expression must have a constant value" >/dev/null
