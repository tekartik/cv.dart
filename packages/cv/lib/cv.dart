/// ContentValue helpers: models converted to `Map<String, Object?>` and back,
/// without code generation.
///
/// A model extends [CvModelBase] and lists its [CvField]s in `fields`:
///
/// ```dart
/// class Note extends CvModelBase {
///   final title = CvField<String>('title');
///   final done = CvField<bool>('done');
///
///   @override
///   CvFields get fields => [title, done];
/// }
///
/// void main() {
///   // Register the model once, before map.cv<Note>() or clone().
///   cvAddConstructor(Note.new);
///
///   var note = Note()..title.v = 'Buy milk';
///   print(note.toMap()); // {title: Buy milk}
///   note = {'title': 'Call Bob', 'done': true}.cv<Note>();
/// }
/// ```
///
/// Nested models use [CvModelField], [CvModelListField] or [CvModelMapField];
/// their types must be registered too. Import `package:cv/cv_json.dart` for
/// the JSON helpers.
library;

export 'src/builder.dart'
    show
        cvAddBuilder,
        cvTypeAddBuilder,
        cvBuildModel,
        cvGetBuilder,
        cvTypeGetBuilder,
        cvTypeBuildModel,
        cvModelField,
        cvModelListField,
        CvMapExt,
        CvMapListExt,
        CvBuilderException,
        CvModelBuilderFunction,
        cvAddConstructor,
        cvAddConstructors,
        CvModelDefaultBuilderFunction;
export 'src/cv_column.dart' show CvColumn;
export 'src/cv_field.dart'
    show
        CvField,
        CvFields,
        cvValuesAreEqual,
        CvModelListField,
        CvModelMapField,
        CvListField,
        CvFieldListExt,
        CvModelField,
        CvModelFieldUtilsExt,
        CvModelMapFieldUtilsExt,
        CvFieldUtilsExt,
        CvListFieldUtilsExt,
        CvFillOptions,
        cvFillOptions1;
export 'src/cv_field_path.dart' show CvFieldPath;
export 'src/cv_model.dart'
    show
        CvModel,
        CvMapModel,
        CvModelBase,
        CvMapModelBase,
        CvModelUtilsExt,
        CvModelEmpty,
        cvTypeNewModel,
        cvNewModel;
export 'src/cv_model_list.dart'
    show CvModelListReadExt, cvNewModelList, cvTypeNewModelList;
export 'src/cv_model_map.dart' show CvModelMapReadExt;
export 'src/cv_model_mixin.dart'
    show CvModelWriteExt, CvModelReadExt, CvModelCloneExt;
export 'src/cv_model_tree_value.dart'
    show CvModelTreeValue, CvModelTreeValueExt;
export 'src/cv_multi_field.dart'
    show
        CvMultiField2,
        CvMultiField,
        CvMultiFieldUtilsExt,
        CvMultiListFieldUtilsExt,
        CvMultiListField,
        CvMultiListField2;
export 'src/cv_tree_path.dart'
    show
        CvTreePath,
        CvTreePathModelReadExt,
        CvTreePathFieldExt,
        CvTreePathListFieldExt,
        CvTreePathModelFieldExt,
        CvTreePathModelListFieldExt,
        CvTreePathModelMapField;
export 'src/list_ext.dart' show ModelRawListExt;
export 'src/map_ext.dart'
    show
        ModelRawMapExt,
        ModelRawMapReadExt,
        keyPartsToString,
        keyPartsFromString;
export 'src/map_list_ext.dart' show ModelListExt;
export 'src/object_ext.dart' show ModelRawObjectExt;
export 'src/typedefs.dart'
    show
        Model,
        ModelList,
        ModelEntry,
        asModel,
        asModelList,
        // ignore: deprecated_member_use_from_same_package
        NewModel,
        newModel,
        newModelList,
        CvBuilderFunction;
export 'src/utils.dart' show cvModelsAreEquals;
