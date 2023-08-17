import 'package:bookingmanager/product/models/session_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/firebase/branch_manager.dart';
import '../../core/services/firebase/session_manager.dart';

final class ProviderManager {
  ProviderManager._();

  static final ProviderContainer ref = ProviderContainer();

  static ChangeNotifierProvider<BranchManager>? _branchManager;
  static StateNotifierProvider<SessionManager, List<SessionModel>>?
      _sessionManager;

  static ChangeNotifierProvider<BranchManager> get branchManagerProvider =>
      _branchManager!;
  static BranchManager get branchManager =>
      ref.read<BranchManager>(branchManagerProvider);

  static StateNotifierProvider<SessionManager, List<SessionModel>>
      get sessionManagerProvider => _sessionManager!;
  static SessionManager get sessionManager =>
      ref.read<SessionManager>(sessionManagerProvider.notifier);
  static StateProvider<bool> sessionsFetching =
      StateProvider<bool>((ref) => false);

  static void initAll() {
    _sessionManager = StateNotifierProvider<SessionManager, List<SessionModel>>(
        (ref) => SessionManager());
    _branchManager =
        ChangeNotifierProvider<BranchManager>((ref) => BranchManager());
  }

  static disposeAll() {
    ref.read(sessionManagerProvider.notifier).dispose();
    ref.read(branchManagerProvider).dispose();
  }
}
