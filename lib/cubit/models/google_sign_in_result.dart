import 'dart:convert';

import 'package:equatable/equatable.dart';

class GoogleSignInResult extends Equatable {
  final String accessToken;
  final String idToken;
  const GoogleSignInResult({
    required this.accessToken,
    required this.idToken,
  });

  GoogleSignInResult copyWith({
    String? accessToken,
    String? idToken,
  }) {
    return GoogleSignInResult(
      accessToken: accessToken ?? this.accessToken,
      idToken: idToken ?? this.idToken,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'accessToken': accessToken,
      'idToken': idToken,
    };
  }

  factory GoogleSignInResult.fromMap(Map<String, dynamic> map) {
    return GoogleSignInResult(
      accessToken: map['accessToken'] as String,
      idToken: map['idToken'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory GoogleSignInResult.fromJson(String source) =>
      GoogleSignInResult.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  List<Object?> get props => [accessToken, idToken];
}
