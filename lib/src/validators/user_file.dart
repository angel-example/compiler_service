library compiler_service.models.user_file;
import 'package:angel_validate/angel_validate.dart';

final Validator USER_FILE = new Validator({
  'name': [isString, isNotEmpty],
  'desc': [isString, isNotEmpty]
});

final Validator CREATE_USER_FILE = USER_FILE.extend({})
  ..requiredFields.addAll(['name', 'desc']);