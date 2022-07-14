import 'package:clean_architecture_tdd/core/network/network_info.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'network_info_test.mocks.dart';


@GenerateMocks([InternetConnectionChecker])
void main(){
  late NetworkInfoImpl networkInfoImpl;
  late MockInternetConnectionChecker mockInternetConnectionChecker;

  setUp((){
    mockInternetConnectionChecker = MockInternetConnectionChecker();
    networkInfoImpl = NetworkInfoImpl(mockInternetConnectionChecker);
  });

  group('isConnected', (){
    test(
    '	should forward the call to InternetConnectionChecker.hasConnection',
      () async {
      // arrange
      final tHasConnectionFuture = Future.value(true);
      when(mockInternetConnectionChecker.hasConnection).thenAnswer((_)  => tHasConnectionFuture);//no need to return async
      // act
      final result = networkInfoImpl.isConnected; //no need to await since we want to expect Future
      // assert
      verify(mockInternetConnectionChecker.hasConnection);
      expect(result, tHasConnectionFuture);//Taking advantage ot referential equality, since both object are pointing to the same location (address) in memory
      }
    );
  });
}