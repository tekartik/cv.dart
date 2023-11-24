import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:cv/cv.dart';
import 'package:matcher/matcher.dart';
import 'package:meta/meta.dart';

class _FillModelMatchesMapMatcher extends Matcher {
  final CvFillOptions? options;
  final Map? map;
  _FillModelMatchesMapMatcher(
    this.map,
    this.options,
  );
  CvModel? lastModel;

  @override
  bool matches(dynamic item, Map<dynamic, dynamic> matchState) {
    CvFillOptions? options;
    if (item is Type) {
      options = this.options?.copyWith();
      var referenceModel = cvTypeNewModel(item)..fillModel(options);
      var model = cvTypeNewModel(item);
      var filledMapModel = CvMapModel();
      if (map != null) {
        filledMapModel.fromMap(map!);
      }

      /// Override missing values.
      filledMapModel.copyFrom(referenceModel);

      /// re-fill the model
      options = this.options?.copyWith();
      // filledMapModel.fillModel(options);
      model.copyFrom(filledMapModel);
      lastModel = model;
      if (DeepCollectionEquality().equals(model.toMap(), map)) {
        return true;
      }
    } else if (item is CvModel) {
      return matches(item.runtimeType, matchState);
    }

    return false;
  }

  @override
  Description describe(Description description) {
    description = description.add('expecting map:\n');
    try {
      description = description.add(
          'expecting ${JsonEncoder.withIndent(' ').convert(lastModel?.toMap())}');
    } catch (e) {
      description = description.add('expecting $lastModel');
    }
    return description;
  }
}

/// Matches a map fill the model, handling any sort order of fields.
///
/// actual value can be a type or an object.
///
/// Not working yet
@experimental
Matcher fillModelMatchesMap(Map map, [CvFillOptions? options]) =>
    _FillModelMatchesMapMatcher(map, options);
