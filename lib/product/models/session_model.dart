// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:bookingmanager/core/services/localization/locale_keys.g.dart';
import 'package:bookingmanager/product/models/branch_model.dart';
import 'package:bookingmanager/product/models/user_model.dart';
import 'package:bookingmanager/product/providers/provider_manager.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class SessionModel {
  final String uid;

  final String lastModifiedByUid;
  Future<UserModel?> get lastModifiedBy async =>
      await ProviderManager.branchManager
          .getBranchUser(branchUid: branchUid, userUid: lastModifiedByUid);

  final String? assignedTo;
  final String branchUid;
  BranchModel get branch => ProviderManager.branchManager.getBranch(branchUid)!;

  String? name;
  DateTime startTime;
  DateTime endTime;
  int durationInMs;
  int get durationInMinute => durationInMs ~/ 60000;

  int personCount;
  num total;
  num? extra;
  num? discount;
  String? phone;
  num serviceTotal;
  final List<String> branchServicesUids;
  String? notes;

  Future<String> get _subject async {
    String _ = "";
    if (name != null && name!.isNotEmpty) {
      _ += "${LocaleKeys.session_model_name.tr(args: [name!])}\n  ";
    }
    if (personCount > 0) {
      _ += "${LocaleKeys.session_model_person_count.tr(args: [
            personCount.toString()
          ])}\n";
    }
    if (phone != null && phone!.isNotEmpty) {
      _ += "${LocaleKeys.session_model_phone.tr(args: [phone!])}\n";
    }
    if (extra != null && extra! > 0) {
      _ += "${LocaleKeys.session_model_extra.tr(args: [extra.toString()])}\n";
    }
    if (discount != null && discount! > 0) {
      _ += "${LocaleKeys.session_model_discount.tr(args: [
            discount.toString()
          ])}\n";
    }
    if (notes != null && notes!.isNotEmpty) {
      _ += LocaleKeys.session_model_notes.tr(args: [notes!]);
    }
    if (assignedTo != null && assignedTo!.isNotEmpty) {
      UserModel assignedToUser =
          branch.users.firstWhere((element) => element.uid == assignedTo);
      _ += "${LocaleKeys.session_model_assigned_to.tr(args: [
            assignedToUser.displayName
          ])}\n";
    }

    final lastModifiedByUser = (await lastModifiedBy);
    _ += LocaleKeys.session_model_last_modified_by
        .tr(args: [lastModifiedByUser!.displayName]);

    return _;
  }

  SessionModel({
    required this.uid,
    required this.lastModifiedByUid,
    this.assignedTo,
    required this.branchUid,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.durationInMs,
    required this.personCount,
    required this.total,
    required this.extra,
    required this.discount,
    required this.phone,
    required this.serviceTotal,
    required this.branchServicesUids,
    required this.notes,
  });

  Future<Appointment> toAppointment() async {
    return Appointment(
      id: uid,
      startTime: startTime,
      endTime: startTime.add(Duration(milliseconds: durationInMs)),
      subject: await _subject,
      color: startTime.isAfter(DateTime.now())
          ? Colors.green
          : endTime.isAfter(DateTime.now())
              ? Colors.blue
              : Colors.red,
    );
  }

  SessionModel copyWith({
    String? uid,
    String? lastModifiedByUid,
    String? assignedTo,
    String? branchUid,
    String? name,
    DateTime? startTime,
    int? durationInMs,
    int? personCount,
    num? total,
    num? extra,
    num? discount,
    String? phone,
    num? serviceTotal,
    List<String>? branchServicesUids,
    String? notes,
    DateTime? endTime,
  }) {
    return SessionModel(
      uid: uid ?? this.uid,
      lastModifiedByUid: lastModifiedByUid ?? this.lastModifiedByUid,
      assignedTo: assignedTo ?? this.assignedTo,
      branchUid: branchUid ?? this.branchUid,
      name: name ?? this.name,
      startTime: startTime ?? this.startTime,
      durationInMs: durationInMs ?? this.durationInMs,
      personCount: personCount ?? this.personCount,
      total: total ?? this.total,
      extra: extra ?? this.extra,
      discount: discount ?? this.discount,
      phone: phone ?? this.phone,
      serviceTotal: serviceTotal ?? this.serviceTotal,
      branchServicesUids: branchServicesUids ?? this.branchServicesUids,
      notes: notes ?? this.notes,
      endTime: endTime ?? this.endTime,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'lastModifiedByUid': lastModifiedByUid,
      'assignedTo': assignedTo,
      'branchUid': branchUid,
      'name': name,
      'startTime': startTime.millisecondsSinceEpoch,
      'durationInMs': durationInMs,
      'personCount': personCount,
      'total': total,
      'extra': extra,
      'discount': discount,
      'phone': phone,
      'serviceTotal': serviceTotal,
      'branchServicesUids': branchServicesUids,
      'notes': notes,
      "endTime": endTime.millisecondsSinceEpoch,
    };
  }

  factory SessionModel.fromMap(Map<String, dynamic> map) {
    return SessionModel(
      uid: map['uid'] as String,
      lastModifiedByUid: map['lastModifiedByUid'] as String,
      assignedTo: map['assignedTo'] as String?,
      branchUid: map['branchUid'] as String,
      name: map['name'] as String?,
      startTime: DateTime.fromMillisecondsSinceEpoch(map['startTime'] as int),
      // startTime: (map['startTime'] as Timestamp).toDate(),
      durationInMs: map['durationInMs'] as int,
      personCount: map['personCount'] as int,
      total: map['total'] as num,
      extra: map['extra'] as num?,
      discount: map['discount'] as num?,
      phone: map['phone'] as String?,
      serviceTotal: map['serviceTotal'] as num,
      branchServicesUids:
          List<String>.from(map['branchServicesUids'].cast<String>()),
      notes: map['notes'] as String?,
      endTime: DateTime.fromMillisecondsSinceEpoch(map['endTime'] as int),
    );
  }
}
