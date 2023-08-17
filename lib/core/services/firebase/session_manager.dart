import 'dart:async';

import 'package:bookingmanager/core/services/firebase/auth/auth_service.dart';
import 'package:bookingmanager/core/services/localization/locale_keys.g.dart';
import 'package:bookingmanager/product/models/branch_model.dart';
import 'package:bookingmanager/product/models/session_model.dart';
import 'package:bookingmanager/product/providers/provider_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SessionManager extends StateNotifier<List<SessionModel>> {
  SessionManager() : super([]);
  StreamSubscription<QuerySnapshot>? appointmentsListener;

  @override
  void dispose() {
    appointmentsListener?.cancel();
    appointmentsListener = null;
    if (mounted) {
      state = [];
    }
    super.dispose();
  }

  void toggleListener({
    required DateTime dayBeginning,
    required DateTime dayEnding,
    required String branchUid,
  }) {
    ProviderManager.ref.read(ProviderManager.sessionsFetching.notifier).state =
        true;
    appointmentsListener?.cancel();
    appointmentsListener = FirebaseFirestore.instance
        .collection("branches/$branchUid/sessions")
        .where("startTime",
            isGreaterThanOrEqualTo: dayBeginning.millisecondsSinceEpoch,
            isLessThanOrEqualTo: dayEnding.millisecondsSinceEpoch)
        .snapshots()
        .listen((event) {
      if (event.docs.isEmpty) {
        state = [];
        return;
      }
      // fetch new appointments
      final newSessions =
          event.docs.map((e) => SessionModel.fromMap(e.data())).toList();
      // remove old appointments at the same uid
      for (var element in newSessions) {
        state.removeWhere((element2) => element2.uid == element.uid);
      }
      // add new appointments
      state.addAll(newSessions);

      // sort appointments by start time
      state.sort((a, b) => a.startTime.compareTo(b.startTime));

      // remove all other days
      state.removeWhere((element) =>
          element.startTime.day != dayBeginning.day ||
          element.startTime.month != dayBeginning.month ||
          element.startTime.year != dayBeginning.year);

      // notify listeners
      state = [...state];
    });
    appointmentsListener!.asFuture().then((value) {
      ProviderManager.ref
          .read(ProviderManager.sessionsFetching.notifier)
          .state = true;
    });
  }

  Future<void> setSession({
    required BranchModel branchModel,
    required String name,
    required int personCount,
    required List<String> branchServicesUids,
    required DateTime startTime,
    required int durationInMinute,
    num? discount,
    num? extra,
    String? notes,
    String? phone,
    String? uid,
    String? assignedTo,
  }) async {
    try {
      final endTime = startTime.add(Duration(minutes: durationInMinute));
      if (startTime.hour < branchModel.startHour ||
          endTime.hour > branchModel.endHour) {
        throw ErrorDescription(
            LocaleKeys.session_manager_session_time_error.tr());
      }

      final docRef = FirebaseFirestore.instance
          .collection("branches/${branchModel.uid}/sessions")
          .doc(uid);

      final serviceTotal = branchServicesUids.fold(
        0.0,
        (previousValue, element) {
          final service = branchModel.branchServices.firstWhere(
            (element2) => element2.uid == element,
          );
          return previousValue + service.price;
        },
      );

      final total = branchModel.pricePerPerson * personCount +
          serviceTotal +
          (extra ?? 0) -
          (discount ?? 0);
      SessionModel session = SessionModel(
        lastModifiedByUid: AuthService.instance.userModel!.uid,
        branchUid: branchModel.uid,
        name: name,
        branchServicesUids: List.from(branchServicesUids).cast<String>(),
        startTime: startTime,
        durationInMs: durationInMinute * 60000,
        discount: discount,
        extra: extra,
        notes: notes,
        phone: phone,
        personCount: personCount,
        uid: uid ?? docRef.id,
        assignedTo: assignedTo,
        total: total,
        serviceTotal: serviceTotal,
        endTime: endTime,
      );
      await docRef.set(session.toMap());
    } catch (e) {
      throw ErrorDescription(e.toString());
    }
  }

  Future<void> updateSession(SessionModel session) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection("branches/${session.branchUid}/sessions")
          .doc(session.uid);
      await docRef.update(session.toMap());
    } catch (e) {
      // throw ErrorDescription("Seans güncellenirken bir hata oluştu.\n$e");
      throw ErrorDescription(
          LocaleKeys.session_manager_session_update_error.tr());
    }
  }

  Future<void> deleteSession(String uid) async {
    try {
      final docRef = FirebaseFirestore.instance
          .collection("branches/${state.first.branchUid}/sessions")
          .doc(uid);
      await docRef.delete();
    } catch (e) {
      // throw ErrorDescription("Seans silinirken bir hata oluştu.\n$e");
      throw ErrorDescription(
          LocaleKeys.session_manager_session_delete_error.tr());
    }
  }
}
