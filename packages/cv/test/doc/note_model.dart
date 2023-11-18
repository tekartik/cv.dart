import 'package:cv/cv.dart';

class Note extends CvModelBase {
  final title = CvField<String>('title');
  final content = CvField<String>('content');
  final date = CvField<DateTime>('date');

  @override
  CvFields get fields => [title, content, date];
}
