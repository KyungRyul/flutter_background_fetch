import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:flutter/material.dart';
import 'package:health/health.dart';

class Health {
  static const platform = MethodChannel('com.example.famcare_t/battery');
  Future<void> getBatteryLevel() async {
    print('실행');
    // String batteryLevel;
    // try {
    final String result = await platform.invokeMethod('getBatteryLevel');
    print(result);
    //   batteryLevel = 'Battery level at $result % .';
    // } on PlatformException catch (e) {
    //   batteryLevel = "Failed to get battery level: '${e.message}'.";
    // }
  }

  List<HealthDataPoint> _healthDataList = [];
  int _nofSteps = 10;
  double _mgdl = 10.0;

  // create a HealthFactory for use in the app
  HealthFactory health = HealthFactory();

  /// Fetch data points from the health plugin and show them in the app.
  Future fetchData() async {
    // setState(() => _state = AppState.FETCHING_DATA);

    // define the types to get
    final types = [
      HealthDataType.HEART_RATE,
      HealthDataType.STEPS,
      HealthDataType.DISTANCE_DELTA,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      // Uncomment these lines on iOS - only available on iOS
      // HealthDataType.AUDIOGRAM
    ];

    // with coresponsing permissions
    final permissions = [
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      HealthDataAccess.READ,
      // HealthDataAccess.READ,
    ];

    // get data within the last 24 hours
    final now = DateTime.now();
    final yesterday = now.subtract(Duration(days: 24));
    // requesting access to the data types before reading them
    // note that strictly speaking, the [permissions] are not
    // needed, since we only want READ access.
    bool requested =
        await health.requestAuthorization(types, permissions: permissions);
    print('requested: $requested');

    // If we are trying to read Step Count, Workout, Sleep or other data that requires
    // the ACTIVITY_RECOGNITION permission, we need to request the permission first.
    // This requires a special request authorization call.
    //
    // The location permission is requested for Workouts using the Distance information.
    // await Permission.activityRecognition.request();
    // await Permission.location.request();

    if (true) {
      try {
        // fetch health data
        List<HealthDataPoint> healthData =
            await health.getHealthDataFromTypes(yesterday, now, types);
        // save all the new data points (only the first 100)
        _healthDataList.addAll((healthData.length < 100)
            ? healthData
            : healthData.sublist(0, 100));
      } catch (error) {
        print("Exception in getHealthDataFromTypes: $error");
      }

      // filter out duplicates
      _healthDataList = HealthFactory.removeDuplicates(_healthDataList);

      // print the results
      print('데이터 갯수');
      print(_healthDataList);
      print(_healthDataList.length);
      return _healthDataList.length;
      // _healthDataList.forEach((x) => print(x));

      // update the UI to display the results
      // setState(() {
      //   _state =
      //       _healthDataList.isEmpty ? AppState.NO_DATA : AppState.DATA_READY;
      // });
    } else {
      print("Authorization not granted");
      // setState(() => _state = AppState.DATA_NOT_FETCHED);
    }
  }
}
