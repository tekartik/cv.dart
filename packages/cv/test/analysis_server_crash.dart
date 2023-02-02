import 'package:cv/cv.dart';
import 'package:cv/src/cv_model.dart';

abstract class MyModel implements CvModel {}

mixin MyModelMixin implements MyModel {}

// This makes dart analyzer crashes in dart 2.19.1, if you comment it, it is ok
abstract class MyModelBase extends CvModelBase
    with MyModelMixin
    implements MyModel {}
