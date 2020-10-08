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
