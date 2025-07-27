extension ListExtensions on List {
  List<List<T>> reshape<T>(List<int> shape) {
    if (shape.length != 2) {
      throw ArgumentError('Only 2D reshape is supported');
    }
    
    final rows = shape[0];
    final cols = shape[1];
    
    if (length != rows * cols) {
      throw ArgumentError('Cannot reshape list of length $length to $shape');
    }
    
    final result = <List<T>>[];
    for (int i = 0; i < rows; i++) {
      final row = <T>[];
      for (int j = 0; j < cols; j++) {
        row.add(this[i * cols + j] as T);
      }
      result.add(row);
    }
    
    return result;
  }
}