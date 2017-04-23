library story.models.story;
import 'package:angel_validate/angel_validate.dart';

final Validator STORY = new Validator({
  'name': [isString, isNotEmpty],
  'desc': [isString, isNotEmpty]
});

final Validator CREATE_STORY = STORY.extend({})
  ..requiredFields.addAll(['name', 'desc']);