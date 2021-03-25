import 'package:hydrated_bloc/hydrated_bloc.dart';

class DriveCubit extends Cubit<Map<String, String>?> {
  DriveCubit() : super(null);

  void setAuthHeaders(Map<String, String>? authHeaders) {
    emit(authHeaders);
  }
}
