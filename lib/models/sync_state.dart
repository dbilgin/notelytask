import 'package:equatable/equatable.dart';

class SyncState extends Equatable {
  final bool loading;
  final bool error;
  final bool dirty;
  final String? message;

  const SyncState({
    this.loading = false,
    this.error = false,
    this.dirty = false,
    this.message,
  });

  bool get isConnected => !error;

  SyncState copyWith({
    bool? loading,
    bool? error,
    bool? dirty,
    String? message,
    bool clearMessage = false,
  }) {
    return SyncState(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      dirty: dirty ?? this.dirty,
      message: clearMessage ? null : message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [
        loading,
        error,
        dirty,
        message,
      ];
}
