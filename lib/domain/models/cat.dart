class Cat {
  final String id;
  final String url;
  final String breedName;
  final String breedDescription;
  final DateTime dateLiked;

  Cat({
    required this.id,
    required this.url,
    required this.breedName,
    required this.breedDescription,
    required this.dateLiked,
  });

  factory Cat.fromJson(Map<String, dynamic> json) {
    return Cat(
      id: json['id'] ?? '',
      url: json['url'] ?? '',
      breedName: json['breeds'][0]['name'] ?? '',
      breedDescription: json['breeds'][0]['description'] ?? '',
      dateLiked: DateTime.now(),
    );
  }
}
