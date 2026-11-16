import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gohotels/app/di.dart';
import 'package:gohotels/core/storage/token_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Qayta o'rnatilgan ilova: iOS Keychain'dagi eski sessiya bilan ochilmasligi.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const staleTokens = {'access_token': 'eski-a', 'refresh_token': 'eski-r'};

  Future<TokenStore> boot({
    required TargetPlatform platform,
    required Map<String, Object> prefs,
  }) async {
    await getIt.reset();
    debugDefaultTargetPlatformOverride = platform;
    SharedPreferences.setMockInitialValues(prefs);
    FlutterSecureStorage.setMockInitialValues(Map.of(staleTokens));
    await configureDependencies();
    return getIt<TokenStore>();
  }

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
  });

  test('iOS: yangi o\'rnatishda Keychain\'dagi eski tokenlar o\'chadi', () async {
    final tokens = await boot(platform: TargetPlatform.iOS, prefs: {});
    expect(tokens.accessToken, isNull);
    expect(await tokens.hasSession, isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('installed'), isTrue);
  });

  test('iOS: oddiy ochilishda sessiya saqlanadi', () async {
    final tokens = await boot(
      platform: TargetPlatform.iOS,
      prefs: {'installed': true},
    );
    expect(tokens.accessToken, 'eski-a');
    expect(await tokens.hasSession, isTrue);
  });

  test('Android: shu versiyaga yangilanganda sessiya saqlanadi', () async {
    final tokens = await boot(platform: TargetPlatform.android, prefs: {});
    expect(tokens.accessToken, 'eski-a');
    expect(await tokens.hasSession, isTrue);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('installed'), isTrue);
  });
}
