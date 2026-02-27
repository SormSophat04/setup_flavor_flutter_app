import 'package:flutter_test/flutter_test.dart';
import 'package:setup_flavor/data/model/auth_model.dart';

void main() {
  group('AuthModel', () {
    test('fromJson maps fields correctly', () {
      final json = {'email': 'john@doe.com', 'password': '123456'};

      final model = AuthModel.fromJson(json);

      expect(model.email, 'john@doe.com');
      expect(model.password, '123456');
    });

    test('toJson returns expected map', () {
      final model = AuthModel(email: 'john@doe.com', password: '123456');

      final json = model.toJson();

      expect(
        json,
        {'email': 'john@doe.com', 'password': '123456'},
      );
    });

    test('fromJson and toJson support round trip', () {
      final original = {'email': 'john@doe.com', 'password': '123456'};

      final model = AuthModel.fromJson(original);
      final encoded = model.toJson();

      expect(encoded, original);
    });

    test('toString returns readable model output', () {
      final model = AuthModel(email: 'john@doe.com', password: '123456');

      expect(
        model.toString(),
        'AuthModel(email: john@doe.com, password: 123456)',
      );
    });
  });
}
