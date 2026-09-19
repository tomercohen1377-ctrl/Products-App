import 'package:flutter/widgets.dart';
import 'package:mylo_products/app/app.dart';
import 'package:mylo_products/app/bootstrap.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyloApp(getIt: bootstrap()));
}
