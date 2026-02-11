import 'dart:convert';

import 'package:flutter/widgets.dart';

import 'package:collection/collection.dart';
import 'package:matrix/matrix_api_lite/utils/logs.dart';

import 'package:extera_next/config/app_config.dart';
import 'package:extera_next/pages/sign_in/view_model/flows/sort_homeservers.dart';
import 'package:extera_next/pages/sign_in/view_model/model/public_homeserver_data.dart';
import 'package:extera_next/pages/sign_in/view_model/sign_in_state.dart';
import 'package:extera_next/widgets/matrix.dart';

class SignInViewModel extends ValueNotifier<SignInState> {
  final MatrixState matrixService;
  final bool signUp;
  final TextEditingController filterTextController = TextEditingController();

  SignInViewModel(this.matrixService, {required this.signUp})
    : super(SignInState()) {
    refreshPublicHomeservers();
    filterTextController.addListener(_filterHomeservers);
  }

  @override
  void dispose() {
    filterTextController.removeListener(_filterHomeservers);
    super.dispose();
  }

  void _filterHomeservers() {
    final filterText = filterTextController.text.trim().toLowerCase();
    final filteredPublicHomeservers =
        value.publicHomeservers.data
            ?.where(
              (homeserver) =>
                  homeserver.name?.toLowerCase().contains(filterText) ?? false,
            )
            .toList() ??
        [];
    final splitted = filterText.split('.');
    if (splitted.length >= 2 && !splitted.any((part) => part.isEmpty)) {
      if (!filteredPublicHomeservers.any(
        (homeserver) => homeserver.name == filterText,
      )) {
        filteredPublicHomeservers.add(PublicHomeserverData(name: filterText));
      }
    }
    value = value.copyWith(
      filteredPublicHomeservers: filteredPublicHomeservers,
    );
  }

  void refreshPublicHomeservers() async {
    value = value.copyWith(publicHomeservers: AsyncSnapshot.waiting());
    final defaultHomeserverData = PublicHomeserverData(
      name: AppConfig.defaultHomeserver,
    );
    try {
      final client = await matrixService.getLoginClient();
      final response = await client.httpClient.get(AppConfig.homeserverList);
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final homeserverJsonList = json['public_servers'] as List;

      final publicHomeservers = homeserverJsonList
          .map((json) => PublicHomeserverData.fromJson(json))
          .toList();

      if (signUp) {
        publicHomeservers.removeWhere((server) {
          return server.regMethod == null;
        });
      }

      publicHomeservers.sort(sortHomeservers);

      final defaultServer =
          publicHomeservers.singleWhereOrNull(
            (server) => server.name == AppConfig.defaultHomeserver,
          ) ??
          defaultHomeserverData;

      publicHomeservers.insert(0, defaultServer);

      value = value.copyWith(
        selectedHomeserver: value.selectedHomeserver ?? publicHomeservers.first,
        publicHomeservers: AsyncSnapshot.withData(
          ConnectionState.done,
          publicHomeservers,
        ),
      );
    } catch (e, s) {
      Logs().w('Unable to fetch public homeservers...', e, s);
      value = value.copyWith(
        selectedHomeserver: defaultHomeserverData,
        publicHomeservers: AsyncSnapshot.withData(ConnectionState.done, [
          defaultHomeserverData,
        ]),
      );
    }
    _filterHomeservers();
  }

  void selectHomeserver(PublicHomeserverData? publicHomeserverData) {
    value = value.copyWith(selectedHomeserver: publicHomeserverData);
  }

  void setLoginLoading(AsyncSnapshot<bool> loginLoading) {
    value = value.copyWith(loginLoading: loginLoading);
  }
}