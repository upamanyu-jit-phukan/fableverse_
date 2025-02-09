class Product {
  final String id;
  final String imagePath;
  final String cost;
  final String title;
  final String description;
  final bool isAdded;

  Product({
    required this.id,
    required this.imagePath,
    required this.cost,
    required this.title,
    required this.description,
    this.isAdded = false,
  });
   Map<String, dynamic> toMap() {
    return {
      'id': id,
      'imagePath': imagePath,
      'cost': cost,
      'title': title,
      'description': description,
      'isAdded': isAdded,
    };


}
}
