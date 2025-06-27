// import 'package:flutter_test/flutter_test.dart';
// import 'package:mocktail/mocktail.dart';
// import 'package:dartz/dartz.dart';
// import 'package:property_manager_app/src/domain/usecases/login_usecase.dart';
// import 'package:property_manager_app/src/domain/repositories/auth_repository.dart';
// import 'package:property_manager_app/src/domain/entities/user.dart';
// import 'package:property_manager_app/src/core/errors/failures.dart';

// class MockAuthRepository extends Mock implements AuthRepository {}

// void main() {
//   late LoginUseCase loginUseCase;
//   late MockAuthRepository mockRepository;

//   setUp(() {
//     mockRepository = MockAuthRepository();
//     loginUseCase = LoginUseCase(mockRepository);
//   });

//   group('LoginUseCase', () {
//     const email = 'test@example.com';
//     const password = 'password123';
//     const user = User(id: '1', email: email, name: 'Test User');
//     const accessToken = 'access_token';
//     const refreshToken = 'refresh_token';

//     test('should return success when login is successful', () async {
//       // Arrange
//       when(() => mockRepository.login(email, password))
//           .thenAnswer((_) async => const Right((accessToken, refreshToken, user)));

//       // Act
//       final result = await loginUseCase(email, password);

//       // Assert
//       expect(result, equals(const Right((accessToken, refreshToken, user))));
//       verify(() => mockRepository.login(email, password)).called(1);
//     });

//     test('should return failure when login fails', () async {
//       // Arrange
//       when(() => mockRepository.login(email, password))
//           .thenAnswer((_) async => const Left(AuthFailure('Invalid credentials')));

//       // Act
//       final result = await loginUseCase(email, password);

//       // Assert
//       expect(result, equals(const Left(AuthFailure('Invalid credentials'))));
//       verify(() => mockRepository.login(email, password)).called(1);
//     });
//   });
// }