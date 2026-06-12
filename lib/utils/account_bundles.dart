import 'package:matrix/matrix.dart';

class AccountBundles {
  String? prefix;
  List<AccountBundle>? bundles;

  AccountBundles({this.prefix, this.bundles});

  AccountBundles.fromJson(Map<String, dynamic> json)
    : prefix = json.tryGet<String>('prefix'),
      bundles = json['bundles'] is List
          ? json['bundles']
                .map((b) {
                  try {
                    return AccountBundle.fromJson(b);
                  } catch (_) {
                    return null;
                  }
                })
                .whereType<AccountBundle>()
                .toList()
          : null;

  Map<String, dynamic> toJson() => {
    if (prefix != null) 'prefix': prefix,
    if (bundles != null) 'bundles': bundles!.map((v) => v.toJson()).toList(),
  };
}

class AccountBundle {
  String? name;
  int? priority;

  AccountBundle({this.name, this.priority});

  AccountBundle.fromJson(Map<String, dynamic> json)
    : name = json.tryGet<String>('name'),
      priority = json.tryGet<int>('priority');

  Map<String, dynamic> toJson() => <String, dynamic>{
    if (name != null) 'name': name,
    if (priority != null) 'priority': priority,
  };
}

const accountBundlesType = 'com.danield.plusly.account_bundles';

extension AccountBundlesExtension on Client {
  List<AccountBundle> get accountBundles {
    List<AccountBundle>? ret;
    if (accountData.containsKey(accountBundlesType)) {
      final content = accountData[accountBundlesType]?.content;
      if (content != null) {
        ret = AccountBundles.fromJson(content).bundles;
      }
    }
    ret ??= [];
    if (ret.isEmpty) {
      ret.add(AccountBundle(name: userID, priority: 0));
    }
    return ret;
  }

  Future<void> setAccountBundle(String name, [int? priority]) async {
    final data = AccountBundles.fromJson(
      accountData[accountBundlesType]?.content ?? {},
    );
    var foundBundle = false;
    final bundles = data.bundles ??= [];
    for (final bundle in bundles) {
      if (bundle.name == name) {
        bundle.priority = priority;
        foundBundle = true;
        break;
      }
    }
    if (!foundBundle) {
      bundles.add(AccountBundle(name: name, priority: priority));
    }
    final uid = userID;
    if (uid == null) return;
    await setAccountData(uid, accountBundlesType, data.toJson());
  }

  Future<void> removeFromAccountBundle(String name) async {
    if (!accountData.containsKey(accountBundlesType)) {
      return; // nothing to do
    }
    final content = accountData[accountBundlesType]?.content;
    if (content == null) return;
    final data = AccountBundles.fromJson(content);
    if (data.bundles == null) return;
    data.bundles!.removeWhere((b) => b.name == name);
    final uid = userID;
    if (uid == null) return;
    await setAccountData(uid, accountBundlesType, data.toJson());
  }

  String get sendPrefix {
    final data = AccountBundles.fromJson(
      accountData[accountBundlesType]?.content ?? {},
    );
    return data.prefix ?? '';
  }
}
