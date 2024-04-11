import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:notelytask/models/google_drive_state.dart';
import 'package:notelytask/repository/google_drive_repository.dart';

class GoogleDriveCubit extends HydratedCubit<GoogleDriveState> {
  GoogleDriveCubit({
    required this.googleDriveRepository,
  }) : super(const GoogleDriveState());
  final GoogleDriveRepository googleDriveRepository;

  Future<bool> getTokens() async {
    reset();
    emit(state.copyWith(loading: true));

    final signInData = await googleDriveRepository.signIn();
    if (signInData == null) {
      reset(shouldError: true);
      return false;
    }

    final accessToken = signInData.accessToken;
    final idToken = signInData.idToken;

    emit(
      state.copyWith(
        accessToken: accessToken,
        idToken: idToken,
      ),
    );
    emit(state.copyWith(loading: false));
    return true;
  }

  Future<bool> signOut() async {
    emit(state.copyWith(loading: true));
    final signedOut = await googleDriveRepository.signOut();
    if (signedOut) {
      reset();
    }

    emit(state.copyWith(loading: false));
    return signedOut;
  }

  void reset({bool shouldError = false}) {
    emit(const GoogleDriveState());
    emit(
      state.copyWith(
        loading: false,
        error: shouldError,
        accessToken: null,
        idToken: null,
      ),
    );
  }

  void invalidateError() {
    emit(state.copyWith(error: false));
  }

  @override
  GoogleDriveState fromJson(Map<String, dynamic> json) {
    return GoogleDriveState.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(GoogleDriveState state) {
    return state.toJson();
  }
}
