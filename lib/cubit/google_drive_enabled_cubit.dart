import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:notelytask/repository/google_drive_repo.dart';

class GoogleDriveEnabledCubit extends Cubit<bool> {
  GoogleDriveEnabledCubit({
    required GoogleDriveRepo googleDriveRepo,
  })   : _googleDriveRepo = googleDriveRepo,
        super(googleDriveRepo.isDriveUploadEnabled()) {
    _googleDriveRepo.listenDriveEnabled((value) => emit(value));
  }

  final GoogleDriveRepo _googleDriveRepo;

  void toggleriveStatus() async {
    var isEnabled = _googleDriveRepo.isDriveUploadEnabled();
    await _googleDriveRepo.setDriveUpload(!isEnabled);
    emit(!isEnabled);
  }
}
