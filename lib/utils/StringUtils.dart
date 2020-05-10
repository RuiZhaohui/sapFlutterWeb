class StringUtils {

  static bool isBank(String s) {
    if (null == s) return true;
    if (s.length == 0) return true;
    return false;
  }

  static bool isNotBank(String s) {
    if (null == s) return false;
    if (s.length == 0) return false;
    return true;
  }
}