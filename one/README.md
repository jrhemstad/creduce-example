# First Example

The first example is a piece of host-only code that fails with nvcc but succeeds with g++.
This usually means a bug in `nvcc` or EDG, or `nvcc`'s preprocessing is triggering a bug in g++.

This code was already manually reduced from a much larger reproducer. 

```c++
class weekday {
  private:
    unsigned char __wd;
  public:
    weekday() = default;
    inline explicit constexpr weekday(unsigned __val) noexcept 
      : __wd(static_cast<unsigned char>(__val == 7 ? 0 : __val)) {}
    inline constexpr unsigned c_encoding()   const noexcept { return __wd;  }
};

constexpr int operator-(const weekday& __lhs, const weekday& __rhs) noexcept
{
  const int __wdu = __lhs.c_encoding() - __rhs.c_encoding();
  const int __wk = (__wdu >= 0 ? __wdu : __wdu-6) / 7;
  return __wdu - __wk * 7;
}

int main(void){
  constexpr weekday w0{0};
  constexpr weekday w6{6};
  static_assert((w0 - w6) == 1, "");
```

Compiling this code with latest `nvcc` at the time of writing (11.1.0) generates the error message:
```
<source>(22): error: expression must have a constant value
<source>(16): note: value exceeds range of "int"
```

Compiling with any version of `g++` (requires C++14 support) succeeds without issue.

Live example: https://godbolt.org/z/T8dWvb

## First Attempt

For our first try, we know we want to try and reproduce the error message:

> error: expression must have a constant value

So lets make a script that compiles our test file and searches for that error text:

```bash
# test0.sh
#!/bin/bash
nvcc --std=c++14 test.cu 2>&1 | grep "error: expression must have a constant value" >/dev/null
```

We run it as:
```
creduce test0.sh test.cu
```

C-Reduce will run for a while and show us the minimized example that still produces our error message:

```c++
class weekday {
    weekday ( unsigned
    {
    constexpr weekday w6 {
    6
```

Unfortunately this isn't valid code. C-Reduce doesn't understand what valid C++ looks like. 
It will keep trying different modifications, and so long as your script returns `0`, it will keep going, regardless of if the code is valid or not.

If we try and actually compile this file, we see that it does indeed reproduce our error message:
```
./test.cu(3): error: expected a ")"

At end of source: error: expected a "}"

./test.cu(4): error: identifier "constexpr" is undefined

./test.cu(4): error: expected a ";"

At end of source: error: expected a "}"

At end of source: error: expected a ";"

6 errors detected in the compilation of "./test.cu".
```

## Second Attempt

So the first attempt didn't succeed because it generated invalid code. 

What if we try and exclude some of the errors we know aren't valid, e.g.,

```
# test1.sh
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
echo ${DIAGNOSTIC}

echo ${DIAGNOSTIC} | grep 'error: expected a ")"' > /dev/null
if [ ${?} -eq 0 ]; then exit 1; fi

echo ${DIAGNOSTIC} | grep 'error: expected a ";"' > /dev/null
if [ ${?} -eq 0 ]; then exit 1; fi

echo ${DIAGNOSTIC} | grep 'error: expected an operator' > /dev/null
if [ ${?} -eq 0 ]; then exit 1; fi

echo ${DIAGNOSTIC} | grep 'error: expected a "}"' > /dev/null
if [ ${?} -eq 0 ]; then exit 1; fi

echo ${DIAGNOSTIC} | grep 'error: expected a type specifier' > /dev/null
if [ ${?} -eq 0 ]; then exit 1; fi

echo ${DIAGNOSTIC} | egrep 'error: identifier ".*" is undefined' > /dev/null
if [ ${?} -eq 0 ]; then exit 1; fi

echo ${DIAGNOSTIC} | grep 'error: expected an identifier' > /dev/null
if [ ${?} -eq 0 ]; then exit 1; fi

echo ${DIAGNOSTIC} | grep 'error: expression must have a constant value' > /dev/null
exit ${?}
```

This script attempts to exclude common syntax errors as being "not interesting".

Once again, we get invalid code:
```c++
class weekday {
  weekday(unsigned);
} operator-() {
  constexpr weekday w0{0};
}
```

## Final Attempt

```
# test2.sh
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
```



```c++
class weekday {
  char __wd;

public:
  constexpr weekday(unsigned __val) : __wd(__val) {}
  constexpr unsigned c_encoding() { return __wd; }
};
constexpr int operator-(weekday, weekday __rhs) {
  int __wdu = -__rhs.c_encoding();
  return __wdu * 7;
}
main() {
  constexpr weekday w0{0};
  static_assert(w0 - 1, "");
}
```

