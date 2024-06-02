class PassSearchResult {
  final int passid;
  final String imageURL;
  final String title;
  final String cityNames;
  final String price;

  PassSearchResult({
    required this.passid,
    required this.imageURL,
    required this.title,
    required this.cityNames,
    required this.price,
  });

  factory PassSearchResult.fromJson(Map<String, dynamic> json) {
    return PassSearchResult(
      passid: json['passID'],
      imageURL: json['imageUrl'],
      title: json['title'],
      cityNames: json['cityNames'],
      price: json['price'],
    );
  }
}