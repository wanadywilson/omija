// globals.dart
List<Map<String, dynamic>> knownUsers = [];

String username = '';
String longName = '';
String phoneNumber = '';

String urlKirimFotoOcr = 'http://141.11.241.147:8080/process-ocr/';
String urlKirimReceipt = 'http://141.11.241.147:8080/splitbill/';
String urlGetHistoryByMe = 'http://141.11.241.147:8080/splitbill/creator/';
String urlGetHistoryForMe = 'http://141.11.241.147:8080/splitbill/related/';