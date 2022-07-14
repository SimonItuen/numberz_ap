import 'package:clean_architecture_tdd/core/error/failures.dart';
import 'package:clean_architecture_tdd/core/usecases/usescase.dart';
import 'package:clean_architecture_tdd/core/util/input_converter.dart';
import 'package:clean_architecture_tdd/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean_architecture_tdd/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean_architecture_tdd/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:clean_architecture_tdd/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:bloc_test/bloc_test.dart';

import 'number_trivia_bloc_test.mocks.dart';

@GenerateMocks([GetConcreteNumberTrivia, GetRandomNumberTrivia, InputConverter])
void main() {
  late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();

    bloc = NumberTriviaBloc(
        getConcreteNumberTrivia: mockGetConcreteNumberTrivia,
        getRandomNumberTrivia: mockGetRandomNumberTrivia,
        inputConverter: mockInputConverter);
  });

  blocTest('emits [ ] when nothing is added',
      build: () => bloc, expect: () => const []);

  group('GetTriviaFromConcreteNumber', () {
    const tNumberString = '1';
    const tNumberParsed = 1;
    const tNumberTrivia = NumberTrivia(number: 1, text: 'test text');

    void setUpMockInputConverterSuccess() {
      when(mockInputConverter.stringToUnsignedInteger(any))
          .thenReturn(const Right(tNumberParsed));
    }

    void setUpMockInputConverterFailure() {
      when(mockInputConverter.stringToUnsignedInteger(any))
          .thenReturn(Left(InvalidInputFailure()));
    }

    blocTest(
        'should call the InputConverter to validate and convert a string to an unsigned integer',
        setUp: () {
          setUpMockInputConverterSuccess();
          when(mockGetConcreteNumberTrivia(any))
              .thenAnswer((_) async => const Right(tNumberTrivia));
        },
        build: () => bloc,
        act: (NumberTriviaBloc bloc) =>
            bloc.add(const GetTriviaForConcreteNumber(tNumberString)),
        verify: (_) =>
            mockInputConverter.stringToUnsignedInteger(tNumberString));

    blocTest('should emit [Error] when the input is invalid',
        setUp: () {
          setUpMockInputConverterFailure();
        },
        build: () => bloc,
        act: (NumberTriviaBloc bloc) =>
            bloc.add(const GetTriviaForConcreteNumber(tNumberString)),
        expect: () => [const Error(message: INVALID_INPUT_FAILURE_MESSAGE)]);

    blocTest('should data from the concrete use case',
        setUp: () {
          setUpMockInputConverterSuccess();
          when(mockGetConcreteNumberTrivia(any))
              .thenAnswer((_) async => const Right(tNumberTrivia));
        },
        build: () => bloc,
        act: (NumberTriviaBloc bloc) =>
            bloc.add(const GetTriviaForConcreteNumber(tNumberString)),
        verify: (_) =>
            mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)));
    blocTest(
      'should emit [Loading, Loaded] when data is gotten succesfully',
      setUp: () {
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => const Right(tNumberTrivia));
      },
      build: () => bloc,
      act: (NumberTriviaBloc bloc) =>
          bloc.add(const GetTriviaForConcreteNumber(tNumberString)),
      expect: () => [const Loading(), const Loaded(trivia: tNumberTrivia)],
    );
    blocTest(
      'should emit [Loading, Error] when getting data fails',
      setUp: () {
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => const Left(ServerFailure()));
      },
      build: () => bloc,
      act: (NumberTriviaBloc bloc) =>
          bloc.add(const GetTriviaForConcreteNumber(tNumberString)),
      expect: () =>
          [const Loading(), const Error(message: SERVER_FAILURE_MESSAGE)],
    );
    blocTest(
      'should emit [Loading, Error] with a proper message when getting data fails',
      setUp: () {
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => const Left(CacheFailure()));
      },
      build: () => bloc,
      act: (NumberTriviaBloc bloc) =>
          bloc.add(const GetTriviaForConcreteNumber(tNumberString)),
      expect: () =>
          [const Loading(), const Error(message: CACHE_FAILURE_MESSAGE)],
    );
  });

  group('GetTriviaFromRandomNumber', () {
    const tNumberTrivia = NumberTrivia(number: 1, text: 'test text');

    blocTest('should data from the random use case',
        setUp: () {
          when(mockGetRandomNumberTrivia(any))
              .thenAnswer((_) async => const Right(tNumberTrivia));
        },
        build: () => bloc,
        act: (NumberTriviaBloc bloc) =>
            bloc.add(const GetTriviaForRandomNumber()),
        verify: (_) =>
            mockGetRandomNumberTrivia(NoParams()));
    blocTest(
      'should emit [Loading, Loaded] when data is gotten succesfully',
      setUp: () {
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => const Right(tNumberTrivia));
      },
      build: () => bloc,
      act: (NumberTriviaBloc bloc) =>
          bloc.add(const GetTriviaForRandomNumber()),
      expect: () => [const Loading(), const Loaded(trivia: tNumberTrivia)],
    );
    blocTest(
      'should emit [Loading, Error] when getting data fails',
      setUp: () {
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => const Left(ServerFailure()));
      },
      build: () => bloc,
      act: (NumberTriviaBloc bloc) =>
          bloc.add(const GetTriviaForRandomNumber()),
      expect: () =>
          [const Loading(), const Error(message: SERVER_FAILURE_MESSAGE)],
    );
    blocTest(
      'should emit [Loading, Error] with a proper message when getting data fails',
      setUp: () {
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => const Left(CacheFailure()));
      },
      build: () => bloc,
      act: (NumberTriviaBloc bloc) =>
          bloc.add(const GetTriviaForRandomNumber()),
      expect: () =>
          [const Loading(), const Error(message: CACHE_FAILURE_MESSAGE)],
    );
  });
}
