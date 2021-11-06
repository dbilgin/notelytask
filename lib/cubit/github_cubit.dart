import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:notelytask/models/github_state.dart';
import 'package:notelytask/repository/github_repository.dart';

class GithubCubit extends HydratedCubit<GithubState> {
  GithubCubit({required this.githubRepository}) : super(GithubState());
  final GithubRepository githubRepository;

  Future<void> setRepoUrl(String ownerRepo, bool keepLocal) async {
    emit(state.copyWith(ownerRepo: ownerRepo));
    var existingFile = githubRepository.getExistingNoteFile(
      ownerRepo,
      state.accessToken,
    );
  }

  void reset() {
    emit(GithubState());
  }

  void setSha(String sha) {
    emit(state.copyWith(sha: sha));
  }

  Future<void> launchLogin() async {
    var loginResult = await githubRepository.initialLogin();
    emit(
      state.copyWith(
        deviceCode: loginResult.deviceCode,
        userCode: loginResult.userCode,
        verificationUri: loginResult.verificationUri,
        expiresIn: loginResult.expiresIn,
      ),
    );
  }

  Future<void> getAccessToken(String deviceCode) async {
    emit(state.copyWith(
        accessToken: await githubRepository.getAccessToken(deviceCode)));
  }

  @override
  GithubState fromJson(Map<String, dynamic> json) {
    return GithubState.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(GithubState state) {
    return state.toJson();
  }
}
