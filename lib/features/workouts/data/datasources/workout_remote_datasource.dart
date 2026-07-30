import 'dart:convert';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/storage/local_storage.dart';
import '../../../../core/utils/logger.dart';
import '../models/workout_models.dart';

/// Remote data source for workout endpoints.
class WorkoutRemoteDataSource {
  final DioClient _dioClient;
  final LocalStorage _localStorage;

  const WorkoutRemoteDataSource(this._dioClient, this._localStorage);

  Future<List<WorkoutAssignmentModel>> getWorkouts() async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.workouts,
    );
    final data = response.data!;
    final list = data['data'] as List<dynamic>? ?? [];
    final models = list
        .map((e) => WorkoutAssignmentModel.fromJson(e as Map<String, dynamic>))
        .toList();

    // Cache
    await _localStorage.setString(AppConstants.workoutsBox, jsonEncode(list));
    return models;
  }

  Future<WorkoutAssignmentModel> getWorkoutDetail(int assignmentId) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.workoutDetail(assignmentId),
    );
    final data = response.data!;
    final payload = data['data'] as Map<String, dynamic>? ?? data;
    return WorkoutAssignmentModel.fromJson(payload);
  }

  Future<WorkoutSessionModel> startWorkout(int assignmentId) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      ApiConstants.startWorkout(assignmentId),
    );
    final data = response.data!;
    final payload = data['data'] as Map<String, dynamic>? ?? data;
    return WorkoutSessionModel.fromJson(payload);
  }

  Future<WorkoutSessionModel?> getCurrentSession() async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.currentWorkout,
    );
    final data = response.data!;
    final payload = data['data'];
    if (payload == null) return null;
    return WorkoutSessionModel.fromJson(payload as Map<String, dynamic>);
  }

  Future<WorkoutSessionModel?> getWorkoutSession(int assignmentId) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.workoutSession(assignmentId),
    );
    final data = response.data!;
    final payload = data['data'];
    if (payload == null) return null;
    return WorkoutSessionModel.fromJson(payload as Map<String, dynamic>);
  }

  Future<void> completeSet({
    required int sessionId,
    required int setId,
    required int reps,
    required double weight,
    int? duration,
  }) async {
    final body = <String, dynamic>{'reps': reps, 'weight': weight};
    if (duration != null) body['duration'] = duration;
    await _dioClient.post<void>(
      ApiConstants.completeSet(sessionId, setId),
      data: body,
    );
  }

  Future<WorkoutSessionModel> finishWorkout(int sessionId) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      ApiConstants.finishWorkout(sessionId),
    );
    final data = response.data!;
    final payload = data['data'] as Map<String, dynamic>? ?? data;
    return WorkoutSessionModel.fromJson(payload);
  }

  Future<List<WorkoutHistoryModel>> getWorkoutHistory() async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiConstants.workoutHistory,
    );
    final data = response.data!;
    final list = data['data'] as List<dynamic>? ?? [];
    return list
        .map((e) => WorkoutHistoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  List<WorkoutAssignmentModel>? getCachedWorkouts() {
    try {
      final raw = _localStorage.getString(AppConstants.workoutsBox);
      if (raw == null) return null;
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map(
            (e) => WorkoutAssignmentModel.fromJson(e as Map<String, dynamic>),
          )
          .toList();
    } catch (e) {
      AppLogger.warning('Failed to read cached workouts', error: e);
      return null;
    }
  }
}
