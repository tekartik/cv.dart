import 'package:cv/cv.dart';

/// Init builders.
void initCvJsonSchemaBuilders() {
  cvAddConstructors([
    CvJsonSchema.new,
    CvJsonSchemaIf.new,
    CvJsonSchemaThen.new,
    CvJsonSchemaIfProperty.new,
  ]);
}

/// Json schema class
class CvJsonSchema extends CvModelBase {
  /// string
  static const typeString = 'string';

  /// number
  static const typeNumber = 'number';

  /// integer
  static const typeInteger = 'integer';

  /// boolean
  static const typeBoolean = 'boolean';

  /// object
  static const typeObject = 'object';

  /// array
  static const typeArray = 'array';

  /// null
  static const typeNull = 'null';

  /// $schema
  final jsonSchema = CvField<String>(r'$schema');

  /// $id
  final schemaId = CvField<String>(r'$id');

  /// type
  final type = CvField<String>('type');

  /// title
  final title = CvField<String>('title');

  /// description
  final description = CvField<String>('description');

  /// required (required is a list of strings)
  final required = CvField<List>(
    // List<String>>(
    'required',
  );

  /// properties
  final properties = CvModelMapField<CvJsonSchema>('properties');

  /// pattern constraint
  final pattern = CvField<String>('pattern');

  /// minimum (for numbers)
  final minimum = CvField<num>('minimum');

  /// maximum (for numbers)
  final maximum = CvField<num>('maximum');

  /// minLength (for string)
  final minLength = CvField<int>('minLength');

  /// maxLength (for string)
  final maxLength = CvField<int>('maxLength');

  /// items (for array)
  final items = CvModelField<CvJsonSchema>('items');

  /// Dependent required, each value is a list of string
  final dependentRequired = CvField<Map>(
    // Map<String, List<String>>>(
    'dependentRequired',
  );

  /// Dependent schemas
  final dependentSchemas = CvModelMapField<CvJsonSchema>('dependentSchemas');

  /// If
  final ifField = CvModelField<CvJsonSchemaIf>('if');

  /// then
  final thenField = CvModelField<CvJsonSchema>('then');

  /// then
  final elseField = CvModelField<CvJsonSchema>('else');

  /// enum, each value is a list of values (null supported too)
  final enumField = CvField<List>('enum');

  /// $def (can only be at the root)
  final schemaDef = CvModelMapField<CvJsonSchema>(r'$defs');

  /// $ref
  final schemaRef = CvField<String>(r'$ref');

  @override
  CvFields get fields => [
    jsonSchema,
    schemaId,
    type,
    title,
    description,
    required,
    properties,
    pattern,
    minimum,
    maximum,
    minLength,
    maxLength,
    items,
    dependentRequired,
    dependentSchemas,
    ifField,
    thenField,
    elseField,
    enumField,
    schemaDef,
    schemaRef,
  ];
}

/// If property definition
class CvJsonSchemaIfProperty extends CvModelBase {
  /// const value
  final constField = CvField<Object>('const');

  @override
  CvFields get fields => [constField];
}

/// If definition
class CvJsonSchemaIf extends CvModelBase {
  /// const value
  final properties = CvModelMapField<CvJsonSchemaIfProperty>('properties');

  @override
  CvFields get fields => [properties];
}

/// Then definition
class CvJsonSchemaThen extends CvModelBase {
  /// const value
  final properties = CvModelMapField<CvJsonSchema>('properties');

  @override
  CvFields get fields => [properties];
}

/// Else definition
typedef CvJsonSchemaElse = CvJsonSchemaThen;
