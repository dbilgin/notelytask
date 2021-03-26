import 'package:flutter/widgets.dart';

bool isSmallScreen(BuildContext context) {
  MediaQueryData queryData = MediaQuery.of(context);
  return queryData.size.width <= 500;
}
