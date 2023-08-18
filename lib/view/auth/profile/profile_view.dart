import 'package:bookingmanager/core/services/localization/locale_keys.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/firebase/auth/auth_service.dart';
import '../../../core/utils/popup_helper.dart';
import '../../../product/providers/provider_manager.dart';

part 'create_branch_dialog.dart';

class ProfileView extends ConsumerStatefulWidget {
  const ProfileView({super.key});
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileViewState();
}

class _ProfileViewState extends ConsumerState<ProfileView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(centerTitle: true, title: Text(LocaleKeys.profile_title.tr())),
      body: _body(),
    );
  }

  Widget _body() {
    final List<Widget Function()> elements = [
      () => _photo(),
      () => _name(),
      () => _email(),
      () => const Divider(),
      () => _createBranch()
    ];
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),
          ListView.separated(
            shrinkWrap: true,
            itemBuilder: (context, index) =>
                Align(alignment: Alignment.center, child: elements[index]()),
            separatorBuilder: (context, index) => const SizedBox(height: 30),
            itemCount: elements.length,
          ),
          const Spacer(),
          _deleteAccountButton(),
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.05),
        ],
      ),
    );
  }

  Widget _photo() {
    return SizedBox(
        height: MediaQuery.sizeOf(context).width * 0.4,
        width: MediaQuery.sizeOf(context).width * 0.4,
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: AuthService.instance.userModel!.photoUrl.isEmpty
                    ? const Icon(Icons.person, size: 100, color: Colors.grey)
                    : Image.network(
                        AuthService.instance.userModel!.photoUrl,
                        errorBuilder: (context, error, stackTrace) =>
                            const Icon(Icons.person,
                                size: 100, color: Colors.grey),
                      ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: CircleAvatar(
                child: IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.camera_alt),
                ),
              ),
            ),
          ],
        ));
  }

  Widget _name() {
    return Text(
        LocaleKeys.profile_welcome
            .tr(args: [AuthService.instance.userModel!.displayName]),
        textAlign: TextAlign.center);
  }

  Widget _email() {
    return GestureDetector(
        onTap: () async {
          await Clipboard.setData(
              ClipboardData(text: AuthService.instance.userModel!.email));
          PopupHelper.showSnackBar(
              message: LocaleKeys.profile_email_copied.tr());
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(LocaleKeys.profile_your_email
                .tr(args: [AuthService.instance.userModel!.email])),
            // Text("E-postanız: ${AuthService.instance.userModel!.email}"),
            const SizedBox(width: 10),
            const Icon(Icons.copy),
          ],
        ));
  }

  Widget _createBranch() {
    return ListTile(
      title: Text(LocaleKeys.profile_create_branch_dialog_title.tr()),
      trailing: const Icon(Icons.add_business),
      onTap: () {
        showDialog(
            context: context,
            builder: (context) => const _CreateBranchDialog());
      },
    );
  }

  // TODO: localization

  Widget _deleteAccountButton() {
    return ElevatedButton(
      onPressed: () async {
        PopupHelper.showOkCancelDialog(
            title: "Dikkat",
            content:
                "Hesabınız silinecek. Bu işlem geri alınamaz. Daha sonra aynı bilgiler ile yeni bir hesap oluşturabilirsiniz",
            onOk: () {
              try {
                PopupHelper.showLoadingWhile(
                    () async => await AuthService.instance.deleteAccount());
              } catch (e) {
                PopupHelper.showAnimatedInfoDialog(
                    title: "Kullanıcı silme başarısız oldu",
                    isSuccessful: false);
              }
            });
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.red,
        fixedSize: Size(MediaQuery.sizeOf(context).width * 0.8, 50),
        foregroundColor: Colors.white,
      ),
      child: const Text("Hesap sil"),
    );
  }
}
