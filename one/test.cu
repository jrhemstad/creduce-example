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
}
