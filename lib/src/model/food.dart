enum FoodType { all, sushi, kebab, tempura, ramen, burger }

class Food {
  String image;
  String name;
  double price;
  int quantity;
  bool isFavorite;
  String description;
  double score;
  FoodType type;
  int voter;

  Food(
    this.image,
    this.name,
    this.price,
    this.quantity,
    this.isFavorite,
    this.description,
    this.score,
    this.type,
    this.voter,
  );
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'image': image,
      'price': price,
      'quantity': quantity,
      'isFavorite': isFavorite,
      'score': score,
      'type': type.toString().split('.').last,
      'voter': voter,
    };
  }

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      json['image'],
      json['name'],
      json['price'],
      json['quantity'],
      json['isFavorite'],
      json['description'],
      json['score'],
      FoodType.sushi,
      json['voter'],
    );
  }
}
