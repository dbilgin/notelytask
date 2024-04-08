import 'package:equatable/equatable.dart';

class RemoteConnectionResult extends Equatable {
  final String? content;
  final bool shouldCreateRemote;

  const RemoteConnectionResult({
    this.content,
    this.shouldCreateRemote = false,
  });

  @override
  List<Object?> get props => [content, shouldCreateRemote];
}
