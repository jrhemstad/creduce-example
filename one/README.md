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

## Second Attempt

## Final Attempt



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

