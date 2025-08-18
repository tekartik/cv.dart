import 'package:cv/cv.dart';
import 'package:cv/src/cv_json_schema.dart';
import 'package:test/test.dart';

void main() {
  initCvJsonSchemaBuilders();

  void checkSchema(Map map) {
    expect(map.cv<CvJsonSchema>().toMap(), map);
    // map = jsonDecode(jsonEncode(map)) as Map;
    // expect(map.cv<CvJsonSchema>().toMap(), map);
  }

  test('basic', () {
    checkSchema(basicJsonSchemaExample1);
  });
  test('array', () {
    checkSchema(arrayOfThinksExample1);
  });
  test('enum', () {
    checkSchema(enumExample1);
  });
  test('regular expression', () {
    checkSchema(regularExpressionExample1);
  });
  test('complex example', () {
    checkSchema(complexObjectExample1);
  });
  test('conditionnal validation', () {
    checkSchema(conditionnalValidationExample1);
  });
  test('dependent schemas', () {
    checkSchema(dependentSchemasExample1);
  });
  test('conditionnal validation if else', () {
    checkSchema(conditionnalValidationExampleIfElse1);
  });
}

/// https://json-schema.org/learn/miscellaneous-examples#basic
final basicJsonSchemaExample1 = {
  r'$id': 'https://example.com/person.schema.json',
  r'$schema': 'https://json-schema.org/draft/2020-12/schema',
  'title': 'Person',
  'type': 'object',
  'properties': {
    'firstName': {'type': 'string', 'description': "The person's first name."},
    'lastName': {'type': 'string', 'description': "The person's last name."},
    'age': {
      'description':
          'Age in years which must be equal to or greater than zero.',
      'type': 'integer',
      'minimum': 0,
    },
  },
};

/// https://json-schema.org/learn/miscellaneous-examples#arrays-of-things
final arrayOfThinksExample1 = {
  r'$id': 'https://example.com/arrays.schema.json',
  r'$schema': 'https://json-schema.org/draft/2020-12/schema',
  'description': 'Arrays of strings and objects',
  'title': 'Arrays',
  'type': 'object',
  'properties': {
    'fruits': {
      'type': 'array',
      'items': {'type': 'string'},
    },
    'vegetables': {
      'type': 'array',
      'items': {r'$ref': r'#/$defs/veggie'},
    },
  },
  r'$defs': {
    'veggie': {
      'type': 'object',
      'required': ['veggieName', 'veggieLike'],
      'properties': {
        'veggieName': {
          'type': 'string',
          'description': 'The name of the vegetable.',
        },
        'veggieLike': {
          'type': 'boolean',
          'description': 'Do I like this vegetable?',
        },
      },
    },
  },
};

/// https://json-schema.org/learn/miscellaneous-examples#enumerated-values
final enumExample1 = {
  r'$id': 'https://example.com/enumerated-values.schema.json',
  r'$schema': 'https://json-schema.org/draft/2020-12/schema',
  'title': 'Enumerated Values',
  'type': 'object',
  'properties': {
    'data': {
      'enum': [
        42,
        true,
        'hello',
        null,
        [1, 2, 3],
      ],
    },
  },
};

/// https://json-schema.org/learn/miscellaneous-examples#regular-expression-pattern
final regularExpressionExample1 = {
  r'$id': 'https://example.com/regex-pattern.schema.json',
  r'$schema': 'https://json-schema.org/draft/2020-12/schema',
  'title': 'Regular Expression Pattern',
  'type': 'object',
  'properties': {
    'code': {'type': 'string', 'pattern': r'^[A-Z]{3}-\\d{3}$'},
  },
};

/// https://json-schema.org/learn/miscellaneous-examples#complex-object-with-nested-properties
final complexObjectExample1 = {
  r'$id': 'https://example.com/complex-object.schema.json',
  r'$schema': 'https://json-schema.org/draft/2020-12/schema',
  'title': 'Complex Object',
  'type': 'object',
  'properties': {
    'name': {'type': 'string'},
    'age': {'type': 'integer', 'minimum': 0},
    'address': {
      'type': 'object',
      'properties': {
        'street': {'type': 'string'},
        'city': {'type': 'string'},
        'state': {'type': 'string'},
        'postalCode': {'type': 'string', 'pattern': '\\d{5}'},
      },
      'required': ['street', 'city', 'state', 'postalCode'],
    },
    'hobbies': {
      'type': 'array',
      'items': {'type': 'string'},
    },
  },
  'required': ['name', 'age'],
};

/// https://json-schema.org/learn/miscellaneous-examples#conditional-validation-with-dependentrequired
final conditionnalValidationExample1 = {
  r'$id':
      'https://example.com/conditional-validation-dependentRequired.schema.json',
  r'$schema': 'https://json-schema.org/draft/2020-12/schema',
  'title': 'Conditional Validation with dependentRequired',
  'type': 'object',
  'properties': {
    'foo': {'type': 'boolean'},
    'bar': {'type': 'string'},
  },
  'dependentRequired': {
    'foo': ['bar'],
  },
};

/// https://json-schema.org/learn/miscellaneous-examples#conditional-validation-with-dependentschemas
const dependentSchemasExample1 = {
  r'$id':
      'https://example.com/conditional-validation-dependentSchemas.schema.json',
  r'$schema': 'https://json-schema.org/draft/2020-12/schema',
  'title': 'Conditional Validation with dependentSchemas',
  'type': 'object',
  'properties': {
    'foo': {'type': 'boolean'},
    'propertiesCount': {'type': 'integer', 'minimum': 0},
  },
  'dependentSchemas': {
    'foo': {
      'required': ['propertiesCount'],
      'properties': {
        'propertiesCount': {'minimum': 7},
      },
    },
  },
};

/// https://json-schema.org/learn/miscellaneous-examples#conditional-validation-with-if-else
const conditionnalValidationExampleIfElse1 = {
  r'$id': 'https://example.com/conditional-validation-if-else.schema.json',
  r'$schema': 'https://json-schema.org/draft/2020-12/schema',
  'title': 'Conditional Validation with If-Else',
  'type': 'object',
  'properties': {
    'isMember': {'type': 'boolean'},
    'membershipNumber': {'type': 'string'},
  },
  'required': ['isMember'],
  'if': {
    'properties': {
      'isMember': {'const': true},
    },
  },
  'then': {
    'properties': {
      'membershipNumber': {'type': 'string', 'minLength': 10, 'maxLength': 10},
    },
  },
  'else': {
    'properties': {
      'membershipNumber': {'type': 'string', 'minLength': 15},
    },
  },
};
