class UserModel {
  final int id;
  final String name;
  final String email;
  final String address;
  final String? profileImage;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.address,
    this.profileImage,
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
      profileImage: json['profile_image']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'address': address,
      'profile_image': profileImage,
    };
  }

  UserModel copyWith({
    int? id,
    String? name,
    String? email,
    String? address,
    String? profileImage,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      address: address ?? this.address,
      profileImage: profileImage ?? this.profileImage,
    );
  }
}
