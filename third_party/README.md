# third_party

## flutter_vodozemac (0.5.0 + patch)

Matrix-E2EE vereist vodozemac 0.5.x; upstream `flutter_vodozemac` 0.5.0
kan niet met de nieuwe Android SDK-platformnaamgeving (`android-37.0`) overweg:
cargokit las `compileSdkVersion.substring(8)` en crashte op `"37.0"`.

Enige wijziging t.o.v. pub.dev 0.5.0 — zie git diff met pub.dev, of:
`cargokit/gradle/plugin.gradle`, regel ~163: robuuste regex-parse van de
compileSdk in plaats van een vaste offset.

Verwijder deze override zodra de matrix-dart-sdk naar vodozemac >= 0.9
gemigrated is en deze plugin upstream gefixt is.
