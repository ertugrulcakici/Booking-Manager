// ignore_for_file: unused_element

part of '../home_view.dart';

class _SetSessionDialog extends ConsumerStatefulWidget {
  final AutoDisposeChangeNotifierProvider<HomeNotifier> provider;
  final SessionModel? session;
  final DateTime selectedTime;
  final BranchModel branch;
  const _SetSessionDialog(
      {super.key,
      required this.provider,
      required this.selectedTime,
      this.session,
      required this.branch});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _SetSessionDialogState();
}

class _SetSessionDialogState extends ConsumerState<_SetSessionDialog>
    with WidgetsBindingObserver {
  final Map<String, dynamic> _formData = {
    "name": null,
    "personCount": null,
    "startTime": null,
    "phone": null,
    "durationInMinute": null,
    "extra": null,
    "discount": null,
    "notes": null,
    "assignedTo": null,
  };
  List<String> branchServicesUids = [];

  bool isKeyboardOpen = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    _formData["startTime"] = widget.selectedTime;
    if (widget.session != null) {
      _formData["name"] = widget.session?.name;
      _formData["personCount"] = widget.session?.personCount;
      _formData["phone"] = widget.session?.phone;
      _formData["durationInMinute"] = widget.session?.durationInMinute;
      _formData["extra"] = widget.session?.extra;
      _formData["discount"] = widget.session?.discount;
      _formData["notes"] = widget.session?.notes;
      _formData["assignedTo"] = widget.session?.assignedTo;
      for (var element in widget.session!.branchServicesUids) {
        branchServicesUids.add(element);
      }
    }
    super.initState();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    final bottomInset = View.of(context).viewInsets.bottom;
    setState(() {
      isKeyboardOpen = bottomInset > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _formData["name"] ?? "",
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                    labelText: LocaleKeys.commons_name_label.tr()),
                onSaved: (value) {
                  _formData["name"] = value?.trim();
                },
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return LocaleKeys.commons_enter_valid_number.tr();
                  }
                  try {
                    int.parse(value);
                  } catch (e) {
                    return LocaleKeys.commons_enter_valid_number.tr();
                  }
                  return null;
                },
                initialValue: (_formData["personCount"] as int?)?.toString() ??
                    widget.branch.defaultPersonCount.toString(),
                decoration: InputDecoration(
                    labelText:
                        LocaleKeys.set_session_dialog_person_count_label.tr()),
                onSaved: (value) {
                  _formData["personCount"] = int.parse(value!);
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //
                  TextButton.icon(
                      onPressed: () {
                        showDatePicker(
                                context: context,
                                initialDate: _formData["startTime"] as DateTime,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now()
                                    .add(const Duration(days: 365)))
                            .then((value) {
                          if (value != null) {
                            setState(() {
                              _formData["startTime"] =
                                  (_formData["startTime"] as DateTime).copyWith(
                                      year: value.year,
                                      month: value.month,
                                      day: value.day);
                            });
                          }
                        });
                      },
                      icon: const Icon(Icons.calendar_month),
                      label: Text(LocaleKeys.set_session_dialog_date.tr(args: [
                        (_formData["startTime"] as DateTime).formattedDate
                      ]))),
                  TextButton.icon(
                      onPressed: () {
                        showTimePicker(
                                context: context,
                                initialTime: TimeOfDay(
                                    hour: widget.session?.startTime.hour ??
                                        widget.selectedTime.hour,
                                    minute: widget.session?.startTime.minute ??
                                        widget.selectedTime.minute))
                            .then((value) {
                          if (value != null) {
                            setState(() {
                              _formData["startTime"] =
                                  (_formData["startTime"] as DateTime).copyWith(
                                      hour: value.hour,
                                      minute: value.minute,
                                      second: 0,
                                      millisecond: 0,
                                      microsecond: 0);
                            });
                          }
                        });
                      },
                      icon: const Icon(Icons.timer),
                      label: Text(
                        _formData["startTime"] == null
                            ? LocaleKeys.set_session_dialog_select_start_time
                                .tr(
                                args: [
                                  (_formData["startTime"] as DateTime)
                                      .formattedTime
                                ],
                              )
                            // : "Saat ${(_formData["startTime"] as DateTime).formattedTime}",
                            : LocaleKeys.set_session_dialog_time.tr(
                                args: [
                                  (_formData["startTime"] as DateTime)
                                      .formattedTime
                                ],
                              ),
                      )),
                ],
              ),
              TextFormField(
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return LocaleKeys.commons_enter_valid_number.tr();
                  }
                  try {
                    int.parse(value);
                  } catch (e) {
                    return LocaleKeys.commons_enter_valid_number.tr();
                  }
                  return null;
                },
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                initialValue:
                    (_formData["durationInMinute"] as int?)?.toString() ??
                        widget.branch.defaultDurationInMinute.toString(),
                decoration: InputDecoration(
                    labelText: LocaleKeys.set_session_dialog_time_minutes.tr()),
                onSaved: (value) {
                  _formData["durationInMinute"] = int.parse(value!);
                },
              ),
              TextFormField(
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
                initialValue: _formData["phone"] ?? "",
                decoration: InputDecoration(
                    labelText: LocaleKeys.set_session_dialog_phone_label.tr()),
                onSaved: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return;
                  }
                  _formData["phone"] = value.trim();
                },
              ),
              TextFormField(
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    try {
                      num.parse(value.trim().replaceAll(",", "."));
                      return null;
                    } catch (e) {
                      return LocaleKeys.commons_enter_valid_number.tr();
                    }
                  } else {
                    return null;
                  }
                },
                onSaved: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return;
                  }
                  _formData["extra"] =
                      num.parse(value.trim().replaceAll(",", "."));
                },
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                initialValue: _formData["extra"]?.toString() ?? "",
                decoration: InputDecoration(
                    labelText: LocaleKeys.set_session_dialog_extra_label.tr()),
              ),
              TextFormField(
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                textInputAction: TextInputAction.done,
                initialValue: _formData["discount"]?.toString() ?? "",
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    try {
                      num.parse(value.trim().replaceAll(",", "."));
                      return null;
                    } catch (e) {
                      return LocaleKeys.commons_enter_valid_number.tr();
                    }
                  } else {
                    return null;
                  }
                },
                decoration: InputDecoration(
                    labelText:
                        LocaleKeys.set_session_dialog_discount_label.tr()),
                onSaved: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return;
                  }
                  _formData["discount"] =
                      num.parse(value.trim().replaceAll(",", "."));
                },
              ),
              TextFormField(
                decoration: InputDecoration(
                    labelText: LocaleKeys.set_session_dialog_notes_label.tr()),
                maxLines: 3,
                textInputAction: TextInputAction.done,
                initialValue: _formData["notes"] ?? "",
                onSaved: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return;
                  }
                  _formData["notes"] = value;
                },
              ),
              Center(
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<UserModel?>(
                      hint: Text(LocaleKeys.set_session_dialog_assign_to.tr()),
                      isExpanded: true,
                      value: _formData["assignedTo"] == null
                          ? null
                          : widget.branch.users.firstWhere((element) =>
                              element.uid == _formData["assignedTo"]),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: ListTile(
                            title: Text(LocaleKeys
                                .set_session_dialog_not_assigned
                                .tr()),
                            leading: const Icon(Icons.not_interested),
                          ),
                        ),
                        ...widget.branch.users
                            .map((e) => DropdownMenuItem(
                                  value: e,
                                  child: ListTile(
                                      title: Text(e.displayName),
                                      leading: e.photoUrl.isEmpty
                                          ? const Icon(Icons.person)
                                          : ProfilePictureWidget(
                                              photoUrl: e.photoUrl, size: 36)),
                                ))
                            .toList()
                      ],
                      onChanged: (user) {
                        setState(() {
                          _formData["assignedTo"] = user?.uid;
                        });
                      }),
                ),
              ),
              Wrap(
                  spacing: 10,
                  children: widget.branch.branchServices
                      .map((e) => InkWell(
                            onTap: () {
                              setState(() {
                                if (branchServicesUids.contains(e.uid)) {
                                  branchServicesUids.remove(e.uid);
                                } else {
                                  branchServicesUids.add(e.uid);
                                }
                              });
                            },
                            child: Chip(
                              label: Text(e.name),
                              backgroundColor:
                                  branchServicesUids.contains(e.uid)
                                      ? Colors.green.shade300
                                      : null,
                            ),
                          ))
                      .toList()),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.cancel),
                      label: Text(LocaleKeys.general_cancel.tr())),
                  if (widget.session != null)
                    ElevatedButton.icon(
                        onPressed: () {
                          try {
                            ProviderManager.ref
                                .read(ProviderManager
                                    .sessionManagerProvider.notifier)
                                .deleteSession(widget.session!.uid)
                                .then((_) async {
                              await PopupHelper.showAnimatedInfoDialog(
                                      title: LocaleKeys
                                          .set_session_dialog_session_deleted
                                          .tr(),
                                      isSuccessful: true)
                                  .then((value) {
                                Navigator.of(context).pop();
                              });
                            });
                          } catch (e) {
                            PopupHelper.showAnimatedInfoDialog(
                                title: e.toString(), isSuccessful: false);
                          }
                        },
                        icon: const Icon(Icons.delete),
                        label: Text(LocaleKeys.general_delete.tr())),
                  ElevatedButton.icon(
                      onPressed: _createSession,
                      icon: const Icon(Icons.save),
                      label: Text(LocaleKeys.general_save.tr())),
                ],
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height:
                    isKeyboardOpen ? View.of(context).viewInsets.bottom / 3 : 0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  _createSession() async {
    /// will be check
    /// startTime
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      if (_formData["startTime"] == null) {
        PopupHelper.showAnimatedInfoDialog(
            title: LocaleKeys.set_session_dialog_select_start_time.tr(),
            isSuccessful: false);
        return;
      }
      try {
        log(_formData["startTime"].toString());
        await PopupHelper.showLoadingWhile(() async => ProviderManager.ref
            .read(ProviderManager.sessionManagerProvider.notifier)
            .setSession(
              branchModel: widget.branch,
              name: _formData["name"],
              personCount: _formData["personCount"],
              branchServicesUids: branchServicesUids,
              startTime: _formData["startTime"],
              durationInMinute: _formData["durationInMinute"],
              discount: _formData["discount"],
              extra: _formData["extra"],
              notes: _formData["notes"],
              phone: _formData["phone"],
              uid: widget.session?.uid,
              assignedTo: _formData["assignedTo"],
            ));
        PopupHelper.showAnimatedInfoDialog(
                title: LocaleKeys.set_session_dialog_session_created.tr(),
                isSuccessful: true)
            .then((value) {
          Navigator.of(context).pop();
        });
      } catch (e) {
        PopupHelper.showAnimatedInfoDialog(
            title: e.toString(), isSuccessful: false);
      }
    }
  }
}
