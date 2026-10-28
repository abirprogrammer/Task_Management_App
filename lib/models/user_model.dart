class UserModel {
  final int id;
  final String name;
  final String email;
  final String address;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.address,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];

    final int parsedId = rawId is int
        ? rawId
        : int.tryParse(rawId?.toString() ?? '') ?? 0;

    return UserModel(
      id: parsedId,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'address': address,
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? address,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      address: address ?? this.address,
    );
  }
}
