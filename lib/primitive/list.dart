// Copyright 2024 ProntoGUI, LLC.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:app/primitive/cbor_conversion.dart';
import 'package:cbor/cbor.dart';
import 'events.dart';
import 'primitive.dart';
import 'primitive_base.dart';
import 'pkey.dart';
import 'fkey.dart';

/// The List primitive.
///
/// A list is a collection of primitives that have a sequential-like
/// relationship and might be dynamic in quantity or kind.
///
/// Note:  the name ListP strays from how other primitives are named.  This is needed
/// to avoid type collision with List<T>.
abstract class ListP {
  /// Accessor for the ListItems field.
  ///
  /// The list items are the primitives shown according to the embodiment.
  List<Primitive> get listItems;

  /// Accessor for the Selected field.
  ///
  /// This is the currently selected item in the list and ranges from 0 (first iteM)
  /// to #items - 1 (last item).  It is -1 if nothing is selected.
  int get selected;

  /// Update the selected field and notify listeners with an update.
  ///
  /// Embodiments call this method whenever the selection is changed.
  void updateSelected(int newSelected);
}

class ListImpl extends PrimitiveBase implements ListP {
  /// Creates a List primitive.
  ///
  ///A list is a collection of primitives that have a sequential-like
  /// relationship and might be dynamic in quantity or kind.
  ListImpl(super.ctorArgs);

  /// Storage for the ListItems field.
  @override
  List<Primitive> listItems = [];

  @override
  int selected = -1;

  /// Notify listeners that selection was updated.
  void notifyUpdated() {
    var fieldUpdates = CborMap({
      CborString("Selected"): CborSmallInt(selected),
    });

    eventHandler.call(EventType.selectedChanged, pkey, fieldUpdates);
  }

  @override
  void updateSelected(int newSelected) {
    selected = newSelected;
    notifyUpdated();
  }

  // Overrides for PrimitiveBase class.
  @override
  bool get isNotificationPoint {
    return true;
  }

  /// Implements the unmarshalling and storage of fields.
  @override
  void updateFieldFromCbor(FKey fkey, CborValue v) {
    // Note:  fields should be handled in alphabetical order with containerIndex
    // increasing monotonically in the switch structure below.
    switch (fkey) {
      case FKey.listItems:
        listItems = createPrimitivesFromCborList1D(v, 0);
      case FKey.selected:
        selected = cborToInt(v);
      default:
        assert(false);
    }
  }

  /// Implements the locating of descendant primitives, since this is a container.
  @override
  Primitive locateDescendant(PKeyLocator locator) {
    // First index refers to the primitive field that contains primitive(s)
    var fieldIndex = locator.nextIndex();

    if (fieldIndex == 0) {
      var itemIndex = locator.nextIndex();
      assert(itemIndex < listItems.length);

      return listItems[itemIndex];
    }

    // TODO:  log this error somehow
    assert(false, 'cannot locate descendent at fieldIndex = $fieldIndex');
    throw Exception('cannot locate descendent at fieldIndex = $fieldIndex');
  }
}
