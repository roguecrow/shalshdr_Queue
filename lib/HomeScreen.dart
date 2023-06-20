import 'package:andtv/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'patients.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  final List<User> userList;
  final String tvToken;

  const HomeScreen({
    Key? key,
    required this.userList,
    required this.tvToken,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Patient> patientList = [];
  late Timer _timer;
  DateTime lastUpdatedTime = DateTime.now();
  bool _isConnected = true;


  Future<void> checkConnectivity() async {
    final connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      if (connectivityResult == ConnectivityResult.none) {
        _isConnected = false;
      }
      else
      {
        _isConnected = true;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    checkConnectivity();
    fetchData();

    // Fetch data every 20 seconds
    _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      checkConnectivity();
      fetchData();
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the screen is disposed
    super.dispose();
  }

  void fetchData() async {
    final url = 'https://api30.slashdr.com/tv/queue/?tv_token=${widget.tvToken}&clinic_id=${widget.userList.first.clinicId}';

    // Make an HTTP GET request to the API endpoint
    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Parsing the response and extracting the data
      var jsonData = jsonDecode(response.body);
      var results = jsonData['list'];

      setState(() {
        // Update the patientList with the fetched data
        patientList =
            List<Patient>.from(results.map((data) => Patient.fromJson(data))).toList();
        lastUpdatedTime = DateTime.now(); // Update the last updated time
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context,
        designSize: Size(375, 812),minTextAdapt: true,);
    return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF010038),
          toolbarHeight: 100,
          elevation: 10,
          automaticallyImplyLeading: false,
         title: Image.asset(
           'assets/logo.png',
           width: 100,
           height: 100,
         ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 25.0, top: 30.0),
              child: Text(
                widget.userList.first.doctorName,
                style: const TextStyle(fontSize: 40.0),
              ),
            ),
          ],
        ),
      backgroundColor: const Color(0xFF010038),
      body: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Column(
          children: [
            if (_isConnected) // Show ListView.builder only if connected
              Visibility(
                visible: patientList.isNotEmpty,
                replacement: Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/emptystate_queue.png',
                        width: 500.w,
                        height: 500.h,
                      ),
                       SizedBox(height: 10.h,),
                      Text(
                        'No Patients In Waiting!',
                        style: GoogleFonts.lato(
                          textStyle: const TextStyle(color: Colors.white, letterSpacing: .5,fontSize: 40),
                        ),
                      ),
                    ],
                  ),
                ),
                child: Expanded(
                  child: ListView.builder(
                    itemCount: patientList.length,
                    itemBuilder: (context, index) {
                      final patient = patientList[index];
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: ScreenUtil().setWidth(3), vertical: ScreenUtil().setWidth(2)),
                        padding: EdgeInsets.all(ScreenUtil().setWidth(2)),
                        decoration: BoxDecoration(
                          color: const Color(0xFF010038),
                          borderRadius: BorderRadius.circular(ScreenUtil().setWidth(10)),
                        ),
                        child: ListTile(
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${patient.name}, ${patient.age}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: ScreenUtil().setSp(40),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            if (!_isConnected) // Show "No Internet Connection" message when not connected
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/NoNet_Connect_queue.png',
                        width: 400.w,
                        height: 400.h,
                      ),
                      const SizedBox(height: 15,),
                      Text(
                        'No internet connection',
                        style: GoogleFonts.lato(
                          textStyle: const TextStyle(color: Colors.white, letterSpacing: .5,fontSize: 40),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding:EdgeInsets.only(right: ScreenUtil().setWidth(5), bottom: ScreenUtil().setWidth(5)),
                child: Text(
                  _isConnected
                      ? 'Last Updated: ${DateFormat('hh:mm a, MMM dd, yyyy').format(lastUpdatedTime)}'
                      : '',
                  style: GoogleFonts.lato(textStyle: TextStyle(color: Colors.white, fontSize: ScreenUtil().setSp(25)),
                ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


