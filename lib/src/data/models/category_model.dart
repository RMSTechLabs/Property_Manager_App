// Category Model
class CategoryModel {
  final String id;
  final String categoryTitle;
  
  CategoryModel({required this.id, required this.categoryTitle});
  
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'].toString(),
      categoryTitle: json['category'] ?? '',
    );
  }
}