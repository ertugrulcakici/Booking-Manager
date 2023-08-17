extension ListExtensionsForList on List {
  List<T> addConditionally<T>(
      {required bool Function() condition, required dynamic Function() value}) {
    if (condition() == true) {
      add(value());
    }
    return cast<T>();
  }
}
