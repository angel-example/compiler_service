library compiler_service.models.compilation_request;
import 'package:angel_validate/angel_validate.dart';

final Validator COMPILATION_REQUEST = new Validator({
  'name': [isString, isNotEmpty],
  'desc': [isString, isNotEmpty]
});

final Validator CREATE_COMPILATION_REQUEST = COMPILATION_REQUEST.extend({})
  ..requiredFields.addAll(['name', 'desc']);