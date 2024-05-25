import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:pdf/pdf.dart'; // For PDF generation
import 'package:pdf/widgets.dart' as pw; // For PDF widgets
import 'package:printing/printing.dart'; // For printing and PDF export

class WorkingTimeScreen extends StatefulWidget {
  final String userId;

  WorkingTimeScreen({required this.userId});

  @override
  _WorkingTimeScreenState createState() => _WorkingTimeScreenState();
}

class _WorkingTimeScreenState extends State<WorkingTimeScreen> {
  int? selectedMonth;
  Future<List<Map<String, dynamic>>>? workingTimeFuture;
  Map<String, dynamic>? userDetails;

  @override
  void initState() {
    super.initState();
    _getUserDetails(widget.userId);
  }

  Future<void> _getUserDetails(String userId) async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('usersdetails')
        .doc(userId)
        .get();

    setState(() {
      userDetails = userSnapshot.data() as Map<String, dynamic>?;
    });
  }

  Future<List<Map<String, dynamic>>> _getWorkingTimeDetails(
      String userId, int month) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('workingtime')
        .where('userId', isEqualTo: userId)
        .get();

    return querySnapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .where((data) {
      Timestamp timestamp = data['date'];
      DateTime date = timestamp.toDate();
      return date.month == month;
    }).toList();
  }

  Future<void> _generatePdf(List<Map<String, dynamic>> data, int month) async {
    final pdf = pw.Document();

    double totalHours = 0;
    data.forEach((record) {
      totalHours += record['differenceInHours'];
      totalHours += record['differenceInMinutes'] / 60;
    });

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                  'Working Time Details for ${DateFormat.MMMM().format(DateTime(0, month))}',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 16),
              pw.Text('Name: ${userDetails?['name'] ?? ''}',
                  style: pw.TextStyle(fontSize: 18)),
              pw.Text('Email: ${userDetails?['email'] ?? ''}',
                  style: pw.TextStyle(fontSize: 18)),
              pw.Text('User ID: ${widget.userId}',
                  style: pw.TextStyle(fontSize: 18)),
              pw.SizedBox(height: 16),
              pw.Table.fromTextArray(
                headers: ['Date', 'Hours', 'Minutes', 'UserID'],
                data: data.map((record) {
                  Timestamp timestamp = record['date'];
                  DateTime date = timestamp.toDate();
                  return [
                    DateFormat.yMMMd().add_jm().format(date),
                    record['differenceInHours'].toString(),
                    record['differenceInMinutes'].toString(),
                    record['userId'].toString(),
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 16),
              pw.Text('Total Hours: ${totalHours.toStringAsFixed(2)}',
                  style: pw.TextStyle(
                      fontSize: 18, fontWeight: pw.FontWeight.bold)),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Working Time Details"),
      ),
      body: Column(
        children: [
          if (userDetails != null) ...[
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Name: ${userDetails!['name']}",
                      style: TextStyle(fontSize: 18)),
                  Text("Email: ${userDetails!['email']}",
                      style: TextStyle(fontSize: 18)),
                  Text("User ID: ${widget.userId}",
                      style: TextStyle(fontSize: 18)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<int>(
                hint: Text("Select Month"),
                value: selectedMonth,
                items: List.generate(
                    12,
                    (index) => DropdownMenuItem(
                          child: Text(
                              DateFormat.MMMM().format(DateTime(0, index + 1))),
                          value: index + 1,
                        )),
                onChanged: (value) {
                  setState(() {
                    selectedMonth = value;
                    if (value != null) {
                      workingTimeFuture =
                          _getWorkingTimeDetails(widget.userId, value);
                    }
                  });
                },
              ),
            ),
          ],
          if (selectedMonth != null)
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: workingTimeFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                        child: Text(
                            "No working time records found for the selected month"));
                  } else {
                    final workingTimeData = snapshot.data!;
                    double totalHours = 0;

                    workingTimeData.forEach((record) {
                      totalHours += record['differenceInHours'];
                      totalHours += record['differenceInMinutes'] / 60;
                    });

                    return Column(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: DataTable(
                              columns: [
                                DataColumn(label: Text("Date")),
                                DataColumn(label: Text("Hours")),
                                DataColumn(label: Text("Minutes")),
                                DataColumn(label: Text("UserID")),
                              ],
                              rows: workingTimeData.map((record) {
                                Timestamp timestamp = record['date'];
                                DateTime date = timestamp.toDate();
                                return DataRow(
                                  cells: [
                                    DataCell(Text(DateFormat.yMMMd()
                                        .add_jm()
                                        .format(date))),
                                    DataCell(Text(record['differenceInHours']
                                        .toString())),
                                    DataCell(Text(record['differenceInMinutes']
                                        .toString())),
                                    DataCell(Text(record['userId'].toString())),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Text(
                            "Total Hours: ${totalHours.toStringAsFixed(2)}",
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _generatePdf(workingTimeData, selectedMonth!);
                          },
                          child: Text('Download as PDF'),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}
