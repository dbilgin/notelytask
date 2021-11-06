import 'package:equatable/equatable.dart';

class GithubState extends Equatable {
  final String? ownerRepo;
  final String? accessToken;
  final String? sha;

  final String? deviceCode;
  final String? userCode;
  final String? verificationUri;
  final int? expiresIn;

  GithubState({
    this.ownerRepo,
    this.accessToken,
    this.sha,
    this.deviceCode,
    this.userCode,
    this.verificationUri,
    this.expiresIn,
  });

  factory GithubState.fromJson(Map<String, dynamic> json) {
    return GithubState(
      ownerRepo: json['ownerRepo'] as String?,
      accessToken: json['accessToken'] as String?,
      sha: json['sha'] as String?,
      deviceCode: json['deviceCode'] as String?,
      userCode: json['userCode'] as String?,
      verificationUri: json['verificationUri'] as String?,
      expiresIn: json['expiresIn'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'ownerRepo': ownerRepo,
        'accessToken': accessToken,
        'sha': sha,
        'deviceCode': deviceCode,
        'userCode': userCode,
        'verificationUri': verificationUri,
        'expiresIn': expiresIn,
      };

  GithubState copyWith({
    String? ownerRepo,
    String? accessToken,
    String? sha,
    String? deviceCode,
    String? userCode,
    String? verificationUri,
    int? expiresIn,
  }) {
    return GithubState(
      ownerRepo: ownerRepo ?? this.ownerRepo,
      accessToken: accessToken ?? this.accessToken,
      sha: sha ?? this.sha,
      deviceCode: deviceCode ?? this.deviceCode,
      userCode: userCode ?? this.userCode,
      verificationUri: verificationUri ?? this.verificationUri,
      expiresIn: expiresIn ?? this.expiresIn,
    );
  }

  @override
  List<Object?> get props => [
        ownerRepo,
        accessToken,
        sha,
        deviceCode,
        userCode,
        verificationUri,
        expiresIn,
      ];
}
