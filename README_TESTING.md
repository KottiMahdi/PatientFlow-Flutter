Testing guide

Run all tests:

```bash
flutter test
```

Run a single test file:

```bash
flutter test test/features/auth/domain/usecases/sign_in_with_email_test.dart
```

Generate coverage:

```bash
flutter test --coverage
# then use genhtml (linux/mac) to view
# genhtml coverage/lcov.info -o coverage/html
```

Best practices:
- Mock external dependencies (Firebase, HTTP) with `mocktail`.
- Keep usecases pure and thoroughly unit-tested.
- Test provider state transitions (loading/success/error).
- Keep widget tests fast and focused.
- Use GH Actions to run tests on CI and upload coverage artifacts.
