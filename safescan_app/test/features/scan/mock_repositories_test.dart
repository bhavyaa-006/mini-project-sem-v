import 'package:flutter_test/flutter_test.dart';
import 'package:safescan_app/features/alternatives/data/alternatives_repository.dart';
import 'package:safescan_app/features/history/data/history_repository.dart';
import 'package:safescan_app/features/profile/data/profile_repository.dart';
import 'package:safescan_app/features/scan/data/scan_repository.dart';

void main() {
  test('mock lookup covers known samples and unknown barcode', () async {
    const repository = MockProductLookupRepository(delay: Duration.zero);

    expect((await repository.lookupByBarcode('890100100001'))?.product.name, 'MOCK Wholegrain Breakfast Oats');
    expect((await repository.lookupByBarcode('890100100002'))?.product.name, 'MOCK Sugary Snack Bar');
    expect((await repository.lookupByBarcode('890100100003'))?.product.name, 'MOCK Gentle Face Moisturiser');
    expect((await repository.lookupByBarcode('890100100004'))?.product.name, 'MOCK Strong Perfume Cream');
    expect((await repository.lookupByBarcode('890100100005'))?.product.name, 'MOCK Imported Cereal Pack');
    expect((await repository.lookupByBarcode('890100100006'))?.product.name, 'MOCK Loose Label Beverage');
    expect(await repository.lookupByBarcode('UNKNOWN-BARCODE'), isNull);
  });

  test('mock alternatives, history and profile repositories work', () async {
    const alternatives = MockAlternativesRepository(delay: Duration.zero);
    const history = MockHistoryRepository(delay: Duration.zero);
    const profile = MockProfileRepository(delay: Duration.zero);

    expect(await alternatives.getAlternatives('mock-food-poor'), isNotEmpty);
    expect(await history.getHistory(), isNotEmpty);

    final mockProfile = await profile.getProfile();
    expect(mockProfile.name, 'Aarav');
    expect(mockProfile.allergies, isNotEmpty);
  });
}
