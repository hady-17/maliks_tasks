import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/profileModel.dart';
import 'package:supabase/supabase.dart';
import 'package:flutter/material.dart';

class ProfilesRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<List<Profile>> getInactiveProfiles() async {
    final response = await _supabase
        .from('profiles')
        .select()
        .eq('active', false)
        .order('created_at', ascending: false);

    return response.map<Profile>((json) => Profile.fromJson(json)).toList();
  }

  /// Stream of inactive profiles (live updates)
  Stream<List<Profile>> streamInactiveProfiles() {
    return _supabase
        .from('profiles')
        .stream(primaryKey: ['id'])
        .eq('active', false)
        .map<List<Profile>>((event) {
          // event is usually a List of records
          final list = (event as List).cast<Map<String, dynamic>>();
          return list.map((json) => Profile.fromJson(json)).toList();
        });
  }

  Future<void> activateUser(String userId) async {
    await _supabase.from('profiles').update({'active': true}).eq('id', userId);
  }
}

class ProfilesViewModel extends ChangeNotifier {
  final ProfilesRepository _repository;

  ProfilesViewModel(this._repository);

  bool isLoading = false;
  String? error;
  List<Profile> inactiveProfiles = [];

  Future<void> fetchInactiveProfiles() async {
    try {
      isLoading = true;
      notifyListeners();

      inactiveProfiles = await _repository.getInactiveProfiles();
      error = null;
    } catch (e) {
      error = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
