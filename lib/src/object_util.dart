class ObjectUtil {
  static bool isEmpty(Object object) {
    if (object == null) return true;
    if (object is String && object.isEmpty) {
      return true;
    } else if (object is List && object.isEmpty) {
      return true;
    } else if (object is Map && object.isEmpty) {
      return true;
    }
    return false;
  }

  static int getLength(Object object) {
    if (object == null) return 0;
    if (object is String) {
      return object.length;
    } else if (object is List) {
      return object.length;
    } else if (object is Map) {
      return object.length;
    } else {
      return 0;
    }
  }
}
