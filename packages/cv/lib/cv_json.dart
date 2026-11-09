/// ContentValue Json helpers, also exports `package:cv/cv.dart`.
///
/// ```dart
/// cvAddConstructor(Note.new);
/// var note = '{"title":"My note"}'.cv<Note>();
/// var notes = '[{"title":"a"},{"title":"b"}]'.cvList<Note>();
/// print(note.toJson()); // {"title":"My note"}
/// print(notes.toJson()); // [{"title":"a"},{"title":"b"}]
/// ```
///
/// A `CvField<DateTime>` cannot be encoded to JSON, use
/// `CvField.encodedDateTime` instead.
library;

export 'cv.dart';
export 'src/cv_json.dart'
    show
        CvJsonModelExt,
        CvJsonModelListExt,
        CvJsonStringExt,
        jsonPrettyEncode,
        CvJsonListExt,
        CvJsonMapExt,
        cvAnyToJsonArrayOrNull,
        cvAnyToJsonObjectOrNull;
