import 'dart:convert';

class SignedUser {
  String id;
  String name;
  String email;
  String imageUrl;
  String imageB64;
  SignedUser({
    required this.id,
    required this.name,
    required this.email,
    required this.imageUrl,
    required this.imageB64,
  });

  SignedUser copyWith({
    String? id,
    String? name,
    String? email,
    String? imageUrl,
    String? imageB64,
  }) {
    return SignedUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      imageUrl: imageUrl ?? this.imageUrl,
      imageB64: imageB64 ?? this.imageB64,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'imageUrl': imageUrl,
      'imageB64': imageB64,
    };
  }

  factory SignedUser.fromMap(Map<String, dynamic> map) {
    return SignedUser(
      id: map['id'] as String,
      name: map['name'] as String,
      email: map['email'] as String,
      imageUrl: map['imageUrl'] as String,
      imageB64: map['imageB64'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory SignedUser.fromJson(String source) =>
      SignedUser.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'SignedUser(id: $id, name: $name, email: $email, imageUrl: $imageUrl, imageB64: $imageB64)';
  }

  @override
  bool operator ==(covariant SignedUser other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.name == name &&
        other.email == email &&
        other.imageUrl == imageUrl &&
        other.imageB64 == imageB64;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        email.hashCode ^
        imageUrl.hashCode ^
        imageB64.hashCode;
  }
}
