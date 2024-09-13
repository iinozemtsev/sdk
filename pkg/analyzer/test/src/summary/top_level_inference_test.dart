// Copyright (c) 2017, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/src/dart/element/element.dart';
import 'package:analyzer/src/error/codes.dart';
import 'package:test_reflective_loader/test_reflective_loader.dart';

import '../dart/resolution/node_text_expectations.dart';
import 'elements_base.dart';

main() {
  defineReflectiveSuite(() {
    defineReflectiveTests(TopLevelInferenceTest);
    defineReflectiveTests(TopLevelInferenceErrorsTest);
    defineReflectiveTests(UpdateNodeTextExpectations);
  });
}

@reflectiveTest
class TopLevelInferenceErrorsTest extends ElementsBaseTest {
  @override
  bool get keepLinkingLibraries => true;

  test_initializer_additive() async {
    await _assertErrorOnlyLeft(['+', '-']);
  }

  test_initializer_assign() async {
    await assertNoErrorsInCode('''
var a = 1;
var t1 = a += 1;
var t2 = a = 2;
''');
  }

  test_initializer_binary_onlyLeft() async {
    await assertNoErrorsInCode('''
var a = 1;
var t = (a = 1) + (a = 2);
''');
  }

  test_initializer_bitwise() async {
    await _assertErrorOnlyLeft(['&', '|', '^']);
  }

  test_initializer_boolean() async {
    await assertNoErrorsInCode('''
var a = 1;
var t1 = ((a = 1) == 0) || ((a = 2) == 0);
var t2 = ((a = 1) == 0) && ((a = 2) == 0);
var t3 = !((a = 1) == 0);
''');
  }

  test_initializer_cascade() async {
    await assertNoErrorsInCode('''
var a = 0;
var t = (a = 1)..isEven;
''');
  }

  test_initializer_classField_instance_instanceCreation() async {
    await assertNoErrorsInCode('''
class A<T> {}
class B {
  var t1 = new A<int>();
  var t2 = new A();
}
''');
  }

  test_initializer_classField_static_instanceCreation() async {
    await assertNoErrorsInCode('''
class A<T> {}
class B {
  static var t1 = 1;
  static var t2 = new A();
}
''');
  }

  test_initializer_conditional() async {
    await assertNoErrorsInCode('''
var a = 1;
var b = true;
var t = b
    ? (a = 1)
    : (a = 2);
''');
  }

  test_initializer_dependencyCycle() async {
    await assertErrorsInCode('''
var a = b;
var b = a;
''', [
      error(CompileTimeErrorCode.TOP_LEVEL_CYCLE, 4, 1),
      error(CompileTimeErrorCode.TOP_LEVEL_CYCLE, 15, 1),
    ]);
  }

  test_initializer_equality() async {
    await assertNoErrorsInCode('''
var a = 1;
var t1 = ((a = 1) == 0) == ((a = 2) == 0);
var t2 = ((a = 1) == 0) != ((a = 2) == 0);
''');
  }

  test_initializer_extractIndex() async {
    await assertNoErrorsInCode('''
var a = [0, 1.2];
var b0 = a[0];
var b1 = a[1];
''');
  }

  test_initializer_functionLiteral_blockBody() async {
    await assertNoErrorsInCode('''
var t = (int p) {};
''');
    assertType(
      findElement.topVar('t').type,
      'Null Function(int)',
    );
  }

  test_initializer_functionLiteral_expressionBody() async {
    await assertNoErrorsInCode('''
var a = 0;
var t = (int p) => (a = 1);
''');
    assertType(
      findElement.topVar('t').type,
      'int Function(int)',
    );
  }

  test_initializer_functionLiteral_parameters_withoutType() async {
    await assertNoErrorsInCode('''
var t = (int a, b,int c, d) => 0;
''');
    assertType(
      findElement.topVar('t').type,
      'int Function(int, dynamic, int, dynamic)',
    );
  }

  test_initializer_hasTypeAnnotation() async {
    await assertNoErrorsInCode('''
var a = 1;
int t = (a = 1);
''');
  }

  test_initializer_identifier() async {
    await assertNoErrorsInCode('''
int top_function() => 0;
var top_variable = 0;
int get top_getter => 0;
class A {
  static var static_field = 0;
  static int get static_getter => 0;
  static int static_method() => 0;
  int instance_method() => 0;
}
var t1 = top_function;
var t2 = top_variable;
var t3 = top_getter;
var t4 = A.static_field;
var t5 = A.static_getter;
var t6 = A.static_method;
var t7 = new A().instance_method;
''');
  }

  test_initializer_identifier_error() async {
    await assertNoErrorsInCode('''
var a = 0;
var b = (a = 1);
var c = b;
''');
  }

  test_initializer_ifNull() async {
    await assertNoErrorsInCode('''
int? a = 1;
var t = a ?? 2;
''');
  }

  test_initializer_instanceCreation_withoutTypeParameters() async {
    await assertNoErrorsInCode('''
class A {}
var t = new A();
''');
  }

  test_initializer_instanceCreation_withTypeParameters() async {
    await assertNoErrorsInCode('''
class A<T> {}
var t1 = new A<int>();
var t2 = new A();
''');
  }

  test_initializer_instanceGetter() async {
    await assertNoErrorsInCode('''
class A {
  int f = 1;
}
var a = new A().f;
''');
  }

  test_initializer_methodInvocation_function() async {
    await assertNoErrorsInCode('''
int f1() => 0;
T f2<T>() => throw 0;
var t1 = f1();
var t2 = f2();
var t3 = f2<int>();
''');
  }

  test_initializer_methodInvocation_method() async {
    await assertNoErrorsInCode('''
class A {
  int m1() => 0;
  T m2<T>() => throw 0;
}
var a = new A();
var t1 = a.m1();
var t2 = a.m2();
var t3 = a.m2<int>();
''');
  }

  test_initializer_multiplicative() async {
    await _assertErrorOnlyLeft(['*', '/', '%', '~/']);
  }

  test_initializer_postfixIncDec() async {
    await assertNoErrorsInCode('''
var a = 1;
var t1 = a++;
var t2 = a--;
''');
  }

  test_initializer_prefixIncDec() async {
    await assertNoErrorsInCode('''
var a = 1;
var t1 = ++a;
var t2 = --a;
''');
  }

  test_initializer_relational() async {
    await _assertErrorOnlyLeft(['>', '>=', '<', '<=']);
  }

  test_initializer_shift() async {
    await _assertErrorOnlyLeft(['<<', '>>']);
  }

  test_initializer_typedList() async {
    await assertNoErrorsInCode('''
var a = 1;
var t = <int>[a = 1];
''');
  }

  test_initializer_typedMap() async {
    await assertNoErrorsInCode('''
var a = 1;
var t = <int, int>{(a = 1) : (a = 2)};
''');
  }

  test_initializer_untypedList() async {
    await assertNoErrorsInCode('''
var a = 1;
var t = [
    a = 1,
    2,
    3,
];
''');
  }

  test_initializer_untypedMap() async {
    await assertNoErrorsInCode('''
var a = 1;
var t = {
    (a = 1) :
        (a = 2),
};
''');
  }

  test_override_conflictFieldType() async {
    await assertErrorsInCode('''
abstract class A {
  int aaa = 0;
}
abstract class B {
  String aaa = '0';
}
class C implements A, B {
  var aaa;
}
''', [
      error(CompileTimeErrorCode.INVALID_OVERRIDE, 109, 3,
          contextMessages: [message(testFile, 64, 3)]),
      error(CompileTimeErrorCode.INVALID_OVERRIDE, 109, 3,
          contextMessages: [message(testFile, 25, 3)]),
    ]);
  }

  test_override_conflictParameterType_method() async {
    await assertErrorsInCode('''
abstract class A {
  void mmm(int a);
}
abstract class B {
  void mmm(String a);
}
class C implements A, B {
  void mmm(a) {}
}
''', [
      error(CompileTimeErrorCode.NO_COMBINED_SUPER_SIGNATURE, 116, 3),
    ]);
  }

  Future<void> _assertErrorOnlyLeft(List<String> operators) async {
    String code = 'var a = 1;\n';
    for (var i = 0; i < operators.length; i++) {
      String operator = operators[i];
      code += 'var t$i = (a = 1) $operator (a = 2);\n';
    }
    await assertNoErrorsInCode(code);
  }
}

@reflectiveTest
class TopLevelInferenceTest extends ElementsBaseTest {
  @override
  bool get keepLinkingLibraries => true;

  test_initializer_additive() async {
    var library = await _encodeDecodeLibrary(r'''
var vPlusIntInt = 1 + 2;
var vPlusIntDouble = 1 + 2.0;
var vPlusDoubleInt = 1.0 + 2;
var vPlusDoubleDouble = 1.0 + 2.0;
var vMinusIntInt = 1 - 2;
var vMinusIntDouble = 1 - 2.0;
var vMinusDoubleInt = 1.0 - 2;
var vMinusDoubleDouble = 1.0 - 2.0;
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      topLevelVariables
        static vPlusIntInt @4
          reference: <testLibraryFragment>::@topLevelVariable::vPlusIntInt
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
        static vPlusIntDouble @29
          reference: <testLibraryFragment>::@topLevelVariable::vPlusIntDouble
          enclosingElement3: <testLibraryFragment>
          type: double
          shouldUseTypeForInitializerInference: false
        static vPlusDoubleInt @59
          reference: <testLibraryFragment>::@topLevelVariable::vPlusDoubleInt
          enclosingElement3: <testLibraryFragment>
          type: double
          shouldUseTypeForInitializerInference: false
        static vPlusDoubleDouble @89
          reference: <testLibraryFragment>::@topLevelVariable::vPlusDoubleDouble
          enclosingElement3: <testLibraryFragment>
          type: double
          shouldUseTypeForInitializerInference: false
        static vMinusIntInt @124
          reference: <testLibraryFragment>::@topLevelVariable::vMinusIntInt
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
        static vMinusIntDouble @150
          reference: <testLibraryFragment>::@topLevelVariable::vMinusIntDouble
          enclosingElement3: <testLibraryFragment>
          type: double
          shouldUseTypeForInitializerInference: false
        static vMinusDoubleInt @181
          reference: <testLibraryFragment>::@topLevelVariable::vMinusDoubleInt
          enclosingElement3: <testLibraryFragment>
          type: double
          shouldUseTypeForInitializerInference: false
        static vMinusDoubleDouble @212
          reference: <testLibraryFragment>::@topLevelVariable::vMinusDoubleDouble
          enclosingElement3: <testLibraryFragment>
          type: double
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get vPlusIntInt @-1
          reference: <testLibraryFragment>::@getter::vPlusIntInt
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set vPlusIntInt= @-1
          reference: <testLibraryFragment>::@setter::vPlusIntInt
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vPlusIntInt @-1
              type: int
          returnType: void
        synthetic static get vPlusIntDouble @-1
          reference: <testLibraryFragment>::@getter::vPlusIntDouble
          enclosingElement3: <testLibraryFragment>
          returnType: double
        synthetic static set vPlusIntDouble= @-1
          reference: <testLibraryFragment>::@setter::vPlusIntDouble
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vPlusIntDouble @-1
              type: double
          returnType: void
        synthetic static get vPlusDoubleInt @-1
          reference: <testLibraryFragment>::@getter::vPlusDoubleInt
          enclosingElement3: <testLibraryFragment>
          returnType: double
        synthetic static set vPlusDoubleInt= @-1
          reference: <testLibraryFragment>::@setter::vPlusDoubleInt
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vPlusDoubleInt @-1
              type: double
          returnType: void
        synthetic static get vPlusDoubleDouble @-1
          reference: <testLibraryFragment>::@getter::vPlusDoubleDouble
          enclosingElement3: <testLibraryFragment>
          returnType: double
        synthetic static set vPlusDoubleDouble= @-1
          reference: <testLibraryFragment>::@setter::vPlusDoubleDouble
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vPlusDoubleDouble @-1
              type: double
          returnType: void
        synthetic static get vMinusIntInt @-1
          reference: <testLibraryFragment>::@getter::vMinusIntInt
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set vMinusIntInt= @-1
          reference: <testLibraryFragment>::@setter::vMinusIntInt
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vMinusIntInt @-1
              type: int
          returnType: void
        synthetic static get vMinusIntDouble @-1
          reference: <testLibraryFragment>::@getter::vMinusIntDouble
          enclosingElement3: <testLibraryFragment>
          returnType: double
        synthetic static set vMinusIntDouble= @-1
          reference: <testLibraryFragment>::@setter::vMinusIntDouble
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vMinusIntDouble @-1
              type: double
          returnType: void
        synthetic static get vMinusDoubleInt @-1
          reference: <testLibraryFragment>::@getter::vMinusDoubleInt
          enclosingElement3: <testLibraryFragment>
          returnType: double
        synthetic static set vMinusDoubleInt= @-1
          reference: <testLibraryFragment>::@setter::vMinusDoubleInt
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vMinusDoubleInt @-1
              type: double
          returnType: void
        synthetic static get vMinusDoubleDouble @-1
          reference: <testLibraryFragment>::@getter::vMinusDoubleDouble
          enclosingElement3: <testLibraryFragment>
          returnType: double
        synthetic static set vMinusDoubleDouble= @-1
          reference: <testLibraryFragment>::@setter::vMinusDoubleDouble
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vMinusDoubleDouble @-1
              type: double
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      topLevelVariables
        vPlusIntInt @4
          reference: <testLibraryFragment>::@topLevelVariable::vPlusIntInt
          element: <none>
          getter2: <testLibraryFragment>::@getter::vPlusIntInt
          setter2: <testLibraryFragment>::@setter::vPlusIntInt
        vPlusIntDouble @29
          reference: <testLibraryFragment>::@topLevelVariable::vPlusIntDouble
          element: <none>
          getter2: <testLibraryFragment>::@getter::vPlusIntDouble
          setter2: <testLibraryFragment>::@setter::vPlusIntDouble
        vPlusDoubleInt @59
          reference: <testLibraryFragment>::@topLevelVariable::vPlusDoubleInt
          element: <none>
          getter2: <testLibraryFragment>::@getter::vPlusDoubleInt
          setter2: <testLibraryFragment>::@setter::vPlusDoubleInt
        vPlusDoubleDouble @89
          reference: <testLibraryFragment>::@topLevelVariable::vPlusDoubleDouble
          element: <none>
          getter2: <testLibraryFragment>::@getter::vPlusDoubleDouble
          setter2: <testLibraryFragment>::@setter::vPlusDoubleDouble
        vMinusIntInt @124
          reference: <testLibraryFragment>::@topLevelVariable::vMinusIntInt
          element: <none>
          getter2: <testLibraryFragment>::@getter::vMinusIntInt
          setter2: <testLibraryFragment>::@setter::vMinusIntInt
        vMinusIntDouble @150
          reference: <testLibraryFragment>::@topLevelVariable::vMinusIntDouble
          element: <none>
          getter2: <testLibraryFragment>::@getter::vMinusIntDouble
          setter2: <testLibraryFragment>::@setter::vMinusIntDouble
        vMinusDoubleInt @181
          reference: <testLibraryFragment>::@topLevelVariable::vMinusDoubleInt
          element: <none>
          getter2: <testLibraryFragment>::@getter::vMinusDoubleInt
          setter2: <testLibraryFragment>::@setter::vMinusDoubleInt
        vMinusDoubleDouble @212
          reference: <testLibraryFragment>::@topLevelVariable::vMinusDoubleDouble
          element: <none>
          getter2: <testLibraryFragment>::@getter::vMinusDoubleDouble
          setter2: <testLibraryFragment>::@setter::vMinusDoubleDouble
      getters
        get vPlusIntInt @-1
          reference: <testLibraryFragment>::@getter::vPlusIntInt
          element: <none>
        get vPlusIntDouble @-1
          reference: <testLibraryFragment>::@getter::vPlusIntDouble
          element: <none>
        get vPlusDoubleInt @-1
          reference: <testLibraryFragment>::@getter::vPlusDoubleInt
          element: <none>
        get vPlusDoubleDouble @-1
          reference: <testLibraryFragment>::@getter::vPlusDoubleDouble
          element: <none>
        get vMinusIntInt @-1
          reference: <testLibraryFragment>::@getter::vMinusIntInt
          element: <none>
        get vMinusIntDouble @-1
          reference: <testLibraryFragment>::@getter::vMinusIntDouble
          element: <none>
        get vMinusDoubleInt @-1
          reference: <testLibraryFragment>::@getter::vMinusDoubleInt
          element: <none>
        get vMinusDoubleDouble @-1
          reference: <testLibraryFragment>::@getter::vMinusDoubleDouble
          element: <none>
      setters
        set vPlusIntInt= @-1
          reference: <testLibraryFragment>::@setter::vPlusIntInt
          element: <none>
          parameters
            _vPlusIntInt @-1
              element: <none>
        set vPlusIntDouble= @-1
          reference: <testLibraryFragment>::@setter::vPlusIntDouble
          element: <none>
          parameters
            _vPlusIntDouble @-1
              element: <none>
        set vPlusDoubleInt= @-1
          reference: <testLibraryFragment>::@setter::vPlusDoubleInt
          element: <none>
          parameters
            _vPlusDoubleInt @-1
              element: <none>
        set vPlusDoubleDouble= @-1
          reference: <testLibraryFragment>::@setter::vPlusDoubleDouble
          element: <none>
          parameters
            _vPlusDoubleDouble @-1
              element: <none>
        set vMinusIntInt= @-1
          reference: <testLibraryFragment>::@setter::vMinusIntInt
          element: <none>
          parameters
            _vMinusIntInt @-1
              element: <none>
        set vMinusIntDouble= @-1
          reference: <testLibraryFragment>::@setter::vMinusIntDouble
          element: <none>
          parameters
            _vMinusIntDouble @-1
              element: <none>
        set vMinusDoubleInt= @-1
          reference: <testLibraryFragment>::@setter::vMinusDoubleInt
          element: <none>
          parameters
            _vMinusDoubleInt @-1
              element: <none>
        set vMinusDoubleDouble= @-1
          reference: <testLibraryFragment>::@setter::vMinusDoubleDouble
          element: <none>
          parameters
            _vMinusDoubleDouble @-1
              element: <none>
  topLevelVariables
    vPlusIntInt
      firstFragment: <testLibraryFragment>::@topLevelVariable::vPlusIntInt
      type: int
      getter: <none>
      setter: <none>
    vPlusIntDouble
      firstFragment: <testLibraryFragment>::@topLevelVariable::vPlusIntDouble
      type: double
      getter: <none>
      setter: <none>
    vPlusDoubleInt
      firstFragment: <testLibraryFragment>::@topLevelVariable::vPlusDoubleInt
      type: double
      getter: <none>
      setter: <none>
    vPlusDoubleDouble
      firstFragment: <testLibraryFragment>::@topLevelVariable::vPlusDoubleDouble
      type: double
      getter: <none>
      setter: <none>
    vMinusIntInt
      firstFragment: <testLibraryFragment>::@topLevelVariable::vMinusIntInt
      type: int
      getter: <none>
      setter: <none>
    vMinusIntDouble
      firstFragment: <testLibraryFragment>::@topLevelVariable::vMinusIntDouble
      type: double
      getter: <none>
      setter: <none>
    vMinusDoubleInt
      firstFragment: <testLibraryFragment>::@topLevelVariable::vMinusDoubleInt
      type: double
      getter: <none>
      setter: <none>
    vMinusDoubleDouble
      firstFragment: <testLibraryFragment>::@topLevelVariable::vMinusDoubleDouble
      type: double
      getter: <none>
      setter: <none>
  getters
    synthetic static get vPlusIntInt
      firstFragment: <testLibraryFragment>::@getter::vPlusIntInt
    synthetic static get vPlusIntDouble
      firstFragment: <testLibraryFragment>::@getter::vPlusIntDouble
    synthetic static get vPlusDoubleInt
      firstFragment: <testLibraryFragment>::@getter::vPlusDoubleInt
    synthetic static get vPlusDoubleDouble
      firstFragment: <testLibraryFragment>::@getter::vPlusDoubleDouble
    synthetic static get vMinusIntInt
      firstFragment: <testLibraryFragment>::@getter::vMinusIntInt
    synthetic static get vMinusIntDouble
      firstFragment: <testLibraryFragment>::@getter::vMinusIntDouble
    synthetic static get vMinusDoubleInt
      firstFragment: <testLibraryFragment>::@getter::vMinusDoubleInt
    synthetic static get vMinusDoubleDouble
      firstFragment: <testLibraryFragment>::@getter::vMinusDoubleDouble
  setters
    synthetic static set vPlusIntInt=
      firstFragment: <testLibraryFragment>::@setter::vPlusIntInt
      parameters
        requiredPositional _vPlusIntInt
          type: int
    synthetic static set vPlusIntDouble=
      firstFragment: <testLibraryFragment>::@setter::vPlusIntDouble
      parameters
        requiredPositional _vPlusIntDouble
          type: double
    synthetic static set vPlusDoubleInt=
      firstFragment: <testLibraryFragment>::@setter::vPlusDoubleInt
      parameters
        requiredPositional _vPlusDoubleInt
          type: double
    synthetic static set vPlusDoubleDouble=
      firstFragment: <testLibraryFragment>::@setter::vPlusDoubleDouble
      parameters
        requiredPositional _vPlusDoubleDouble
          type: double
    synthetic static set vMinusIntInt=
      firstFragment: <testLibraryFragment>::@setter::vMinusIntInt
      parameters
        requiredPositional _vMinusIntInt
          type: int
    synthetic static set vMinusIntDouble=
      firstFragment: <testLibraryFragment>::@setter::vMinusIntDouble
      parameters
        requiredPositional _vMinusIntDouble
          type: double
    synthetic static set vMinusDoubleInt=
      firstFragment: <testLibraryFragment>::@setter::vMinusDoubleInt
      parameters
        requiredPositional _vMinusDoubleInt
          type: double
    synthetic static set vMinusDoubleDouble=
      firstFragment: <testLibraryFragment>::@setter::vMinusDoubleDouble
      parameters
        requiredPositional _vMinusDoubleDouble
          type: double
''');
  }

  test_initializer_as() async {
    var library = await _encodeDecodeLibrary(r'''
var V = 1 as num;
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      topLevelVariables
        static V @4
          reference: <testLibraryFragment>::@topLevelVariable::V
          enclosingElement3: <testLibraryFragment>
          type: num
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get V @-1
          reference: <testLibraryFragment>::@getter::V
          enclosingElement3: <testLibraryFragment>
          returnType: num
        synthetic static set V= @-1
          reference: <testLibraryFragment>::@setter::V
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _V @-1
              type: num
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      topLevelVariables
        V @4
          reference: <testLibraryFragment>::@topLevelVariable::V
          element: <none>
          getter2: <testLibraryFragment>::@getter::V
          setter2: <testLibraryFragment>::@setter::V
      getters
        get V @-1
          reference: <testLibraryFragment>::@getter::V
          element: <none>
      setters
        set V= @-1
          reference: <testLibraryFragment>::@setter::V
          element: <none>
          parameters
            _V @-1
              element: <none>
  topLevelVariables
    V
      firstFragment: <testLibraryFragment>::@topLevelVariable::V
      type: num
      getter: <none>
      setter: <none>
  getters
    synthetic static get V
      firstFragment: <testLibraryFragment>::@getter::V
  setters
    synthetic static set V=
      firstFragment: <testLibraryFragment>::@setter::V
      parameters
        requiredPositional _V
          type: num
''');
  }

  test_initializer_assign() async {
    var library = await _encodeDecodeLibrary(r'''
var a = 1;
var t1 = (a = 2);
var t2 = (a += 2);
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      topLevelVariables
        static a @4
          reference: <testLibraryFragment>::@topLevelVariable::a
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
        static t1 @15
          reference: <testLibraryFragment>::@topLevelVariable::t1
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
        static t2 @33
          reference: <testLibraryFragment>::@topLevelVariable::t2
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get a @-1
          reference: <testLibraryFragment>::@getter::a
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set a= @-1
          reference: <testLibraryFragment>::@setter::a
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _a @-1
              type: int
          returnType: void
        synthetic static get t1 @-1
          reference: <testLibraryFragment>::@getter::t1
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set t1= @-1
          reference: <testLibraryFragment>::@setter::t1
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _t1 @-1
              type: int
          returnType: void
        synthetic static get t2 @-1
          reference: <testLibraryFragment>::@getter::t2
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set t2= @-1
          reference: <testLibraryFragment>::@setter::t2
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _t2 @-1
              type: int
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      topLevelVariables
        a @4
          reference: <testLibraryFragment>::@topLevelVariable::a
          element: <none>
          getter2: <testLibraryFragment>::@getter::a
          setter2: <testLibraryFragment>::@setter::a
        t1 @15
          reference: <testLibraryFragment>::@topLevelVariable::t1
          element: <none>
          getter2: <testLibraryFragment>::@getter::t1
          setter2: <testLibraryFragment>::@setter::t1
        t2 @33
          reference: <testLibraryFragment>::@topLevelVariable::t2
          element: <none>
          getter2: <testLibraryFragment>::@getter::t2
          setter2: <testLibraryFragment>::@setter::t2
      getters
        get a @-1
          reference: <testLibraryFragment>::@getter::a
          element: <none>
        get t1 @-1
          reference: <testLibraryFragment>::@getter::t1
          element: <none>
        get t2 @-1
          reference: <testLibraryFragment>::@getter::t2
          element: <none>
      setters
        set a= @-1
          reference: <testLibraryFragment>::@setter::a
          element: <none>
          parameters
            _a @-1
              element: <none>
        set t1= @-1
          reference: <testLibraryFragment>::@setter::t1
          element: <none>
          parameters
            _t1 @-1
              element: <none>
        set t2= @-1
          reference: <testLibraryFragment>::@setter::t2
          element: <none>
          parameters
            _t2 @-1
              element: <none>
  topLevelVariables
    a
      firstFragment: <testLibraryFragment>::@topLevelVariable::a
      type: int
      getter: <none>
      setter: <none>
    t1
      firstFragment: <testLibraryFragment>::@topLevelVariable::t1
      type: int
      getter: <none>
      setter: <none>
    t2
      firstFragment: <testLibraryFragment>::@topLevelVariable::t2
      type: int
      getter: <none>
      setter: <none>
  getters
    synthetic static get a
      firstFragment: <testLibraryFragment>::@getter::a
    synthetic static get t1
      firstFragment: <testLibraryFragment>::@getter::t1
    synthetic static get t2
      firstFragment: <testLibraryFragment>::@getter::t2
  setters
    synthetic static set a=
      firstFragment: <testLibraryFragment>::@setter::a
      parameters
        requiredPositional _a
          type: int
    synthetic static set t1=
      firstFragment: <testLibraryFragment>::@setter::t1
      parameters
        requiredPositional _t1
          type: int
    synthetic static set t2=
      firstFragment: <testLibraryFragment>::@setter::t2
      parameters
        requiredPositional _t2
          type: int
''');
  }

  test_initializer_assign_indexed() async {
    var library = await _encodeDecodeLibrary(r'''
var a = [0];
var t1 = (a[0] = 2);
var t2 = (a[0] += 2);
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      topLevelVariables
        static a @4
          reference: <testLibraryFragment>::@topLevelVariable::a
          enclosingElement3: <testLibraryFragment>
          type: List<int>
          shouldUseTypeForInitializerInference: false
        static t1 @17
          reference: <testLibraryFragment>::@topLevelVariable::t1
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
        static t2 @38
          reference: <testLibraryFragment>::@topLevelVariable::t2
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get a @-1
          reference: <testLibraryFragment>::@getter::a
          enclosingElement3: <testLibraryFragment>
          returnType: List<int>
        synthetic static set a= @-1
          reference: <testLibraryFragment>::@setter::a
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _a @-1
              type: List<int>
          returnType: void
        synthetic static get t1 @-1
          reference: <testLibraryFragment>::@getter::t1
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set t1= @-1
          reference: <testLibraryFragment>::@setter::t1
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _t1 @-1
              type: int
          returnType: void
        synthetic static get t2 @-1
          reference: <testLibraryFragment>::@getter::t2
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set t2= @-1
          reference: <testLibraryFragment>::@setter::t2
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _t2 @-1
              type: int
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      topLevelVariables
        a @4
          reference: <testLibraryFragment>::@topLevelVariable::a
          element: <none>
          getter2: <testLibraryFragment>::@getter::a
          setter2: <testLibraryFragment>::@setter::a
        t1 @17
          reference: <testLibraryFragment>::@topLevelVariable::t1
          element: <none>
          getter2: <testLibraryFragment>::@getter::t1
          setter2: <testLibraryFragment>::@setter::t1
        t2 @38
          reference: <testLibraryFragment>::@topLevelVariable::t2
          element: <none>
          getter2: <testLibraryFragment>::@getter::t2
          setter2: <testLibraryFragment>::@setter::t2
      getters
        get a @-1
          reference: <testLibraryFragment>::@getter::a
          element: <none>
        get t1 @-1
          reference: <testLibraryFragment>::@getter::t1
          element: <none>
        get t2 @-1
          reference: <testLibraryFragment>::@getter::t2
          element: <none>
      setters
        set a= @-1
          reference: <testLibraryFragment>::@setter::a
          element: <none>
          parameters
            _a @-1
              element: <none>
        set t1= @-1
          reference: <testLibraryFragment>::@setter::t1
          element: <none>
          parameters
            _t1 @-1
              element: <none>
        set t2= @-1
          reference: <testLibraryFragment>::@setter::t2
          element: <none>
          parameters
            _t2 @-1
              element: <none>
  topLevelVariables
    a
      firstFragment: <testLibraryFragment>::@topLevelVariable::a
      type: List<int>
      getter: <none>
      setter: <none>
    t1
      firstFragment: <testLibraryFragment>::@topLevelVariable::t1
      type: int
      getter: <none>
      setter: <none>
    t2
      firstFragment: <testLibraryFragment>::@topLevelVariable::t2
      type: int
      getter: <none>
      setter: <none>
  getters
    synthetic static get a
      firstFragment: <testLibraryFragment>::@getter::a
    synthetic static get t1
      firstFragment: <testLibraryFragment>::@getter::t1
    synthetic static get t2
      firstFragment: <testLibraryFragment>::@getter::t2
  setters
    synthetic static set a=
      firstFragment: <testLibraryFragment>::@setter::a
      parameters
        requiredPositional _a
          type: List<int>
    synthetic static set t1=
      firstFragment: <testLibraryFragment>::@setter::t1
      parameters
        requiredPositional _t1
          type: int
    synthetic static set t2=
      firstFragment: <testLibraryFragment>::@setter::t2
      parameters
        requiredPositional _t2
          type: int
''');
  }

  test_initializer_assign_prefixed() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  int f;
}
var a = new A();
var t1 = (a.f = 1);
var t2 = (a.f += 2);
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          fields
            f @16
              reference: <testLibraryFragment>::@class::A::@field::f
              enclosingElement3: <testLibraryFragment>::@class::A
              type: int
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          accessors
            synthetic get f @-1
              reference: <testLibraryFragment>::@class::A::@getter::f
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: int
            synthetic set f= @-1
              reference: <testLibraryFragment>::@class::A::@setter::f
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional _f @-1
                  type: int
              returnType: void
      topLevelVariables
        static a @25
          reference: <testLibraryFragment>::@topLevelVariable::a
          enclosingElement3: <testLibraryFragment>
          type: A
          shouldUseTypeForInitializerInference: false
        static t1 @42
          reference: <testLibraryFragment>::@topLevelVariable::t1
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
        static t2 @62
          reference: <testLibraryFragment>::@topLevelVariable::t2
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get a @-1
          reference: <testLibraryFragment>::@getter::a
          enclosingElement3: <testLibraryFragment>
          returnType: A
        synthetic static set a= @-1
          reference: <testLibraryFragment>::@setter::a
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _a @-1
              type: A
          returnType: void
        synthetic static get t1 @-1
          reference: <testLibraryFragment>::@getter::t1
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set t1= @-1
          reference: <testLibraryFragment>::@setter::t1
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _t1 @-1
              type: int
          returnType: void
        synthetic static get t2 @-1
          reference: <testLibraryFragment>::@getter::t2
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set t2= @-1
          reference: <testLibraryFragment>::@setter::t2
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _t2 @-1
              type: int
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          fields
            f @16
              reference: <testLibraryFragment>::@class::A::@field::f
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::f
              setter2: <testLibraryFragment>::@class::A::@setter::f
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          getters
            get f @-1
              reference: <testLibraryFragment>::@class::A::@getter::f
              element: <none>
          setters
            set f= @-1
              reference: <testLibraryFragment>::@class::A::@setter::f
              element: <none>
              parameters
                _f @-1
                  element: <none>
      topLevelVariables
        a @25
          reference: <testLibraryFragment>::@topLevelVariable::a
          element: <none>
          getter2: <testLibraryFragment>::@getter::a
          setter2: <testLibraryFragment>::@setter::a
        t1 @42
          reference: <testLibraryFragment>::@topLevelVariable::t1
          element: <none>
          getter2: <testLibraryFragment>::@getter::t1
          setter2: <testLibraryFragment>::@setter::t1
        t2 @62
          reference: <testLibraryFragment>::@topLevelVariable::t2
          element: <none>
          getter2: <testLibraryFragment>::@getter::t2
          setter2: <testLibraryFragment>::@setter::t2
      getters
        get a @-1
          reference: <testLibraryFragment>::@getter::a
          element: <none>
        get t1 @-1
          reference: <testLibraryFragment>::@getter::t1
          element: <none>
        get t2 @-1
          reference: <testLibraryFragment>::@getter::t2
          element: <none>
      setters
        set a= @-1
          reference: <testLibraryFragment>::@setter::a
          element: <none>
          parameters
            _a @-1
              element: <none>
        set t1= @-1
          reference: <testLibraryFragment>::@setter::t1
          element: <none>
          parameters
            _t1 @-1
              element: <none>
        set t2= @-1
          reference: <testLibraryFragment>::@setter::t2
          element: <none>
          parameters
            _t2 @-1
              element: <none>
  classes
    class A
      firstFragment: <testLibraryFragment>::@class::A
      fields
        f
          firstFragment: <testLibraryFragment>::@class::A::@field::f
          type: int
          getter: <none>
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      getters
        synthetic get f
          firstFragment: <testLibraryFragment>::@class::A::@getter::f
      setters
        synthetic set f=
          firstFragment: <testLibraryFragment>::@class::A::@setter::f
          parameters
            requiredPositional _f
              type: int
  topLevelVariables
    a
      firstFragment: <testLibraryFragment>::@topLevelVariable::a
      type: A
      getter: <none>
      setter: <none>
    t1
      firstFragment: <testLibraryFragment>::@topLevelVariable::t1
      type: int
      getter: <none>
      setter: <none>
    t2
      firstFragment: <testLibraryFragment>::@topLevelVariable::t2
      type: int
      getter: <none>
      setter: <none>
  getters
    synthetic static get a
      firstFragment: <testLibraryFragment>::@getter::a
    synthetic static get t1
      firstFragment: <testLibraryFragment>::@getter::t1
    synthetic static get t2
      firstFragment: <testLibraryFragment>::@getter::t2
  setters
    synthetic static set a=
      firstFragment: <testLibraryFragment>::@setter::a
      parameters
        requiredPositional _a
          type: A
    synthetic static set t1=
      firstFragment: <testLibraryFragment>::@setter::t1
      parameters
        requiredPositional _t1
          type: int
    synthetic static set t2=
      firstFragment: <testLibraryFragment>::@setter::t2
      parameters
        requiredPositional _t2
          type: int
''');
  }

  test_initializer_assign_prefixed_viaInterface() async {
    var library = await _encodeDecodeLibrary(r'''
class I {
  int f;
}
abstract class C implements I {}
C c;
var t1 = (c.f = 1);
var t2 = (c.f += 2);
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class I @6
          reference: <testLibraryFragment>::@class::I
          enclosingElement3: <testLibraryFragment>
          fields
            f @16
              reference: <testLibraryFragment>::@class::I::@field::f
              enclosingElement3: <testLibraryFragment>::@class::I
              type: int
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::I::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::I
          accessors
            synthetic get f @-1
              reference: <testLibraryFragment>::@class::I::@getter::f
              enclosingElement3: <testLibraryFragment>::@class::I
              returnType: int
            synthetic set f= @-1
              reference: <testLibraryFragment>::@class::I::@setter::f
              enclosingElement3: <testLibraryFragment>::@class::I
              parameters
                requiredPositional _f @-1
                  type: int
              returnType: void
        abstract class C @36
          reference: <testLibraryFragment>::@class::C
          enclosingElement3: <testLibraryFragment>
          interfaces
            I
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::C
      topLevelVariables
        static c @56
          reference: <testLibraryFragment>::@topLevelVariable::c
          enclosingElement3: <testLibraryFragment>
          type: C
        static t1 @63
          reference: <testLibraryFragment>::@topLevelVariable::t1
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
        static t2 @83
          reference: <testLibraryFragment>::@topLevelVariable::t2
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get c @-1
          reference: <testLibraryFragment>::@getter::c
          enclosingElement3: <testLibraryFragment>
          returnType: C
        synthetic static set c= @-1
          reference: <testLibraryFragment>::@setter::c
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _c @-1
              type: C
          returnType: void
        synthetic static get t1 @-1
          reference: <testLibraryFragment>::@getter::t1
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set t1= @-1
          reference: <testLibraryFragment>::@setter::t1
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _t1 @-1
              type: int
          returnType: void
        synthetic static get t2 @-1
          reference: <testLibraryFragment>::@getter::t2
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set t2= @-1
          reference: <testLibraryFragment>::@setter::t2
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _t2 @-1
              type: int
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class I @6
          reference: <testLibraryFragment>::@class::I
          element: <testLibraryFragment>::@class::I
          fields
            f @16
              reference: <testLibraryFragment>::@class::I::@field::f
              element: <none>
              getter2: <testLibraryFragment>::@class::I::@getter::f
              setter2: <testLibraryFragment>::@class::I::@setter::f
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::I::@constructor::new
              element: <none>
          getters
            get f @-1
              reference: <testLibraryFragment>::@class::I::@getter::f
              element: <none>
          setters
            set f= @-1
              reference: <testLibraryFragment>::@class::I::@setter::f
              element: <none>
              parameters
                _f @-1
                  element: <none>
        class C @36
          reference: <testLibraryFragment>::@class::C
          element: <testLibraryFragment>::@class::C
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              element: <none>
      topLevelVariables
        c @56
          reference: <testLibraryFragment>::@topLevelVariable::c
          element: <none>
          getter2: <testLibraryFragment>::@getter::c
          setter2: <testLibraryFragment>::@setter::c
        t1 @63
          reference: <testLibraryFragment>::@topLevelVariable::t1
          element: <none>
          getter2: <testLibraryFragment>::@getter::t1
          setter2: <testLibraryFragment>::@setter::t1
        t2 @83
          reference: <testLibraryFragment>::@topLevelVariable::t2
          element: <none>
          getter2: <testLibraryFragment>::@getter::t2
          setter2: <testLibraryFragment>::@setter::t2
      getters
        get c @-1
          reference: <testLibraryFragment>::@getter::c
          element: <none>
        get t1 @-1
          reference: <testLibraryFragment>::@getter::t1
          element: <none>
        get t2 @-1
          reference: <testLibraryFragment>::@getter::t2
          element: <none>
      setters
        set c= @-1
          reference: <testLibraryFragment>::@setter::c
          element: <none>
          parameters
            _c @-1
              element: <none>
        set t1= @-1
          reference: <testLibraryFragment>::@setter::t1
          element: <none>
          parameters
            _t1 @-1
              element: <none>
        set t2= @-1
          reference: <testLibraryFragment>::@setter::t2
          element: <none>
          parameters
            _t2 @-1
              element: <none>
  classes
    class I
      firstFragment: <testLibraryFragment>::@class::I
      fields
        f
          firstFragment: <testLibraryFragment>::@class::I::@field::f
          type: int
          getter: <none>
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::I::@constructor::new
      getters
        synthetic get f
          firstFragment: <testLibraryFragment>::@class::I::@getter::f
      setters
        synthetic set f=
          firstFragment: <testLibraryFragment>::@class::I::@setter::f
          parameters
            requiredPositional _f
              type: int
    abstract class C
      firstFragment: <testLibraryFragment>::@class::C
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::C::@constructor::new
  topLevelVariables
    c
      firstFragment: <testLibraryFragment>::@topLevelVariable::c
      type: C
      getter: <none>
      setter: <none>
    t1
      firstFragment: <testLibraryFragment>::@topLevelVariable::t1
      type: int
      getter: <none>
      setter: <none>
    t2
      firstFragment: <testLibraryFragment>::@topLevelVariable::t2
      type: int
      getter: <none>
      setter: <none>
  getters
    synthetic static get c
      firstFragment: <testLibraryFragment>::@getter::c
    synthetic static get t1
      firstFragment: <testLibraryFragment>::@getter::t1
    synthetic static get t2
      firstFragment: <testLibraryFragment>::@getter::t2
  setters
    synthetic static set c=
      firstFragment: <testLibraryFragment>::@setter::c
      parameters
        requiredPositional _c
          type: C
    synthetic static set t1=
      firstFragment: <testLibraryFragment>::@setter::t1
      parameters
        requiredPositional _t1
          type: int
    synthetic static set t2=
      firstFragment: <testLibraryFragment>::@setter::t2
      parameters
        requiredPositional _t2
          type: int
''');
  }

  test_initializer_assign_viaInterface() async {
    var library = await _encodeDecodeLibrary(r'''
class I {
  int f;
}
abstract class C implements I {}
C getC() => null;
var t1 = (getC().f = 1);
var t2 = (getC().f += 2);
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class I @6
          reference: <testLibraryFragment>::@class::I
          enclosingElement3: <testLibraryFragment>
          fields
            f @16
              reference: <testLibraryFragment>::@class::I::@field::f
              enclosingElement3: <testLibraryFragment>::@class::I
              type: int
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::I::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::I
          accessors
            synthetic get f @-1
              reference: <testLibraryFragment>::@class::I::@getter::f
              enclosingElement3: <testLibraryFragment>::@class::I
              returnType: int
            synthetic set f= @-1
              reference: <testLibraryFragment>::@class::I::@setter::f
              enclosingElement3: <testLibraryFragment>::@class::I
              parameters
                requiredPositional _f @-1
                  type: int
              returnType: void
        abstract class C @36
          reference: <testLibraryFragment>::@class::C
          enclosingElement3: <testLibraryFragment>
          interfaces
            I
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::C
      topLevelVariables
        static t1 @76
          reference: <testLibraryFragment>::@topLevelVariable::t1
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
        static t2 @101
          reference: <testLibraryFragment>::@topLevelVariable::t2
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get t1 @-1
          reference: <testLibraryFragment>::@getter::t1
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set t1= @-1
          reference: <testLibraryFragment>::@setter::t1
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _t1 @-1
              type: int
          returnType: void
        synthetic static get t2 @-1
          reference: <testLibraryFragment>::@getter::t2
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set t2= @-1
          reference: <testLibraryFragment>::@setter::t2
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _t2 @-1
              type: int
          returnType: void
      functions
        getC @56
          reference: <testLibraryFragment>::@function::getC
          enclosingElement3: <testLibraryFragment>
          returnType: C
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class I @6
          reference: <testLibraryFragment>::@class::I
          element: <testLibraryFragment>::@class::I
          fields
            f @16
              reference: <testLibraryFragment>::@class::I::@field::f
              element: <none>
              getter2: <testLibraryFragment>::@class::I::@getter::f
              setter2: <testLibraryFragment>::@class::I::@setter::f
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::I::@constructor::new
              element: <none>
          getters
            get f @-1
              reference: <testLibraryFragment>::@class::I::@getter::f
              element: <none>
          setters
            set f= @-1
              reference: <testLibraryFragment>::@class::I::@setter::f
              element: <none>
              parameters
                _f @-1
                  element: <none>
        class C @36
          reference: <testLibraryFragment>::@class::C
          element: <testLibraryFragment>::@class::C
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              element: <none>
      topLevelVariables
        t1 @76
          reference: <testLibraryFragment>::@topLevelVariable::t1
          element: <none>
          getter2: <testLibraryFragment>::@getter::t1
          setter2: <testLibraryFragment>::@setter::t1
        t2 @101
          reference: <testLibraryFragment>::@topLevelVariable::t2
          element: <none>
          getter2: <testLibraryFragment>::@getter::t2
          setter2: <testLibraryFragment>::@setter::t2
      getters
        get t1 @-1
          reference: <testLibraryFragment>::@getter::t1
          element: <none>
        get t2 @-1
          reference: <testLibraryFragment>::@getter::t2
          element: <none>
      setters
        set t1= @-1
          reference: <testLibraryFragment>::@setter::t1
          element: <none>
          parameters
            _t1 @-1
              element: <none>
        set t2= @-1
          reference: <testLibraryFragment>::@setter::t2
          element: <none>
          parameters
            _t2 @-1
              element: <none>
      functions
        getC @56
          reference: <testLibraryFragment>::@function::getC
          element: <none>
  classes
    class I
      firstFragment: <testLibraryFragment>::@class::I
      fields
        f
          firstFragment: <testLibraryFragment>::@class::I::@field::f
          type: int
          getter: <none>
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::I::@constructor::new
      getters
        synthetic get f
          firstFragment: <testLibraryFragment>::@class::I::@getter::f
      setters
        synthetic set f=
          firstFragment: <testLibraryFragment>::@class::I::@setter::f
          parameters
            requiredPositional _f
              type: int
    abstract class C
      firstFragment: <testLibraryFragment>::@class::C
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::C::@constructor::new
  topLevelVariables
    t1
      firstFragment: <testLibraryFragment>::@topLevelVariable::t1
      type: int
      getter: <none>
      setter: <none>
    t2
      firstFragment: <testLibraryFragment>::@topLevelVariable::t2
      type: int
      getter: <none>
      setter: <none>
  getters
    synthetic static get t1
      firstFragment: <testLibraryFragment>::@getter::t1
    synthetic static get t2
      firstFragment: <testLibraryFragment>::@getter::t2
  setters
    synthetic static set t1=
      firstFragment: <testLibraryFragment>::@setter::t1
      parameters
        requiredPositional _t1
          type: int
    synthetic static set t2=
      firstFragment: <testLibraryFragment>::@setter::t2
      parameters
        requiredPositional _t2
          type: int
  functions
    getC
      firstFragment: <testLibraryFragment>::@function::getC
      returnType: C
''');
  }

  test_initializer_await() async {
    var library = await _encodeDecodeLibrary(r'''
import 'dart:async';
int fValue() => 42;
Future<int> fFuture() async => 42;
var uValue = () async => await fValue();
var uFuture = () async => await fFuture();
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  libraryImports
    dart:async
      enclosingElement3: <testLibraryFragment>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      libraryImports
        dart:async
          enclosingElement3: <testLibraryFragment>
      topLevelVariables
        static uValue @80
          reference: <testLibraryFragment>::@topLevelVariable::uValue
          enclosingElement3: <testLibraryFragment>
          type: Future<int> Function()
          shouldUseTypeForInitializerInference: false
        static uFuture @121
          reference: <testLibraryFragment>::@topLevelVariable::uFuture
          enclosingElement3: <testLibraryFragment>
          type: Future<int> Function()
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get uValue @-1
          reference: <testLibraryFragment>::@getter::uValue
          enclosingElement3: <testLibraryFragment>
          returnType: Future<int> Function()
        synthetic static set uValue= @-1
          reference: <testLibraryFragment>::@setter::uValue
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _uValue @-1
              type: Future<int> Function()
          returnType: void
        synthetic static get uFuture @-1
          reference: <testLibraryFragment>::@getter::uFuture
          enclosingElement3: <testLibraryFragment>
          returnType: Future<int> Function()
        synthetic static set uFuture= @-1
          reference: <testLibraryFragment>::@setter::uFuture
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _uFuture @-1
              type: Future<int> Function()
          returnType: void
      functions
        fValue @25
          reference: <testLibraryFragment>::@function::fValue
          enclosingElement3: <testLibraryFragment>
          returnType: int
        fFuture @53 async
          reference: <testLibraryFragment>::@function::fFuture
          enclosingElement3: <testLibraryFragment>
          returnType: Future<int>
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      libraryImports
        dart:async
      topLevelVariables
        uValue @80
          reference: <testLibraryFragment>::@topLevelVariable::uValue
          element: <none>
          getter2: <testLibraryFragment>::@getter::uValue
          setter2: <testLibraryFragment>::@setter::uValue
        uFuture @121
          reference: <testLibraryFragment>::@topLevelVariable::uFuture
          element: <none>
          getter2: <testLibraryFragment>::@getter::uFuture
          setter2: <testLibraryFragment>::@setter::uFuture
      getters
        get uValue @-1
          reference: <testLibraryFragment>::@getter::uValue
          element: <none>
        get uFuture @-1
          reference: <testLibraryFragment>::@getter::uFuture
          element: <none>
      setters
        set uValue= @-1
          reference: <testLibraryFragment>::@setter::uValue
          element: <none>
          parameters
            _uValue @-1
              element: <none>
        set uFuture= @-1
          reference: <testLibraryFragment>::@setter::uFuture
          element: <none>
          parameters
            _uFuture @-1
              element: <none>
      functions
        fValue @25
          reference: <testLibraryFragment>::@function::fValue
          element: <none>
        fFuture @53
          reference: <testLibraryFragment>::@function::fFuture
          element: <none>
  topLevelVariables
    uValue
      firstFragment: <testLibraryFragment>::@topLevelVariable::uValue
      type: Future<int> Function()
      getter: <none>
      setter: <none>
    uFuture
      firstFragment: <testLibraryFragment>::@topLevelVariable::uFuture
      type: Future<int> Function()
      getter: <none>
      setter: <none>
  getters
    synthetic static get uValue
      firstFragment: <testLibraryFragment>::@getter::uValue
    synthetic static get uFuture
      firstFragment: <testLibraryFragment>::@getter::uFuture
  setters
    synthetic static set uValue=
      firstFragment: <testLibraryFragment>::@setter::uValue
      parameters
        requiredPositional _uValue
          type: Future<int> Function()
    synthetic static set uFuture=
      firstFragment: <testLibraryFragment>::@setter::uFuture
      parameters
        requiredPositional _uFuture
          type: Future<int> Function()
  functions
    fValue
      firstFragment: <testLibraryFragment>::@function::fValue
      returnType: int
    fFuture
      firstFragment: <testLibraryFragment>::@function::fFuture
      returnType: Future<int>
''');
  }

  test_initializer_bitwise() async {
    var library = await _encodeDecodeLibrary(r'''
var vBitXor = 1 ^ 2;
var vBitAnd = 1 & 2;
var vBitOr = 1 | 2;
var vBitShiftLeft = 1 << 2;
var vBitShiftRight = 1 >> 2;
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      topLevelVariables
        static vBitXor @4
          reference: <testLibraryFragment>::@topLevelVariable::vBitXor
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
        static vBitAnd @25
          reference: <testLibraryFragment>::@topLevelVariable::vBitAnd
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
        static vBitOr @46
          reference: <testLibraryFragment>::@topLevelVariable::vBitOr
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
        static vBitShiftLeft @66
          reference: <testLibraryFragment>::@topLevelVariable::vBitShiftLeft
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
        static vBitShiftRight @94
          reference: <testLibraryFragment>::@topLevelVariable::vBitShiftRight
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get vBitXor @-1
          reference: <testLibraryFragment>::@getter::vBitXor
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set vBitXor= @-1
          reference: <testLibraryFragment>::@setter::vBitXor
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vBitXor @-1
              type: int
          returnType: void
        synthetic static get vBitAnd @-1
          reference: <testLibraryFragment>::@getter::vBitAnd
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set vBitAnd= @-1
          reference: <testLibraryFragment>::@setter::vBitAnd
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vBitAnd @-1
              type: int
          returnType: void
        synthetic static get vBitOr @-1
          reference: <testLibraryFragment>::@getter::vBitOr
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set vBitOr= @-1
          reference: <testLibraryFragment>::@setter::vBitOr
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vBitOr @-1
              type: int
          returnType: void
        synthetic static get vBitShiftLeft @-1
          reference: <testLibraryFragment>::@getter::vBitShiftLeft
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set vBitShiftLeft= @-1
          reference: <testLibraryFragment>::@setter::vBitShiftLeft
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vBitShiftLeft @-1
              type: int
          returnType: void
        synthetic static get vBitShiftRight @-1
          reference: <testLibraryFragment>::@getter::vBitShiftRight
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set vBitShiftRight= @-1
          reference: <testLibraryFragment>::@setter::vBitShiftRight
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vBitShiftRight @-1
              type: int
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      topLevelVariables
        vBitXor @4
          reference: <testLibraryFragment>::@topLevelVariable::vBitXor
          element: <none>
          getter2: <testLibraryFragment>::@getter::vBitXor
          setter2: <testLibraryFragment>::@setter::vBitXor
        vBitAnd @25
          reference: <testLibraryFragment>::@topLevelVariable::vBitAnd
          element: <none>
          getter2: <testLibraryFragment>::@getter::vBitAnd
          setter2: <testLibraryFragment>::@setter::vBitAnd
        vBitOr @46
          reference: <testLibraryFragment>::@topLevelVariable::vBitOr
          element: <none>
          getter2: <testLibraryFragment>::@getter::vBitOr
          setter2: <testLibraryFragment>::@setter::vBitOr
        vBitShiftLeft @66
          reference: <testLibraryFragment>::@topLevelVariable::vBitShiftLeft
          element: <none>
          getter2: <testLibraryFragment>::@getter::vBitShiftLeft
          setter2: <testLibraryFragment>::@setter::vBitShiftLeft
        vBitShiftRight @94
          reference: <testLibraryFragment>::@topLevelVariable::vBitShiftRight
          element: <none>
          getter2: <testLibraryFragment>::@getter::vBitShiftRight
          setter2: <testLibraryFragment>::@setter::vBitShiftRight
      getters
        get vBitXor @-1
          reference: <testLibraryFragment>::@getter::vBitXor
          element: <none>
        get vBitAnd @-1
          reference: <testLibraryFragment>::@getter::vBitAnd
          element: <none>
        get vBitOr @-1
          reference: <testLibraryFragment>::@getter::vBitOr
          element: <none>
        get vBitShiftLeft @-1
          reference: <testLibraryFragment>::@getter::vBitShiftLeft
          element: <none>
        get vBitShiftRight @-1
          reference: <testLibraryFragment>::@getter::vBitShiftRight
          element: <none>
      setters
        set vBitXor= @-1
          reference: <testLibraryFragment>::@setter::vBitXor
          element: <none>
          parameters
            _vBitXor @-1
              element: <none>
        set vBitAnd= @-1
          reference: <testLibraryFragment>::@setter::vBitAnd
          element: <none>
          parameters
            _vBitAnd @-1
              element: <none>
        set vBitOr= @-1
          reference: <testLibraryFragment>::@setter::vBitOr
          element: <none>
          parameters
            _vBitOr @-1
              element: <none>
        set vBitShiftLeft= @-1
          reference: <testLibraryFragment>::@setter::vBitShiftLeft
          element: <none>
          parameters
            _vBitShiftLeft @-1
              element: <none>
        set vBitShiftRight= @-1
          reference: <testLibraryFragment>::@setter::vBitShiftRight
          element: <none>
          parameters
            _vBitShiftRight @-1
              element: <none>
  topLevelVariables
    vBitXor
      firstFragment: <testLibraryFragment>::@topLevelVariable::vBitXor
      type: int
      getter: <none>
      setter: <none>
    vBitAnd
      firstFragment: <testLibraryFragment>::@topLevelVariable::vBitAnd
      type: int
      getter: <none>
      setter: <none>
    vBitOr
      firstFragment: <testLibraryFragment>::@topLevelVariable::vBitOr
      type: int
      getter: <none>
      setter: <none>
    vBitShiftLeft
      firstFragment: <testLibraryFragment>::@topLevelVariable::vBitShiftLeft
      type: int
      getter: <none>
      setter: <none>
    vBitShiftRight
      firstFragment: <testLibraryFragment>::@topLevelVariable::vBitShiftRight
      type: int
      getter: <none>
      setter: <none>
  getters
    synthetic static get vBitXor
      firstFragment: <testLibraryFragment>::@getter::vBitXor
    synthetic static get vBitAnd
      firstFragment: <testLibraryFragment>::@getter::vBitAnd
    synthetic static get vBitOr
      firstFragment: <testLibraryFragment>::@getter::vBitOr
    synthetic static get vBitShiftLeft
      firstFragment: <testLibraryFragment>::@getter::vBitShiftLeft
    synthetic static get vBitShiftRight
      firstFragment: <testLibraryFragment>::@getter::vBitShiftRight
  setters
    synthetic static set vBitXor=
      firstFragment: <testLibraryFragment>::@setter::vBitXor
      parameters
        requiredPositional _vBitXor
          type: int
    synthetic static set vBitAnd=
      firstFragment: <testLibraryFragment>::@setter::vBitAnd
      parameters
        requiredPositional _vBitAnd
          type: int
    synthetic static set vBitOr=
      firstFragment: <testLibraryFragment>::@setter::vBitOr
      parameters
        requiredPositional _vBitOr
          type: int
    synthetic static set vBitShiftLeft=
      firstFragment: <testLibraryFragment>::@setter::vBitShiftLeft
      parameters
        requiredPositional _vBitShiftLeft
          type: int
    synthetic static set vBitShiftRight=
      firstFragment: <testLibraryFragment>::@setter::vBitShiftRight
      parameters
        requiredPositional _vBitShiftRight
          type: int
''');
  }

  test_initializer_cascade() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  int a;
  void m() {}
}
var vSetField = new A()..a = 1;
var vInvokeMethod = new A()..m();
var vBoth = new A()..a = 1..m();
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          fields
            a @16
              reference: <testLibraryFragment>::@class::A::@field::a
              enclosingElement3: <testLibraryFragment>::@class::A
              type: int
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          accessors
            synthetic get a @-1
              reference: <testLibraryFragment>::@class::A::@getter::a
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: int
            synthetic set a= @-1
              reference: <testLibraryFragment>::@class::A::@setter::a
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional _a @-1
                  type: int
              returnType: void
          methods
            m @26
              reference: <testLibraryFragment>::@class::A::@method::m
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: void
      topLevelVariables
        static vSetField @39
          reference: <testLibraryFragment>::@topLevelVariable::vSetField
          enclosingElement3: <testLibraryFragment>
          type: A
          shouldUseTypeForInitializerInference: false
        static vInvokeMethod @71
          reference: <testLibraryFragment>::@topLevelVariable::vInvokeMethod
          enclosingElement3: <testLibraryFragment>
          type: A
          shouldUseTypeForInitializerInference: false
        static vBoth @105
          reference: <testLibraryFragment>::@topLevelVariable::vBoth
          enclosingElement3: <testLibraryFragment>
          type: A
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get vSetField @-1
          reference: <testLibraryFragment>::@getter::vSetField
          enclosingElement3: <testLibraryFragment>
          returnType: A
        synthetic static set vSetField= @-1
          reference: <testLibraryFragment>::@setter::vSetField
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vSetField @-1
              type: A
          returnType: void
        synthetic static get vInvokeMethod @-1
          reference: <testLibraryFragment>::@getter::vInvokeMethod
          enclosingElement3: <testLibraryFragment>
          returnType: A
        synthetic static set vInvokeMethod= @-1
          reference: <testLibraryFragment>::@setter::vInvokeMethod
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vInvokeMethod @-1
              type: A
          returnType: void
        synthetic static get vBoth @-1
          reference: <testLibraryFragment>::@getter::vBoth
          enclosingElement3: <testLibraryFragment>
          returnType: A
        synthetic static set vBoth= @-1
          reference: <testLibraryFragment>::@setter::vBoth
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vBoth @-1
              type: A
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          fields
            a @16
              reference: <testLibraryFragment>::@class::A::@field::a
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::a
              setter2: <testLibraryFragment>::@class::A::@setter::a
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          getters
            get a @-1
              reference: <testLibraryFragment>::@class::A::@getter::a
              element: <none>
          setters
            set a= @-1
              reference: <testLibraryFragment>::@class::A::@setter::a
              element: <none>
              parameters
                _a @-1
                  element: <none>
          methods
            m @26
              reference: <testLibraryFragment>::@class::A::@method::m
              element: <none>
      topLevelVariables
        vSetField @39
          reference: <testLibraryFragment>::@topLevelVariable::vSetField
          element: <none>
          getter2: <testLibraryFragment>::@getter::vSetField
          setter2: <testLibraryFragment>::@setter::vSetField
        vInvokeMethod @71
          reference: <testLibraryFragment>::@topLevelVariable::vInvokeMethod
          element: <none>
          getter2: <testLibraryFragment>::@getter::vInvokeMethod
          setter2: <testLibraryFragment>::@setter::vInvokeMethod
        vBoth @105
          reference: <testLibraryFragment>::@topLevelVariable::vBoth
          element: <none>
          getter2: <testLibraryFragment>::@getter::vBoth
          setter2: <testLibraryFragment>::@setter::vBoth
      getters
        get vSetField @-1
          reference: <testLibraryFragment>::@getter::vSetField
          element: <none>
        get vInvokeMethod @-1
          reference: <testLibraryFragment>::@getter::vInvokeMethod
          element: <none>
        get vBoth @-1
          reference: <testLibraryFragment>::@getter::vBoth
          element: <none>
      setters
        set vSetField= @-1
          reference: <testLibraryFragment>::@setter::vSetField
          element: <none>
          parameters
            _vSetField @-1
              element: <none>
        set vInvokeMethod= @-1
          reference: <testLibraryFragment>::@setter::vInvokeMethod
          element: <none>
          parameters
            _vInvokeMethod @-1
              element: <none>
        set vBoth= @-1
          reference: <testLibraryFragment>::@setter::vBoth
          element: <none>
          parameters
            _vBoth @-1
              element: <none>
  classes
    class A
      firstFragment: <testLibraryFragment>::@class::A
      fields
        a
          firstFragment: <testLibraryFragment>::@class::A::@field::a
          type: int
          getter: <none>
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      getters
        synthetic get a
          firstFragment: <testLibraryFragment>::@class::A::@getter::a
      setters
        synthetic set a=
          firstFragment: <testLibraryFragment>::@class::A::@setter::a
          parameters
            requiredPositional _a
              type: int
      methods
        m
          firstFragment: <testLibraryFragment>::@class::A::@method::m
  topLevelVariables
    vSetField
      firstFragment: <testLibraryFragment>::@topLevelVariable::vSetField
      type: A
      getter: <none>
      setter: <none>
    vInvokeMethod
      firstFragment: <testLibraryFragment>::@topLevelVariable::vInvokeMethod
      type: A
      getter: <none>
      setter: <none>
    vBoth
      firstFragment: <testLibraryFragment>::@topLevelVariable::vBoth
      type: A
      getter: <none>
      setter: <none>
  getters
    synthetic static get vSetField
      firstFragment: <testLibraryFragment>::@getter::vSetField
    synthetic static get vInvokeMethod
      firstFragment: <testLibraryFragment>::@getter::vInvokeMethod
    synthetic static get vBoth
      firstFragment: <testLibraryFragment>::@getter::vBoth
  setters
    synthetic static set vSetField=
      firstFragment: <testLibraryFragment>::@setter::vSetField
      parameters
        requiredPositional _vSetField
          type: A
    synthetic static set vInvokeMethod=
      firstFragment: <testLibraryFragment>::@setter::vInvokeMethod
      parameters
        requiredPositional _vInvokeMethod
          type: A
    synthetic static set vBoth=
      firstFragment: <testLibraryFragment>::@setter::vBoth
      parameters
        requiredPositional _vBoth
          type: A
''');
  }

  /// A simple or qualified identifier referring to a top level function, static
  /// variable, field, getter; or a static class variable, static getter or
  /// method; or an instance method; has the inferred type of the identifier.
  ///
  test_initializer_classField_useInstanceGetter() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  int f = 1;
}
class B {
  A a;
}
class C {
  B b;
}
class X {
  A a = new A();
  B b = new B();
  C c = new C();
  var t01 = a.f;
  var t02 = b.a.f;
  var t03 = c.b.a.f;
  var t11 = new A().f;
  var t12 = new B().a.f;
  var t13 = new C().b.a.f;
  var t21 = newA().f;
  var t22 = newB().a.f;
  var t23 = newC().b.a.f;
}
A newA() => new A();
B newB() => new B();
C newC() => new C();
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          fields
            f @16
              reference: <testLibraryFragment>::@class::A::@field::f
              enclosingElement3: <testLibraryFragment>::@class::A
              type: int
              shouldUseTypeForInitializerInference: true
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          accessors
            synthetic get f @-1
              reference: <testLibraryFragment>::@class::A::@getter::f
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: int
            synthetic set f= @-1
              reference: <testLibraryFragment>::@class::A::@setter::f
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional _f @-1
                  type: int
              returnType: void
        class B @31
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          fields
            a @39
              reference: <testLibraryFragment>::@class::B::@field::a
              enclosingElement3: <testLibraryFragment>::@class::B
              type: A
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
          accessors
            synthetic get a @-1
              reference: <testLibraryFragment>::@class::B::@getter::a
              enclosingElement3: <testLibraryFragment>::@class::B
              returnType: A
            synthetic set a= @-1
              reference: <testLibraryFragment>::@class::B::@setter::a
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional _a @-1
                  type: A
              returnType: void
        class C @50
          reference: <testLibraryFragment>::@class::C
          enclosingElement3: <testLibraryFragment>
          fields
            b @58
              reference: <testLibraryFragment>::@class::C::@field::b
              enclosingElement3: <testLibraryFragment>::@class::C
              type: B
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::C
          accessors
            synthetic get b @-1
              reference: <testLibraryFragment>::@class::C::@getter::b
              enclosingElement3: <testLibraryFragment>::@class::C
              returnType: B
            synthetic set b= @-1
              reference: <testLibraryFragment>::@class::C::@setter::b
              enclosingElement3: <testLibraryFragment>::@class::C
              parameters
                requiredPositional _b @-1
                  type: B
              returnType: void
        class X @69
          reference: <testLibraryFragment>::@class::X
          enclosingElement3: <testLibraryFragment>
          fields
            a @77
              reference: <testLibraryFragment>::@class::X::@field::a
              enclosingElement3: <testLibraryFragment>::@class::X
              type: A
              shouldUseTypeForInitializerInference: true
            b @94
              reference: <testLibraryFragment>::@class::X::@field::b
              enclosingElement3: <testLibraryFragment>::@class::X
              type: B
              shouldUseTypeForInitializerInference: true
            c @111
              reference: <testLibraryFragment>::@class::X::@field::c
              enclosingElement3: <testLibraryFragment>::@class::X
              type: C
              shouldUseTypeForInitializerInference: true
            t01 @130
              reference: <testLibraryFragment>::@class::X::@field::t01
              enclosingElement3: <testLibraryFragment>::@class::X
              type: int
              shouldUseTypeForInitializerInference: false
            t02 @147
              reference: <testLibraryFragment>::@class::X::@field::t02
              enclosingElement3: <testLibraryFragment>::@class::X
              type: int
              shouldUseTypeForInitializerInference: false
            t03 @166
              reference: <testLibraryFragment>::@class::X::@field::t03
              enclosingElement3: <testLibraryFragment>::@class::X
              type: int
              shouldUseTypeForInitializerInference: false
            t11 @187
              reference: <testLibraryFragment>::@class::X::@field::t11
              enclosingElement3: <testLibraryFragment>::@class::X
              type: int
              shouldUseTypeForInitializerInference: false
            t12 @210
              reference: <testLibraryFragment>::@class::X::@field::t12
              enclosingElement3: <testLibraryFragment>::@class::X
              type: int
              shouldUseTypeForInitializerInference: false
            t13 @235
              reference: <testLibraryFragment>::@class::X::@field::t13
              enclosingElement3: <testLibraryFragment>::@class::X
              type: int
              shouldUseTypeForInitializerInference: false
            t21 @262
              reference: <testLibraryFragment>::@class::X::@field::t21
              enclosingElement3: <testLibraryFragment>::@class::X
              type: int
              shouldUseTypeForInitializerInference: false
            t22 @284
              reference: <testLibraryFragment>::@class::X::@field::t22
              enclosingElement3: <testLibraryFragment>::@class::X
              type: int
              shouldUseTypeForInitializerInference: false
            t23 @308
              reference: <testLibraryFragment>::@class::X::@field::t23
              enclosingElement3: <testLibraryFragment>::@class::X
              type: int
              shouldUseTypeForInitializerInference: false
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::X::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::X
          accessors
            synthetic get a @-1
              reference: <testLibraryFragment>::@class::X::@getter::a
              enclosingElement3: <testLibraryFragment>::@class::X
              returnType: A
            synthetic set a= @-1
              reference: <testLibraryFragment>::@class::X::@setter::a
              enclosingElement3: <testLibraryFragment>::@class::X
              parameters
                requiredPositional _a @-1
                  type: A
              returnType: void
            synthetic get b @-1
              reference: <testLibraryFragment>::@class::X::@getter::b
              enclosingElement3: <testLibraryFragment>::@class::X
              returnType: B
            synthetic set b= @-1
              reference: <testLibraryFragment>::@class::X::@setter::b
              enclosingElement3: <testLibraryFragment>::@class::X
              parameters
                requiredPositional _b @-1
                  type: B
              returnType: void
            synthetic get c @-1
              reference: <testLibraryFragment>::@class::X::@getter::c
              enclosingElement3: <testLibraryFragment>::@class::X
              returnType: C
            synthetic set c= @-1
              reference: <testLibraryFragment>::@class::X::@setter::c
              enclosingElement3: <testLibraryFragment>::@class::X
              parameters
                requiredPositional _c @-1
                  type: C
              returnType: void
            synthetic get t01 @-1
              reference: <testLibraryFragment>::@class::X::@getter::t01
              enclosingElement3: <testLibraryFragment>::@class::X
              returnType: int
            synthetic set t01= @-1
              reference: <testLibraryFragment>::@class::X::@setter::t01
              enclosingElement3: <testLibraryFragment>::@class::X
              parameters
                requiredPositional _t01 @-1
                  type: int
              returnType: void
            synthetic get t02 @-1
              reference: <testLibraryFragment>::@class::X::@getter::t02
              enclosingElement3: <testLibraryFragment>::@class::X
              returnType: int
            synthetic set t02= @-1
              reference: <testLibraryFragment>::@class::X::@setter::t02
              enclosingElement3: <testLibraryFragment>::@class::X
              parameters
                requiredPositional _t02 @-1
                  type: int
              returnType: void
            synthetic get t03 @-1
              reference: <testLibraryFragment>::@class::X::@getter::t03
              enclosingElement3: <testLibraryFragment>::@class::X
              returnType: int
            synthetic set t03= @-1
              reference: <testLibraryFragment>::@class::X::@setter::t03
              enclosingElement3: <testLibraryFragment>::@class::X
              parameters
                requiredPositional _t03 @-1
                  type: int
              returnType: void
            synthetic get t11 @-1
              reference: <testLibraryFragment>::@class::X::@getter::t11
              enclosingElement3: <testLibraryFragment>::@class::X
              returnType: int
            synthetic set t11= @-1
              reference: <testLibraryFragment>::@class::X::@setter::t11
              enclosingElement3: <testLibraryFragment>::@class::X
              parameters
                requiredPositional _t11 @-1
                  type: int
              returnType: void
            synthetic get t12 @-1
              reference: <testLibraryFragment>::@class::X::@getter::t12
              enclosingElement3: <testLibraryFragment>::@class::X
              returnType: int
            synthetic set t12= @-1
              reference: <testLibraryFragment>::@class::X::@setter::t12
              enclosingElement3: <testLibraryFragment>::@class::X
              parameters
                requiredPositional _t12 @-1
                  type: int
              returnType: void
            synthetic get t13 @-1
              reference: <testLibraryFragment>::@class::X::@getter::t13
              enclosingElement3: <testLibraryFragment>::@class::X
              returnType: int
            synthetic set t13= @-1
              reference: <testLibraryFragment>::@class::X::@setter::t13
              enclosingElement3: <testLibraryFragment>::@class::X
              parameters
                requiredPositional _t13 @-1
                  type: int
              returnType: void
            synthetic get t21 @-1
              reference: <testLibraryFragment>::@class::X::@getter::t21
              enclosingElement3: <testLibraryFragment>::@class::X
              returnType: int
            synthetic set t21= @-1
              reference: <testLibraryFragment>::@class::X::@setter::t21
              enclosingElement3: <testLibraryFragment>::@class::X
              parameters
                requiredPositional _t21 @-1
                  type: int
              returnType: void
            synthetic get t22 @-1
              reference: <testLibraryFragment>::@class::X::@getter::t22
              enclosingElement3: <testLibraryFragment>::@class::X
              returnType: int
            synthetic set t22= @-1
              reference: <testLibraryFragment>::@class::X::@setter::t22
              enclosingElement3: <testLibraryFragment>::@class::X
              parameters
                requiredPositional _t22 @-1
                  type: int
              returnType: void
            synthetic get t23 @-1
              reference: <testLibraryFragment>::@class::X::@getter::t23
              enclosingElement3: <testLibraryFragment>::@class::X
              returnType: int
            synthetic set t23= @-1
              reference: <testLibraryFragment>::@class::X::@setter::t23
              enclosingElement3: <testLibraryFragment>::@class::X
              parameters
                requiredPositional _t23 @-1
                  type: int
              returnType: void
      functions
        newA @332
          reference: <testLibraryFragment>::@function::newA
          enclosingElement3: <testLibraryFragment>
          returnType: A
        newB @353
          reference: <testLibraryFragment>::@function::newB
          enclosingElement3: <testLibraryFragment>
          returnType: B
        newC @374
          reference: <testLibraryFragment>::@function::newC
          enclosingElement3: <testLibraryFragment>
          returnType: C
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          fields
            f @16
              reference: <testLibraryFragment>::@class::A::@field::f
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::f
              setter2: <testLibraryFragment>::@class::A::@setter::f
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          getters
            get f @-1
              reference: <testLibraryFragment>::@class::A::@getter::f
              element: <none>
          setters
            set f= @-1
              reference: <testLibraryFragment>::@class::A::@setter::f
              element: <none>
              parameters
                _f @-1
                  element: <none>
        class B @31
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          fields
            a @39
              reference: <testLibraryFragment>::@class::B::@field::a
              element: <none>
              getter2: <testLibraryFragment>::@class::B::@getter::a
              setter2: <testLibraryFragment>::@class::B::@setter::a
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
          getters
            get a @-1
              reference: <testLibraryFragment>::@class::B::@getter::a
              element: <none>
          setters
            set a= @-1
              reference: <testLibraryFragment>::@class::B::@setter::a
              element: <none>
              parameters
                _a @-1
                  element: <none>
        class C @50
          reference: <testLibraryFragment>::@class::C
          element: <testLibraryFragment>::@class::C
          fields
            b @58
              reference: <testLibraryFragment>::@class::C::@field::b
              element: <none>
              getter2: <testLibraryFragment>::@class::C::@getter::b
              setter2: <testLibraryFragment>::@class::C::@setter::b
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              element: <none>
          getters
            get b @-1
              reference: <testLibraryFragment>::@class::C::@getter::b
              element: <none>
          setters
            set b= @-1
              reference: <testLibraryFragment>::@class::C::@setter::b
              element: <none>
              parameters
                _b @-1
                  element: <none>
        class X @69
          reference: <testLibraryFragment>::@class::X
          element: <testLibraryFragment>::@class::X
          fields
            a @77
              reference: <testLibraryFragment>::@class::X::@field::a
              element: <none>
              getter2: <testLibraryFragment>::@class::X::@getter::a
              setter2: <testLibraryFragment>::@class::X::@setter::a
            b @94
              reference: <testLibraryFragment>::@class::X::@field::b
              element: <none>
              getter2: <testLibraryFragment>::@class::X::@getter::b
              setter2: <testLibraryFragment>::@class::X::@setter::b
            c @111
              reference: <testLibraryFragment>::@class::X::@field::c
              element: <none>
              getter2: <testLibraryFragment>::@class::X::@getter::c
              setter2: <testLibraryFragment>::@class::X::@setter::c
            t01 @130
              reference: <testLibraryFragment>::@class::X::@field::t01
              element: <none>
              getter2: <testLibraryFragment>::@class::X::@getter::t01
              setter2: <testLibraryFragment>::@class::X::@setter::t01
            t02 @147
              reference: <testLibraryFragment>::@class::X::@field::t02
              element: <none>
              getter2: <testLibraryFragment>::@class::X::@getter::t02
              setter2: <testLibraryFragment>::@class::X::@setter::t02
            t03 @166
              reference: <testLibraryFragment>::@class::X::@field::t03
              element: <none>
              getter2: <testLibraryFragment>::@class::X::@getter::t03
              setter2: <testLibraryFragment>::@class::X::@setter::t03
            t11 @187
              reference: <testLibraryFragment>::@class::X::@field::t11
              element: <none>
              getter2: <testLibraryFragment>::@class::X::@getter::t11
              setter2: <testLibraryFragment>::@class::X::@setter::t11
            t12 @210
              reference: <testLibraryFragment>::@class::X::@field::t12
              element: <none>
              getter2: <testLibraryFragment>::@class::X::@getter::t12
              setter2: <testLibraryFragment>::@class::X::@setter::t12
            t13 @235
              reference: <testLibraryFragment>::@class::X::@field::t13
              element: <none>
              getter2: <testLibraryFragment>::@class::X::@getter::t13
              setter2: <testLibraryFragment>::@class::X::@setter::t13
            t21 @262
              reference: <testLibraryFragment>::@class::X::@field::t21
              element: <none>
              getter2: <testLibraryFragment>::@class::X::@getter::t21
              setter2: <testLibraryFragment>::@class::X::@setter::t21
            t22 @284
              reference: <testLibraryFragment>::@class::X::@field::t22
              element: <none>
              getter2: <testLibraryFragment>::@class::X::@getter::t22
              setter2: <testLibraryFragment>::@class::X::@setter::t22
            t23 @308
              reference: <testLibraryFragment>::@class::X::@field::t23
              element: <none>
              getter2: <testLibraryFragment>::@class::X::@getter::t23
              setter2: <testLibraryFragment>::@class::X::@setter::t23
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::X::@constructor::new
              element: <none>
          getters
            get a @-1
              reference: <testLibraryFragment>::@class::X::@getter::a
              element: <none>
            get b @-1
              reference: <testLibraryFragment>::@class::X::@getter::b
              element: <none>
            get c @-1
              reference: <testLibraryFragment>::@class::X::@getter::c
              element: <none>
            get t01 @-1
              reference: <testLibraryFragment>::@class::X::@getter::t01
              element: <none>
            get t02 @-1
              reference: <testLibraryFragment>::@class::X::@getter::t02
              element: <none>
            get t03 @-1
              reference: <testLibraryFragment>::@class::X::@getter::t03
              element: <none>
            get t11 @-1
              reference: <testLibraryFragment>::@class::X::@getter::t11
              element: <none>
            get t12 @-1
              reference: <testLibraryFragment>::@class::X::@getter::t12
              element: <none>
            get t13 @-1
              reference: <testLibraryFragment>::@class::X::@getter::t13
              element: <none>
            get t21 @-1
              reference: <testLibraryFragment>::@class::X::@getter::t21
              element: <none>
            get t22 @-1
              reference: <testLibraryFragment>::@class::X::@getter::t22
              element: <none>
            get t23 @-1
              reference: <testLibraryFragment>::@class::X::@getter::t23
              element: <none>
          setters
            set a= @-1
              reference: <testLibraryFragment>::@class::X::@setter::a
              element: <none>
              parameters
                _a @-1
                  element: <none>
            set b= @-1
              reference: <testLibraryFragment>::@class::X::@setter::b
              element: <none>
              parameters
                _b @-1
                  element: <none>
            set c= @-1
              reference: <testLibraryFragment>::@class::X::@setter::c
              element: <none>
              parameters
                _c @-1
                  element: <none>
            set t01= @-1
              reference: <testLibraryFragment>::@class::X::@setter::t01
              element: <none>
              parameters
                _t01 @-1
                  element: <none>
            set t02= @-1
              reference: <testLibraryFragment>::@class::X::@setter::t02
              element: <none>
              parameters
                _t02 @-1
                  element: <none>
            set t03= @-1
              reference: <testLibraryFragment>::@class::X::@setter::t03
              element: <none>
              parameters
                _t03 @-1
                  element: <none>
            set t11= @-1
              reference: <testLibraryFragment>::@class::X::@setter::t11
              element: <none>
              parameters
                _t11 @-1
                  element: <none>
            set t12= @-1
              reference: <testLibraryFragment>::@class::X::@setter::t12
              element: <none>
              parameters
                _t12 @-1
                  element: <none>
            set t13= @-1
              reference: <testLibraryFragment>::@class::X::@setter::t13
              element: <none>
              parameters
                _t13 @-1
                  element: <none>
            set t21= @-1
              reference: <testLibraryFragment>::@class::X::@setter::t21
              element: <none>
              parameters
                _t21 @-1
                  element: <none>
            set t22= @-1
              reference: <testLibraryFragment>::@class::X::@setter::t22
              element: <none>
              parameters
                _t22 @-1
                  element: <none>
            set t23= @-1
              reference: <testLibraryFragment>::@class::X::@setter::t23
              element: <none>
              parameters
                _t23 @-1
                  element: <none>
      functions
        newA @332
          reference: <testLibraryFragment>::@function::newA
          element: <none>
        newB @353
          reference: <testLibraryFragment>::@function::newB
          element: <none>
        newC @374
          reference: <testLibraryFragment>::@function::newC
          element: <none>
  classes
    class A
      firstFragment: <testLibraryFragment>::@class::A
      fields
        f
          firstFragment: <testLibraryFragment>::@class::A::@field::f
          type: int
          getter: <none>
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      getters
        synthetic get f
          firstFragment: <testLibraryFragment>::@class::A::@getter::f
      setters
        synthetic set f=
          firstFragment: <testLibraryFragment>::@class::A::@setter::f
          parameters
            requiredPositional _f
              type: int
    class B
      firstFragment: <testLibraryFragment>::@class::B
      fields
        a
          firstFragment: <testLibraryFragment>::@class::B::@field::a
          type: A
          getter: <none>
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
      getters
        synthetic get a
          firstFragment: <testLibraryFragment>::@class::B::@getter::a
      setters
        synthetic set a=
          firstFragment: <testLibraryFragment>::@class::B::@setter::a
          parameters
            requiredPositional _a
              type: A
    class C
      firstFragment: <testLibraryFragment>::@class::C
      fields
        b
          firstFragment: <testLibraryFragment>::@class::C::@field::b
          type: B
          getter: <none>
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::C::@constructor::new
      getters
        synthetic get b
          firstFragment: <testLibraryFragment>::@class::C::@getter::b
      setters
        synthetic set b=
          firstFragment: <testLibraryFragment>::@class::C::@setter::b
          parameters
            requiredPositional _b
              type: B
    class X
      firstFragment: <testLibraryFragment>::@class::X
      fields
        a
          firstFragment: <testLibraryFragment>::@class::X::@field::a
          type: A
          getter: <none>
          setter: <none>
        b
          firstFragment: <testLibraryFragment>::@class::X::@field::b
          type: B
          getter: <none>
          setter: <none>
        c
          firstFragment: <testLibraryFragment>::@class::X::@field::c
          type: C
          getter: <none>
          setter: <none>
        t01
          firstFragment: <testLibraryFragment>::@class::X::@field::t01
          type: int
          getter: <none>
          setter: <none>
        t02
          firstFragment: <testLibraryFragment>::@class::X::@field::t02
          type: int
          getter: <none>
          setter: <none>
        t03
          firstFragment: <testLibraryFragment>::@class::X::@field::t03
          type: int
          getter: <none>
          setter: <none>
        t11
          firstFragment: <testLibraryFragment>::@class::X::@field::t11
          type: int
          getter: <none>
          setter: <none>
        t12
          firstFragment: <testLibraryFragment>::@class::X::@field::t12
          type: int
          getter: <none>
          setter: <none>
        t13
          firstFragment: <testLibraryFragment>::@class::X::@field::t13
          type: int
          getter: <none>
          setter: <none>
        t21
          firstFragment: <testLibraryFragment>::@class::X::@field::t21
          type: int
          getter: <none>
          setter: <none>
        t22
          firstFragment: <testLibraryFragment>::@class::X::@field::t22
          type: int
          getter: <none>
          setter: <none>
        t23
          firstFragment: <testLibraryFragment>::@class::X::@field::t23
          type: int
          getter: <none>
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::X::@constructor::new
      getters
        synthetic get a
          firstFragment: <testLibraryFragment>::@class::X::@getter::a
        synthetic get b
          firstFragment: <testLibraryFragment>::@class::X::@getter::b
        synthetic get c
          firstFragment: <testLibraryFragment>::@class::X::@getter::c
        synthetic get t01
          firstFragment: <testLibraryFragment>::@class::X::@getter::t01
        synthetic get t02
          firstFragment: <testLibraryFragment>::@class::X::@getter::t02
        synthetic get t03
          firstFragment: <testLibraryFragment>::@class::X::@getter::t03
        synthetic get t11
          firstFragment: <testLibraryFragment>::@class::X::@getter::t11
        synthetic get t12
          firstFragment: <testLibraryFragment>::@class::X::@getter::t12
        synthetic get t13
          firstFragment: <testLibraryFragment>::@class::X::@getter::t13
        synthetic get t21
          firstFragment: <testLibraryFragment>::@class::X::@getter::t21
        synthetic get t22
          firstFragment: <testLibraryFragment>::@class::X::@getter::t22
        synthetic get t23
          firstFragment: <testLibraryFragment>::@class::X::@getter::t23
      setters
        synthetic set a=
          firstFragment: <testLibraryFragment>::@class::X::@setter::a
          parameters
            requiredPositional _a
              type: A
        synthetic set b=
          firstFragment: <testLibraryFragment>::@class::X::@setter::b
          parameters
            requiredPositional _b
              type: B
        synthetic set c=
          firstFragment: <testLibraryFragment>::@class::X::@setter::c
          parameters
            requiredPositional _c
              type: C
        synthetic set t01=
          firstFragment: <testLibraryFragment>::@class::X::@setter::t01
          parameters
            requiredPositional _t01
              type: int
        synthetic set t02=
          firstFragment: <testLibraryFragment>::@class::X::@setter::t02
          parameters
            requiredPositional _t02
              type: int
        synthetic set t03=
          firstFragment: <testLibraryFragment>::@class::X::@setter::t03
          parameters
            requiredPositional _t03
              type: int
        synthetic set t11=
          firstFragment: <testLibraryFragment>::@class::X::@setter::t11
          parameters
            requiredPositional _t11
              type: int
        synthetic set t12=
          firstFragment: <testLibraryFragment>::@class::X::@setter::t12
          parameters
            requiredPositional _t12
              type: int
        synthetic set t13=
          firstFragment: <testLibraryFragment>::@class::X::@setter::t13
          parameters
            requiredPositional _t13
              type: int
        synthetic set t21=
          firstFragment: <testLibraryFragment>::@class::X::@setter::t21
          parameters
            requiredPositional _t21
              type: int
        synthetic set t22=
          firstFragment: <testLibraryFragment>::@class::X::@setter::t22
          parameters
            requiredPositional _t22
              type: int
        synthetic set t23=
          firstFragment: <testLibraryFragment>::@class::X::@setter::t23
          parameters
            requiredPositional _t23
              type: int
  functions
    newA
      firstFragment: <testLibraryFragment>::@function::newA
      returnType: A
    newB
      firstFragment: <testLibraryFragment>::@function::newB
      returnType: B
    newC
      firstFragment: <testLibraryFragment>::@function::newC
      returnType: C
''');
  }

  test_initializer_conditional() async {
    var library = await _encodeDecodeLibrary(r'''
var V = true ? 1 : 2.3;
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      topLevelVariables
        static V @4
          reference: <testLibraryFragment>::@topLevelVariable::V
          enclosingElement3: <testLibraryFragment>
          type: num
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get V @-1
          reference: <testLibraryFragment>::@getter::V
          enclosingElement3: <testLibraryFragment>
          returnType: num
        synthetic static set V= @-1
          reference: <testLibraryFragment>::@setter::V
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _V @-1
              type: num
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      topLevelVariables
        V @4
          reference: <testLibraryFragment>::@topLevelVariable::V
          element: <none>
          getter2: <testLibraryFragment>::@getter::V
          setter2: <testLibraryFragment>::@setter::V
      getters
        get V @-1
          reference: <testLibraryFragment>::@getter::V
          element: <none>
      setters
        set V= @-1
          reference: <testLibraryFragment>::@setter::V
          element: <none>
          parameters
            _V @-1
              element: <none>
  topLevelVariables
    V
      firstFragment: <testLibraryFragment>::@topLevelVariable::V
      type: num
      getter: <none>
      setter: <none>
  getters
    synthetic static get V
      firstFragment: <testLibraryFragment>::@getter::V
  setters
    synthetic static set V=
      firstFragment: <testLibraryFragment>::@setter::V
      parameters
        requiredPositional _V
          type: num
''');
  }

  test_initializer_equality() async {
    var library = await _encodeDecodeLibrary(r'''
var vEq = 1 == 2;
var vNotEq = 1 != 2;
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      topLevelVariables
        static vEq @4
          reference: <testLibraryFragment>::@topLevelVariable::vEq
          enclosingElement3: <testLibraryFragment>
          type: bool
          shouldUseTypeForInitializerInference: false
        static vNotEq @22
          reference: <testLibraryFragment>::@topLevelVariable::vNotEq
          enclosingElement3: <testLibraryFragment>
          type: bool
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get vEq @-1
          reference: <testLibraryFragment>::@getter::vEq
          enclosingElement3: <testLibraryFragment>
          returnType: bool
        synthetic static set vEq= @-1
          reference: <testLibraryFragment>::@setter::vEq
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vEq @-1
              type: bool
          returnType: void
        synthetic static get vNotEq @-1
          reference: <testLibraryFragment>::@getter::vNotEq
          enclosingElement3: <testLibraryFragment>
          returnType: bool
        synthetic static set vNotEq= @-1
          reference: <testLibraryFragment>::@setter::vNotEq
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vNotEq @-1
              type: bool
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      topLevelVariables
        vEq @4
          reference: <testLibraryFragment>::@topLevelVariable::vEq
          element: <none>
          getter2: <testLibraryFragment>::@getter::vEq
          setter2: <testLibraryFragment>::@setter::vEq
        vNotEq @22
          reference: <testLibraryFragment>::@topLevelVariable::vNotEq
          element: <none>
          getter2: <testLibraryFragment>::@getter::vNotEq
          setter2: <testLibraryFragment>::@setter::vNotEq
      getters
        get vEq @-1
          reference: <testLibraryFragment>::@getter::vEq
          element: <none>
        get vNotEq @-1
          reference: <testLibraryFragment>::@getter::vNotEq
          element: <none>
      setters
        set vEq= @-1
          reference: <testLibraryFragment>::@setter::vEq
          element: <none>
          parameters
            _vEq @-1
              element: <none>
        set vNotEq= @-1
          reference: <testLibraryFragment>::@setter::vNotEq
          element: <none>
          parameters
            _vNotEq @-1
              element: <none>
  topLevelVariables
    vEq
      firstFragment: <testLibraryFragment>::@topLevelVariable::vEq
      type: bool
      getter: <none>
      setter: <none>
    vNotEq
      firstFragment: <testLibraryFragment>::@topLevelVariable::vNotEq
      type: bool
      getter: <none>
      setter: <none>
  getters
    synthetic static get vEq
      firstFragment: <testLibraryFragment>::@getter::vEq
    synthetic static get vNotEq
      firstFragment: <testLibraryFragment>::@getter::vNotEq
  setters
    synthetic static set vEq=
      firstFragment: <testLibraryFragment>::@setter::vEq
      parameters
        requiredPositional _vEq
          type: bool
    synthetic static set vNotEq=
      firstFragment: <testLibraryFragment>::@setter::vNotEq
      parameters
        requiredPositional _vNotEq
          type: bool
''');
  }

  test_initializer_error_methodInvocation_cycle_topLevel() async {
    var library = await _encodeDecodeLibrary(r'''
var a = b.foo();
var b = a.foo();
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      topLevelVariables
        static a @4
          reference: <testLibraryFragment>::@topLevelVariable::a
          enclosingElement3: <testLibraryFragment>
          typeInferenceError: dependencyCycle
            arguments: [a, b]
          type: dynamic
          shouldUseTypeForInitializerInference: false
        static b @21
          reference: <testLibraryFragment>::@topLevelVariable::b
          enclosingElement3: <testLibraryFragment>
          typeInferenceError: dependencyCycle
            arguments: [a, b]
          type: dynamic
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get a @-1
          reference: <testLibraryFragment>::@getter::a
          enclosingElement3: <testLibraryFragment>
          returnType: dynamic
        synthetic static set a= @-1
          reference: <testLibraryFragment>::@setter::a
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _a @-1
              type: dynamic
          returnType: void
        synthetic static get b @-1
          reference: <testLibraryFragment>::@getter::b
          enclosingElement3: <testLibraryFragment>
          returnType: dynamic
        synthetic static set b= @-1
          reference: <testLibraryFragment>::@setter::b
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _b @-1
              type: dynamic
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      topLevelVariables
        a @4
          reference: <testLibraryFragment>::@topLevelVariable::a
          element: <none>
          getter2: <testLibraryFragment>::@getter::a
          setter2: <testLibraryFragment>::@setter::a
        b @21
          reference: <testLibraryFragment>::@topLevelVariable::b
          element: <none>
          getter2: <testLibraryFragment>::@getter::b
          setter2: <testLibraryFragment>::@setter::b
      getters
        get a @-1
          reference: <testLibraryFragment>::@getter::a
          element: <none>
        get b @-1
          reference: <testLibraryFragment>::@getter::b
          element: <none>
      setters
        set a= @-1
          reference: <testLibraryFragment>::@setter::a
          element: <none>
          parameters
            _a @-1
              element: <none>
        set b= @-1
          reference: <testLibraryFragment>::@setter::b
          element: <none>
          parameters
            _b @-1
              element: <none>
  topLevelVariables
    a
      firstFragment: <testLibraryFragment>::@topLevelVariable::a
      type: dynamic
      getter: <none>
      setter: <none>
    b
      firstFragment: <testLibraryFragment>::@topLevelVariable::b
      type: dynamic
      getter: <none>
      setter: <none>
  getters
    synthetic static get a
      firstFragment: <testLibraryFragment>::@getter::a
    synthetic static get b
      firstFragment: <testLibraryFragment>::@getter::b
  setters
    synthetic static set a=
      firstFragment: <testLibraryFragment>::@setter::a
      parameters
        requiredPositional _a
          type: dynamic
    synthetic static set b=
      firstFragment: <testLibraryFragment>::@setter::b
      parameters
        requiredPositional _b
          type: dynamic
''');
  }

  test_initializer_error_methodInvocation_cycle_topLevel_self() async {
    var library = await _encodeDecodeLibrary(r'''
var a = a.foo();
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      topLevelVariables
        static a @4
          reference: <testLibraryFragment>::@topLevelVariable::a
          enclosingElement3: <testLibraryFragment>
          typeInferenceError: dependencyCycle
            arguments: [a]
          type: dynamic
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get a @-1
          reference: <testLibraryFragment>::@getter::a
          enclosingElement3: <testLibraryFragment>
          returnType: dynamic
        synthetic static set a= @-1
          reference: <testLibraryFragment>::@setter::a
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _a @-1
              type: dynamic
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      topLevelVariables
        a @4
          reference: <testLibraryFragment>::@topLevelVariable::a
          element: <none>
          getter2: <testLibraryFragment>::@getter::a
          setter2: <testLibraryFragment>::@setter::a
      getters
        get a @-1
          reference: <testLibraryFragment>::@getter::a
          element: <none>
      setters
        set a= @-1
          reference: <testLibraryFragment>::@setter::a
          element: <none>
          parameters
            _a @-1
              element: <none>
  topLevelVariables
    a
      firstFragment: <testLibraryFragment>::@topLevelVariable::a
      type: dynamic
      getter: <none>
      setter: <none>
  getters
    synthetic static get a
      firstFragment: <testLibraryFragment>::@getter::a
  setters
    synthetic static set a=
      firstFragment: <testLibraryFragment>::@setter::a
      parameters
        requiredPositional _a
          type: dynamic
''');
  }

  test_initializer_extractIndex() async {
    var library = await _encodeDecodeLibrary(r'''
var a = [0, 1.2];
var b0 = a[0];
var b1 = a[1];
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      topLevelVariables
        static a @4
          reference: <testLibraryFragment>::@topLevelVariable::a
          enclosingElement3: <testLibraryFragment>
          type: List<num>
          shouldUseTypeForInitializerInference: false
        static b0 @22
          reference: <testLibraryFragment>::@topLevelVariable::b0
          enclosingElement3: <testLibraryFragment>
          type: num
          shouldUseTypeForInitializerInference: false
        static b1 @37
          reference: <testLibraryFragment>::@topLevelVariable::b1
          enclosingElement3: <testLibraryFragment>
          type: num
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get a @-1
          reference: <testLibraryFragment>::@getter::a
          enclosingElement3: <testLibraryFragment>
          returnType: List<num>
        synthetic static set a= @-1
          reference: <testLibraryFragment>::@setter::a
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _a @-1
              type: List<num>
          returnType: void
        synthetic static get b0 @-1
          reference: <testLibraryFragment>::@getter::b0
          enclosingElement3: <testLibraryFragment>
          returnType: num
        synthetic static set b0= @-1
          reference: <testLibraryFragment>::@setter::b0
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _b0 @-1
              type: num
          returnType: void
        synthetic static get b1 @-1
          reference: <testLibraryFragment>::@getter::b1
          enclosingElement3: <testLibraryFragment>
          returnType: num
        synthetic static set b1= @-1
          reference: <testLibraryFragment>::@setter::b1
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _b1 @-1
              type: num
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      topLevelVariables
        a @4
          reference: <testLibraryFragment>::@topLevelVariable::a
          element: <none>
          getter2: <testLibraryFragment>::@getter::a
          setter2: <testLibraryFragment>::@setter::a
        b0 @22
          reference: <testLibraryFragment>::@topLevelVariable::b0
          element: <none>
          getter2: <testLibraryFragment>::@getter::b0
          setter2: <testLibraryFragment>::@setter::b0
        b1 @37
          reference: <testLibraryFragment>::@topLevelVariable::b1
          element: <none>
          getter2: <testLibraryFragment>::@getter::b1
          setter2: <testLibraryFragment>::@setter::b1
      getters
        get a @-1
          reference: <testLibraryFragment>::@getter::a
          element: <none>
        get b0 @-1
          reference: <testLibraryFragment>::@getter::b0
          element: <none>
        get b1 @-1
          reference: <testLibraryFragment>::@getter::b1
          element: <none>
      setters
        set a= @-1
          reference: <testLibraryFragment>::@setter::a
          element: <none>
          parameters
            _a @-1
              element: <none>
        set b0= @-1
          reference: <testLibraryFragment>::@setter::b0
          element: <none>
          parameters
            _b0 @-1
              element: <none>
        set b1= @-1
          reference: <testLibraryFragment>::@setter::b1
          element: <none>
          parameters
            _b1 @-1
              element: <none>
  topLevelVariables
    a
      firstFragment: <testLibraryFragment>::@topLevelVariable::a
      type: List<num>
      getter: <none>
      setter: <none>
    b0
      firstFragment: <testLibraryFragment>::@topLevelVariable::b0
      type: num
      getter: <none>
      setter: <none>
    b1
      firstFragment: <testLibraryFragment>::@topLevelVariable::b1
      type: num
      getter: <none>
      setter: <none>
  getters
    synthetic static get a
      firstFragment: <testLibraryFragment>::@getter::a
    synthetic static get b0
      firstFragment: <testLibraryFragment>::@getter::b0
    synthetic static get b1
      firstFragment: <testLibraryFragment>::@getter::b1
  setters
    synthetic static set a=
      firstFragment: <testLibraryFragment>::@setter::a
      parameters
        requiredPositional _a
          type: List<num>
    synthetic static set b0=
      firstFragment: <testLibraryFragment>::@setter::b0
      parameters
        requiredPositional _b0
          type: num
    synthetic static set b1=
      firstFragment: <testLibraryFragment>::@setter::b1
      parameters
        requiredPositional _b1
          type: num
''');
  }

  test_initializer_extractProperty_explicitlyTyped_differentLibraryCycle() async {
    newFile('$testPackageLibPath/a.dart', r'''
class C {
  int f = 0;
}
''');
    var library = await _encodeDecodeLibrary(r'''
import 'a.dart';
var x = new C().f;
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  libraryImports
    package:test/a.dart
      enclosingElement3: <testLibraryFragment>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      libraryImports
        package:test/a.dart
          enclosingElement3: <testLibraryFragment>
      topLevelVariables
        static x @21
          reference: <testLibraryFragment>::@topLevelVariable::x
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get x @-1
          reference: <testLibraryFragment>::@getter::x
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set x= @-1
          reference: <testLibraryFragment>::@setter::x
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _x @-1
              type: int
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      libraryImports
        package:test/a.dart
      topLevelVariables
        x @21
          reference: <testLibraryFragment>::@topLevelVariable::x
          element: <none>
          getter2: <testLibraryFragment>::@getter::x
          setter2: <testLibraryFragment>::@setter::x
      getters
        get x @-1
          reference: <testLibraryFragment>::@getter::x
          element: <none>
      setters
        set x= @-1
          reference: <testLibraryFragment>::@setter::x
          element: <none>
          parameters
            _x @-1
              element: <none>
  topLevelVariables
    x
      firstFragment: <testLibraryFragment>::@topLevelVariable::x
      type: int
      getter: <none>
      setter: <none>
  getters
    synthetic static get x
      firstFragment: <testLibraryFragment>::@getter::x
  setters
    synthetic static set x=
      firstFragment: <testLibraryFragment>::@setter::x
      parameters
        requiredPositional _x
          type: int
''');
  }

  test_initializer_extractProperty_explicitlyTyped_sameLibrary() async {
    var library = await _encodeDecodeLibrary(r'''
class C {
  int f = 0;
}
var x = new C().f;
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class C @6
          reference: <testLibraryFragment>::@class::C
          enclosingElement3: <testLibraryFragment>
          fields
            f @16
              reference: <testLibraryFragment>::@class::C::@field::f
              enclosingElement3: <testLibraryFragment>::@class::C
              type: int
              shouldUseTypeForInitializerInference: true
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::C
          accessors
            synthetic get f @-1
              reference: <testLibraryFragment>::@class::C::@getter::f
              enclosingElement3: <testLibraryFragment>::@class::C
              returnType: int
            synthetic set f= @-1
              reference: <testLibraryFragment>::@class::C::@setter::f
              enclosingElement3: <testLibraryFragment>::@class::C
              parameters
                requiredPositional _f @-1
                  type: int
              returnType: void
      topLevelVariables
        static x @29
          reference: <testLibraryFragment>::@topLevelVariable::x
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get x @-1
          reference: <testLibraryFragment>::@getter::x
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set x= @-1
          reference: <testLibraryFragment>::@setter::x
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _x @-1
              type: int
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class C @6
          reference: <testLibraryFragment>::@class::C
          element: <testLibraryFragment>::@class::C
          fields
            f @16
              reference: <testLibraryFragment>::@class::C::@field::f
              element: <none>
              getter2: <testLibraryFragment>::@class::C::@getter::f
              setter2: <testLibraryFragment>::@class::C::@setter::f
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              element: <none>
          getters
            get f @-1
              reference: <testLibraryFragment>::@class::C::@getter::f
              element: <none>
          setters
            set f= @-1
              reference: <testLibraryFragment>::@class::C::@setter::f
              element: <none>
              parameters
                _f @-1
                  element: <none>
      topLevelVariables
        x @29
          reference: <testLibraryFragment>::@topLevelVariable::x
          element: <none>
          getter2: <testLibraryFragment>::@getter::x
          setter2: <testLibraryFragment>::@setter::x
      getters
        get x @-1
          reference: <testLibraryFragment>::@getter::x
          element: <none>
      setters
        set x= @-1
          reference: <testLibraryFragment>::@setter::x
          element: <none>
          parameters
            _x @-1
              element: <none>
  classes
    class C
      firstFragment: <testLibraryFragment>::@class::C
      fields
        f
          firstFragment: <testLibraryFragment>::@class::C::@field::f
          type: int
          getter: <none>
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::C::@constructor::new
      getters
        synthetic get f
          firstFragment: <testLibraryFragment>::@class::C::@getter::f
      setters
        synthetic set f=
          firstFragment: <testLibraryFragment>::@class::C::@setter::f
          parameters
            requiredPositional _f
              type: int
  topLevelVariables
    x
      firstFragment: <testLibraryFragment>::@topLevelVariable::x
      type: int
      getter: <none>
      setter: <none>
  getters
    synthetic static get x
      firstFragment: <testLibraryFragment>::@getter::x
  setters
    synthetic static set x=
      firstFragment: <testLibraryFragment>::@setter::x
      parameters
        requiredPositional _x
          type: int
''');
  }

  test_initializer_extractProperty_explicitlyTyped_sameLibraryCycle() async {
    newFile('$testPackageLibPath/a.dart', r'''
import 'test.dart'; // just do make it part of the library cycle
class C {
  int f = 0;
}
''');
    var library = await _encodeDecodeLibrary(r'''
import 'a.dart';
var x = new C().f;
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  libraryImports
    package:test/a.dart
      enclosingElement3: <testLibraryFragment>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      libraryImports
        package:test/a.dart
          enclosingElement3: <testLibraryFragment>
      topLevelVariables
        static x @21
          reference: <testLibraryFragment>::@topLevelVariable::x
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get x @-1
          reference: <testLibraryFragment>::@getter::x
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set x= @-1
          reference: <testLibraryFragment>::@setter::x
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _x @-1
              type: int
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      libraryImports
        package:test/a.dart
      topLevelVariables
        x @21
          reference: <testLibraryFragment>::@topLevelVariable::x
          element: <none>
          getter2: <testLibraryFragment>::@getter::x
          setter2: <testLibraryFragment>::@setter::x
      getters
        get x @-1
          reference: <testLibraryFragment>::@getter::x
          element: <none>
      setters
        set x= @-1
          reference: <testLibraryFragment>::@setter::x
          element: <none>
          parameters
            _x @-1
              element: <none>
  topLevelVariables
    x
      firstFragment: <testLibraryFragment>::@topLevelVariable::x
      type: int
      getter: <none>
      setter: <none>
  getters
    synthetic static get x
      firstFragment: <testLibraryFragment>::@getter::x
  setters
    synthetic static set x=
      firstFragment: <testLibraryFragment>::@setter::x
      parameters
        requiredPositional _x
          type: int
''');
  }

  test_initializer_extractProperty_implicitlyTyped_differentLibraryCycle() async {
    newFile('$testPackageLibPath/a.dart', r'''
class C {
  var f = 0;
}
''');
    var library = await _encodeDecodeLibrary(r'''
import 'a.dart';
var x = new C().f;
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  libraryImports
    package:test/a.dart
      enclosingElement3: <testLibraryFragment>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      libraryImports
        package:test/a.dart
          enclosingElement3: <testLibraryFragment>
      topLevelVariables
        static x @21
          reference: <testLibraryFragment>::@topLevelVariable::x
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get x @-1
          reference: <testLibraryFragment>::@getter::x
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set x= @-1
          reference: <testLibraryFragment>::@setter::x
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _x @-1
              type: int
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      libraryImports
        package:test/a.dart
      topLevelVariables
        x @21
          reference: <testLibraryFragment>::@topLevelVariable::x
          element: <none>
          getter2: <testLibraryFragment>::@getter::x
          setter2: <testLibraryFragment>::@setter::x
      getters
        get x @-1
          reference: <testLibraryFragment>::@getter::x
          element: <none>
      setters
        set x= @-1
          reference: <testLibraryFragment>::@setter::x
          element: <none>
          parameters
            _x @-1
              element: <none>
  topLevelVariables
    x
      firstFragment: <testLibraryFragment>::@topLevelVariable::x
      type: int
      getter: <none>
      setter: <none>
  getters
    synthetic static get x
      firstFragment: <testLibraryFragment>::@getter::x
  setters
    synthetic static set x=
      firstFragment: <testLibraryFragment>::@setter::x
      parameters
        requiredPositional _x
          type: int
''');
  }

  test_initializer_extractProperty_implicitlyTyped_sameLibrary() async {
    var library = await _encodeDecodeLibrary(r'''
class C {
  var f = 0;
}
var x = new C().f;
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class C @6
          reference: <testLibraryFragment>::@class::C
          enclosingElement3: <testLibraryFragment>
          fields
            f @16
              reference: <testLibraryFragment>::@class::C::@field::f
              enclosingElement3: <testLibraryFragment>::@class::C
              type: int
              shouldUseTypeForInitializerInference: false
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::C
          accessors
            synthetic get f @-1
              reference: <testLibraryFragment>::@class::C::@getter::f
              enclosingElement3: <testLibraryFragment>::@class::C
              returnType: int
            synthetic set f= @-1
              reference: <testLibraryFragment>::@class::C::@setter::f
              enclosingElement3: <testLibraryFragment>::@class::C
              parameters
                requiredPositional _f @-1
                  type: int
              returnType: void
      topLevelVariables
        static x @29
          reference: <testLibraryFragment>::@topLevelVariable::x
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get x @-1
          reference: <testLibraryFragment>::@getter::x
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set x= @-1
          reference: <testLibraryFragment>::@setter::x
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _x @-1
              type: int
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class C @6
          reference: <testLibraryFragment>::@class::C
          element: <testLibraryFragment>::@class::C
          fields
            f @16
              reference: <testLibraryFragment>::@class::C::@field::f
              element: <none>
              getter2: <testLibraryFragment>::@class::C::@getter::f
              setter2: <testLibraryFragment>::@class::C::@setter::f
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              element: <none>
          getters
            get f @-1
              reference: <testLibraryFragment>::@class::C::@getter::f
              element: <none>
          setters
            set f= @-1
              reference: <testLibraryFragment>::@class::C::@setter::f
              element: <none>
              parameters
                _f @-1
                  element: <none>
      topLevelVariables
        x @29
          reference: <testLibraryFragment>::@topLevelVariable::x
          element: <none>
          getter2: <testLibraryFragment>::@getter::x
          setter2: <testLibraryFragment>::@setter::x
      getters
        get x @-1
          reference: <testLibraryFragment>::@getter::x
          element: <none>
      setters
        set x= @-1
          reference: <testLibraryFragment>::@setter::x
          element: <none>
          parameters
            _x @-1
              element: <none>
  classes
    class C
      firstFragment: <testLibraryFragment>::@class::C
      fields
        f
          firstFragment: <testLibraryFragment>::@class::C::@field::f
          type: int
          getter: <none>
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::C::@constructor::new
      getters
        synthetic get f
          firstFragment: <testLibraryFragment>::@class::C::@getter::f
      setters
        synthetic set f=
          firstFragment: <testLibraryFragment>::@class::C::@setter::f
          parameters
            requiredPositional _f
              type: int
  topLevelVariables
    x
      firstFragment: <testLibraryFragment>::@topLevelVariable::x
      type: int
      getter: <none>
      setter: <none>
  getters
    synthetic static get x
      firstFragment: <testLibraryFragment>::@getter::x
  setters
    synthetic static set x=
      firstFragment: <testLibraryFragment>::@setter::x
      parameters
        requiredPositional _x
          type: int
''');
  }

  test_initializer_extractProperty_implicitlyTyped_sameLibraryCycle() async {
    newFile('$testPackageLibPath/a.dart', r'''
import 'test.dart'; // just do make it part of the library cycle
class C {
  var f = 0;
}
''');
    var library = await _encodeDecodeLibrary(r'''
import 'a.dart';
var x = new C().f;
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  libraryImports
    package:test/a.dart
      enclosingElement3: <testLibraryFragment>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      libraryImports
        package:test/a.dart
          enclosingElement3: <testLibraryFragment>
      topLevelVariables
        static x @21
          reference: <testLibraryFragment>::@topLevelVariable::x
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get x @-1
          reference: <testLibraryFragment>::@getter::x
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set x= @-1
          reference: <testLibraryFragment>::@setter::x
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _x @-1
              type: int
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      libraryImports
        package:test/a.dart
      topLevelVariables
        x @21
          reference: <testLibraryFragment>::@topLevelVariable::x
          element: <none>
          getter2: <testLibraryFragment>::@getter::x
          setter2: <testLibraryFragment>::@setter::x
      getters
        get x @-1
          reference: <testLibraryFragment>::@getter::x
          element: <none>
      setters
        set x= @-1
          reference: <testLibraryFragment>::@setter::x
          element: <none>
          parameters
            _x @-1
              element: <none>
  topLevelVariables
    x
      firstFragment: <testLibraryFragment>::@topLevelVariable::x
      type: int
      getter: <none>
      setter: <none>
  getters
    synthetic static get x
      firstFragment: <testLibraryFragment>::@getter::x
  setters
    synthetic static set x=
      firstFragment: <testLibraryFragment>::@setter::x
      parameters
        requiredPositional _x
          type: int
''');
  }

  test_initializer_extractProperty_inStaticField() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  int f;
}
class B {
  static var t = new A().f;
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          fields
            f @16
              reference: <testLibraryFragment>::@class::A::@field::f
              enclosingElement3: <testLibraryFragment>::@class::A
              type: int
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          accessors
            synthetic get f @-1
              reference: <testLibraryFragment>::@class::A::@getter::f
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: int
            synthetic set f= @-1
              reference: <testLibraryFragment>::@class::A::@setter::f
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional _f @-1
                  type: int
              returnType: void
        class B @27
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          fields
            static t @44
              reference: <testLibraryFragment>::@class::B::@field::t
              enclosingElement3: <testLibraryFragment>::@class::B
              type: int
              shouldUseTypeForInitializerInference: false
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
          accessors
            synthetic static get t @-1
              reference: <testLibraryFragment>::@class::B::@getter::t
              enclosingElement3: <testLibraryFragment>::@class::B
              returnType: int
            synthetic static set t= @-1
              reference: <testLibraryFragment>::@class::B::@setter::t
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional _t @-1
                  type: int
              returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          fields
            f @16
              reference: <testLibraryFragment>::@class::A::@field::f
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::f
              setter2: <testLibraryFragment>::@class::A::@setter::f
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          getters
            get f @-1
              reference: <testLibraryFragment>::@class::A::@getter::f
              element: <none>
          setters
            set f= @-1
              reference: <testLibraryFragment>::@class::A::@setter::f
              element: <none>
              parameters
                _f @-1
                  element: <none>
        class B @27
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          fields
            t @44
              reference: <testLibraryFragment>::@class::B::@field::t
              element: <none>
              getter2: <testLibraryFragment>::@class::B::@getter::t
              setter2: <testLibraryFragment>::@class::B::@setter::t
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
          getters
            get t @-1
              reference: <testLibraryFragment>::@class::B::@getter::t
              element: <none>
          setters
            set t= @-1
              reference: <testLibraryFragment>::@class::B::@setter::t
              element: <none>
              parameters
                _t @-1
                  element: <none>
  classes
    class A
      firstFragment: <testLibraryFragment>::@class::A
      fields
        f
          firstFragment: <testLibraryFragment>::@class::A::@field::f
          type: int
          getter: <none>
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      getters
        synthetic get f
          firstFragment: <testLibraryFragment>::@class::A::@getter::f
      setters
        synthetic set f=
          firstFragment: <testLibraryFragment>::@class::A::@setter::f
          parameters
            requiredPositional _f
              type: int
    class B
      firstFragment: <testLibraryFragment>::@class::B
      fields
        static t
          firstFragment: <testLibraryFragment>::@class::B::@field::t
          type: int
          getter: <none>
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
      getters
        synthetic static get t
          firstFragment: <testLibraryFragment>::@class::B::@getter::t
      setters
        synthetic static set t=
          firstFragment: <testLibraryFragment>::@class::B::@setter::t
          parameters
            requiredPositional _t
              type: int
''');
  }

  test_initializer_extractProperty_prefixedIdentifier() async {
    var library = await _encodeDecodeLibrary(r'''
class C {
  bool b;
}
C c;
var x = c.b;
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class C @6
          reference: <testLibraryFragment>::@class::C
          enclosingElement3: <testLibraryFragment>
          fields
            b @17
              reference: <testLibraryFragment>::@class::C::@field::b
              enclosingElement3: <testLibraryFragment>::@class::C
              type: bool
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::C
          accessors
            synthetic get b @-1
              reference: <testLibraryFragment>::@class::C::@getter::b
              enclosingElement3: <testLibraryFragment>::@class::C
              returnType: bool
            synthetic set b= @-1
              reference: <testLibraryFragment>::@class::C::@setter::b
              enclosingElement3: <testLibraryFragment>::@class::C
              parameters
                requiredPositional _b @-1
                  type: bool
              returnType: void
      topLevelVariables
        static c @24
          reference: <testLibraryFragment>::@topLevelVariable::c
          enclosingElement3: <testLibraryFragment>
          type: C
        static x @31
          reference: <testLibraryFragment>::@topLevelVariable::x
          enclosingElement3: <testLibraryFragment>
          type: bool
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get c @-1
          reference: <testLibraryFragment>::@getter::c
          enclosingElement3: <testLibraryFragment>
          returnType: C
        synthetic static set c= @-1
          reference: <testLibraryFragment>::@setter::c
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _c @-1
              type: C
          returnType: void
        synthetic static get x @-1
          reference: <testLibraryFragment>::@getter::x
          enclosingElement3: <testLibraryFragment>
          returnType: bool
        synthetic static set x= @-1
          reference: <testLibraryFragment>::@setter::x
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _x @-1
              type: bool
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class C @6
          reference: <testLibraryFragment>::@class::C
          element: <testLibraryFragment>::@class::C
          fields
            b @17
              reference: <testLibraryFragment>::@class::C::@field::b
              element: <none>
              getter2: <testLibraryFragment>::@class::C::@getter::b
              setter2: <testLibraryFragment>::@class::C::@setter::b
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              element: <none>
          getters
            get b @-1
              reference: <testLibraryFragment>::@class::C::@getter::b
              element: <none>
          setters
            set b= @-1
              reference: <testLibraryFragment>::@class::C::@setter::b
              element: <none>
              parameters
                _b @-1
                  element: <none>
      topLevelVariables
        c @24
          reference: <testLibraryFragment>::@topLevelVariable::c
          element: <none>
          getter2: <testLibraryFragment>::@getter::c
          setter2: <testLibraryFragment>::@setter::c
        x @31
          reference: <testLibraryFragment>::@topLevelVariable::x
          element: <none>
          getter2: <testLibraryFragment>::@getter::x
          setter2: <testLibraryFragment>::@setter::x
      getters
        get c @-1
          reference: <testLibraryFragment>::@getter::c
          element: <none>
        get x @-1
          reference: <testLibraryFragment>::@getter::x
          element: <none>
      setters
        set c= @-1
          reference: <testLibraryFragment>::@setter::c
          element: <none>
          parameters
            _c @-1
              element: <none>
        set x= @-1
          reference: <testLibraryFragment>::@setter::x
          element: <none>
          parameters
            _x @-1
              element: <none>
  classes
    class C
      firstFragment: <testLibraryFragment>::@class::C
      fields
        b
          firstFragment: <testLibraryFragment>::@class::C::@field::b
          type: bool
          getter: <none>
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::C::@constructor::new
      getters
        synthetic get b
          firstFragment: <testLibraryFragment>::@class::C::@getter::b
      setters
        synthetic set b=
          firstFragment: <testLibraryFragment>::@class::C::@setter::b
          parameters
            requiredPositional _b
              type: bool
  topLevelVariables
    c
      firstFragment: <testLibraryFragment>::@topLevelVariable::c
      type: C
      getter: <none>
      setter: <none>
    x
      firstFragment: <testLibraryFragment>::@topLevelVariable::x
      type: bool
      getter: <none>
      setter: <none>
  getters
    synthetic static get c
      firstFragment: <testLibraryFragment>::@getter::c
    synthetic static get x
      firstFragment: <testLibraryFragment>::@getter::x
  setters
    synthetic static set c=
      firstFragment: <testLibraryFragment>::@setter::c
      parameters
        requiredPositional _c
          type: C
    synthetic static set x=
      firstFragment: <testLibraryFragment>::@setter::x
      parameters
        requiredPositional _x
          type: bool
''');
  }

  test_initializer_extractProperty_prefixedIdentifier_viaInterface() async {
    var library = await _encodeDecodeLibrary(r'''
class I {
  bool b;
}
abstract class C implements I {}
C c;
var x = c.b;
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class I @6
          reference: <testLibraryFragment>::@class::I
          enclosingElement3: <testLibraryFragment>
          fields
            b @17
              reference: <testLibraryFragment>::@class::I::@field::b
              enclosingElement3: <testLibraryFragment>::@class::I
              type: bool
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::I::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::I
          accessors
            synthetic get b @-1
              reference: <testLibraryFragment>::@class::I::@getter::b
              enclosingElement3: <testLibraryFragment>::@class::I
              returnType: bool
            synthetic set b= @-1
              reference: <testLibraryFragment>::@class::I::@setter::b
              enclosingElement3: <testLibraryFragment>::@class::I
              parameters
                requiredPositional _b @-1
                  type: bool
              returnType: void
        abstract class C @37
          reference: <testLibraryFragment>::@class::C
          enclosingElement3: <testLibraryFragment>
          interfaces
            I
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::C
      topLevelVariables
        static c @57
          reference: <testLibraryFragment>::@topLevelVariable::c
          enclosingElement3: <testLibraryFragment>
          type: C
        static x @64
          reference: <testLibraryFragment>::@topLevelVariable::x
          enclosingElement3: <testLibraryFragment>
          type: bool
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get c @-1
          reference: <testLibraryFragment>::@getter::c
          enclosingElement3: <testLibraryFragment>
          returnType: C
        synthetic static set c= @-1
          reference: <testLibraryFragment>::@setter::c
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _c @-1
              type: C
          returnType: void
        synthetic static get x @-1
          reference: <testLibraryFragment>::@getter::x
          enclosingElement3: <testLibraryFragment>
          returnType: bool
        synthetic static set x= @-1
          reference: <testLibraryFragment>::@setter::x
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _x @-1
              type: bool
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class I @6
          reference: <testLibraryFragment>::@class::I
          element: <testLibraryFragment>::@class::I
          fields
            b @17
              reference: <testLibraryFragment>::@class::I::@field::b
              element: <none>
              getter2: <testLibraryFragment>::@class::I::@getter::b
              setter2: <testLibraryFragment>::@class::I::@setter::b
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::I::@constructor::new
              element: <none>
          getters
            get b @-1
              reference: <testLibraryFragment>::@class::I::@getter::b
              element: <none>
          setters
            set b= @-1
              reference: <testLibraryFragment>::@class::I::@setter::b
              element: <none>
              parameters
                _b @-1
                  element: <none>
        class C @37
          reference: <testLibraryFragment>::@class::C
          element: <testLibraryFragment>::@class::C
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              element: <none>
      topLevelVariables
        c @57
          reference: <testLibraryFragment>::@topLevelVariable::c
          element: <none>
          getter2: <testLibraryFragment>::@getter::c
          setter2: <testLibraryFragment>::@setter::c
        x @64
          reference: <testLibraryFragment>::@topLevelVariable::x
          element: <none>
          getter2: <testLibraryFragment>::@getter::x
          setter2: <testLibraryFragment>::@setter::x
      getters
        get c @-1
          reference: <testLibraryFragment>::@getter::c
          element: <none>
        get x @-1
          reference: <testLibraryFragment>::@getter::x
          element: <none>
      setters
        set c= @-1
          reference: <testLibraryFragment>::@setter::c
          element: <none>
          parameters
            _c @-1
              element: <none>
        set x= @-1
          reference: <testLibraryFragment>::@setter::x
          element: <none>
          parameters
            _x @-1
              element: <none>
  classes
    class I
      firstFragment: <testLibraryFragment>::@class::I
      fields
        b
          firstFragment: <testLibraryFragment>::@class::I::@field::b
          type: bool
          getter: <none>
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::I::@constructor::new
      getters
        synthetic get b
          firstFragment: <testLibraryFragment>::@class::I::@getter::b
      setters
        synthetic set b=
          firstFragment: <testLibraryFragment>::@class::I::@setter::b
          parameters
            requiredPositional _b
              type: bool
    abstract class C
      firstFragment: <testLibraryFragment>::@class::C
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::C::@constructor::new
  topLevelVariables
    c
      firstFragment: <testLibraryFragment>::@topLevelVariable::c
      type: C
      getter: <none>
      setter: <none>
    x
      firstFragment: <testLibraryFragment>::@topLevelVariable::x
      type: bool
      getter: <none>
      setter: <none>
  getters
    synthetic static get c
      firstFragment: <testLibraryFragment>::@getter::c
    synthetic static get x
      firstFragment: <testLibraryFragment>::@getter::x
  setters
    synthetic static set c=
      firstFragment: <testLibraryFragment>::@setter::c
      parameters
        requiredPositional _c
          type: C
    synthetic static set x=
      firstFragment: <testLibraryFragment>::@setter::x
      parameters
        requiredPositional _x
          type: bool
''');
  }

  test_initializer_extractProperty_viaInterface() async {
    var library = await _encodeDecodeLibrary(r'''
class I {
  bool b;
}
abstract class C implements I {}
C f() => null;
var x = f().b;
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class I @6
          reference: <testLibraryFragment>::@class::I
          enclosingElement3: <testLibraryFragment>
          fields
            b @17
              reference: <testLibraryFragment>::@class::I::@field::b
              enclosingElement3: <testLibraryFragment>::@class::I
              type: bool
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::I::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::I
          accessors
            synthetic get b @-1
              reference: <testLibraryFragment>::@class::I::@getter::b
              enclosingElement3: <testLibraryFragment>::@class::I
              returnType: bool
            synthetic set b= @-1
              reference: <testLibraryFragment>::@class::I::@setter::b
              enclosingElement3: <testLibraryFragment>::@class::I
              parameters
                requiredPositional _b @-1
                  type: bool
              returnType: void
        abstract class C @37
          reference: <testLibraryFragment>::@class::C
          enclosingElement3: <testLibraryFragment>
          interfaces
            I
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::C
      topLevelVariables
        static x @74
          reference: <testLibraryFragment>::@topLevelVariable::x
          enclosingElement3: <testLibraryFragment>
          type: bool
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get x @-1
          reference: <testLibraryFragment>::@getter::x
          enclosingElement3: <testLibraryFragment>
          returnType: bool
        synthetic static set x= @-1
          reference: <testLibraryFragment>::@setter::x
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _x @-1
              type: bool
          returnType: void
      functions
        f @57
          reference: <testLibraryFragment>::@function::f
          enclosingElement3: <testLibraryFragment>
          returnType: C
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class I @6
          reference: <testLibraryFragment>::@class::I
          element: <testLibraryFragment>::@class::I
          fields
            b @17
              reference: <testLibraryFragment>::@class::I::@field::b
              element: <none>
              getter2: <testLibraryFragment>::@class::I::@getter::b
              setter2: <testLibraryFragment>::@class::I::@setter::b
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::I::@constructor::new
              element: <none>
          getters
            get b @-1
              reference: <testLibraryFragment>::@class::I::@getter::b
              element: <none>
          setters
            set b= @-1
              reference: <testLibraryFragment>::@class::I::@setter::b
              element: <none>
              parameters
                _b @-1
                  element: <none>
        class C @37
          reference: <testLibraryFragment>::@class::C
          element: <testLibraryFragment>::@class::C
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              element: <none>
      topLevelVariables
        x @74
          reference: <testLibraryFragment>::@topLevelVariable::x
          element: <none>
          getter2: <testLibraryFragment>::@getter::x
          setter2: <testLibraryFragment>::@setter::x
      getters
        get x @-1
          reference: <testLibraryFragment>::@getter::x
          element: <none>
      setters
        set x= @-1
          reference: <testLibraryFragment>::@setter::x
          element: <none>
          parameters
            _x @-1
              element: <none>
      functions
        f @57
          reference: <testLibraryFragment>::@function::f
          element: <none>
  classes
    class I
      firstFragment: <testLibraryFragment>::@class::I
      fields
        b
          firstFragment: <testLibraryFragment>::@class::I::@field::b
          type: bool
          getter: <none>
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::I::@constructor::new
      getters
        synthetic get b
          firstFragment: <testLibraryFragment>::@class::I::@getter::b
      setters
        synthetic set b=
          firstFragment: <testLibraryFragment>::@class::I::@setter::b
          parameters
            requiredPositional _b
              type: bool
    abstract class C
      firstFragment: <testLibraryFragment>::@class::C
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::C::@constructor::new
  topLevelVariables
    x
      firstFragment: <testLibraryFragment>::@topLevelVariable::x
      type: bool
      getter: <none>
      setter: <none>
  getters
    synthetic static get x
      firstFragment: <testLibraryFragment>::@getter::x
  setters
    synthetic static set x=
      firstFragment: <testLibraryFragment>::@setter::x
      parameters
        requiredPositional _x
          type: bool
  functions
    f
      firstFragment: <testLibraryFragment>::@function::f
      returnType: C
''');
  }

  test_initializer_fromInstanceMethod() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  int foo() => 0;
}
class B extends A {
  foo() => 1;
}
var x = A().foo();
var y = B().foo();
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          methods
            foo @16
              reference: <testLibraryFragment>::@class::A::@method::foo
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: int
        class B @36
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          supertype: A
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
              superConstructor: <testLibraryFragment>::@class::A::@constructor::new
          methods
            foo @52
              reference: <testLibraryFragment>::@class::B::@method::foo
              enclosingElement3: <testLibraryFragment>::@class::B
              returnType: int
      topLevelVariables
        static x @70
          reference: <testLibraryFragment>::@topLevelVariable::x
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
        static y @89
          reference: <testLibraryFragment>::@topLevelVariable::y
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get x @-1
          reference: <testLibraryFragment>::@getter::x
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set x= @-1
          reference: <testLibraryFragment>::@setter::x
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _x @-1
              type: int
          returnType: void
        synthetic static get y @-1
          reference: <testLibraryFragment>::@getter::y
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set y= @-1
          reference: <testLibraryFragment>::@setter::y
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _y @-1
              type: int
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          methods
            foo @16
              reference: <testLibraryFragment>::@class::A::@method::foo
              element: <none>
        class B @36
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
              superConstructor: <testLibraryFragment>::@class::A::@constructor::new
          methods
            foo @52
              reference: <testLibraryFragment>::@class::B::@method::foo
              element: <none>
      topLevelVariables
        x @70
          reference: <testLibraryFragment>::@topLevelVariable::x
          element: <none>
          getter2: <testLibraryFragment>::@getter::x
          setter2: <testLibraryFragment>::@setter::x
        y @89
          reference: <testLibraryFragment>::@topLevelVariable::y
          element: <none>
          getter2: <testLibraryFragment>::@getter::y
          setter2: <testLibraryFragment>::@setter::y
      getters
        get x @-1
          reference: <testLibraryFragment>::@getter::x
          element: <none>
        get y @-1
          reference: <testLibraryFragment>::@getter::y
          element: <none>
      setters
        set x= @-1
          reference: <testLibraryFragment>::@setter::x
          element: <none>
          parameters
            _x @-1
              element: <none>
        set y= @-1
          reference: <testLibraryFragment>::@setter::y
          element: <none>
          parameters
            _y @-1
              element: <none>
  classes
    class A
      firstFragment: <testLibraryFragment>::@class::A
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      methods
        foo
          firstFragment: <testLibraryFragment>::@class::A::@method::foo
    class B
      firstFragment: <testLibraryFragment>::@class::B
      supertype: A
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
          superConstructor: <none>
      methods
        foo
          firstFragment: <testLibraryFragment>::@class::B::@method::foo
  topLevelVariables
    x
      firstFragment: <testLibraryFragment>::@topLevelVariable::x
      type: int
      getter: <none>
      setter: <none>
    y
      firstFragment: <testLibraryFragment>::@topLevelVariable::y
      type: int
      getter: <none>
      setter: <none>
  getters
    synthetic static get x
      firstFragment: <testLibraryFragment>::@getter::x
    synthetic static get y
      firstFragment: <testLibraryFragment>::@getter::y
  setters
    synthetic static set x=
      firstFragment: <testLibraryFragment>::@setter::x
      parameters
        requiredPositional _x
          type: int
    synthetic static set y=
      firstFragment: <testLibraryFragment>::@setter::y
      parameters
        requiredPositional _y
          type: int
''');
  }

  test_initializer_functionExpression() async {
    var library = await _encodeDecodeLibrary(r'''
import 'dart:async';
var vFuture = new Future<int>(42);
var v_noParameters_inferredReturnType = () => 42;
var v_hasParameter_withType_inferredReturnType = (String a) => 42;
var v_hasParameter_withType_returnParameter = (String a) => a;
var v_async_returnValue = () async => 42;
var v_async_returnFuture = () async => vFuture;
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  libraryImports
    dart:async
      enclosingElement3: <testLibraryFragment>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      libraryImports
        dart:async
          enclosingElement3: <testLibraryFragment>
      topLevelVariables
        static vFuture @25
          reference: <testLibraryFragment>::@topLevelVariable::vFuture
          enclosingElement3: <testLibraryFragment>
          type: Future<int>
          shouldUseTypeForInitializerInference: false
        static v_noParameters_inferredReturnType @60
          reference: <testLibraryFragment>::@topLevelVariable::v_noParameters_inferredReturnType
          enclosingElement3: <testLibraryFragment>
          type: int Function()
          shouldUseTypeForInitializerInference: false
        static v_hasParameter_withType_inferredReturnType @110
          reference: <testLibraryFragment>::@topLevelVariable::v_hasParameter_withType_inferredReturnType
          enclosingElement3: <testLibraryFragment>
          type: int Function(String)
          shouldUseTypeForInitializerInference: false
        static v_hasParameter_withType_returnParameter @177
          reference: <testLibraryFragment>::@topLevelVariable::v_hasParameter_withType_returnParameter
          enclosingElement3: <testLibraryFragment>
          type: String Function(String)
          shouldUseTypeForInitializerInference: false
        static v_async_returnValue @240
          reference: <testLibraryFragment>::@topLevelVariable::v_async_returnValue
          enclosingElement3: <testLibraryFragment>
          type: Future<int> Function()
          shouldUseTypeForInitializerInference: false
        static v_async_returnFuture @282
          reference: <testLibraryFragment>::@topLevelVariable::v_async_returnFuture
          enclosingElement3: <testLibraryFragment>
          type: Future<int> Function()
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get vFuture @-1
          reference: <testLibraryFragment>::@getter::vFuture
          enclosingElement3: <testLibraryFragment>
          returnType: Future<int>
        synthetic static set vFuture= @-1
          reference: <testLibraryFragment>::@setter::vFuture
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vFuture @-1
              type: Future<int>
          returnType: void
        synthetic static get v_noParameters_inferredReturnType @-1
          reference: <testLibraryFragment>::@getter::v_noParameters_inferredReturnType
          enclosingElement3: <testLibraryFragment>
          returnType: int Function()
        synthetic static set v_noParameters_inferredReturnType= @-1
          reference: <testLibraryFragment>::@setter::v_noParameters_inferredReturnType
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _v_noParameters_inferredReturnType @-1
              type: int Function()
          returnType: void
        synthetic static get v_hasParameter_withType_inferredReturnType @-1
          reference: <testLibraryFragment>::@getter::v_hasParameter_withType_inferredReturnType
          enclosingElement3: <testLibraryFragment>
          returnType: int Function(String)
        synthetic static set v_hasParameter_withType_inferredReturnType= @-1
          reference: <testLibraryFragment>::@setter::v_hasParameter_withType_inferredReturnType
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _v_hasParameter_withType_inferredReturnType @-1
              type: int Function(String)
          returnType: void
        synthetic static get v_hasParameter_withType_returnParameter @-1
          reference: <testLibraryFragment>::@getter::v_hasParameter_withType_returnParameter
          enclosingElement3: <testLibraryFragment>
          returnType: String Function(String)
        synthetic static set v_hasParameter_withType_returnParameter= @-1
          reference: <testLibraryFragment>::@setter::v_hasParameter_withType_returnParameter
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _v_hasParameter_withType_returnParameter @-1
              type: String Function(String)
          returnType: void
        synthetic static get v_async_returnValue @-1
          reference: <testLibraryFragment>::@getter::v_async_returnValue
          enclosingElement3: <testLibraryFragment>
          returnType: Future<int> Function()
        synthetic static set v_async_returnValue= @-1
          reference: <testLibraryFragment>::@setter::v_async_returnValue
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _v_async_returnValue @-1
              type: Future<int> Function()
          returnType: void
        synthetic static get v_async_returnFuture @-1
          reference: <testLibraryFragment>::@getter::v_async_returnFuture
          enclosingElement3: <testLibraryFragment>
          returnType: Future<int> Function()
        synthetic static set v_async_returnFuture= @-1
          reference: <testLibraryFragment>::@setter::v_async_returnFuture
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _v_async_returnFuture @-1
              type: Future<int> Function()
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      libraryImports
        dart:async
      topLevelVariables
        vFuture @25
          reference: <testLibraryFragment>::@topLevelVariable::vFuture
          element: <none>
          getter2: <testLibraryFragment>::@getter::vFuture
          setter2: <testLibraryFragment>::@setter::vFuture
        v_noParameters_inferredReturnType @60
          reference: <testLibraryFragment>::@topLevelVariable::v_noParameters_inferredReturnType
          element: <none>
          getter2: <testLibraryFragment>::@getter::v_noParameters_inferredReturnType
          setter2: <testLibraryFragment>::@setter::v_noParameters_inferredReturnType
        v_hasParameter_withType_inferredReturnType @110
          reference: <testLibraryFragment>::@topLevelVariable::v_hasParameter_withType_inferredReturnType
          element: <none>
          getter2: <testLibraryFragment>::@getter::v_hasParameter_withType_inferredReturnType
          setter2: <testLibraryFragment>::@setter::v_hasParameter_withType_inferredReturnType
        v_hasParameter_withType_returnParameter @177
          reference: <testLibraryFragment>::@topLevelVariable::v_hasParameter_withType_returnParameter
          element: <none>
          getter2: <testLibraryFragment>::@getter::v_hasParameter_withType_returnParameter
          setter2: <testLibraryFragment>::@setter::v_hasParameter_withType_returnParameter
        v_async_returnValue @240
          reference: <testLibraryFragment>::@topLevelVariable::v_async_returnValue
          element: <none>
          getter2: <testLibraryFragment>::@getter::v_async_returnValue
          setter2: <testLibraryFragment>::@setter::v_async_returnValue
        v_async_returnFuture @282
          reference: <testLibraryFragment>::@topLevelVariable::v_async_returnFuture
          element: <none>
          getter2: <testLibraryFragment>::@getter::v_async_returnFuture
          setter2: <testLibraryFragment>::@setter::v_async_returnFuture
      getters
        get vFuture @-1
          reference: <testLibraryFragment>::@getter::vFuture
          element: <none>
        get v_noParameters_inferredReturnType @-1
          reference: <testLibraryFragment>::@getter::v_noParameters_inferredReturnType
          element: <none>
        get v_hasParameter_withType_inferredReturnType @-1
          reference: <testLibraryFragment>::@getter::v_hasParameter_withType_inferredReturnType
          element: <none>
        get v_hasParameter_withType_returnParameter @-1
          reference: <testLibraryFragment>::@getter::v_hasParameter_withType_returnParameter
          element: <none>
        get v_async_returnValue @-1
          reference: <testLibraryFragment>::@getter::v_async_returnValue
          element: <none>
        get v_async_returnFuture @-1
          reference: <testLibraryFragment>::@getter::v_async_returnFuture
          element: <none>
      setters
        set vFuture= @-1
          reference: <testLibraryFragment>::@setter::vFuture
          element: <none>
          parameters
            _vFuture @-1
              element: <none>
        set v_noParameters_inferredReturnType= @-1
          reference: <testLibraryFragment>::@setter::v_noParameters_inferredReturnType
          element: <none>
          parameters
            _v_noParameters_inferredReturnType @-1
              element: <none>
        set v_hasParameter_withType_inferredReturnType= @-1
          reference: <testLibraryFragment>::@setter::v_hasParameter_withType_inferredReturnType
          element: <none>
          parameters
            _v_hasParameter_withType_inferredReturnType @-1
              element: <none>
        set v_hasParameter_withType_returnParameter= @-1
          reference: <testLibraryFragment>::@setter::v_hasParameter_withType_returnParameter
          element: <none>
          parameters
            _v_hasParameter_withType_returnParameter @-1
              element: <none>
        set v_async_returnValue= @-1
          reference: <testLibraryFragment>::@setter::v_async_returnValue
          element: <none>
          parameters
            _v_async_returnValue @-1
              element: <none>
        set v_async_returnFuture= @-1
          reference: <testLibraryFragment>::@setter::v_async_returnFuture
          element: <none>
          parameters
            _v_async_returnFuture @-1
              element: <none>
  topLevelVariables
    vFuture
      firstFragment: <testLibraryFragment>::@topLevelVariable::vFuture
      type: Future<int>
      getter: <none>
      setter: <none>
    v_noParameters_inferredReturnType
      firstFragment: <testLibraryFragment>::@topLevelVariable::v_noParameters_inferredReturnType
      type: int Function()
      getter: <none>
      setter: <none>
    v_hasParameter_withType_inferredReturnType
      firstFragment: <testLibraryFragment>::@topLevelVariable::v_hasParameter_withType_inferredReturnType
      type: int Function(String)
      getter: <none>
      setter: <none>
    v_hasParameter_withType_returnParameter
      firstFragment: <testLibraryFragment>::@topLevelVariable::v_hasParameter_withType_returnParameter
      type: String Function(String)
      getter: <none>
      setter: <none>
    v_async_returnValue
      firstFragment: <testLibraryFragment>::@topLevelVariable::v_async_returnValue
      type: Future<int> Function()
      getter: <none>
      setter: <none>
    v_async_returnFuture
      firstFragment: <testLibraryFragment>::@topLevelVariable::v_async_returnFuture
      type: Future<int> Function()
      getter: <none>
      setter: <none>
  getters
    synthetic static get vFuture
      firstFragment: <testLibraryFragment>::@getter::vFuture
    synthetic static get v_noParameters_inferredReturnType
      firstFragment: <testLibraryFragment>::@getter::v_noParameters_inferredReturnType
    synthetic static get v_hasParameter_withType_inferredReturnType
      firstFragment: <testLibraryFragment>::@getter::v_hasParameter_withType_inferredReturnType
    synthetic static get v_hasParameter_withType_returnParameter
      firstFragment: <testLibraryFragment>::@getter::v_hasParameter_withType_returnParameter
    synthetic static get v_async_returnValue
      firstFragment: <testLibraryFragment>::@getter::v_async_returnValue
    synthetic static get v_async_returnFuture
      firstFragment: <testLibraryFragment>::@getter::v_async_returnFuture
  setters
    synthetic static set vFuture=
      firstFragment: <testLibraryFragment>::@setter::vFuture
      parameters
        requiredPositional _vFuture
          type: Future<int>
    synthetic static set v_noParameters_inferredReturnType=
      firstFragment: <testLibraryFragment>::@setter::v_noParameters_inferredReturnType
      parameters
        requiredPositional _v_noParameters_inferredReturnType
          type: int Function()
    synthetic static set v_hasParameter_withType_inferredReturnType=
      firstFragment: <testLibraryFragment>::@setter::v_hasParameter_withType_inferredReturnType
      parameters
        requiredPositional _v_hasParameter_withType_inferredReturnType
          type: int Function(String)
    synthetic static set v_hasParameter_withType_returnParameter=
      firstFragment: <testLibraryFragment>::@setter::v_hasParameter_withType_returnParameter
      parameters
        requiredPositional _v_hasParameter_withType_returnParameter
          type: String Function(String)
    synthetic static set v_async_returnValue=
      firstFragment: <testLibraryFragment>::@setter::v_async_returnValue
      parameters
        requiredPositional _v_async_returnValue
          type: Future<int> Function()
    synthetic static set v_async_returnFuture=
      firstFragment: <testLibraryFragment>::@setter::v_async_returnFuture
      parameters
        requiredPositional _v_async_returnFuture
          type: Future<int> Function()
''');
  }

  test_initializer_functionExpressionInvocation_noTypeParameters() async {
    var library = await _encodeDecodeLibrary(r'''
var v = (() => 42)();
''');
    // TODO(scheglov): add more function expression tests
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      topLevelVariables
        static v @4
          reference: <testLibraryFragment>::@topLevelVariable::v
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get v @-1
          reference: <testLibraryFragment>::@getter::v
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set v= @-1
          reference: <testLibraryFragment>::@setter::v
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _v @-1
              type: int
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      topLevelVariables
        v @4
          reference: <testLibraryFragment>::@topLevelVariable::v
          element: <none>
          getter2: <testLibraryFragment>::@getter::v
          setter2: <testLibraryFragment>::@setter::v
      getters
        get v @-1
          reference: <testLibraryFragment>::@getter::v
          element: <none>
      setters
        set v= @-1
          reference: <testLibraryFragment>::@setter::v
          element: <none>
          parameters
            _v @-1
              element: <none>
  topLevelVariables
    v
      firstFragment: <testLibraryFragment>::@topLevelVariable::v
      type: int
      getter: <none>
      setter: <none>
  getters
    synthetic static get v
      firstFragment: <testLibraryFragment>::@getter::v
  setters
    synthetic static set v=
      firstFragment: <testLibraryFragment>::@setter::v
      parameters
        requiredPositional _v
          type: int
''');
  }

  test_initializer_functionInvocation_hasTypeParameters() async {
    var library = await _encodeDecodeLibrary(r'''
T f<T>() => null;
var vHasTypeArgument = f<int>();
var vNoTypeArgument = f();
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      topLevelVariables
        static vHasTypeArgument @22
          reference: <testLibraryFragment>::@topLevelVariable::vHasTypeArgument
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
        static vNoTypeArgument @55
          reference: <testLibraryFragment>::@topLevelVariable::vNoTypeArgument
          enclosingElement3: <testLibraryFragment>
          type: dynamic
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get vHasTypeArgument @-1
          reference: <testLibraryFragment>::@getter::vHasTypeArgument
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set vHasTypeArgument= @-1
          reference: <testLibraryFragment>::@setter::vHasTypeArgument
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vHasTypeArgument @-1
              type: int
          returnType: void
        synthetic static get vNoTypeArgument @-1
          reference: <testLibraryFragment>::@getter::vNoTypeArgument
          enclosingElement3: <testLibraryFragment>
          returnType: dynamic
        synthetic static set vNoTypeArgument= @-1
          reference: <testLibraryFragment>::@setter::vNoTypeArgument
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vNoTypeArgument @-1
              type: dynamic
          returnType: void
      functions
        f @2
          reference: <testLibraryFragment>::@function::f
          enclosingElement3: <testLibraryFragment>
          typeParameters
            covariant T @4
              defaultType: dynamic
          returnType: T
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      topLevelVariables
        vHasTypeArgument @22
          reference: <testLibraryFragment>::@topLevelVariable::vHasTypeArgument
          element: <none>
          getter2: <testLibraryFragment>::@getter::vHasTypeArgument
          setter2: <testLibraryFragment>::@setter::vHasTypeArgument
        vNoTypeArgument @55
          reference: <testLibraryFragment>::@topLevelVariable::vNoTypeArgument
          element: <none>
          getter2: <testLibraryFragment>::@getter::vNoTypeArgument
          setter2: <testLibraryFragment>::@setter::vNoTypeArgument
      getters
        get vHasTypeArgument @-1
          reference: <testLibraryFragment>::@getter::vHasTypeArgument
          element: <none>
        get vNoTypeArgument @-1
          reference: <testLibraryFragment>::@getter::vNoTypeArgument
          element: <none>
      setters
        set vHasTypeArgument= @-1
          reference: <testLibraryFragment>::@setter::vHasTypeArgument
          element: <none>
          parameters
            _vHasTypeArgument @-1
              element: <none>
        set vNoTypeArgument= @-1
          reference: <testLibraryFragment>::@setter::vNoTypeArgument
          element: <none>
          parameters
            _vNoTypeArgument @-1
              element: <none>
      functions
        f @2
          reference: <testLibraryFragment>::@function::f
          element: <none>
          typeParameters
            T @4
              element: <none>
  topLevelVariables
    vHasTypeArgument
      firstFragment: <testLibraryFragment>::@topLevelVariable::vHasTypeArgument
      type: int
      getter: <none>
      setter: <none>
    vNoTypeArgument
      firstFragment: <testLibraryFragment>::@topLevelVariable::vNoTypeArgument
      type: dynamic
      getter: <none>
      setter: <none>
  getters
    synthetic static get vHasTypeArgument
      firstFragment: <testLibraryFragment>::@getter::vHasTypeArgument
    synthetic static get vNoTypeArgument
      firstFragment: <testLibraryFragment>::@getter::vNoTypeArgument
  setters
    synthetic static set vHasTypeArgument=
      firstFragment: <testLibraryFragment>::@setter::vHasTypeArgument
      parameters
        requiredPositional _vHasTypeArgument
          type: int
    synthetic static set vNoTypeArgument=
      firstFragment: <testLibraryFragment>::@setter::vNoTypeArgument
      parameters
        requiredPositional _vNoTypeArgument
          type: dynamic
  functions
    f
      firstFragment: <testLibraryFragment>::@function::f
      typeParameters
        T
      returnType: T
''');
  }

  test_initializer_functionInvocation_noTypeParameters() async {
    var library = await _encodeDecodeLibrary(r'''
String f(int p) => null;
var vOkArgumentType = f(1);
var vWrongArgumentType = f(2.0);
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      topLevelVariables
        static vOkArgumentType @29
          reference: <testLibraryFragment>::@topLevelVariable::vOkArgumentType
          enclosingElement3: <testLibraryFragment>
          type: String
          shouldUseTypeForInitializerInference: false
        static vWrongArgumentType @57
          reference: <testLibraryFragment>::@topLevelVariable::vWrongArgumentType
          enclosingElement3: <testLibraryFragment>
          type: String
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get vOkArgumentType @-1
          reference: <testLibraryFragment>::@getter::vOkArgumentType
          enclosingElement3: <testLibraryFragment>
          returnType: String
        synthetic static set vOkArgumentType= @-1
          reference: <testLibraryFragment>::@setter::vOkArgumentType
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vOkArgumentType @-1
              type: String
          returnType: void
        synthetic static get vWrongArgumentType @-1
          reference: <testLibraryFragment>::@getter::vWrongArgumentType
          enclosingElement3: <testLibraryFragment>
          returnType: String
        synthetic static set vWrongArgumentType= @-1
          reference: <testLibraryFragment>::@setter::vWrongArgumentType
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vWrongArgumentType @-1
              type: String
          returnType: void
      functions
        f @7
          reference: <testLibraryFragment>::@function::f
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional p @13
              type: int
          returnType: String
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      topLevelVariables
        vOkArgumentType @29
          reference: <testLibraryFragment>::@topLevelVariable::vOkArgumentType
          element: <none>
          getter2: <testLibraryFragment>::@getter::vOkArgumentType
          setter2: <testLibraryFragment>::@setter::vOkArgumentType
        vWrongArgumentType @57
          reference: <testLibraryFragment>::@topLevelVariable::vWrongArgumentType
          element: <none>
          getter2: <testLibraryFragment>::@getter::vWrongArgumentType
          setter2: <testLibraryFragment>::@setter::vWrongArgumentType
      getters
        get vOkArgumentType @-1
          reference: <testLibraryFragment>::@getter::vOkArgumentType
          element: <none>
        get vWrongArgumentType @-1
          reference: <testLibraryFragment>::@getter::vWrongArgumentType
          element: <none>
      setters
        set vOkArgumentType= @-1
          reference: <testLibraryFragment>::@setter::vOkArgumentType
          element: <none>
          parameters
            _vOkArgumentType @-1
              element: <none>
        set vWrongArgumentType= @-1
          reference: <testLibraryFragment>::@setter::vWrongArgumentType
          element: <none>
          parameters
            _vWrongArgumentType @-1
              element: <none>
      functions
        f @7
          reference: <testLibraryFragment>::@function::f
          element: <none>
          parameters
            p @13
              element: <none>
  topLevelVariables
    vOkArgumentType
      firstFragment: <testLibraryFragment>::@topLevelVariable::vOkArgumentType
      type: String
      getter: <none>
      setter: <none>
    vWrongArgumentType
      firstFragment: <testLibraryFragment>::@topLevelVariable::vWrongArgumentType
      type: String
      getter: <none>
      setter: <none>
  getters
    synthetic static get vOkArgumentType
      firstFragment: <testLibraryFragment>::@getter::vOkArgumentType
    synthetic static get vWrongArgumentType
      firstFragment: <testLibraryFragment>::@getter::vWrongArgumentType
  setters
    synthetic static set vOkArgumentType=
      firstFragment: <testLibraryFragment>::@setter::vOkArgumentType
      parameters
        requiredPositional _vOkArgumentType
          type: String
    synthetic static set vWrongArgumentType=
      firstFragment: <testLibraryFragment>::@setter::vWrongArgumentType
      parameters
        requiredPositional _vWrongArgumentType
          type: String
  functions
    f
      firstFragment: <testLibraryFragment>::@function::f
      parameters
        requiredPositional p
          type: int
      returnType: String
''');
  }

  test_initializer_identifier() async {
    var library = await _encodeDecodeLibrary(r'''
String topLevelFunction(int p) => null;
var topLevelVariable = 0;
int get topLevelGetter => 0;
class A {
  static var staticClassVariable = 0;
  static int get staticGetter => 0;
  static String staticClassMethod(int p) => null;
  String instanceClassMethod(int p) => null;
}
var r_topLevelFunction = topLevelFunction;
var r_topLevelVariable = topLevelVariable;
var r_topLevelGetter = topLevelGetter;
var r_staticClassVariable = A.staticClassVariable;
var r_staticGetter = A.staticGetter;
var r_staticClassMethod = A.staticClassMethod;
var instanceOfA = new A();
var r_instanceClassMethod = instanceOfA.instanceClassMethod;
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class A @101
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          fields
            static staticClassVariable @118
              reference: <testLibraryFragment>::@class::A::@field::staticClassVariable
              enclosingElement3: <testLibraryFragment>::@class::A
              type: int
              shouldUseTypeForInitializerInference: false
            synthetic static staticGetter @-1
              reference: <testLibraryFragment>::@class::A::@field::staticGetter
              enclosingElement3: <testLibraryFragment>::@class::A
              type: int
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          accessors
            synthetic static get staticClassVariable @-1
              reference: <testLibraryFragment>::@class::A::@getter::staticClassVariable
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: int
            synthetic static set staticClassVariable= @-1
              reference: <testLibraryFragment>::@class::A::@setter::staticClassVariable
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional _staticClassVariable @-1
                  type: int
              returnType: void
            static get staticGetter @160
              reference: <testLibraryFragment>::@class::A::@getter::staticGetter
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: int
          methods
            static staticClassMethod @195
              reference: <testLibraryFragment>::@class::A::@method::staticClassMethod
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional p @217
                  type: int
              returnType: String
            instanceClassMethod @238
              reference: <testLibraryFragment>::@class::A::@method::instanceClassMethod
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional p @262
                  type: int
              returnType: String
      topLevelVariables
        static topLevelVariable @44
          reference: <testLibraryFragment>::@topLevelVariable::topLevelVariable
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
        static r_topLevelFunction @280
          reference: <testLibraryFragment>::@topLevelVariable::r_topLevelFunction
          enclosingElement3: <testLibraryFragment>
          type: String Function(int)
          shouldUseTypeForInitializerInference: false
        static r_topLevelVariable @323
          reference: <testLibraryFragment>::@topLevelVariable::r_topLevelVariable
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
        static r_topLevelGetter @366
          reference: <testLibraryFragment>::@topLevelVariable::r_topLevelGetter
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
        static r_staticClassVariable @405
          reference: <testLibraryFragment>::@topLevelVariable::r_staticClassVariable
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
        static r_staticGetter @456
          reference: <testLibraryFragment>::@topLevelVariable::r_staticGetter
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
        static r_staticClassMethod @493
          reference: <testLibraryFragment>::@topLevelVariable::r_staticClassMethod
          enclosingElement3: <testLibraryFragment>
          type: String Function(int)
          shouldUseTypeForInitializerInference: false
        static instanceOfA @540
          reference: <testLibraryFragment>::@topLevelVariable::instanceOfA
          enclosingElement3: <testLibraryFragment>
          type: A
          shouldUseTypeForInitializerInference: false
        static r_instanceClassMethod @567
          reference: <testLibraryFragment>::@topLevelVariable::r_instanceClassMethod
          enclosingElement3: <testLibraryFragment>
          type: String Function(int)
          shouldUseTypeForInitializerInference: false
        synthetic static topLevelGetter @-1
          reference: <testLibraryFragment>::@topLevelVariable::topLevelGetter
          enclosingElement3: <testLibraryFragment>
          type: int
      accessors
        synthetic static get topLevelVariable @-1
          reference: <testLibraryFragment>::@getter::topLevelVariable
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set topLevelVariable= @-1
          reference: <testLibraryFragment>::@setter::topLevelVariable
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _topLevelVariable @-1
              type: int
          returnType: void
        synthetic static get r_topLevelFunction @-1
          reference: <testLibraryFragment>::@getter::r_topLevelFunction
          enclosingElement3: <testLibraryFragment>
          returnType: String Function(int)
        synthetic static set r_topLevelFunction= @-1
          reference: <testLibraryFragment>::@setter::r_topLevelFunction
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _r_topLevelFunction @-1
              type: String Function(int)
          returnType: void
        synthetic static get r_topLevelVariable @-1
          reference: <testLibraryFragment>::@getter::r_topLevelVariable
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set r_topLevelVariable= @-1
          reference: <testLibraryFragment>::@setter::r_topLevelVariable
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _r_topLevelVariable @-1
              type: int
          returnType: void
        synthetic static get r_topLevelGetter @-1
          reference: <testLibraryFragment>::@getter::r_topLevelGetter
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set r_topLevelGetter= @-1
          reference: <testLibraryFragment>::@setter::r_topLevelGetter
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _r_topLevelGetter @-1
              type: int
          returnType: void
        synthetic static get r_staticClassVariable @-1
          reference: <testLibraryFragment>::@getter::r_staticClassVariable
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set r_staticClassVariable= @-1
          reference: <testLibraryFragment>::@setter::r_staticClassVariable
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _r_staticClassVariable @-1
              type: int
          returnType: void
        synthetic static get r_staticGetter @-1
          reference: <testLibraryFragment>::@getter::r_staticGetter
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set r_staticGetter= @-1
          reference: <testLibraryFragment>::@setter::r_staticGetter
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _r_staticGetter @-1
              type: int
          returnType: void
        synthetic static get r_staticClassMethod @-1
          reference: <testLibraryFragment>::@getter::r_staticClassMethod
          enclosingElement3: <testLibraryFragment>
          returnType: String Function(int)
        synthetic static set r_staticClassMethod= @-1
          reference: <testLibraryFragment>::@setter::r_staticClassMethod
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _r_staticClassMethod @-1
              type: String Function(int)
          returnType: void
        synthetic static get instanceOfA @-1
          reference: <testLibraryFragment>::@getter::instanceOfA
          enclosingElement3: <testLibraryFragment>
          returnType: A
        synthetic static set instanceOfA= @-1
          reference: <testLibraryFragment>::@setter::instanceOfA
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _instanceOfA @-1
              type: A
          returnType: void
        synthetic static get r_instanceClassMethod @-1
          reference: <testLibraryFragment>::@getter::r_instanceClassMethod
          enclosingElement3: <testLibraryFragment>
          returnType: String Function(int)
        synthetic static set r_instanceClassMethod= @-1
          reference: <testLibraryFragment>::@setter::r_instanceClassMethod
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _r_instanceClassMethod @-1
              type: String Function(int)
          returnType: void
        static get topLevelGetter @74
          reference: <testLibraryFragment>::@getter::topLevelGetter
          enclosingElement3: <testLibraryFragment>
          returnType: int
      functions
        topLevelFunction @7
          reference: <testLibraryFragment>::@function::topLevelFunction
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional p @28
              type: int
          returnType: String
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @101
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          fields
            staticClassVariable @118
              reference: <testLibraryFragment>::@class::A::@field::staticClassVariable
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::staticClassVariable
              setter2: <testLibraryFragment>::@class::A::@setter::staticClassVariable
            staticGetter @-1
              reference: <testLibraryFragment>::@class::A::@field::staticGetter
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::staticGetter
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          getters
            get staticClassVariable @-1
              reference: <testLibraryFragment>::@class::A::@getter::staticClassVariable
              element: <none>
            get staticGetter @160
              reference: <testLibraryFragment>::@class::A::@getter::staticGetter
              element: <none>
          setters
            set staticClassVariable= @-1
              reference: <testLibraryFragment>::@class::A::@setter::staticClassVariable
              element: <none>
              parameters
                _staticClassVariable @-1
                  element: <none>
          methods
            staticClassMethod @195
              reference: <testLibraryFragment>::@class::A::@method::staticClassMethod
              element: <none>
              parameters
                p @217
                  element: <none>
            instanceClassMethod @238
              reference: <testLibraryFragment>::@class::A::@method::instanceClassMethod
              element: <none>
              parameters
                p @262
                  element: <none>
      topLevelVariables
        topLevelVariable @44
          reference: <testLibraryFragment>::@topLevelVariable::topLevelVariable
          element: <none>
          getter2: <testLibraryFragment>::@getter::topLevelVariable
          setter2: <testLibraryFragment>::@setter::topLevelVariable
        r_topLevelFunction @280
          reference: <testLibraryFragment>::@topLevelVariable::r_topLevelFunction
          element: <none>
          getter2: <testLibraryFragment>::@getter::r_topLevelFunction
          setter2: <testLibraryFragment>::@setter::r_topLevelFunction
        r_topLevelVariable @323
          reference: <testLibraryFragment>::@topLevelVariable::r_topLevelVariable
          element: <none>
          getter2: <testLibraryFragment>::@getter::r_topLevelVariable
          setter2: <testLibraryFragment>::@setter::r_topLevelVariable
        r_topLevelGetter @366
          reference: <testLibraryFragment>::@topLevelVariable::r_topLevelGetter
          element: <none>
          getter2: <testLibraryFragment>::@getter::r_topLevelGetter
          setter2: <testLibraryFragment>::@setter::r_topLevelGetter
        r_staticClassVariable @405
          reference: <testLibraryFragment>::@topLevelVariable::r_staticClassVariable
          element: <none>
          getter2: <testLibraryFragment>::@getter::r_staticClassVariable
          setter2: <testLibraryFragment>::@setter::r_staticClassVariable
        r_staticGetter @456
          reference: <testLibraryFragment>::@topLevelVariable::r_staticGetter
          element: <none>
          getter2: <testLibraryFragment>::@getter::r_staticGetter
          setter2: <testLibraryFragment>::@setter::r_staticGetter
        r_staticClassMethod @493
          reference: <testLibraryFragment>::@topLevelVariable::r_staticClassMethod
          element: <none>
          getter2: <testLibraryFragment>::@getter::r_staticClassMethod
          setter2: <testLibraryFragment>::@setter::r_staticClassMethod
        instanceOfA @540
          reference: <testLibraryFragment>::@topLevelVariable::instanceOfA
          element: <none>
          getter2: <testLibraryFragment>::@getter::instanceOfA
          setter2: <testLibraryFragment>::@setter::instanceOfA
        r_instanceClassMethod @567
          reference: <testLibraryFragment>::@topLevelVariable::r_instanceClassMethod
          element: <none>
          getter2: <testLibraryFragment>::@getter::r_instanceClassMethod
          setter2: <testLibraryFragment>::@setter::r_instanceClassMethod
        synthetic topLevelGetter @-1
          reference: <testLibraryFragment>::@topLevelVariable::topLevelGetter
          element: <none>
          getter2: <testLibraryFragment>::@getter::topLevelGetter
      getters
        get topLevelVariable @-1
          reference: <testLibraryFragment>::@getter::topLevelVariable
          element: <none>
        get r_topLevelFunction @-1
          reference: <testLibraryFragment>::@getter::r_topLevelFunction
          element: <none>
        get r_topLevelVariable @-1
          reference: <testLibraryFragment>::@getter::r_topLevelVariable
          element: <none>
        get r_topLevelGetter @-1
          reference: <testLibraryFragment>::@getter::r_topLevelGetter
          element: <none>
        get r_staticClassVariable @-1
          reference: <testLibraryFragment>::@getter::r_staticClassVariable
          element: <none>
        get r_staticGetter @-1
          reference: <testLibraryFragment>::@getter::r_staticGetter
          element: <none>
        get r_staticClassMethod @-1
          reference: <testLibraryFragment>::@getter::r_staticClassMethod
          element: <none>
        get instanceOfA @-1
          reference: <testLibraryFragment>::@getter::instanceOfA
          element: <none>
        get r_instanceClassMethod @-1
          reference: <testLibraryFragment>::@getter::r_instanceClassMethod
          element: <none>
        get topLevelGetter @74
          reference: <testLibraryFragment>::@getter::topLevelGetter
          element: <none>
      setters
        set topLevelVariable= @-1
          reference: <testLibraryFragment>::@setter::topLevelVariable
          element: <none>
          parameters
            _topLevelVariable @-1
              element: <none>
        set r_topLevelFunction= @-1
          reference: <testLibraryFragment>::@setter::r_topLevelFunction
          element: <none>
          parameters
            _r_topLevelFunction @-1
              element: <none>
        set r_topLevelVariable= @-1
          reference: <testLibraryFragment>::@setter::r_topLevelVariable
          element: <none>
          parameters
            _r_topLevelVariable @-1
              element: <none>
        set r_topLevelGetter= @-1
          reference: <testLibraryFragment>::@setter::r_topLevelGetter
          element: <none>
          parameters
            _r_topLevelGetter @-1
              element: <none>
        set r_staticClassVariable= @-1
          reference: <testLibraryFragment>::@setter::r_staticClassVariable
          element: <none>
          parameters
            _r_staticClassVariable @-1
              element: <none>
        set r_staticGetter= @-1
          reference: <testLibraryFragment>::@setter::r_staticGetter
          element: <none>
          parameters
            _r_staticGetter @-1
              element: <none>
        set r_staticClassMethod= @-1
          reference: <testLibraryFragment>::@setter::r_staticClassMethod
          element: <none>
          parameters
            _r_staticClassMethod @-1
              element: <none>
        set instanceOfA= @-1
          reference: <testLibraryFragment>::@setter::instanceOfA
          element: <none>
          parameters
            _instanceOfA @-1
              element: <none>
        set r_instanceClassMethod= @-1
          reference: <testLibraryFragment>::@setter::r_instanceClassMethod
          element: <none>
          parameters
            _r_instanceClassMethod @-1
              element: <none>
      functions
        topLevelFunction @7
          reference: <testLibraryFragment>::@function::topLevelFunction
          element: <none>
          parameters
            p @28
              element: <none>
  classes
    class A
      firstFragment: <testLibraryFragment>::@class::A
      fields
        static staticClassVariable
          firstFragment: <testLibraryFragment>::@class::A::@field::staticClassVariable
          type: int
          getter: <none>
          setter: <none>
        synthetic static staticGetter
          firstFragment: <testLibraryFragment>::@class::A::@field::staticGetter
          type: int
          getter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      getters
        synthetic static get staticClassVariable
          firstFragment: <testLibraryFragment>::@class::A::@getter::staticClassVariable
        static get staticGetter
          firstFragment: <testLibraryFragment>::@class::A::@getter::staticGetter
      setters
        synthetic static set staticClassVariable=
          firstFragment: <testLibraryFragment>::@class::A::@setter::staticClassVariable
          parameters
            requiredPositional _staticClassVariable
              type: int
      methods
        static staticClassMethod
          firstFragment: <testLibraryFragment>::@class::A::@method::staticClassMethod
          parameters
            requiredPositional p
              type: int
        instanceClassMethod
          firstFragment: <testLibraryFragment>::@class::A::@method::instanceClassMethod
          parameters
            requiredPositional p
              type: int
  topLevelVariables
    topLevelVariable
      firstFragment: <testLibraryFragment>::@topLevelVariable::topLevelVariable
      type: int
      getter: <none>
      setter: <none>
    r_topLevelFunction
      firstFragment: <testLibraryFragment>::@topLevelVariable::r_topLevelFunction
      type: String Function(int)
      getter: <none>
      setter: <none>
    r_topLevelVariable
      firstFragment: <testLibraryFragment>::@topLevelVariable::r_topLevelVariable
      type: int
      getter: <none>
      setter: <none>
    r_topLevelGetter
      firstFragment: <testLibraryFragment>::@topLevelVariable::r_topLevelGetter
      type: int
      getter: <none>
      setter: <none>
    r_staticClassVariable
      firstFragment: <testLibraryFragment>::@topLevelVariable::r_staticClassVariable
      type: int
      getter: <none>
      setter: <none>
    r_staticGetter
      firstFragment: <testLibraryFragment>::@topLevelVariable::r_staticGetter
      type: int
      getter: <none>
      setter: <none>
    r_staticClassMethod
      firstFragment: <testLibraryFragment>::@topLevelVariable::r_staticClassMethod
      type: String Function(int)
      getter: <none>
      setter: <none>
    instanceOfA
      firstFragment: <testLibraryFragment>::@topLevelVariable::instanceOfA
      type: A
      getter: <none>
      setter: <none>
    r_instanceClassMethod
      firstFragment: <testLibraryFragment>::@topLevelVariable::r_instanceClassMethod
      type: String Function(int)
      getter: <none>
      setter: <none>
    synthetic topLevelGetter
      firstFragment: <testLibraryFragment>::@topLevelVariable::topLevelGetter
      type: int
      getter: <none>
  getters
    synthetic static get topLevelVariable
      firstFragment: <testLibraryFragment>::@getter::topLevelVariable
    synthetic static get r_topLevelFunction
      firstFragment: <testLibraryFragment>::@getter::r_topLevelFunction
    synthetic static get r_topLevelVariable
      firstFragment: <testLibraryFragment>::@getter::r_topLevelVariable
    synthetic static get r_topLevelGetter
      firstFragment: <testLibraryFragment>::@getter::r_topLevelGetter
    synthetic static get r_staticClassVariable
      firstFragment: <testLibraryFragment>::@getter::r_staticClassVariable
    synthetic static get r_staticGetter
      firstFragment: <testLibraryFragment>::@getter::r_staticGetter
    synthetic static get r_staticClassMethod
      firstFragment: <testLibraryFragment>::@getter::r_staticClassMethod
    synthetic static get instanceOfA
      firstFragment: <testLibraryFragment>::@getter::instanceOfA
    synthetic static get r_instanceClassMethod
      firstFragment: <testLibraryFragment>::@getter::r_instanceClassMethod
    static get topLevelGetter
      firstFragment: <testLibraryFragment>::@getter::topLevelGetter
  setters
    synthetic static set topLevelVariable=
      firstFragment: <testLibraryFragment>::@setter::topLevelVariable
      parameters
        requiredPositional _topLevelVariable
          type: int
    synthetic static set r_topLevelFunction=
      firstFragment: <testLibraryFragment>::@setter::r_topLevelFunction
      parameters
        requiredPositional _r_topLevelFunction
          type: String Function(int)
    synthetic static set r_topLevelVariable=
      firstFragment: <testLibraryFragment>::@setter::r_topLevelVariable
      parameters
        requiredPositional _r_topLevelVariable
          type: int
    synthetic static set r_topLevelGetter=
      firstFragment: <testLibraryFragment>::@setter::r_topLevelGetter
      parameters
        requiredPositional _r_topLevelGetter
          type: int
    synthetic static set r_staticClassVariable=
      firstFragment: <testLibraryFragment>::@setter::r_staticClassVariable
      parameters
        requiredPositional _r_staticClassVariable
          type: int
    synthetic static set r_staticGetter=
      firstFragment: <testLibraryFragment>::@setter::r_staticGetter
      parameters
        requiredPositional _r_staticGetter
          type: int
    synthetic static set r_staticClassMethod=
      firstFragment: <testLibraryFragment>::@setter::r_staticClassMethod
      parameters
        requiredPositional _r_staticClassMethod
          type: String Function(int)
    synthetic static set instanceOfA=
      firstFragment: <testLibraryFragment>::@setter::instanceOfA
      parameters
        requiredPositional _instanceOfA
          type: A
    synthetic static set r_instanceClassMethod=
      firstFragment: <testLibraryFragment>::@setter::r_instanceClassMethod
      parameters
        requiredPositional _r_instanceClassMethod
          type: String Function(int)
  functions
    topLevelFunction
      firstFragment: <testLibraryFragment>::@function::topLevelFunction
      parameters
        requiredPositional p
          type: int
      returnType: String
''');
  }

  test_initializer_identifier_error_cycle_classField() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  static var a = B.b;
}
class B {
  static var b = A.a;
}
var c = A.a;
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          fields
            static a @23
              reference: <testLibraryFragment>::@class::A::@field::a
              enclosingElement3: <testLibraryFragment>::@class::A
              typeInferenceError: dependencyCycle
                arguments: [a, b]
              type: dynamic
              shouldUseTypeForInitializerInference: false
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          accessors
            synthetic static get a @-1
              reference: <testLibraryFragment>::@class::A::@getter::a
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: dynamic
            synthetic static set a= @-1
              reference: <testLibraryFragment>::@class::A::@setter::a
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional _a @-1
                  type: dynamic
              returnType: void
        class B @40
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          fields
            static b @57
              reference: <testLibraryFragment>::@class::B::@field::b
              enclosingElement3: <testLibraryFragment>::@class::B
              typeInferenceError: dependencyCycle
                arguments: [a, b]
              type: dynamic
              shouldUseTypeForInitializerInference: false
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
          accessors
            synthetic static get b @-1
              reference: <testLibraryFragment>::@class::B::@getter::b
              enclosingElement3: <testLibraryFragment>::@class::B
              returnType: dynamic
            synthetic static set b= @-1
              reference: <testLibraryFragment>::@class::B::@setter::b
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional _b @-1
                  type: dynamic
              returnType: void
      topLevelVariables
        static c @72
          reference: <testLibraryFragment>::@topLevelVariable::c
          enclosingElement3: <testLibraryFragment>
          type: dynamic
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get c @-1
          reference: <testLibraryFragment>::@getter::c
          enclosingElement3: <testLibraryFragment>
          returnType: dynamic
        synthetic static set c= @-1
          reference: <testLibraryFragment>::@setter::c
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _c @-1
              type: dynamic
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          fields
            a @23
              reference: <testLibraryFragment>::@class::A::@field::a
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::a
              setter2: <testLibraryFragment>::@class::A::@setter::a
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          getters
            get a @-1
              reference: <testLibraryFragment>::@class::A::@getter::a
              element: <none>
          setters
            set a= @-1
              reference: <testLibraryFragment>::@class::A::@setter::a
              element: <none>
              parameters
                _a @-1
                  element: <none>
        class B @40
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          fields
            b @57
              reference: <testLibraryFragment>::@class::B::@field::b
              element: <none>
              getter2: <testLibraryFragment>::@class::B::@getter::b
              setter2: <testLibraryFragment>::@class::B::@setter::b
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
          getters
            get b @-1
              reference: <testLibraryFragment>::@class::B::@getter::b
              element: <none>
          setters
            set b= @-1
              reference: <testLibraryFragment>::@class::B::@setter::b
              element: <none>
              parameters
                _b @-1
                  element: <none>
      topLevelVariables
        c @72
          reference: <testLibraryFragment>::@topLevelVariable::c
          element: <none>
          getter2: <testLibraryFragment>::@getter::c
          setter2: <testLibraryFragment>::@setter::c
      getters
        get c @-1
          reference: <testLibraryFragment>::@getter::c
          element: <none>
      setters
        set c= @-1
          reference: <testLibraryFragment>::@setter::c
          element: <none>
          parameters
            _c @-1
              element: <none>
  classes
    class A
      firstFragment: <testLibraryFragment>::@class::A
      fields
        static a
          firstFragment: <testLibraryFragment>::@class::A::@field::a
          type: dynamic
          getter: <none>
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      getters
        synthetic static get a
          firstFragment: <testLibraryFragment>::@class::A::@getter::a
      setters
        synthetic static set a=
          firstFragment: <testLibraryFragment>::@class::A::@setter::a
          parameters
            requiredPositional _a
              type: dynamic
    class B
      firstFragment: <testLibraryFragment>::@class::B
      fields
        static b
          firstFragment: <testLibraryFragment>::@class::B::@field::b
          type: dynamic
          getter: <none>
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
      getters
        synthetic static get b
          firstFragment: <testLibraryFragment>::@class::B::@getter::b
      setters
        synthetic static set b=
          firstFragment: <testLibraryFragment>::@class::B::@setter::b
          parameters
            requiredPositional _b
              type: dynamic
  topLevelVariables
    c
      firstFragment: <testLibraryFragment>::@topLevelVariable::c
      type: dynamic
      getter: <none>
      setter: <none>
  getters
    synthetic static get c
      firstFragment: <testLibraryFragment>::@getter::c
  setters
    synthetic static set c=
      firstFragment: <testLibraryFragment>::@setter::c
      parameters
        requiredPositional _c
          type: dynamic
''');
  }

  test_initializer_identifier_error_cycle_mix() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  static var a = b;
}
var b = A.a;
var c = b;
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          fields
            static a @23
              reference: <testLibraryFragment>::@class::A::@field::a
              enclosingElement3: <testLibraryFragment>::@class::A
              typeInferenceError: dependencyCycle
                arguments: [a, b]
              type: dynamic
              shouldUseTypeForInitializerInference: false
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          accessors
            synthetic static get a @-1
              reference: <testLibraryFragment>::@class::A::@getter::a
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: dynamic
            synthetic static set a= @-1
              reference: <testLibraryFragment>::@class::A::@setter::a
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional _a @-1
                  type: dynamic
              returnType: void
      topLevelVariables
        static b @36
          reference: <testLibraryFragment>::@topLevelVariable::b
          enclosingElement3: <testLibraryFragment>
          typeInferenceError: dependencyCycle
            arguments: [a, b]
          type: dynamic
          shouldUseTypeForInitializerInference: false
        static c @49
          reference: <testLibraryFragment>::@topLevelVariable::c
          enclosingElement3: <testLibraryFragment>
          type: dynamic
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get b @-1
          reference: <testLibraryFragment>::@getter::b
          enclosingElement3: <testLibraryFragment>
          returnType: dynamic
        synthetic static set b= @-1
          reference: <testLibraryFragment>::@setter::b
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _b @-1
              type: dynamic
          returnType: void
        synthetic static get c @-1
          reference: <testLibraryFragment>::@getter::c
          enclosingElement3: <testLibraryFragment>
          returnType: dynamic
        synthetic static set c= @-1
          reference: <testLibraryFragment>::@setter::c
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _c @-1
              type: dynamic
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          fields
            a @23
              reference: <testLibraryFragment>::@class::A::@field::a
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::a
              setter2: <testLibraryFragment>::@class::A::@setter::a
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          getters
            get a @-1
              reference: <testLibraryFragment>::@class::A::@getter::a
              element: <none>
          setters
            set a= @-1
              reference: <testLibraryFragment>::@class::A::@setter::a
              element: <none>
              parameters
                _a @-1
                  element: <none>
      topLevelVariables
        b @36
          reference: <testLibraryFragment>::@topLevelVariable::b
          element: <none>
          getter2: <testLibraryFragment>::@getter::b
          setter2: <testLibraryFragment>::@setter::b
        c @49
          reference: <testLibraryFragment>::@topLevelVariable::c
          element: <none>
          getter2: <testLibraryFragment>::@getter::c
          setter2: <testLibraryFragment>::@setter::c
      getters
        get b @-1
          reference: <testLibraryFragment>::@getter::b
          element: <none>
        get c @-1
          reference: <testLibraryFragment>::@getter::c
          element: <none>
      setters
        set b= @-1
          reference: <testLibraryFragment>::@setter::b
          element: <none>
          parameters
            _b @-1
              element: <none>
        set c= @-1
          reference: <testLibraryFragment>::@setter::c
          element: <none>
          parameters
            _c @-1
              element: <none>
  classes
    class A
      firstFragment: <testLibraryFragment>::@class::A
      fields
        static a
          firstFragment: <testLibraryFragment>::@class::A::@field::a
          type: dynamic
          getter: <none>
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      getters
        synthetic static get a
          firstFragment: <testLibraryFragment>::@class::A::@getter::a
      setters
        synthetic static set a=
          firstFragment: <testLibraryFragment>::@class::A::@setter::a
          parameters
            requiredPositional _a
              type: dynamic
  topLevelVariables
    b
      firstFragment: <testLibraryFragment>::@topLevelVariable::b
      type: dynamic
      getter: <none>
      setter: <none>
    c
      firstFragment: <testLibraryFragment>::@topLevelVariable::c
      type: dynamic
      getter: <none>
      setter: <none>
  getters
    synthetic static get b
      firstFragment: <testLibraryFragment>::@getter::b
    synthetic static get c
      firstFragment: <testLibraryFragment>::@getter::c
  setters
    synthetic static set b=
      firstFragment: <testLibraryFragment>::@setter::b
      parameters
        requiredPositional _b
          type: dynamic
    synthetic static set c=
      firstFragment: <testLibraryFragment>::@setter::c
      parameters
        requiredPositional _c
          type: dynamic
''');
  }

  test_initializer_identifier_error_cycle_topLevel() async {
    var library = await _encodeDecodeLibrary(r'''
final a = b;
final b = c;
final c = a;
final d = a;
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      topLevelVariables
        static final a @6
          reference: <testLibraryFragment>::@topLevelVariable::a
          enclosingElement3: <testLibraryFragment>
          typeInferenceError: dependencyCycle
            arguments: [a, b, c]
          type: dynamic
          shouldUseTypeForInitializerInference: false
        static final b @19
          reference: <testLibraryFragment>::@topLevelVariable::b
          enclosingElement3: <testLibraryFragment>
          typeInferenceError: dependencyCycle
            arguments: [a, b, c]
          type: dynamic
          shouldUseTypeForInitializerInference: false
        static final c @32
          reference: <testLibraryFragment>::@topLevelVariable::c
          enclosingElement3: <testLibraryFragment>
          typeInferenceError: dependencyCycle
            arguments: [a, b, c]
          type: dynamic
          shouldUseTypeForInitializerInference: false
        static final d @45
          reference: <testLibraryFragment>::@topLevelVariable::d
          enclosingElement3: <testLibraryFragment>
          type: dynamic
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get a @-1
          reference: <testLibraryFragment>::@getter::a
          enclosingElement3: <testLibraryFragment>
          returnType: dynamic
        synthetic static get b @-1
          reference: <testLibraryFragment>::@getter::b
          enclosingElement3: <testLibraryFragment>
          returnType: dynamic
        synthetic static get c @-1
          reference: <testLibraryFragment>::@getter::c
          enclosingElement3: <testLibraryFragment>
          returnType: dynamic
        synthetic static get d @-1
          reference: <testLibraryFragment>::@getter::d
          enclosingElement3: <testLibraryFragment>
          returnType: dynamic
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      topLevelVariables
        final a @6
          reference: <testLibraryFragment>::@topLevelVariable::a
          element: <none>
          getter2: <testLibraryFragment>::@getter::a
        final b @19
          reference: <testLibraryFragment>::@topLevelVariable::b
          element: <none>
          getter2: <testLibraryFragment>::@getter::b
        final c @32
          reference: <testLibraryFragment>::@topLevelVariable::c
          element: <none>
          getter2: <testLibraryFragment>::@getter::c
        final d @45
          reference: <testLibraryFragment>::@topLevelVariable::d
          element: <none>
          getter2: <testLibraryFragment>::@getter::d
      getters
        get a @-1
          reference: <testLibraryFragment>::@getter::a
          element: <none>
        get b @-1
          reference: <testLibraryFragment>::@getter::b
          element: <none>
        get c @-1
          reference: <testLibraryFragment>::@getter::c
          element: <none>
        get d @-1
          reference: <testLibraryFragment>::@getter::d
          element: <none>
  topLevelVariables
    final a
      firstFragment: <testLibraryFragment>::@topLevelVariable::a
      type: dynamic
      getter: <none>
    final b
      firstFragment: <testLibraryFragment>::@topLevelVariable::b
      type: dynamic
      getter: <none>
    final c
      firstFragment: <testLibraryFragment>::@topLevelVariable::c
      type: dynamic
      getter: <none>
    final d
      firstFragment: <testLibraryFragment>::@topLevelVariable::d
      type: dynamic
      getter: <none>
  getters
    synthetic static get a
      firstFragment: <testLibraryFragment>::@getter::a
    synthetic static get b
      firstFragment: <testLibraryFragment>::@getter::b
    synthetic static get c
      firstFragment: <testLibraryFragment>::@getter::c
    synthetic static get d
      firstFragment: <testLibraryFragment>::@getter::d
''');
  }

  test_initializer_identifier_formalParameter() async {
    // TODO(scheglov): I don't understand this yet
  }

  @skippedTest
  test_initializer_instanceCreation_hasTypeParameter() async {
    var library = await _encodeDecodeLibrary(r'''
class A<T> {}
var a = new A<int>();
var b = new A();
''');
    // TODO(scheglov): test for inference failure error
    checkElementText(library, r'''
class A<T> {
}
A<int> a;
dynamic b;
''');
  }

  test_initializer_instanceCreation_noTypeParameters() async {
    var library = await _encodeDecodeLibrary(r'''
class A {}
var a = new A();
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
      topLevelVariables
        static a @15
          reference: <testLibraryFragment>::@topLevelVariable::a
          enclosingElement3: <testLibraryFragment>
          type: A
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get a @-1
          reference: <testLibraryFragment>::@getter::a
          enclosingElement3: <testLibraryFragment>
          returnType: A
        synthetic static set a= @-1
          reference: <testLibraryFragment>::@setter::a
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _a @-1
              type: A
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
      topLevelVariables
        a @15
          reference: <testLibraryFragment>::@topLevelVariable::a
          element: <none>
          getter2: <testLibraryFragment>::@getter::a
          setter2: <testLibraryFragment>::@setter::a
      getters
        get a @-1
          reference: <testLibraryFragment>::@getter::a
          element: <none>
      setters
        set a= @-1
          reference: <testLibraryFragment>::@setter::a
          element: <none>
          parameters
            _a @-1
              element: <none>
  classes
    class A
      firstFragment: <testLibraryFragment>::@class::A
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
  topLevelVariables
    a
      firstFragment: <testLibraryFragment>::@topLevelVariable::a
      type: A
      getter: <none>
      setter: <none>
  getters
    synthetic static get a
      firstFragment: <testLibraryFragment>::@getter::a
  setters
    synthetic static set a=
      firstFragment: <testLibraryFragment>::@setter::a
      parameters
        requiredPositional _a
          type: A
''');
  }

  test_initializer_instanceGetterOfObject() async {
    var library = await _encodeDecodeLibrary(r'''
dynamic f() => null;
var s = f().toString();
var h = f().hashCode;
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      topLevelVariables
        static s @25
          reference: <testLibraryFragment>::@topLevelVariable::s
          enclosingElement3: <testLibraryFragment>
          type: String
          shouldUseTypeForInitializerInference: false
        static h @49
          reference: <testLibraryFragment>::@topLevelVariable::h
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get s @-1
          reference: <testLibraryFragment>::@getter::s
          enclosingElement3: <testLibraryFragment>
          returnType: String
        synthetic static set s= @-1
          reference: <testLibraryFragment>::@setter::s
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _s @-1
              type: String
          returnType: void
        synthetic static get h @-1
          reference: <testLibraryFragment>::@getter::h
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set h= @-1
          reference: <testLibraryFragment>::@setter::h
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _h @-1
              type: int
          returnType: void
      functions
        f @8
          reference: <testLibraryFragment>::@function::f
          enclosingElement3: <testLibraryFragment>
          returnType: dynamic
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      topLevelVariables
        s @25
          reference: <testLibraryFragment>::@topLevelVariable::s
          element: <none>
          getter2: <testLibraryFragment>::@getter::s
          setter2: <testLibraryFragment>::@setter::s
        h @49
          reference: <testLibraryFragment>::@topLevelVariable::h
          element: <none>
          getter2: <testLibraryFragment>::@getter::h
          setter2: <testLibraryFragment>::@setter::h
      getters
        get s @-1
          reference: <testLibraryFragment>::@getter::s
          element: <none>
        get h @-1
          reference: <testLibraryFragment>::@getter::h
          element: <none>
      setters
        set s= @-1
          reference: <testLibraryFragment>::@setter::s
          element: <none>
          parameters
            _s @-1
              element: <none>
        set h= @-1
          reference: <testLibraryFragment>::@setter::h
          element: <none>
          parameters
            _h @-1
              element: <none>
      functions
        f @8
          reference: <testLibraryFragment>::@function::f
          element: <none>
  topLevelVariables
    s
      firstFragment: <testLibraryFragment>::@topLevelVariable::s
      type: String
      getter: <none>
      setter: <none>
    h
      firstFragment: <testLibraryFragment>::@topLevelVariable::h
      type: int
      getter: <none>
      setter: <none>
  getters
    synthetic static get s
      firstFragment: <testLibraryFragment>::@getter::s
    synthetic static get h
      firstFragment: <testLibraryFragment>::@getter::h
  setters
    synthetic static set s=
      firstFragment: <testLibraryFragment>::@setter::s
      parameters
        requiredPositional _s
          type: String
    synthetic static set h=
      firstFragment: <testLibraryFragment>::@setter::h
      parameters
        requiredPositional _h
          type: int
  functions
    f
      firstFragment: <testLibraryFragment>::@function::f
      returnType: dynamic
''');
  }

  test_initializer_instanceGetterOfObject_prefixed() async {
    var library = await _encodeDecodeLibrary(r'''
dynamic d;
var s = d.toString();
var h = d.hashCode;
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      topLevelVariables
        static d @8
          reference: <testLibraryFragment>::@topLevelVariable::d
          enclosingElement3: <testLibraryFragment>
          type: dynamic
        static s @15
          reference: <testLibraryFragment>::@topLevelVariable::s
          enclosingElement3: <testLibraryFragment>
          type: String
          shouldUseTypeForInitializerInference: false
        static h @37
          reference: <testLibraryFragment>::@topLevelVariable::h
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get d @-1
          reference: <testLibraryFragment>::@getter::d
          enclosingElement3: <testLibraryFragment>
          returnType: dynamic
        synthetic static set d= @-1
          reference: <testLibraryFragment>::@setter::d
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _d @-1
              type: dynamic
          returnType: void
        synthetic static get s @-1
          reference: <testLibraryFragment>::@getter::s
          enclosingElement3: <testLibraryFragment>
          returnType: String
        synthetic static set s= @-1
          reference: <testLibraryFragment>::@setter::s
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _s @-1
              type: String
          returnType: void
        synthetic static get h @-1
          reference: <testLibraryFragment>::@getter::h
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set h= @-1
          reference: <testLibraryFragment>::@setter::h
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _h @-1
              type: int
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      topLevelVariables
        d @8
          reference: <testLibraryFragment>::@topLevelVariable::d
          element: <none>
          getter2: <testLibraryFragment>::@getter::d
          setter2: <testLibraryFragment>::@setter::d
        s @15
          reference: <testLibraryFragment>::@topLevelVariable::s
          element: <none>
          getter2: <testLibraryFragment>::@getter::s
          setter2: <testLibraryFragment>::@setter::s
        h @37
          reference: <testLibraryFragment>::@topLevelVariable::h
          element: <none>
          getter2: <testLibraryFragment>::@getter::h
          setter2: <testLibraryFragment>::@setter::h
      getters
        get d @-1
          reference: <testLibraryFragment>::@getter::d
          element: <none>
        get s @-1
          reference: <testLibraryFragment>::@getter::s
          element: <none>
        get h @-1
          reference: <testLibraryFragment>::@getter::h
          element: <none>
      setters
        set d= @-1
          reference: <testLibraryFragment>::@setter::d
          element: <none>
          parameters
            _d @-1
              element: <none>
        set s= @-1
          reference: <testLibraryFragment>::@setter::s
          element: <none>
          parameters
            _s @-1
              element: <none>
        set h= @-1
          reference: <testLibraryFragment>::@setter::h
          element: <none>
          parameters
            _h @-1
              element: <none>
  topLevelVariables
    d
      firstFragment: <testLibraryFragment>::@topLevelVariable::d
      type: dynamic
      getter: <none>
      setter: <none>
    s
      firstFragment: <testLibraryFragment>::@topLevelVariable::s
      type: String
      getter: <none>
      setter: <none>
    h
      firstFragment: <testLibraryFragment>::@topLevelVariable::h
      type: int
      getter: <none>
      setter: <none>
  getters
    synthetic static get d
      firstFragment: <testLibraryFragment>::@getter::d
    synthetic static get s
      firstFragment: <testLibraryFragment>::@getter::s
    synthetic static get h
      firstFragment: <testLibraryFragment>::@getter::h
  setters
    synthetic static set d=
      firstFragment: <testLibraryFragment>::@setter::d
      parameters
        requiredPositional _d
          type: dynamic
    synthetic static set s=
      firstFragment: <testLibraryFragment>::@setter::s
      parameters
        requiredPositional _s
          type: String
    synthetic static set h=
      firstFragment: <testLibraryFragment>::@setter::h
      parameters
        requiredPositional _h
          type: int
''');
  }

  test_initializer_is() async {
    var library = await _encodeDecodeLibrary(r'''
var a = 1.2;
var b = a is int;
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      topLevelVariables
        static a @4
          reference: <testLibraryFragment>::@topLevelVariable::a
          enclosingElement3: <testLibraryFragment>
          type: double
          shouldUseTypeForInitializerInference: false
        static b @17
          reference: <testLibraryFragment>::@topLevelVariable::b
          enclosingElement3: <testLibraryFragment>
          type: bool
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get a @-1
          reference: <testLibraryFragment>::@getter::a
          enclosingElement3: <testLibraryFragment>
          returnType: double
        synthetic static set a= @-1
          reference: <testLibraryFragment>::@setter::a
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _a @-1
              type: double
          returnType: void
        synthetic static get b @-1
          reference: <testLibraryFragment>::@getter::b
          enclosingElement3: <testLibraryFragment>
          returnType: bool
        synthetic static set b= @-1
          reference: <testLibraryFragment>::@setter::b
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _b @-1
              type: bool
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      topLevelVariables
        a @4
          reference: <testLibraryFragment>::@topLevelVariable::a
          element: <none>
          getter2: <testLibraryFragment>::@getter::a
          setter2: <testLibraryFragment>::@setter::a
        b @17
          reference: <testLibraryFragment>::@topLevelVariable::b
          element: <none>
          getter2: <testLibraryFragment>::@getter::b
          setter2: <testLibraryFragment>::@setter::b
      getters
        get a @-1
          reference: <testLibraryFragment>::@getter::a
          element: <none>
        get b @-1
          reference: <testLibraryFragment>::@getter::b
          element: <none>
      setters
        set a= @-1
          reference: <testLibraryFragment>::@setter::a
          element: <none>
          parameters
            _a @-1
              element: <none>
        set b= @-1
          reference: <testLibraryFragment>::@setter::b
          element: <none>
          parameters
            _b @-1
              element: <none>
  topLevelVariables
    a
      firstFragment: <testLibraryFragment>::@topLevelVariable::a
      type: double
      getter: <none>
      setter: <none>
    b
      firstFragment: <testLibraryFragment>::@topLevelVariable::b
      type: bool
      getter: <none>
      setter: <none>
  getters
    synthetic static get a
      firstFragment: <testLibraryFragment>::@getter::a
    synthetic static get b
      firstFragment: <testLibraryFragment>::@getter::b
  setters
    synthetic static set a=
      firstFragment: <testLibraryFragment>::@setter::a
      parameters
        requiredPositional _a
          type: double
    synthetic static set b=
      firstFragment: <testLibraryFragment>::@setter::b
      parameters
        requiredPositional _b
          type: bool
''');
  }

  @skippedTest
  test_initializer_literal() async {
    var library = await _encodeDecodeLibrary(r'''
var vNull = null;
var vBoolFalse = false;
var vBoolTrue = true;
var vInt = 1;
var vIntLong = 0x9876543210987654321;
var vDouble = 2.3;
var vString = 'abc';
var vStringConcat = 'aaa' 'bbb';
var vStringInterpolation = 'aaa ${true} ${42} bbb';
var vSymbol = #aaa.bbb.ccc;
''');
    checkElementText(library, r'''
Null vNull;
bool vBoolFalse;
bool vBoolTrue;
int vInt;
int vIntLong;
double vDouble;
String vString;
String vStringConcat;
String vStringInterpolation;
Symbol vSymbol;
''');
  }

  test_initializer_literal_list_typed() async {
    var library = await _encodeDecodeLibrary(r'''
var vObject = <Object>[1, 2, 3];
var vNum = <num>[1, 2, 3];
var vNumEmpty = <num>[];
var vInt = <int>[1, 2, 3];
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      topLevelVariables
        static vObject @4
          reference: <testLibraryFragment>::@topLevelVariable::vObject
          enclosingElement3: <testLibraryFragment>
          type: List<Object>
          shouldUseTypeForInitializerInference: false
        static vNum @37
          reference: <testLibraryFragment>::@topLevelVariable::vNum
          enclosingElement3: <testLibraryFragment>
          type: List<num>
          shouldUseTypeForInitializerInference: false
        static vNumEmpty @64
          reference: <testLibraryFragment>::@topLevelVariable::vNumEmpty
          enclosingElement3: <testLibraryFragment>
          type: List<num>
          shouldUseTypeForInitializerInference: false
        static vInt @89
          reference: <testLibraryFragment>::@topLevelVariable::vInt
          enclosingElement3: <testLibraryFragment>
          type: List<int>
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get vObject @-1
          reference: <testLibraryFragment>::@getter::vObject
          enclosingElement3: <testLibraryFragment>
          returnType: List<Object>
        synthetic static set vObject= @-1
          reference: <testLibraryFragment>::@setter::vObject
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vObject @-1
              type: List<Object>
          returnType: void
        synthetic static get vNum @-1
          reference: <testLibraryFragment>::@getter::vNum
          enclosingElement3: <testLibraryFragment>
          returnType: List<num>
        synthetic static set vNum= @-1
          reference: <testLibraryFragment>::@setter::vNum
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vNum @-1
              type: List<num>
          returnType: void
        synthetic static get vNumEmpty @-1
          reference: <testLibraryFragment>::@getter::vNumEmpty
          enclosingElement3: <testLibraryFragment>
          returnType: List<num>
        synthetic static set vNumEmpty= @-1
          reference: <testLibraryFragment>::@setter::vNumEmpty
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vNumEmpty @-1
              type: List<num>
          returnType: void
        synthetic static get vInt @-1
          reference: <testLibraryFragment>::@getter::vInt
          enclosingElement3: <testLibraryFragment>
          returnType: List<int>
        synthetic static set vInt= @-1
          reference: <testLibraryFragment>::@setter::vInt
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vInt @-1
              type: List<int>
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      topLevelVariables
        vObject @4
          reference: <testLibraryFragment>::@topLevelVariable::vObject
          element: <none>
          getter2: <testLibraryFragment>::@getter::vObject
          setter2: <testLibraryFragment>::@setter::vObject
        vNum @37
          reference: <testLibraryFragment>::@topLevelVariable::vNum
          element: <none>
          getter2: <testLibraryFragment>::@getter::vNum
          setter2: <testLibraryFragment>::@setter::vNum
        vNumEmpty @64
          reference: <testLibraryFragment>::@topLevelVariable::vNumEmpty
          element: <none>
          getter2: <testLibraryFragment>::@getter::vNumEmpty
          setter2: <testLibraryFragment>::@setter::vNumEmpty
        vInt @89
          reference: <testLibraryFragment>::@topLevelVariable::vInt
          element: <none>
          getter2: <testLibraryFragment>::@getter::vInt
          setter2: <testLibraryFragment>::@setter::vInt
      getters
        get vObject @-1
          reference: <testLibraryFragment>::@getter::vObject
          element: <none>
        get vNum @-1
          reference: <testLibraryFragment>::@getter::vNum
          element: <none>
        get vNumEmpty @-1
          reference: <testLibraryFragment>::@getter::vNumEmpty
          element: <none>
        get vInt @-1
          reference: <testLibraryFragment>::@getter::vInt
          element: <none>
      setters
        set vObject= @-1
          reference: <testLibraryFragment>::@setter::vObject
          element: <none>
          parameters
            _vObject @-1
              element: <none>
        set vNum= @-1
          reference: <testLibraryFragment>::@setter::vNum
          element: <none>
          parameters
            _vNum @-1
              element: <none>
        set vNumEmpty= @-1
          reference: <testLibraryFragment>::@setter::vNumEmpty
          element: <none>
          parameters
            _vNumEmpty @-1
              element: <none>
        set vInt= @-1
          reference: <testLibraryFragment>::@setter::vInt
          element: <none>
          parameters
            _vInt @-1
              element: <none>
  topLevelVariables
    vObject
      firstFragment: <testLibraryFragment>::@topLevelVariable::vObject
      type: List<Object>
      getter: <none>
      setter: <none>
    vNum
      firstFragment: <testLibraryFragment>::@topLevelVariable::vNum
      type: List<num>
      getter: <none>
      setter: <none>
    vNumEmpty
      firstFragment: <testLibraryFragment>::@topLevelVariable::vNumEmpty
      type: List<num>
      getter: <none>
      setter: <none>
    vInt
      firstFragment: <testLibraryFragment>::@topLevelVariable::vInt
      type: List<int>
      getter: <none>
      setter: <none>
  getters
    synthetic static get vObject
      firstFragment: <testLibraryFragment>::@getter::vObject
    synthetic static get vNum
      firstFragment: <testLibraryFragment>::@getter::vNum
    synthetic static get vNumEmpty
      firstFragment: <testLibraryFragment>::@getter::vNumEmpty
    synthetic static get vInt
      firstFragment: <testLibraryFragment>::@getter::vInt
  setters
    synthetic static set vObject=
      firstFragment: <testLibraryFragment>::@setter::vObject
      parameters
        requiredPositional _vObject
          type: List<Object>
    synthetic static set vNum=
      firstFragment: <testLibraryFragment>::@setter::vNum
      parameters
        requiredPositional _vNum
          type: List<num>
    synthetic static set vNumEmpty=
      firstFragment: <testLibraryFragment>::@setter::vNumEmpty
      parameters
        requiredPositional _vNumEmpty
          type: List<num>
    synthetic static set vInt=
      firstFragment: <testLibraryFragment>::@setter::vInt
      parameters
        requiredPositional _vInt
          type: List<int>
''');
  }

  test_initializer_literal_list_untyped() async {
    var library = await _encodeDecodeLibrary(r'''
var vInt = [1, 2, 3];
var vNum = [1, 2.0];
var vObject = [1, 2.0, '333'];
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      topLevelVariables
        static vInt @4
          reference: <testLibraryFragment>::@topLevelVariable::vInt
          enclosingElement3: <testLibraryFragment>
          type: List<int>
          shouldUseTypeForInitializerInference: false
        static vNum @26
          reference: <testLibraryFragment>::@topLevelVariable::vNum
          enclosingElement3: <testLibraryFragment>
          type: List<num>
          shouldUseTypeForInitializerInference: false
        static vObject @47
          reference: <testLibraryFragment>::@topLevelVariable::vObject
          enclosingElement3: <testLibraryFragment>
          type: List<Object>
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get vInt @-1
          reference: <testLibraryFragment>::@getter::vInt
          enclosingElement3: <testLibraryFragment>
          returnType: List<int>
        synthetic static set vInt= @-1
          reference: <testLibraryFragment>::@setter::vInt
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vInt @-1
              type: List<int>
          returnType: void
        synthetic static get vNum @-1
          reference: <testLibraryFragment>::@getter::vNum
          enclosingElement3: <testLibraryFragment>
          returnType: List<num>
        synthetic static set vNum= @-1
          reference: <testLibraryFragment>::@setter::vNum
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vNum @-1
              type: List<num>
          returnType: void
        synthetic static get vObject @-1
          reference: <testLibraryFragment>::@getter::vObject
          enclosingElement3: <testLibraryFragment>
          returnType: List<Object>
        synthetic static set vObject= @-1
          reference: <testLibraryFragment>::@setter::vObject
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vObject @-1
              type: List<Object>
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      topLevelVariables
        vInt @4
          reference: <testLibraryFragment>::@topLevelVariable::vInt
          element: <none>
          getter2: <testLibraryFragment>::@getter::vInt
          setter2: <testLibraryFragment>::@setter::vInt
        vNum @26
          reference: <testLibraryFragment>::@topLevelVariable::vNum
          element: <none>
          getter2: <testLibraryFragment>::@getter::vNum
          setter2: <testLibraryFragment>::@setter::vNum
        vObject @47
          reference: <testLibraryFragment>::@topLevelVariable::vObject
          element: <none>
          getter2: <testLibraryFragment>::@getter::vObject
          setter2: <testLibraryFragment>::@setter::vObject
      getters
        get vInt @-1
          reference: <testLibraryFragment>::@getter::vInt
          element: <none>
        get vNum @-1
          reference: <testLibraryFragment>::@getter::vNum
          element: <none>
        get vObject @-1
          reference: <testLibraryFragment>::@getter::vObject
          element: <none>
      setters
        set vInt= @-1
          reference: <testLibraryFragment>::@setter::vInt
          element: <none>
          parameters
            _vInt @-1
              element: <none>
        set vNum= @-1
          reference: <testLibraryFragment>::@setter::vNum
          element: <none>
          parameters
            _vNum @-1
              element: <none>
        set vObject= @-1
          reference: <testLibraryFragment>::@setter::vObject
          element: <none>
          parameters
            _vObject @-1
              element: <none>
  topLevelVariables
    vInt
      firstFragment: <testLibraryFragment>::@topLevelVariable::vInt
      type: List<int>
      getter: <none>
      setter: <none>
    vNum
      firstFragment: <testLibraryFragment>::@topLevelVariable::vNum
      type: List<num>
      getter: <none>
      setter: <none>
    vObject
      firstFragment: <testLibraryFragment>::@topLevelVariable::vObject
      type: List<Object>
      getter: <none>
      setter: <none>
  getters
    synthetic static get vInt
      firstFragment: <testLibraryFragment>::@getter::vInt
    synthetic static get vNum
      firstFragment: <testLibraryFragment>::@getter::vNum
    synthetic static get vObject
      firstFragment: <testLibraryFragment>::@getter::vObject
  setters
    synthetic static set vInt=
      firstFragment: <testLibraryFragment>::@setter::vInt
      parameters
        requiredPositional _vInt
          type: List<int>
    synthetic static set vNum=
      firstFragment: <testLibraryFragment>::@setter::vNum
      parameters
        requiredPositional _vNum
          type: List<num>
    synthetic static set vObject=
      firstFragment: <testLibraryFragment>::@setter::vObject
      parameters
        requiredPositional _vObject
          type: List<Object>
''');
  }

  @skippedTest
  test_initializer_literal_list_untyped_empty() async {
    var library = await _encodeDecodeLibrary(r'''
var vNonConst = [];
var vConst = const [];
''');
    checkElementText(library, r'''
List<dynamic> vNonConst;
List<Null> vConst;
''');
  }

  test_initializer_literal_map_typed() async {
    var library = await _encodeDecodeLibrary(r'''
var vObjectObject = <Object, Object>{1: 'a'};
var vComparableObject = <Comparable<int>, Object>{1: 'a'};
var vNumString = <num, String>{1: 'a'};
var vNumStringEmpty = <num, String>{};
var vIntString = <int, String>{};
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      topLevelVariables
        static vObjectObject @4
          reference: <testLibraryFragment>::@topLevelVariable::vObjectObject
          enclosingElement3: <testLibraryFragment>
          type: Map<Object, Object>
          shouldUseTypeForInitializerInference: false
        static vComparableObject @50
          reference: <testLibraryFragment>::@topLevelVariable::vComparableObject
          enclosingElement3: <testLibraryFragment>
          type: Map<Comparable<int>, Object>
          shouldUseTypeForInitializerInference: false
        static vNumString @109
          reference: <testLibraryFragment>::@topLevelVariable::vNumString
          enclosingElement3: <testLibraryFragment>
          type: Map<num, String>
          shouldUseTypeForInitializerInference: false
        static vNumStringEmpty @149
          reference: <testLibraryFragment>::@topLevelVariable::vNumStringEmpty
          enclosingElement3: <testLibraryFragment>
          type: Map<num, String>
          shouldUseTypeForInitializerInference: false
        static vIntString @188
          reference: <testLibraryFragment>::@topLevelVariable::vIntString
          enclosingElement3: <testLibraryFragment>
          type: Map<int, String>
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get vObjectObject @-1
          reference: <testLibraryFragment>::@getter::vObjectObject
          enclosingElement3: <testLibraryFragment>
          returnType: Map<Object, Object>
        synthetic static set vObjectObject= @-1
          reference: <testLibraryFragment>::@setter::vObjectObject
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vObjectObject @-1
              type: Map<Object, Object>
          returnType: void
        synthetic static get vComparableObject @-1
          reference: <testLibraryFragment>::@getter::vComparableObject
          enclosingElement3: <testLibraryFragment>
          returnType: Map<Comparable<int>, Object>
        synthetic static set vComparableObject= @-1
          reference: <testLibraryFragment>::@setter::vComparableObject
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vComparableObject @-1
              type: Map<Comparable<int>, Object>
          returnType: void
        synthetic static get vNumString @-1
          reference: <testLibraryFragment>::@getter::vNumString
          enclosingElement3: <testLibraryFragment>
          returnType: Map<num, String>
        synthetic static set vNumString= @-1
          reference: <testLibraryFragment>::@setter::vNumString
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vNumString @-1
              type: Map<num, String>
          returnType: void
        synthetic static get vNumStringEmpty @-1
          reference: <testLibraryFragment>::@getter::vNumStringEmpty
          enclosingElement3: <testLibraryFragment>
          returnType: Map<num, String>
        synthetic static set vNumStringEmpty= @-1
          reference: <testLibraryFragment>::@setter::vNumStringEmpty
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vNumStringEmpty @-1
              type: Map<num, String>
          returnType: void
        synthetic static get vIntString @-1
          reference: <testLibraryFragment>::@getter::vIntString
          enclosingElement3: <testLibraryFragment>
          returnType: Map<int, String>
        synthetic static set vIntString= @-1
          reference: <testLibraryFragment>::@setter::vIntString
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vIntString @-1
              type: Map<int, String>
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      topLevelVariables
        vObjectObject @4
          reference: <testLibraryFragment>::@topLevelVariable::vObjectObject
          element: <none>
          getter2: <testLibraryFragment>::@getter::vObjectObject
          setter2: <testLibraryFragment>::@setter::vObjectObject
        vComparableObject @50
          reference: <testLibraryFragment>::@topLevelVariable::vComparableObject
          element: <none>
          getter2: <testLibraryFragment>::@getter::vComparableObject
          setter2: <testLibraryFragment>::@setter::vComparableObject
        vNumString @109
          reference: <testLibraryFragment>::@topLevelVariable::vNumString
          element: <none>
          getter2: <testLibraryFragment>::@getter::vNumString
          setter2: <testLibraryFragment>::@setter::vNumString
        vNumStringEmpty @149
          reference: <testLibraryFragment>::@topLevelVariable::vNumStringEmpty
          element: <none>
          getter2: <testLibraryFragment>::@getter::vNumStringEmpty
          setter2: <testLibraryFragment>::@setter::vNumStringEmpty
        vIntString @188
          reference: <testLibraryFragment>::@topLevelVariable::vIntString
          element: <none>
          getter2: <testLibraryFragment>::@getter::vIntString
          setter2: <testLibraryFragment>::@setter::vIntString
      getters
        get vObjectObject @-1
          reference: <testLibraryFragment>::@getter::vObjectObject
          element: <none>
        get vComparableObject @-1
          reference: <testLibraryFragment>::@getter::vComparableObject
          element: <none>
        get vNumString @-1
          reference: <testLibraryFragment>::@getter::vNumString
          element: <none>
        get vNumStringEmpty @-1
          reference: <testLibraryFragment>::@getter::vNumStringEmpty
          element: <none>
        get vIntString @-1
          reference: <testLibraryFragment>::@getter::vIntString
          element: <none>
      setters
        set vObjectObject= @-1
          reference: <testLibraryFragment>::@setter::vObjectObject
          element: <none>
          parameters
            _vObjectObject @-1
              element: <none>
        set vComparableObject= @-1
          reference: <testLibraryFragment>::@setter::vComparableObject
          element: <none>
          parameters
            _vComparableObject @-1
              element: <none>
        set vNumString= @-1
          reference: <testLibraryFragment>::@setter::vNumString
          element: <none>
          parameters
            _vNumString @-1
              element: <none>
        set vNumStringEmpty= @-1
          reference: <testLibraryFragment>::@setter::vNumStringEmpty
          element: <none>
          parameters
            _vNumStringEmpty @-1
              element: <none>
        set vIntString= @-1
          reference: <testLibraryFragment>::@setter::vIntString
          element: <none>
          parameters
            _vIntString @-1
              element: <none>
  topLevelVariables
    vObjectObject
      firstFragment: <testLibraryFragment>::@topLevelVariable::vObjectObject
      type: Map<Object, Object>
      getter: <none>
      setter: <none>
    vComparableObject
      firstFragment: <testLibraryFragment>::@topLevelVariable::vComparableObject
      type: Map<Comparable<int>, Object>
      getter: <none>
      setter: <none>
    vNumString
      firstFragment: <testLibraryFragment>::@topLevelVariable::vNumString
      type: Map<num, String>
      getter: <none>
      setter: <none>
    vNumStringEmpty
      firstFragment: <testLibraryFragment>::@topLevelVariable::vNumStringEmpty
      type: Map<num, String>
      getter: <none>
      setter: <none>
    vIntString
      firstFragment: <testLibraryFragment>::@topLevelVariable::vIntString
      type: Map<int, String>
      getter: <none>
      setter: <none>
  getters
    synthetic static get vObjectObject
      firstFragment: <testLibraryFragment>::@getter::vObjectObject
    synthetic static get vComparableObject
      firstFragment: <testLibraryFragment>::@getter::vComparableObject
    synthetic static get vNumString
      firstFragment: <testLibraryFragment>::@getter::vNumString
    synthetic static get vNumStringEmpty
      firstFragment: <testLibraryFragment>::@getter::vNumStringEmpty
    synthetic static get vIntString
      firstFragment: <testLibraryFragment>::@getter::vIntString
  setters
    synthetic static set vObjectObject=
      firstFragment: <testLibraryFragment>::@setter::vObjectObject
      parameters
        requiredPositional _vObjectObject
          type: Map<Object, Object>
    synthetic static set vComparableObject=
      firstFragment: <testLibraryFragment>::@setter::vComparableObject
      parameters
        requiredPositional _vComparableObject
          type: Map<Comparable<int>, Object>
    synthetic static set vNumString=
      firstFragment: <testLibraryFragment>::@setter::vNumString
      parameters
        requiredPositional _vNumString
          type: Map<num, String>
    synthetic static set vNumStringEmpty=
      firstFragment: <testLibraryFragment>::@setter::vNumStringEmpty
      parameters
        requiredPositional _vNumStringEmpty
          type: Map<num, String>
    synthetic static set vIntString=
      firstFragment: <testLibraryFragment>::@setter::vIntString
      parameters
        requiredPositional _vIntString
          type: Map<int, String>
''');
  }

  test_initializer_literal_map_untyped() async {
    var library = await _encodeDecodeLibrary(r'''
var vIntString = {1: 'a', 2: 'b'};
var vNumString = {1: 'a', 2.0: 'b'};
var vIntObject = {1: 'a', 2: 3.0};
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      topLevelVariables
        static vIntString @4
          reference: <testLibraryFragment>::@topLevelVariable::vIntString
          enclosingElement3: <testLibraryFragment>
          type: Map<int, String>
          shouldUseTypeForInitializerInference: false
        static vNumString @39
          reference: <testLibraryFragment>::@topLevelVariable::vNumString
          enclosingElement3: <testLibraryFragment>
          type: Map<num, String>
          shouldUseTypeForInitializerInference: false
        static vIntObject @76
          reference: <testLibraryFragment>::@topLevelVariable::vIntObject
          enclosingElement3: <testLibraryFragment>
          type: Map<int, Object>
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get vIntString @-1
          reference: <testLibraryFragment>::@getter::vIntString
          enclosingElement3: <testLibraryFragment>
          returnType: Map<int, String>
        synthetic static set vIntString= @-1
          reference: <testLibraryFragment>::@setter::vIntString
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vIntString @-1
              type: Map<int, String>
          returnType: void
        synthetic static get vNumString @-1
          reference: <testLibraryFragment>::@getter::vNumString
          enclosingElement3: <testLibraryFragment>
          returnType: Map<num, String>
        synthetic static set vNumString= @-1
          reference: <testLibraryFragment>::@setter::vNumString
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vNumString @-1
              type: Map<num, String>
          returnType: void
        synthetic static get vIntObject @-1
          reference: <testLibraryFragment>::@getter::vIntObject
          enclosingElement3: <testLibraryFragment>
          returnType: Map<int, Object>
        synthetic static set vIntObject= @-1
          reference: <testLibraryFragment>::@setter::vIntObject
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vIntObject @-1
              type: Map<int, Object>
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      topLevelVariables
        vIntString @4
          reference: <testLibraryFragment>::@topLevelVariable::vIntString
          element: <none>
          getter2: <testLibraryFragment>::@getter::vIntString
          setter2: <testLibraryFragment>::@setter::vIntString
        vNumString @39
          reference: <testLibraryFragment>::@topLevelVariable::vNumString
          element: <none>
          getter2: <testLibraryFragment>::@getter::vNumString
          setter2: <testLibraryFragment>::@setter::vNumString
        vIntObject @76
          reference: <testLibraryFragment>::@topLevelVariable::vIntObject
          element: <none>
          getter2: <testLibraryFragment>::@getter::vIntObject
          setter2: <testLibraryFragment>::@setter::vIntObject
      getters
        get vIntString @-1
          reference: <testLibraryFragment>::@getter::vIntString
          element: <none>
        get vNumString @-1
          reference: <testLibraryFragment>::@getter::vNumString
          element: <none>
        get vIntObject @-1
          reference: <testLibraryFragment>::@getter::vIntObject
          element: <none>
      setters
        set vIntString= @-1
          reference: <testLibraryFragment>::@setter::vIntString
          element: <none>
          parameters
            _vIntString @-1
              element: <none>
        set vNumString= @-1
          reference: <testLibraryFragment>::@setter::vNumString
          element: <none>
          parameters
            _vNumString @-1
              element: <none>
        set vIntObject= @-1
          reference: <testLibraryFragment>::@setter::vIntObject
          element: <none>
          parameters
            _vIntObject @-1
              element: <none>
  topLevelVariables
    vIntString
      firstFragment: <testLibraryFragment>::@topLevelVariable::vIntString
      type: Map<int, String>
      getter: <none>
      setter: <none>
    vNumString
      firstFragment: <testLibraryFragment>::@topLevelVariable::vNumString
      type: Map<num, String>
      getter: <none>
      setter: <none>
    vIntObject
      firstFragment: <testLibraryFragment>::@topLevelVariable::vIntObject
      type: Map<int, Object>
      getter: <none>
      setter: <none>
  getters
    synthetic static get vIntString
      firstFragment: <testLibraryFragment>::@getter::vIntString
    synthetic static get vNumString
      firstFragment: <testLibraryFragment>::@getter::vNumString
    synthetic static get vIntObject
      firstFragment: <testLibraryFragment>::@getter::vIntObject
  setters
    synthetic static set vIntString=
      firstFragment: <testLibraryFragment>::@setter::vIntString
      parameters
        requiredPositional _vIntString
          type: Map<int, String>
    synthetic static set vNumString=
      firstFragment: <testLibraryFragment>::@setter::vNumString
      parameters
        requiredPositional _vNumString
          type: Map<num, String>
    synthetic static set vIntObject=
      firstFragment: <testLibraryFragment>::@setter::vIntObject
      parameters
        requiredPositional _vIntObject
          type: Map<int, Object>
''');
  }

  @skippedTest
  test_initializer_literal_map_untyped_empty() async {
    var library = await _encodeDecodeLibrary(r'''
var vNonConst = {};
var vConst = const {};
''');
    checkElementText(library, r'''
Map<dynamic, dynamic> vNonConst;
Map<Null, Null> vConst;
''');
  }

  test_initializer_logicalBool() async {
    var library = await _encodeDecodeLibrary(r'''
var a = true;
var b = true;
var vEq = 1 == 2;
var vAnd = a && b;
var vOr = a || b;
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      topLevelVariables
        static a @4
          reference: <testLibraryFragment>::@topLevelVariable::a
          enclosingElement3: <testLibraryFragment>
          type: bool
          shouldUseTypeForInitializerInference: false
        static b @18
          reference: <testLibraryFragment>::@topLevelVariable::b
          enclosingElement3: <testLibraryFragment>
          type: bool
          shouldUseTypeForInitializerInference: false
        static vEq @32
          reference: <testLibraryFragment>::@topLevelVariable::vEq
          enclosingElement3: <testLibraryFragment>
          type: bool
          shouldUseTypeForInitializerInference: false
        static vAnd @50
          reference: <testLibraryFragment>::@topLevelVariable::vAnd
          enclosingElement3: <testLibraryFragment>
          type: bool
          shouldUseTypeForInitializerInference: false
        static vOr @69
          reference: <testLibraryFragment>::@topLevelVariable::vOr
          enclosingElement3: <testLibraryFragment>
          type: bool
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get a @-1
          reference: <testLibraryFragment>::@getter::a
          enclosingElement3: <testLibraryFragment>
          returnType: bool
        synthetic static set a= @-1
          reference: <testLibraryFragment>::@setter::a
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _a @-1
              type: bool
          returnType: void
        synthetic static get b @-1
          reference: <testLibraryFragment>::@getter::b
          enclosingElement3: <testLibraryFragment>
          returnType: bool
        synthetic static set b= @-1
          reference: <testLibraryFragment>::@setter::b
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _b @-1
              type: bool
          returnType: void
        synthetic static get vEq @-1
          reference: <testLibraryFragment>::@getter::vEq
          enclosingElement3: <testLibraryFragment>
          returnType: bool
        synthetic static set vEq= @-1
          reference: <testLibraryFragment>::@setter::vEq
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vEq @-1
              type: bool
          returnType: void
        synthetic static get vAnd @-1
          reference: <testLibraryFragment>::@getter::vAnd
          enclosingElement3: <testLibraryFragment>
          returnType: bool
        synthetic static set vAnd= @-1
          reference: <testLibraryFragment>::@setter::vAnd
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vAnd @-1
              type: bool
          returnType: void
        synthetic static get vOr @-1
          reference: <testLibraryFragment>::@getter::vOr
          enclosingElement3: <testLibraryFragment>
          returnType: bool
        synthetic static set vOr= @-1
          reference: <testLibraryFragment>::@setter::vOr
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vOr @-1
              type: bool
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      topLevelVariables
        a @4
          reference: <testLibraryFragment>::@topLevelVariable::a
          element: <none>
          getter2: <testLibraryFragment>::@getter::a
          setter2: <testLibraryFragment>::@setter::a
        b @18
          reference: <testLibraryFragment>::@topLevelVariable::b
          element: <none>
          getter2: <testLibraryFragment>::@getter::b
          setter2: <testLibraryFragment>::@setter::b
        vEq @32
          reference: <testLibraryFragment>::@topLevelVariable::vEq
          element: <none>
          getter2: <testLibraryFragment>::@getter::vEq
          setter2: <testLibraryFragment>::@setter::vEq
        vAnd @50
          reference: <testLibraryFragment>::@topLevelVariable::vAnd
          element: <none>
          getter2: <testLibraryFragment>::@getter::vAnd
          setter2: <testLibraryFragment>::@setter::vAnd
        vOr @69
          reference: <testLibraryFragment>::@topLevelVariable::vOr
          element: <none>
          getter2: <testLibraryFragment>::@getter::vOr
          setter2: <testLibraryFragment>::@setter::vOr
      getters
        get a @-1
          reference: <testLibraryFragment>::@getter::a
          element: <none>
        get b @-1
          reference: <testLibraryFragment>::@getter::b
          element: <none>
        get vEq @-1
          reference: <testLibraryFragment>::@getter::vEq
          element: <none>
        get vAnd @-1
          reference: <testLibraryFragment>::@getter::vAnd
          element: <none>
        get vOr @-1
          reference: <testLibraryFragment>::@getter::vOr
          element: <none>
      setters
        set a= @-1
          reference: <testLibraryFragment>::@setter::a
          element: <none>
          parameters
            _a @-1
              element: <none>
        set b= @-1
          reference: <testLibraryFragment>::@setter::b
          element: <none>
          parameters
            _b @-1
              element: <none>
        set vEq= @-1
          reference: <testLibraryFragment>::@setter::vEq
          element: <none>
          parameters
            _vEq @-1
              element: <none>
        set vAnd= @-1
          reference: <testLibraryFragment>::@setter::vAnd
          element: <none>
          parameters
            _vAnd @-1
              element: <none>
        set vOr= @-1
          reference: <testLibraryFragment>::@setter::vOr
          element: <none>
          parameters
            _vOr @-1
              element: <none>
  topLevelVariables
    a
      firstFragment: <testLibraryFragment>::@topLevelVariable::a
      type: bool
      getter: <none>
      setter: <none>
    b
      firstFragment: <testLibraryFragment>::@topLevelVariable::b
      type: bool
      getter: <none>
      setter: <none>
    vEq
      firstFragment: <testLibraryFragment>::@topLevelVariable::vEq
      type: bool
      getter: <none>
      setter: <none>
    vAnd
      firstFragment: <testLibraryFragment>::@topLevelVariable::vAnd
      type: bool
      getter: <none>
      setter: <none>
    vOr
      firstFragment: <testLibraryFragment>::@topLevelVariable::vOr
      type: bool
      getter: <none>
      setter: <none>
  getters
    synthetic static get a
      firstFragment: <testLibraryFragment>::@getter::a
    synthetic static get b
      firstFragment: <testLibraryFragment>::@getter::b
    synthetic static get vEq
      firstFragment: <testLibraryFragment>::@getter::vEq
    synthetic static get vAnd
      firstFragment: <testLibraryFragment>::@getter::vAnd
    synthetic static get vOr
      firstFragment: <testLibraryFragment>::@getter::vOr
  setters
    synthetic static set a=
      firstFragment: <testLibraryFragment>::@setter::a
      parameters
        requiredPositional _a
          type: bool
    synthetic static set b=
      firstFragment: <testLibraryFragment>::@setter::b
      parameters
        requiredPositional _b
          type: bool
    synthetic static set vEq=
      firstFragment: <testLibraryFragment>::@setter::vEq
      parameters
        requiredPositional _vEq
          type: bool
    synthetic static set vAnd=
      firstFragment: <testLibraryFragment>::@setter::vAnd
      parameters
        requiredPositional _vAnd
          type: bool
    synthetic static set vOr=
      firstFragment: <testLibraryFragment>::@setter::vOr
      parameters
        requiredPositional _vOr
          type: bool
''');
  }

  @skippedTest
  test_initializer_methodInvocation_hasTypeParameters() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  List<T> m<T>() => null;
}
var vWithTypeArgument = new A().m<int>();
var vWithoutTypeArgument = new A().m();
''');
    // TODO(scheglov): test for inference failure error
    checkElementText(library, r'''
class A {
  List<T> m<T>(int p) {}
}
List<int> vWithTypeArgument;
dynamic vWithoutTypeArgument;
''');
  }

  test_initializer_methodInvocation_noTypeParameters() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  String m(int p) => null;
}
var instanceOfA = new A();
var v1 = instanceOfA.m();
var v2 = new A().m();
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          methods
            m @19
              reference: <testLibraryFragment>::@class::A::@method::m
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional p @25
                  type: int
              returnType: String
      topLevelVariables
        static instanceOfA @43
          reference: <testLibraryFragment>::@topLevelVariable::instanceOfA
          enclosingElement3: <testLibraryFragment>
          type: A
          shouldUseTypeForInitializerInference: false
        static v1 @70
          reference: <testLibraryFragment>::@topLevelVariable::v1
          enclosingElement3: <testLibraryFragment>
          type: String
          shouldUseTypeForInitializerInference: false
        static v2 @96
          reference: <testLibraryFragment>::@topLevelVariable::v2
          enclosingElement3: <testLibraryFragment>
          type: String
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get instanceOfA @-1
          reference: <testLibraryFragment>::@getter::instanceOfA
          enclosingElement3: <testLibraryFragment>
          returnType: A
        synthetic static set instanceOfA= @-1
          reference: <testLibraryFragment>::@setter::instanceOfA
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _instanceOfA @-1
              type: A
          returnType: void
        synthetic static get v1 @-1
          reference: <testLibraryFragment>::@getter::v1
          enclosingElement3: <testLibraryFragment>
          returnType: String
        synthetic static set v1= @-1
          reference: <testLibraryFragment>::@setter::v1
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _v1 @-1
              type: String
          returnType: void
        synthetic static get v2 @-1
          reference: <testLibraryFragment>::@getter::v2
          enclosingElement3: <testLibraryFragment>
          returnType: String
        synthetic static set v2= @-1
          reference: <testLibraryFragment>::@setter::v2
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _v2 @-1
              type: String
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          methods
            m @19
              reference: <testLibraryFragment>::@class::A::@method::m
              element: <none>
              parameters
                p @25
                  element: <none>
      topLevelVariables
        instanceOfA @43
          reference: <testLibraryFragment>::@topLevelVariable::instanceOfA
          element: <none>
          getter2: <testLibraryFragment>::@getter::instanceOfA
          setter2: <testLibraryFragment>::@setter::instanceOfA
        v1 @70
          reference: <testLibraryFragment>::@topLevelVariable::v1
          element: <none>
          getter2: <testLibraryFragment>::@getter::v1
          setter2: <testLibraryFragment>::@setter::v1
        v2 @96
          reference: <testLibraryFragment>::@topLevelVariable::v2
          element: <none>
          getter2: <testLibraryFragment>::@getter::v2
          setter2: <testLibraryFragment>::@setter::v2
      getters
        get instanceOfA @-1
          reference: <testLibraryFragment>::@getter::instanceOfA
          element: <none>
        get v1 @-1
          reference: <testLibraryFragment>::@getter::v1
          element: <none>
        get v2 @-1
          reference: <testLibraryFragment>::@getter::v2
          element: <none>
      setters
        set instanceOfA= @-1
          reference: <testLibraryFragment>::@setter::instanceOfA
          element: <none>
          parameters
            _instanceOfA @-1
              element: <none>
        set v1= @-1
          reference: <testLibraryFragment>::@setter::v1
          element: <none>
          parameters
            _v1 @-1
              element: <none>
        set v2= @-1
          reference: <testLibraryFragment>::@setter::v2
          element: <none>
          parameters
            _v2 @-1
              element: <none>
  classes
    class A
      firstFragment: <testLibraryFragment>::@class::A
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      methods
        m
          firstFragment: <testLibraryFragment>::@class::A::@method::m
          parameters
            requiredPositional p
              type: int
  topLevelVariables
    instanceOfA
      firstFragment: <testLibraryFragment>::@topLevelVariable::instanceOfA
      type: A
      getter: <none>
      setter: <none>
    v1
      firstFragment: <testLibraryFragment>::@topLevelVariable::v1
      type: String
      getter: <none>
      setter: <none>
    v2
      firstFragment: <testLibraryFragment>::@topLevelVariable::v2
      type: String
      getter: <none>
      setter: <none>
  getters
    synthetic static get instanceOfA
      firstFragment: <testLibraryFragment>::@getter::instanceOfA
    synthetic static get v1
      firstFragment: <testLibraryFragment>::@getter::v1
    synthetic static get v2
      firstFragment: <testLibraryFragment>::@getter::v2
  setters
    synthetic static set instanceOfA=
      firstFragment: <testLibraryFragment>::@setter::instanceOfA
      parameters
        requiredPositional _instanceOfA
          type: A
    synthetic static set v1=
      firstFragment: <testLibraryFragment>::@setter::v1
      parameters
        requiredPositional _v1
          type: String
    synthetic static set v2=
      firstFragment: <testLibraryFragment>::@setter::v2
      parameters
        requiredPositional _v2
          type: String
''');
  }

  test_initializer_multiplicative() async {
    var library = await _encodeDecodeLibrary(r'''
var vModuloIntInt = 1 % 2;
var vModuloIntDouble = 1 % 2.0;
var vMultiplyIntInt = 1 * 2;
var vMultiplyIntDouble = 1 * 2.0;
var vMultiplyDoubleInt = 1.0 * 2;
var vMultiplyDoubleDouble = 1.0 * 2.0;
var vDivideIntInt = 1 / 2;
var vDivideIntDouble = 1 / 2.0;
var vDivideDoubleInt = 1.0 / 2;
var vDivideDoubleDouble = 1.0 / 2.0;
var vFloorDivide = 1 ~/ 2;
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      topLevelVariables
        static vModuloIntInt @4
          reference: <testLibraryFragment>::@topLevelVariable::vModuloIntInt
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
        static vModuloIntDouble @31
          reference: <testLibraryFragment>::@topLevelVariable::vModuloIntDouble
          enclosingElement3: <testLibraryFragment>
          type: double
          shouldUseTypeForInitializerInference: false
        static vMultiplyIntInt @63
          reference: <testLibraryFragment>::@topLevelVariable::vMultiplyIntInt
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
        static vMultiplyIntDouble @92
          reference: <testLibraryFragment>::@topLevelVariable::vMultiplyIntDouble
          enclosingElement3: <testLibraryFragment>
          type: double
          shouldUseTypeForInitializerInference: false
        static vMultiplyDoubleInt @126
          reference: <testLibraryFragment>::@topLevelVariable::vMultiplyDoubleInt
          enclosingElement3: <testLibraryFragment>
          type: double
          shouldUseTypeForInitializerInference: false
        static vMultiplyDoubleDouble @160
          reference: <testLibraryFragment>::@topLevelVariable::vMultiplyDoubleDouble
          enclosingElement3: <testLibraryFragment>
          type: double
          shouldUseTypeForInitializerInference: false
        static vDivideIntInt @199
          reference: <testLibraryFragment>::@topLevelVariable::vDivideIntInt
          enclosingElement3: <testLibraryFragment>
          type: double
          shouldUseTypeForInitializerInference: false
        static vDivideIntDouble @226
          reference: <testLibraryFragment>::@topLevelVariable::vDivideIntDouble
          enclosingElement3: <testLibraryFragment>
          type: double
          shouldUseTypeForInitializerInference: false
        static vDivideDoubleInt @258
          reference: <testLibraryFragment>::@topLevelVariable::vDivideDoubleInt
          enclosingElement3: <testLibraryFragment>
          type: double
          shouldUseTypeForInitializerInference: false
        static vDivideDoubleDouble @290
          reference: <testLibraryFragment>::@topLevelVariable::vDivideDoubleDouble
          enclosingElement3: <testLibraryFragment>
          type: double
          shouldUseTypeForInitializerInference: false
        static vFloorDivide @327
          reference: <testLibraryFragment>::@topLevelVariable::vFloorDivide
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get vModuloIntInt @-1
          reference: <testLibraryFragment>::@getter::vModuloIntInt
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set vModuloIntInt= @-1
          reference: <testLibraryFragment>::@setter::vModuloIntInt
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vModuloIntInt @-1
              type: int
          returnType: void
        synthetic static get vModuloIntDouble @-1
          reference: <testLibraryFragment>::@getter::vModuloIntDouble
          enclosingElement3: <testLibraryFragment>
          returnType: double
        synthetic static set vModuloIntDouble= @-1
          reference: <testLibraryFragment>::@setter::vModuloIntDouble
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vModuloIntDouble @-1
              type: double
          returnType: void
        synthetic static get vMultiplyIntInt @-1
          reference: <testLibraryFragment>::@getter::vMultiplyIntInt
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set vMultiplyIntInt= @-1
          reference: <testLibraryFragment>::@setter::vMultiplyIntInt
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vMultiplyIntInt @-1
              type: int
          returnType: void
        synthetic static get vMultiplyIntDouble @-1
          reference: <testLibraryFragment>::@getter::vMultiplyIntDouble
          enclosingElement3: <testLibraryFragment>
          returnType: double
        synthetic static set vMultiplyIntDouble= @-1
          reference: <testLibraryFragment>::@setter::vMultiplyIntDouble
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vMultiplyIntDouble @-1
              type: double
          returnType: void
        synthetic static get vMultiplyDoubleInt @-1
          reference: <testLibraryFragment>::@getter::vMultiplyDoubleInt
          enclosingElement3: <testLibraryFragment>
          returnType: double
        synthetic static set vMultiplyDoubleInt= @-1
          reference: <testLibraryFragment>::@setter::vMultiplyDoubleInt
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vMultiplyDoubleInt @-1
              type: double
          returnType: void
        synthetic static get vMultiplyDoubleDouble @-1
          reference: <testLibraryFragment>::@getter::vMultiplyDoubleDouble
          enclosingElement3: <testLibraryFragment>
          returnType: double
        synthetic static set vMultiplyDoubleDouble= @-1
          reference: <testLibraryFragment>::@setter::vMultiplyDoubleDouble
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vMultiplyDoubleDouble @-1
              type: double
          returnType: void
        synthetic static get vDivideIntInt @-1
          reference: <testLibraryFragment>::@getter::vDivideIntInt
          enclosingElement3: <testLibraryFragment>
          returnType: double
        synthetic static set vDivideIntInt= @-1
          reference: <testLibraryFragment>::@setter::vDivideIntInt
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vDivideIntInt @-1
              type: double
          returnType: void
        synthetic static get vDivideIntDouble @-1
          reference: <testLibraryFragment>::@getter::vDivideIntDouble
          enclosingElement3: <testLibraryFragment>
          returnType: double
        synthetic static set vDivideIntDouble= @-1
          reference: <testLibraryFragment>::@setter::vDivideIntDouble
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vDivideIntDouble @-1
              type: double
          returnType: void
        synthetic static get vDivideDoubleInt @-1
          reference: <testLibraryFragment>::@getter::vDivideDoubleInt
          enclosingElement3: <testLibraryFragment>
          returnType: double
        synthetic static set vDivideDoubleInt= @-1
          reference: <testLibraryFragment>::@setter::vDivideDoubleInt
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vDivideDoubleInt @-1
              type: double
          returnType: void
        synthetic static get vDivideDoubleDouble @-1
          reference: <testLibraryFragment>::@getter::vDivideDoubleDouble
          enclosingElement3: <testLibraryFragment>
          returnType: double
        synthetic static set vDivideDoubleDouble= @-1
          reference: <testLibraryFragment>::@setter::vDivideDoubleDouble
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vDivideDoubleDouble @-1
              type: double
          returnType: void
        synthetic static get vFloorDivide @-1
          reference: <testLibraryFragment>::@getter::vFloorDivide
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set vFloorDivide= @-1
          reference: <testLibraryFragment>::@setter::vFloorDivide
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vFloorDivide @-1
              type: int
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      topLevelVariables
        vModuloIntInt @4
          reference: <testLibraryFragment>::@topLevelVariable::vModuloIntInt
          element: <none>
          getter2: <testLibraryFragment>::@getter::vModuloIntInt
          setter2: <testLibraryFragment>::@setter::vModuloIntInt
        vModuloIntDouble @31
          reference: <testLibraryFragment>::@topLevelVariable::vModuloIntDouble
          element: <none>
          getter2: <testLibraryFragment>::@getter::vModuloIntDouble
          setter2: <testLibraryFragment>::@setter::vModuloIntDouble
        vMultiplyIntInt @63
          reference: <testLibraryFragment>::@topLevelVariable::vMultiplyIntInt
          element: <none>
          getter2: <testLibraryFragment>::@getter::vMultiplyIntInt
          setter2: <testLibraryFragment>::@setter::vMultiplyIntInt
        vMultiplyIntDouble @92
          reference: <testLibraryFragment>::@topLevelVariable::vMultiplyIntDouble
          element: <none>
          getter2: <testLibraryFragment>::@getter::vMultiplyIntDouble
          setter2: <testLibraryFragment>::@setter::vMultiplyIntDouble
        vMultiplyDoubleInt @126
          reference: <testLibraryFragment>::@topLevelVariable::vMultiplyDoubleInt
          element: <none>
          getter2: <testLibraryFragment>::@getter::vMultiplyDoubleInt
          setter2: <testLibraryFragment>::@setter::vMultiplyDoubleInt
        vMultiplyDoubleDouble @160
          reference: <testLibraryFragment>::@topLevelVariable::vMultiplyDoubleDouble
          element: <none>
          getter2: <testLibraryFragment>::@getter::vMultiplyDoubleDouble
          setter2: <testLibraryFragment>::@setter::vMultiplyDoubleDouble
        vDivideIntInt @199
          reference: <testLibraryFragment>::@topLevelVariable::vDivideIntInt
          element: <none>
          getter2: <testLibraryFragment>::@getter::vDivideIntInt
          setter2: <testLibraryFragment>::@setter::vDivideIntInt
        vDivideIntDouble @226
          reference: <testLibraryFragment>::@topLevelVariable::vDivideIntDouble
          element: <none>
          getter2: <testLibraryFragment>::@getter::vDivideIntDouble
          setter2: <testLibraryFragment>::@setter::vDivideIntDouble
        vDivideDoubleInt @258
          reference: <testLibraryFragment>::@topLevelVariable::vDivideDoubleInt
          element: <none>
          getter2: <testLibraryFragment>::@getter::vDivideDoubleInt
          setter2: <testLibraryFragment>::@setter::vDivideDoubleInt
        vDivideDoubleDouble @290
          reference: <testLibraryFragment>::@topLevelVariable::vDivideDoubleDouble
          element: <none>
          getter2: <testLibraryFragment>::@getter::vDivideDoubleDouble
          setter2: <testLibraryFragment>::@setter::vDivideDoubleDouble
        vFloorDivide @327
          reference: <testLibraryFragment>::@topLevelVariable::vFloorDivide
          element: <none>
          getter2: <testLibraryFragment>::@getter::vFloorDivide
          setter2: <testLibraryFragment>::@setter::vFloorDivide
      getters
        get vModuloIntInt @-1
          reference: <testLibraryFragment>::@getter::vModuloIntInt
          element: <none>
        get vModuloIntDouble @-1
          reference: <testLibraryFragment>::@getter::vModuloIntDouble
          element: <none>
        get vMultiplyIntInt @-1
          reference: <testLibraryFragment>::@getter::vMultiplyIntInt
          element: <none>
        get vMultiplyIntDouble @-1
          reference: <testLibraryFragment>::@getter::vMultiplyIntDouble
          element: <none>
        get vMultiplyDoubleInt @-1
          reference: <testLibraryFragment>::@getter::vMultiplyDoubleInt
          element: <none>
        get vMultiplyDoubleDouble @-1
          reference: <testLibraryFragment>::@getter::vMultiplyDoubleDouble
          element: <none>
        get vDivideIntInt @-1
          reference: <testLibraryFragment>::@getter::vDivideIntInt
          element: <none>
        get vDivideIntDouble @-1
          reference: <testLibraryFragment>::@getter::vDivideIntDouble
          element: <none>
        get vDivideDoubleInt @-1
          reference: <testLibraryFragment>::@getter::vDivideDoubleInt
          element: <none>
        get vDivideDoubleDouble @-1
          reference: <testLibraryFragment>::@getter::vDivideDoubleDouble
          element: <none>
        get vFloorDivide @-1
          reference: <testLibraryFragment>::@getter::vFloorDivide
          element: <none>
      setters
        set vModuloIntInt= @-1
          reference: <testLibraryFragment>::@setter::vModuloIntInt
          element: <none>
          parameters
            _vModuloIntInt @-1
              element: <none>
        set vModuloIntDouble= @-1
          reference: <testLibraryFragment>::@setter::vModuloIntDouble
          element: <none>
          parameters
            _vModuloIntDouble @-1
              element: <none>
        set vMultiplyIntInt= @-1
          reference: <testLibraryFragment>::@setter::vMultiplyIntInt
          element: <none>
          parameters
            _vMultiplyIntInt @-1
              element: <none>
        set vMultiplyIntDouble= @-1
          reference: <testLibraryFragment>::@setter::vMultiplyIntDouble
          element: <none>
          parameters
            _vMultiplyIntDouble @-1
              element: <none>
        set vMultiplyDoubleInt= @-1
          reference: <testLibraryFragment>::@setter::vMultiplyDoubleInt
          element: <none>
          parameters
            _vMultiplyDoubleInt @-1
              element: <none>
        set vMultiplyDoubleDouble= @-1
          reference: <testLibraryFragment>::@setter::vMultiplyDoubleDouble
          element: <none>
          parameters
            _vMultiplyDoubleDouble @-1
              element: <none>
        set vDivideIntInt= @-1
          reference: <testLibraryFragment>::@setter::vDivideIntInt
          element: <none>
          parameters
            _vDivideIntInt @-1
              element: <none>
        set vDivideIntDouble= @-1
          reference: <testLibraryFragment>::@setter::vDivideIntDouble
          element: <none>
          parameters
            _vDivideIntDouble @-1
              element: <none>
        set vDivideDoubleInt= @-1
          reference: <testLibraryFragment>::@setter::vDivideDoubleInt
          element: <none>
          parameters
            _vDivideDoubleInt @-1
              element: <none>
        set vDivideDoubleDouble= @-1
          reference: <testLibraryFragment>::@setter::vDivideDoubleDouble
          element: <none>
          parameters
            _vDivideDoubleDouble @-1
              element: <none>
        set vFloorDivide= @-1
          reference: <testLibraryFragment>::@setter::vFloorDivide
          element: <none>
          parameters
            _vFloorDivide @-1
              element: <none>
  topLevelVariables
    vModuloIntInt
      firstFragment: <testLibraryFragment>::@topLevelVariable::vModuloIntInt
      type: int
      getter: <none>
      setter: <none>
    vModuloIntDouble
      firstFragment: <testLibraryFragment>::@topLevelVariable::vModuloIntDouble
      type: double
      getter: <none>
      setter: <none>
    vMultiplyIntInt
      firstFragment: <testLibraryFragment>::@topLevelVariable::vMultiplyIntInt
      type: int
      getter: <none>
      setter: <none>
    vMultiplyIntDouble
      firstFragment: <testLibraryFragment>::@topLevelVariable::vMultiplyIntDouble
      type: double
      getter: <none>
      setter: <none>
    vMultiplyDoubleInt
      firstFragment: <testLibraryFragment>::@topLevelVariable::vMultiplyDoubleInt
      type: double
      getter: <none>
      setter: <none>
    vMultiplyDoubleDouble
      firstFragment: <testLibraryFragment>::@topLevelVariable::vMultiplyDoubleDouble
      type: double
      getter: <none>
      setter: <none>
    vDivideIntInt
      firstFragment: <testLibraryFragment>::@topLevelVariable::vDivideIntInt
      type: double
      getter: <none>
      setter: <none>
    vDivideIntDouble
      firstFragment: <testLibraryFragment>::@topLevelVariable::vDivideIntDouble
      type: double
      getter: <none>
      setter: <none>
    vDivideDoubleInt
      firstFragment: <testLibraryFragment>::@topLevelVariable::vDivideDoubleInt
      type: double
      getter: <none>
      setter: <none>
    vDivideDoubleDouble
      firstFragment: <testLibraryFragment>::@topLevelVariable::vDivideDoubleDouble
      type: double
      getter: <none>
      setter: <none>
    vFloorDivide
      firstFragment: <testLibraryFragment>::@topLevelVariable::vFloorDivide
      type: int
      getter: <none>
      setter: <none>
  getters
    synthetic static get vModuloIntInt
      firstFragment: <testLibraryFragment>::@getter::vModuloIntInt
    synthetic static get vModuloIntDouble
      firstFragment: <testLibraryFragment>::@getter::vModuloIntDouble
    synthetic static get vMultiplyIntInt
      firstFragment: <testLibraryFragment>::@getter::vMultiplyIntInt
    synthetic static get vMultiplyIntDouble
      firstFragment: <testLibraryFragment>::@getter::vMultiplyIntDouble
    synthetic static get vMultiplyDoubleInt
      firstFragment: <testLibraryFragment>::@getter::vMultiplyDoubleInt
    synthetic static get vMultiplyDoubleDouble
      firstFragment: <testLibraryFragment>::@getter::vMultiplyDoubleDouble
    synthetic static get vDivideIntInt
      firstFragment: <testLibraryFragment>::@getter::vDivideIntInt
    synthetic static get vDivideIntDouble
      firstFragment: <testLibraryFragment>::@getter::vDivideIntDouble
    synthetic static get vDivideDoubleInt
      firstFragment: <testLibraryFragment>::@getter::vDivideDoubleInt
    synthetic static get vDivideDoubleDouble
      firstFragment: <testLibraryFragment>::@getter::vDivideDoubleDouble
    synthetic static get vFloorDivide
      firstFragment: <testLibraryFragment>::@getter::vFloorDivide
  setters
    synthetic static set vModuloIntInt=
      firstFragment: <testLibraryFragment>::@setter::vModuloIntInt
      parameters
        requiredPositional _vModuloIntInt
          type: int
    synthetic static set vModuloIntDouble=
      firstFragment: <testLibraryFragment>::@setter::vModuloIntDouble
      parameters
        requiredPositional _vModuloIntDouble
          type: double
    synthetic static set vMultiplyIntInt=
      firstFragment: <testLibraryFragment>::@setter::vMultiplyIntInt
      parameters
        requiredPositional _vMultiplyIntInt
          type: int
    synthetic static set vMultiplyIntDouble=
      firstFragment: <testLibraryFragment>::@setter::vMultiplyIntDouble
      parameters
        requiredPositional _vMultiplyIntDouble
          type: double
    synthetic static set vMultiplyDoubleInt=
      firstFragment: <testLibraryFragment>::@setter::vMultiplyDoubleInt
      parameters
        requiredPositional _vMultiplyDoubleInt
          type: double
    synthetic static set vMultiplyDoubleDouble=
      firstFragment: <testLibraryFragment>::@setter::vMultiplyDoubleDouble
      parameters
        requiredPositional _vMultiplyDoubleDouble
          type: double
    synthetic static set vDivideIntInt=
      firstFragment: <testLibraryFragment>::@setter::vDivideIntInt
      parameters
        requiredPositional _vDivideIntInt
          type: double
    synthetic static set vDivideIntDouble=
      firstFragment: <testLibraryFragment>::@setter::vDivideIntDouble
      parameters
        requiredPositional _vDivideIntDouble
          type: double
    synthetic static set vDivideDoubleInt=
      firstFragment: <testLibraryFragment>::@setter::vDivideDoubleInt
      parameters
        requiredPositional _vDivideDoubleInt
          type: double
    synthetic static set vDivideDoubleDouble=
      firstFragment: <testLibraryFragment>::@setter::vDivideDoubleDouble
      parameters
        requiredPositional _vDivideDoubleDouble
          type: double
    synthetic static set vFloorDivide=
      firstFragment: <testLibraryFragment>::@setter::vFloorDivide
      parameters
        requiredPositional _vFloorDivide
          type: int
''');
  }

  test_initializer_onlyLeft() async {
    var library = await _encodeDecodeLibrary(r'''
var a = 1;
var vEq = a == ((a = 2) == 0);
var vNotEq = a != ((a = 2) == 0);
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      topLevelVariables
        static a @4
          reference: <testLibraryFragment>::@topLevelVariable::a
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
        static vEq @15
          reference: <testLibraryFragment>::@topLevelVariable::vEq
          enclosingElement3: <testLibraryFragment>
          type: bool
          shouldUseTypeForInitializerInference: false
        static vNotEq @46
          reference: <testLibraryFragment>::@topLevelVariable::vNotEq
          enclosingElement3: <testLibraryFragment>
          type: bool
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get a @-1
          reference: <testLibraryFragment>::@getter::a
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set a= @-1
          reference: <testLibraryFragment>::@setter::a
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _a @-1
              type: int
          returnType: void
        synthetic static get vEq @-1
          reference: <testLibraryFragment>::@getter::vEq
          enclosingElement3: <testLibraryFragment>
          returnType: bool
        synthetic static set vEq= @-1
          reference: <testLibraryFragment>::@setter::vEq
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vEq @-1
              type: bool
          returnType: void
        synthetic static get vNotEq @-1
          reference: <testLibraryFragment>::@getter::vNotEq
          enclosingElement3: <testLibraryFragment>
          returnType: bool
        synthetic static set vNotEq= @-1
          reference: <testLibraryFragment>::@setter::vNotEq
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vNotEq @-1
              type: bool
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      topLevelVariables
        a @4
          reference: <testLibraryFragment>::@topLevelVariable::a
          element: <none>
          getter2: <testLibraryFragment>::@getter::a
          setter2: <testLibraryFragment>::@setter::a
        vEq @15
          reference: <testLibraryFragment>::@topLevelVariable::vEq
          element: <none>
          getter2: <testLibraryFragment>::@getter::vEq
          setter2: <testLibraryFragment>::@setter::vEq
        vNotEq @46
          reference: <testLibraryFragment>::@topLevelVariable::vNotEq
          element: <none>
          getter2: <testLibraryFragment>::@getter::vNotEq
          setter2: <testLibraryFragment>::@setter::vNotEq
      getters
        get a @-1
          reference: <testLibraryFragment>::@getter::a
          element: <none>
        get vEq @-1
          reference: <testLibraryFragment>::@getter::vEq
          element: <none>
        get vNotEq @-1
          reference: <testLibraryFragment>::@getter::vNotEq
          element: <none>
      setters
        set a= @-1
          reference: <testLibraryFragment>::@setter::a
          element: <none>
          parameters
            _a @-1
              element: <none>
        set vEq= @-1
          reference: <testLibraryFragment>::@setter::vEq
          element: <none>
          parameters
            _vEq @-1
              element: <none>
        set vNotEq= @-1
          reference: <testLibraryFragment>::@setter::vNotEq
          element: <none>
          parameters
            _vNotEq @-1
              element: <none>
  topLevelVariables
    a
      firstFragment: <testLibraryFragment>::@topLevelVariable::a
      type: int
      getter: <none>
      setter: <none>
    vEq
      firstFragment: <testLibraryFragment>::@topLevelVariable::vEq
      type: bool
      getter: <none>
      setter: <none>
    vNotEq
      firstFragment: <testLibraryFragment>::@topLevelVariable::vNotEq
      type: bool
      getter: <none>
      setter: <none>
  getters
    synthetic static get a
      firstFragment: <testLibraryFragment>::@getter::a
    synthetic static get vEq
      firstFragment: <testLibraryFragment>::@getter::vEq
    synthetic static get vNotEq
      firstFragment: <testLibraryFragment>::@getter::vNotEq
  setters
    synthetic static set a=
      firstFragment: <testLibraryFragment>::@setter::a
      parameters
        requiredPositional _a
          type: int
    synthetic static set vEq=
      firstFragment: <testLibraryFragment>::@setter::vEq
      parameters
        requiredPositional _vEq
          type: bool
    synthetic static set vNotEq=
      firstFragment: <testLibraryFragment>::@setter::vNotEq
      parameters
        requiredPositional _vNotEq
          type: bool
''');
  }

  test_initializer_parenthesized() async {
    var library = await _encodeDecodeLibrary(r'''
var V = (42);
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      topLevelVariables
        static V @4
          reference: <testLibraryFragment>::@topLevelVariable::V
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get V @-1
          reference: <testLibraryFragment>::@getter::V
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set V= @-1
          reference: <testLibraryFragment>::@setter::V
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _V @-1
              type: int
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      topLevelVariables
        V @4
          reference: <testLibraryFragment>::@topLevelVariable::V
          element: <none>
          getter2: <testLibraryFragment>::@getter::V
          setter2: <testLibraryFragment>::@setter::V
      getters
        get V @-1
          reference: <testLibraryFragment>::@getter::V
          element: <none>
      setters
        set V= @-1
          reference: <testLibraryFragment>::@setter::V
          element: <none>
          parameters
            _V @-1
              element: <none>
  topLevelVariables
    V
      firstFragment: <testLibraryFragment>::@topLevelVariable::V
      type: int
      getter: <none>
      setter: <none>
  getters
    synthetic static get V
      firstFragment: <testLibraryFragment>::@getter::V
  setters
    synthetic static set V=
      firstFragment: <testLibraryFragment>::@setter::V
      parameters
        requiredPositional _V
          type: int
''');
  }

  test_initializer_postfix() async {
    var library = await _encodeDecodeLibrary(r'''
var vInt = 1;
var vDouble = 2.0;
var vIncInt = vInt++;
var vDecInt = vInt--;
var vIncDouble = vDouble++;
var vDecDouble = vDouble--;
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      topLevelVariables
        static vInt @4
          reference: <testLibraryFragment>::@topLevelVariable::vInt
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
        static vDouble @18
          reference: <testLibraryFragment>::@topLevelVariable::vDouble
          enclosingElement3: <testLibraryFragment>
          type: double
          shouldUseTypeForInitializerInference: false
        static vIncInt @37
          reference: <testLibraryFragment>::@topLevelVariable::vIncInt
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
        static vDecInt @59
          reference: <testLibraryFragment>::@topLevelVariable::vDecInt
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
        static vIncDouble @81
          reference: <testLibraryFragment>::@topLevelVariable::vIncDouble
          enclosingElement3: <testLibraryFragment>
          type: double
          shouldUseTypeForInitializerInference: false
        static vDecDouble @109
          reference: <testLibraryFragment>::@topLevelVariable::vDecDouble
          enclosingElement3: <testLibraryFragment>
          type: double
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get vInt @-1
          reference: <testLibraryFragment>::@getter::vInt
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set vInt= @-1
          reference: <testLibraryFragment>::@setter::vInt
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vInt @-1
              type: int
          returnType: void
        synthetic static get vDouble @-1
          reference: <testLibraryFragment>::@getter::vDouble
          enclosingElement3: <testLibraryFragment>
          returnType: double
        synthetic static set vDouble= @-1
          reference: <testLibraryFragment>::@setter::vDouble
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vDouble @-1
              type: double
          returnType: void
        synthetic static get vIncInt @-1
          reference: <testLibraryFragment>::@getter::vIncInt
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set vIncInt= @-1
          reference: <testLibraryFragment>::@setter::vIncInt
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vIncInt @-1
              type: int
          returnType: void
        synthetic static get vDecInt @-1
          reference: <testLibraryFragment>::@getter::vDecInt
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set vDecInt= @-1
          reference: <testLibraryFragment>::@setter::vDecInt
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vDecInt @-1
              type: int
          returnType: void
        synthetic static get vIncDouble @-1
          reference: <testLibraryFragment>::@getter::vIncDouble
          enclosingElement3: <testLibraryFragment>
          returnType: double
        synthetic static set vIncDouble= @-1
          reference: <testLibraryFragment>::@setter::vIncDouble
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vIncDouble @-1
              type: double
          returnType: void
        synthetic static get vDecDouble @-1
          reference: <testLibraryFragment>::@getter::vDecDouble
          enclosingElement3: <testLibraryFragment>
          returnType: double
        synthetic static set vDecDouble= @-1
          reference: <testLibraryFragment>::@setter::vDecDouble
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vDecDouble @-1
              type: double
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      topLevelVariables
        vInt @4
          reference: <testLibraryFragment>::@topLevelVariable::vInt
          element: <none>
          getter2: <testLibraryFragment>::@getter::vInt
          setter2: <testLibraryFragment>::@setter::vInt
        vDouble @18
          reference: <testLibraryFragment>::@topLevelVariable::vDouble
          element: <none>
          getter2: <testLibraryFragment>::@getter::vDouble
          setter2: <testLibraryFragment>::@setter::vDouble
        vIncInt @37
          reference: <testLibraryFragment>::@topLevelVariable::vIncInt
          element: <none>
          getter2: <testLibraryFragment>::@getter::vIncInt
          setter2: <testLibraryFragment>::@setter::vIncInt
        vDecInt @59
          reference: <testLibraryFragment>::@topLevelVariable::vDecInt
          element: <none>
          getter2: <testLibraryFragment>::@getter::vDecInt
          setter2: <testLibraryFragment>::@setter::vDecInt
        vIncDouble @81
          reference: <testLibraryFragment>::@topLevelVariable::vIncDouble
          element: <none>
          getter2: <testLibraryFragment>::@getter::vIncDouble
          setter2: <testLibraryFragment>::@setter::vIncDouble
        vDecDouble @109
          reference: <testLibraryFragment>::@topLevelVariable::vDecDouble
          element: <none>
          getter2: <testLibraryFragment>::@getter::vDecDouble
          setter2: <testLibraryFragment>::@setter::vDecDouble
      getters
        get vInt @-1
          reference: <testLibraryFragment>::@getter::vInt
          element: <none>
        get vDouble @-1
          reference: <testLibraryFragment>::@getter::vDouble
          element: <none>
        get vIncInt @-1
          reference: <testLibraryFragment>::@getter::vIncInt
          element: <none>
        get vDecInt @-1
          reference: <testLibraryFragment>::@getter::vDecInt
          element: <none>
        get vIncDouble @-1
          reference: <testLibraryFragment>::@getter::vIncDouble
          element: <none>
        get vDecDouble @-1
          reference: <testLibraryFragment>::@getter::vDecDouble
          element: <none>
      setters
        set vInt= @-1
          reference: <testLibraryFragment>::@setter::vInt
          element: <none>
          parameters
            _vInt @-1
              element: <none>
        set vDouble= @-1
          reference: <testLibraryFragment>::@setter::vDouble
          element: <none>
          parameters
            _vDouble @-1
              element: <none>
        set vIncInt= @-1
          reference: <testLibraryFragment>::@setter::vIncInt
          element: <none>
          parameters
            _vIncInt @-1
              element: <none>
        set vDecInt= @-1
          reference: <testLibraryFragment>::@setter::vDecInt
          element: <none>
          parameters
            _vDecInt @-1
              element: <none>
        set vIncDouble= @-1
          reference: <testLibraryFragment>::@setter::vIncDouble
          element: <none>
          parameters
            _vIncDouble @-1
              element: <none>
        set vDecDouble= @-1
          reference: <testLibraryFragment>::@setter::vDecDouble
          element: <none>
          parameters
            _vDecDouble @-1
              element: <none>
  topLevelVariables
    vInt
      firstFragment: <testLibraryFragment>::@topLevelVariable::vInt
      type: int
      getter: <none>
      setter: <none>
    vDouble
      firstFragment: <testLibraryFragment>::@topLevelVariable::vDouble
      type: double
      getter: <none>
      setter: <none>
    vIncInt
      firstFragment: <testLibraryFragment>::@topLevelVariable::vIncInt
      type: int
      getter: <none>
      setter: <none>
    vDecInt
      firstFragment: <testLibraryFragment>::@topLevelVariable::vDecInt
      type: int
      getter: <none>
      setter: <none>
    vIncDouble
      firstFragment: <testLibraryFragment>::@topLevelVariable::vIncDouble
      type: double
      getter: <none>
      setter: <none>
    vDecDouble
      firstFragment: <testLibraryFragment>::@topLevelVariable::vDecDouble
      type: double
      getter: <none>
      setter: <none>
  getters
    synthetic static get vInt
      firstFragment: <testLibraryFragment>::@getter::vInt
    synthetic static get vDouble
      firstFragment: <testLibraryFragment>::@getter::vDouble
    synthetic static get vIncInt
      firstFragment: <testLibraryFragment>::@getter::vIncInt
    synthetic static get vDecInt
      firstFragment: <testLibraryFragment>::@getter::vDecInt
    synthetic static get vIncDouble
      firstFragment: <testLibraryFragment>::@getter::vIncDouble
    synthetic static get vDecDouble
      firstFragment: <testLibraryFragment>::@getter::vDecDouble
  setters
    synthetic static set vInt=
      firstFragment: <testLibraryFragment>::@setter::vInt
      parameters
        requiredPositional _vInt
          type: int
    synthetic static set vDouble=
      firstFragment: <testLibraryFragment>::@setter::vDouble
      parameters
        requiredPositional _vDouble
          type: double
    synthetic static set vIncInt=
      firstFragment: <testLibraryFragment>::@setter::vIncInt
      parameters
        requiredPositional _vIncInt
          type: int
    synthetic static set vDecInt=
      firstFragment: <testLibraryFragment>::@setter::vDecInt
      parameters
        requiredPositional _vDecInt
          type: int
    synthetic static set vIncDouble=
      firstFragment: <testLibraryFragment>::@setter::vIncDouble
      parameters
        requiredPositional _vIncDouble
          type: double
    synthetic static set vDecDouble=
      firstFragment: <testLibraryFragment>::@setter::vDecDouble
      parameters
        requiredPositional _vDecDouble
          type: double
''');
  }

  test_initializer_postfix_indexed() async {
    var library = await _encodeDecodeLibrary(r'''
var vInt = [1];
var vDouble = [2.0];
var vIncInt = vInt[0]++;
var vDecInt = vInt[0]--;
var vIncDouble = vDouble[0]++;
var vDecDouble = vDouble[0]--;
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      topLevelVariables
        static vInt @4
          reference: <testLibraryFragment>::@topLevelVariable::vInt
          enclosingElement3: <testLibraryFragment>
          type: List<int>
          shouldUseTypeForInitializerInference: false
        static vDouble @20
          reference: <testLibraryFragment>::@topLevelVariable::vDouble
          enclosingElement3: <testLibraryFragment>
          type: List<double>
          shouldUseTypeForInitializerInference: false
        static vIncInt @41
          reference: <testLibraryFragment>::@topLevelVariable::vIncInt
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
        static vDecInt @66
          reference: <testLibraryFragment>::@topLevelVariable::vDecInt
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
        static vIncDouble @91
          reference: <testLibraryFragment>::@topLevelVariable::vIncDouble
          enclosingElement3: <testLibraryFragment>
          type: double
          shouldUseTypeForInitializerInference: false
        static vDecDouble @122
          reference: <testLibraryFragment>::@topLevelVariable::vDecDouble
          enclosingElement3: <testLibraryFragment>
          type: double
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get vInt @-1
          reference: <testLibraryFragment>::@getter::vInt
          enclosingElement3: <testLibraryFragment>
          returnType: List<int>
        synthetic static set vInt= @-1
          reference: <testLibraryFragment>::@setter::vInt
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vInt @-1
              type: List<int>
          returnType: void
        synthetic static get vDouble @-1
          reference: <testLibraryFragment>::@getter::vDouble
          enclosingElement3: <testLibraryFragment>
          returnType: List<double>
        synthetic static set vDouble= @-1
          reference: <testLibraryFragment>::@setter::vDouble
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vDouble @-1
              type: List<double>
          returnType: void
        synthetic static get vIncInt @-1
          reference: <testLibraryFragment>::@getter::vIncInt
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set vIncInt= @-1
          reference: <testLibraryFragment>::@setter::vIncInt
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vIncInt @-1
              type: int
          returnType: void
        synthetic static get vDecInt @-1
          reference: <testLibraryFragment>::@getter::vDecInt
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set vDecInt= @-1
          reference: <testLibraryFragment>::@setter::vDecInt
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vDecInt @-1
              type: int
          returnType: void
        synthetic static get vIncDouble @-1
          reference: <testLibraryFragment>::@getter::vIncDouble
          enclosingElement3: <testLibraryFragment>
          returnType: double
        synthetic static set vIncDouble= @-1
          reference: <testLibraryFragment>::@setter::vIncDouble
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vIncDouble @-1
              type: double
          returnType: void
        synthetic static get vDecDouble @-1
          reference: <testLibraryFragment>::@getter::vDecDouble
          enclosingElement3: <testLibraryFragment>
          returnType: double
        synthetic static set vDecDouble= @-1
          reference: <testLibraryFragment>::@setter::vDecDouble
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vDecDouble @-1
              type: double
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      topLevelVariables
        vInt @4
          reference: <testLibraryFragment>::@topLevelVariable::vInt
          element: <none>
          getter2: <testLibraryFragment>::@getter::vInt
          setter2: <testLibraryFragment>::@setter::vInt
        vDouble @20
          reference: <testLibraryFragment>::@topLevelVariable::vDouble
          element: <none>
          getter2: <testLibraryFragment>::@getter::vDouble
          setter2: <testLibraryFragment>::@setter::vDouble
        vIncInt @41
          reference: <testLibraryFragment>::@topLevelVariable::vIncInt
          element: <none>
          getter2: <testLibraryFragment>::@getter::vIncInt
          setter2: <testLibraryFragment>::@setter::vIncInt
        vDecInt @66
          reference: <testLibraryFragment>::@topLevelVariable::vDecInt
          element: <none>
          getter2: <testLibraryFragment>::@getter::vDecInt
          setter2: <testLibraryFragment>::@setter::vDecInt
        vIncDouble @91
          reference: <testLibraryFragment>::@topLevelVariable::vIncDouble
          element: <none>
          getter2: <testLibraryFragment>::@getter::vIncDouble
          setter2: <testLibraryFragment>::@setter::vIncDouble
        vDecDouble @122
          reference: <testLibraryFragment>::@topLevelVariable::vDecDouble
          element: <none>
          getter2: <testLibraryFragment>::@getter::vDecDouble
          setter2: <testLibraryFragment>::@setter::vDecDouble
      getters
        get vInt @-1
          reference: <testLibraryFragment>::@getter::vInt
          element: <none>
        get vDouble @-1
          reference: <testLibraryFragment>::@getter::vDouble
          element: <none>
        get vIncInt @-1
          reference: <testLibraryFragment>::@getter::vIncInt
          element: <none>
        get vDecInt @-1
          reference: <testLibraryFragment>::@getter::vDecInt
          element: <none>
        get vIncDouble @-1
          reference: <testLibraryFragment>::@getter::vIncDouble
          element: <none>
        get vDecDouble @-1
          reference: <testLibraryFragment>::@getter::vDecDouble
          element: <none>
      setters
        set vInt= @-1
          reference: <testLibraryFragment>::@setter::vInt
          element: <none>
          parameters
            _vInt @-1
              element: <none>
        set vDouble= @-1
          reference: <testLibraryFragment>::@setter::vDouble
          element: <none>
          parameters
            _vDouble @-1
              element: <none>
        set vIncInt= @-1
          reference: <testLibraryFragment>::@setter::vIncInt
          element: <none>
          parameters
            _vIncInt @-1
              element: <none>
        set vDecInt= @-1
          reference: <testLibraryFragment>::@setter::vDecInt
          element: <none>
          parameters
            _vDecInt @-1
              element: <none>
        set vIncDouble= @-1
          reference: <testLibraryFragment>::@setter::vIncDouble
          element: <none>
          parameters
            _vIncDouble @-1
              element: <none>
        set vDecDouble= @-1
          reference: <testLibraryFragment>::@setter::vDecDouble
          element: <none>
          parameters
            _vDecDouble @-1
              element: <none>
  topLevelVariables
    vInt
      firstFragment: <testLibraryFragment>::@topLevelVariable::vInt
      type: List<int>
      getter: <none>
      setter: <none>
    vDouble
      firstFragment: <testLibraryFragment>::@topLevelVariable::vDouble
      type: List<double>
      getter: <none>
      setter: <none>
    vIncInt
      firstFragment: <testLibraryFragment>::@topLevelVariable::vIncInt
      type: int
      getter: <none>
      setter: <none>
    vDecInt
      firstFragment: <testLibraryFragment>::@topLevelVariable::vDecInt
      type: int
      getter: <none>
      setter: <none>
    vIncDouble
      firstFragment: <testLibraryFragment>::@topLevelVariable::vIncDouble
      type: double
      getter: <none>
      setter: <none>
    vDecDouble
      firstFragment: <testLibraryFragment>::@topLevelVariable::vDecDouble
      type: double
      getter: <none>
      setter: <none>
  getters
    synthetic static get vInt
      firstFragment: <testLibraryFragment>::@getter::vInt
    synthetic static get vDouble
      firstFragment: <testLibraryFragment>::@getter::vDouble
    synthetic static get vIncInt
      firstFragment: <testLibraryFragment>::@getter::vIncInt
    synthetic static get vDecInt
      firstFragment: <testLibraryFragment>::@getter::vDecInt
    synthetic static get vIncDouble
      firstFragment: <testLibraryFragment>::@getter::vIncDouble
    synthetic static get vDecDouble
      firstFragment: <testLibraryFragment>::@getter::vDecDouble
  setters
    synthetic static set vInt=
      firstFragment: <testLibraryFragment>::@setter::vInt
      parameters
        requiredPositional _vInt
          type: List<int>
    synthetic static set vDouble=
      firstFragment: <testLibraryFragment>::@setter::vDouble
      parameters
        requiredPositional _vDouble
          type: List<double>
    synthetic static set vIncInt=
      firstFragment: <testLibraryFragment>::@setter::vIncInt
      parameters
        requiredPositional _vIncInt
          type: int
    synthetic static set vDecInt=
      firstFragment: <testLibraryFragment>::@setter::vDecInt
      parameters
        requiredPositional _vDecInt
          type: int
    synthetic static set vIncDouble=
      firstFragment: <testLibraryFragment>::@setter::vIncDouble
      parameters
        requiredPositional _vIncDouble
          type: double
    synthetic static set vDecDouble=
      firstFragment: <testLibraryFragment>::@setter::vDecDouble
      parameters
        requiredPositional _vDecDouble
          type: double
''');
  }

  test_initializer_prefix_incDec() async {
    var library = await _encodeDecodeLibrary(r'''
var vInt = 1;
var vDouble = 2.0;
var vIncInt = ++vInt;
var vDecInt = --vInt;
var vIncDouble = ++vDouble;
var vDecInt = --vDouble;
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      topLevelVariables
        static vInt @4
          reference: <testLibraryFragment>::@topLevelVariable::vInt
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
        static vDouble @18
          reference: <testLibraryFragment>::@topLevelVariable::vDouble
          enclosingElement3: <testLibraryFragment>
          type: double
          shouldUseTypeForInitializerInference: false
        static vIncInt @37
          reference: <testLibraryFragment>::@topLevelVariable::vIncInt
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
        static vDecInt @59
          reference: <testLibraryFragment>::@topLevelVariable::vDecInt::@def::0
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
        static vIncDouble @81
          reference: <testLibraryFragment>::@topLevelVariable::vIncDouble
          enclosingElement3: <testLibraryFragment>
          type: double
          shouldUseTypeForInitializerInference: false
        static vDecInt @109
          reference: <testLibraryFragment>::@topLevelVariable::vDecInt::@def::1
          enclosingElement3: <testLibraryFragment>
          type: double
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get vInt @-1
          reference: <testLibraryFragment>::@getter::vInt
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set vInt= @-1
          reference: <testLibraryFragment>::@setter::vInt
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vInt @-1
              type: int
          returnType: void
        synthetic static get vDouble @-1
          reference: <testLibraryFragment>::@getter::vDouble
          enclosingElement3: <testLibraryFragment>
          returnType: double
        synthetic static set vDouble= @-1
          reference: <testLibraryFragment>::@setter::vDouble
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vDouble @-1
              type: double
          returnType: void
        synthetic static get vIncInt @-1
          reference: <testLibraryFragment>::@getter::vIncInt
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set vIncInt= @-1
          reference: <testLibraryFragment>::@setter::vIncInt
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vIncInt @-1
              type: int
          returnType: void
        synthetic static get vDecInt @-1
          reference: <testLibraryFragment>::@getter::vDecInt::@def::0
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set vDecInt= @-1
          reference: <testLibraryFragment>::@setter::vDecInt::@def::0
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vDecInt @-1
              type: int
          returnType: void
        synthetic static get vIncDouble @-1
          reference: <testLibraryFragment>::@getter::vIncDouble
          enclosingElement3: <testLibraryFragment>
          returnType: double
        synthetic static set vIncDouble= @-1
          reference: <testLibraryFragment>::@setter::vIncDouble
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vIncDouble @-1
              type: double
          returnType: void
        synthetic static get vDecInt @-1
          reference: <testLibraryFragment>::@getter::vDecInt::@def::1
          enclosingElement3: <testLibraryFragment>
          returnType: double
        synthetic static set vDecInt= @-1
          reference: <testLibraryFragment>::@setter::vDecInt::@def::1
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vDecInt @-1
              type: double
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      topLevelVariables
        vInt @4
          reference: <testLibraryFragment>::@topLevelVariable::vInt
          element: <none>
          getter2: <testLibraryFragment>::@getter::vInt
          setter2: <testLibraryFragment>::@setter::vInt
        vDouble @18
          reference: <testLibraryFragment>::@topLevelVariable::vDouble
          element: <none>
          getter2: <testLibraryFragment>::@getter::vDouble
          setter2: <testLibraryFragment>::@setter::vDouble
        vIncInt @37
          reference: <testLibraryFragment>::@topLevelVariable::vIncInt
          element: <none>
          getter2: <testLibraryFragment>::@getter::vIncInt
          setter2: <testLibraryFragment>::@setter::vIncInt
        vDecInt @59
          reference: <testLibraryFragment>::@topLevelVariable::vDecInt::@def::0
          element: <none>
          getter2: <testLibraryFragment>::@getter::vDecInt::@def::0
          setter2: <testLibraryFragment>::@setter::vDecInt::@def::0
        vIncDouble @81
          reference: <testLibraryFragment>::@topLevelVariable::vIncDouble
          element: <none>
          getter2: <testLibraryFragment>::@getter::vIncDouble
          setter2: <testLibraryFragment>::@setter::vIncDouble
        vDecInt @109
          reference: <testLibraryFragment>::@topLevelVariable::vDecInt::@def::1
          element: <none>
          getter2: <testLibraryFragment>::@getter::vDecInt::@def::1
          setter2: <testLibraryFragment>::@setter::vDecInt::@def::1
      getters
        get vInt @-1
          reference: <testLibraryFragment>::@getter::vInt
          element: <none>
        get vDouble @-1
          reference: <testLibraryFragment>::@getter::vDouble
          element: <none>
        get vIncInt @-1
          reference: <testLibraryFragment>::@getter::vIncInt
          element: <none>
        get vDecInt @-1
          reference: <testLibraryFragment>::@getter::vDecInt::@def::0
          element: <none>
        get vIncDouble @-1
          reference: <testLibraryFragment>::@getter::vIncDouble
          element: <none>
        get vDecInt @-1
          reference: <testLibraryFragment>::@getter::vDecInt::@def::1
          element: <none>
      setters
        set vInt= @-1
          reference: <testLibraryFragment>::@setter::vInt
          element: <none>
          parameters
            _vInt @-1
              element: <none>
        set vDouble= @-1
          reference: <testLibraryFragment>::@setter::vDouble
          element: <none>
          parameters
            _vDouble @-1
              element: <none>
        set vIncInt= @-1
          reference: <testLibraryFragment>::@setter::vIncInt
          element: <none>
          parameters
            _vIncInt @-1
              element: <none>
        set vDecInt= @-1
          reference: <testLibraryFragment>::@setter::vDecInt::@def::0
          element: <none>
          parameters
            _vDecInt @-1
              element: <none>
        set vIncDouble= @-1
          reference: <testLibraryFragment>::@setter::vIncDouble
          element: <none>
          parameters
            _vIncDouble @-1
              element: <none>
        set vDecInt= @-1
          reference: <testLibraryFragment>::@setter::vDecInt::@def::1
          element: <none>
          parameters
            _vDecInt @-1
              element: <none>
  topLevelVariables
    vInt
      firstFragment: <testLibraryFragment>::@topLevelVariable::vInt
      type: int
      getter: <none>
      setter: <none>
    vDouble
      firstFragment: <testLibraryFragment>::@topLevelVariable::vDouble
      type: double
      getter: <none>
      setter: <none>
    vIncInt
      firstFragment: <testLibraryFragment>::@topLevelVariable::vIncInt
      type: int
      getter: <none>
      setter: <none>
    vDecInt
      firstFragment: <testLibraryFragment>::@topLevelVariable::vDecInt::@def::0
      type: int
      getter: <none>
      setter: <none>
    vIncDouble
      firstFragment: <testLibraryFragment>::@topLevelVariable::vIncDouble
      type: double
      getter: <none>
      setter: <none>
    vDecInt
      firstFragment: <testLibraryFragment>::@topLevelVariable::vDecInt::@def::1
      type: double
      getter: <none>
      setter: <none>
  getters
    synthetic static get vInt
      firstFragment: <testLibraryFragment>::@getter::vInt
    synthetic static get vDouble
      firstFragment: <testLibraryFragment>::@getter::vDouble
    synthetic static get vIncInt
      firstFragment: <testLibraryFragment>::@getter::vIncInt
    synthetic static get vDecInt
      firstFragment: <testLibraryFragment>::@getter::vDecInt::@def::0
    synthetic static get vIncDouble
      firstFragment: <testLibraryFragment>::@getter::vIncDouble
    synthetic static get vDecInt
      firstFragment: <testLibraryFragment>::@getter::vDecInt::@def::1
  setters
    synthetic static set vInt=
      firstFragment: <testLibraryFragment>::@setter::vInt
      parameters
        requiredPositional _vInt
          type: int
    synthetic static set vDouble=
      firstFragment: <testLibraryFragment>::@setter::vDouble
      parameters
        requiredPositional _vDouble
          type: double
    synthetic static set vIncInt=
      firstFragment: <testLibraryFragment>::@setter::vIncInt
      parameters
        requiredPositional _vIncInt
          type: int
    synthetic static set vDecInt=
      firstFragment: <testLibraryFragment>::@setter::vDecInt::@def::0
      parameters
        requiredPositional _vDecInt
          type: int
    synthetic static set vIncDouble=
      firstFragment: <testLibraryFragment>::@setter::vIncDouble
      parameters
        requiredPositional _vIncDouble
          type: double
    synthetic static set vDecInt=
      firstFragment: <testLibraryFragment>::@setter::vDecInt::@def::1
      parameters
        requiredPositional _vDecInt
          type: double
''');
  }

  @skippedTest
  test_initializer_prefix_incDec_custom() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  B operator+(int v) => null;
}
class B {}
var a = new A();
var vInc = ++a;
var vDec = --a;
''');
    checkElementText(library, r'''
A a;
B vInc;
B vDec;
''');
  }

  test_initializer_prefix_incDec_indexed() async {
    var library = await _encodeDecodeLibrary(r'''
var vInt = [1];
var vDouble = [2.0];
var vIncInt = ++vInt[0];
var vDecInt = --vInt[0];
var vIncDouble = ++vDouble[0];
var vDecInt = --vDouble[0];
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      topLevelVariables
        static vInt @4
          reference: <testLibraryFragment>::@topLevelVariable::vInt
          enclosingElement3: <testLibraryFragment>
          type: List<int>
          shouldUseTypeForInitializerInference: false
        static vDouble @20
          reference: <testLibraryFragment>::@topLevelVariable::vDouble
          enclosingElement3: <testLibraryFragment>
          type: List<double>
          shouldUseTypeForInitializerInference: false
        static vIncInt @41
          reference: <testLibraryFragment>::@topLevelVariable::vIncInt
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
        static vDecInt @66
          reference: <testLibraryFragment>::@topLevelVariable::vDecInt::@def::0
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
        static vIncDouble @91
          reference: <testLibraryFragment>::@topLevelVariable::vIncDouble
          enclosingElement3: <testLibraryFragment>
          type: double
          shouldUseTypeForInitializerInference: false
        static vDecInt @122
          reference: <testLibraryFragment>::@topLevelVariable::vDecInt::@def::1
          enclosingElement3: <testLibraryFragment>
          type: double
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get vInt @-1
          reference: <testLibraryFragment>::@getter::vInt
          enclosingElement3: <testLibraryFragment>
          returnType: List<int>
        synthetic static set vInt= @-1
          reference: <testLibraryFragment>::@setter::vInt
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vInt @-1
              type: List<int>
          returnType: void
        synthetic static get vDouble @-1
          reference: <testLibraryFragment>::@getter::vDouble
          enclosingElement3: <testLibraryFragment>
          returnType: List<double>
        synthetic static set vDouble= @-1
          reference: <testLibraryFragment>::@setter::vDouble
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vDouble @-1
              type: List<double>
          returnType: void
        synthetic static get vIncInt @-1
          reference: <testLibraryFragment>::@getter::vIncInt
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set vIncInt= @-1
          reference: <testLibraryFragment>::@setter::vIncInt
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vIncInt @-1
              type: int
          returnType: void
        synthetic static get vDecInt @-1
          reference: <testLibraryFragment>::@getter::vDecInt::@def::0
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set vDecInt= @-1
          reference: <testLibraryFragment>::@setter::vDecInt::@def::0
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vDecInt @-1
              type: int
          returnType: void
        synthetic static get vIncDouble @-1
          reference: <testLibraryFragment>::@getter::vIncDouble
          enclosingElement3: <testLibraryFragment>
          returnType: double
        synthetic static set vIncDouble= @-1
          reference: <testLibraryFragment>::@setter::vIncDouble
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vIncDouble @-1
              type: double
          returnType: void
        synthetic static get vDecInt @-1
          reference: <testLibraryFragment>::@getter::vDecInt::@def::1
          enclosingElement3: <testLibraryFragment>
          returnType: double
        synthetic static set vDecInt= @-1
          reference: <testLibraryFragment>::@setter::vDecInt::@def::1
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vDecInt @-1
              type: double
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      topLevelVariables
        vInt @4
          reference: <testLibraryFragment>::@topLevelVariable::vInt
          element: <none>
          getter2: <testLibraryFragment>::@getter::vInt
          setter2: <testLibraryFragment>::@setter::vInt
        vDouble @20
          reference: <testLibraryFragment>::@topLevelVariable::vDouble
          element: <none>
          getter2: <testLibraryFragment>::@getter::vDouble
          setter2: <testLibraryFragment>::@setter::vDouble
        vIncInt @41
          reference: <testLibraryFragment>::@topLevelVariable::vIncInt
          element: <none>
          getter2: <testLibraryFragment>::@getter::vIncInt
          setter2: <testLibraryFragment>::@setter::vIncInt
        vDecInt @66
          reference: <testLibraryFragment>::@topLevelVariable::vDecInt::@def::0
          element: <none>
          getter2: <testLibraryFragment>::@getter::vDecInt::@def::0
          setter2: <testLibraryFragment>::@setter::vDecInt::@def::0
        vIncDouble @91
          reference: <testLibraryFragment>::@topLevelVariable::vIncDouble
          element: <none>
          getter2: <testLibraryFragment>::@getter::vIncDouble
          setter2: <testLibraryFragment>::@setter::vIncDouble
        vDecInt @122
          reference: <testLibraryFragment>::@topLevelVariable::vDecInt::@def::1
          element: <none>
          getter2: <testLibraryFragment>::@getter::vDecInt::@def::1
          setter2: <testLibraryFragment>::@setter::vDecInt::@def::1
      getters
        get vInt @-1
          reference: <testLibraryFragment>::@getter::vInt
          element: <none>
        get vDouble @-1
          reference: <testLibraryFragment>::@getter::vDouble
          element: <none>
        get vIncInt @-1
          reference: <testLibraryFragment>::@getter::vIncInt
          element: <none>
        get vDecInt @-1
          reference: <testLibraryFragment>::@getter::vDecInt::@def::0
          element: <none>
        get vIncDouble @-1
          reference: <testLibraryFragment>::@getter::vIncDouble
          element: <none>
        get vDecInt @-1
          reference: <testLibraryFragment>::@getter::vDecInt::@def::1
          element: <none>
      setters
        set vInt= @-1
          reference: <testLibraryFragment>::@setter::vInt
          element: <none>
          parameters
            _vInt @-1
              element: <none>
        set vDouble= @-1
          reference: <testLibraryFragment>::@setter::vDouble
          element: <none>
          parameters
            _vDouble @-1
              element: <none>
        set vIncInt= @-1
          reference: <testLibraryFragment>::@setter::vIncInt
          element: <none>
          parameters
            _vIncInt @-1
              element: <none>
        set vDecInt= @-1
          reference: <testLibraryFragment>::@setter::vDecInt::@def::0
          element: <none>
          parameters
            _vDecInt @-1
              element: <none>
        set vIncDouble= @-1
          reference: <testLibraryFragment>::@setter::vIncDouble
          element: <none>
          parameters
            _vIncDouble @-1
              element: <none>
        set vDecInt= @-1
          reference: <testLibraryFragment>::@setter::vDecInt::@def::1
          element: <none>
          parameters
            _vDecInt @-1
              element: <none>
  topLevelVariables
    vInt
      firstFragment: <testLibraryFragment>::@topLevelVariable::vInt
      type: List<int>
      getter: <none>
      setter: <none>
    vDouble
      firstFragment: <testLibraryFragment>::@topLevelVariable::vDouble
      type: List<double>
      getter: <none>
      setter: <none>
    vIncInt
      firstFragment: <testLibraryFragment>::@topLevelVariable::vIncInt
      type: int
      getter: <none>
      setter: <none>
    vDecInt
      firstFragment: <testLibraryFragment>::@topLevelVariable::vDecInt::@def::0
      type: int
      getter: <none>
      setter: <none>
    vIncDouble
      firstFragment: <testLibraryFragment>::@topLevelVariable::vIncDouble
      type: double
      getter: <none>
      setter: <none>
    vDecInt
      firstFragment: <testLibraryFragment>::@topLevelVariable::vDecInt::@def::1
      type: double
      getter: <none>
      setter: <none>
  getters
    synthetic static get vInt
      firstFragment: <testLibraryFragment>::@getter::vInt
    synthetic static get vDouble
      firstFragment: <testLibraryFragment>::@getter::vDouble
    synthetic static get vIncInt
      firstFragment: <testLibraryFragment>::@getter::vIncInt
    synthetic static get vDecInt
      firstFragment: <testLibraryFragment>::@getter::vDecInt::@def::0
    synthetic static get vIncDouble
      firstFragment: <testLibraryFragment>::@getter::vIncDouble
    synthetic static get vDecInt
      firstFragment: <testLibraryFragment>::@getter::vDecInt::@def::1
  setters
    synthetic static set vInt=
      firstFragment: <testLibraryFragment>::@setter::vInt
      parameters
        requiredPositional _vInt
          type: List<int>
    synthetic static set vDouble=
      firstFragment: <testLibraryFragment>::@setter::vDouble
      parameters
        requiredPositional _vDouble
          type: List<double>
    synthetic static set vIncInt=
      firstFragment: <testLibraryFragment>::@setter::vIncInt
      parameters
        requiredPositional _vIncInt
          type: int
    synthetic static set vDecInt=
      firstFragment: <testLibraryFragment>::@setter::vDecInt::@def::0
      parameters
        requiredPositional _vDecInt
          type: int
    synthetic static set vIncDouble=
      firstFragment: <testLibraryFragment>::@setter::vIncDouble
      parameters
        requiredPositional _vIncDouble
          type: double
    synthetic static set vDecInt=
      firstFragment: <testLibraryFragment>::@setter::vDecInt::@def::1
      parameters
        requiredPositional _vDecInt
          type: double
''');
  }

  test_initializer_prefix_not() async {
    var library = await _encodeDecodeLibrary(r'''
var vNot = !true;
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      topLevelVariables
        static vNot @4
          reference: <testLibraryFragment>::@topLevelVariable::vNot
          enclosingElement3: <testLibraryFragment>
          type: bool
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get vNot @-1
          reference: <testLibraryFragment>::@getter::vNot
          enclosingElement3: <testLibraryFragment>
          returnType: bool
        synthetic static set vNot= @-1
          reference: <testLibraryFragment>::@setter::vNot
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vNot @-1
              type: bool
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      topLevelVariables
        vNot @4
          reference: <testLibraryFragment>::@topLevelVariable::vNot
          element: <none>
          getter2: <testLibraryFragment>::@getter::vNot
          setter2: <testLibraryFragment>::@setter::vNot
      getters
        get vNot @-1
          reference: <testLibraryFragment>::@getter::vNot
          element: <none>
      setters
        set vNot= @-1
          reference: <testLibraryFragment>::@setter::vNot
          element: <none>
          parameters
            _vNot @-1
              element: <none>
  topLevelVariables
    vNot
      firstFragment: <testLibraryFragment>::@topLevelVariable::vNot
      type: bool
      getter: <none>
      setter: <none>
  getters
    synthetic static get vNot
      firstFragment: <testLibraryFragment>::@getter::vNot
  setters
    synthetic static set vNot=
      firstFragment: <testLibraryFragment>::@setter::vNot
      parameters
        requiredPositional _vNot
          type: bool
''');
  }

  test_initializer_prefix_other() async {
    var library = await _encodeDecodeLibrary(r'''
var vNegateInt = -1;
var vNegateDouble = -1.0;
var vComplement = ~1;
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      topLevelVariables
        static vNegateInt @4
          reference: <testLibraryFragment>::@topLevelVariable::vNegateInt
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
        static vNegateDouble @25
          reference: <testLibraryFragment>::@topLevelVariable::vNegateDouble
          enclosingElement3: <testLibraryFragment>
          type: double
          shouldUseTypeForInitializerInference: false
        static vComplement @51
          reference: <testLibraryFragment>::@topLevelVariable::vComplement
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get vNegateInt @-1
          reference: <testLibraryFragment>::@getter::vNegateInt
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set vNegateInt= @-1
          reference: <testLibraryFragment>::@setter::vNegateInt
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vNegateInt @-1
              type: int
          returnType: void
        synthetic static get vNegateDouble @-1
          reference: <testLibraryFragment>::@getter::vNegateDouble
          enclosingElement3: <testLibraryFragment>
          returnType: double
        synthetic static set vNegateDouble= @-1
          reference: <testLibraryFragment>::@setter::vNegateDouble
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vNegateDouble @-1
              type: double
          returnType: void
        synthetic static get vComplement @-1
          reference: <testLibraryFragment>::@getter::vComplement
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set vComplement= @-1
          reference: <testLibraryFragment>::@setter::vComplement
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vComplement @-1
              type: int
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      topLevelVariables
        vNegateInt @4
          reference: <testLibraryFragment>::@topLevelVariable::vNegateInt
          element: <none>
          getter2: <testLibraryFragment>::@getter::vNegateInt
          setter2: <testLibraryFragment>::@setter::vNegateInt
        vNegateDouble @25
          reference: <testLibraryFragment>::@topLevelVariable::vNegateDouble
          element: <none>
          getter2: <testLibraryFragment>::@getter::vNegateDouble
          setter2: <testLibraryFragment>::@setter::vNegateDouble
        vComplement @51
          reference: <testLibraryFragment>::@topLevelVariable::vComplement
          element: <none>
          getter2: <testLibraryFragment>::@getter::vComplement
          setter2: <testLibraryFragment>::@setter::vComplement
      getters
        get vNegateInt @-1
          reference: <testLibraryFragment>::@getter::vNegateInt
          element: <none>
        get vNegateDouble @-1
          reference: <testLibraryFragment>::@getter::vNegateDouble
          element: <none>
        get vComplement @-1
          reference: <testLibraryFragment>::@getter::vComplement
          element: <none>
      setters
        set vNegateInt= @-1
          reference: <testLibraryFragment>::@setter::vNegateInt
          element: <none>
          parameters
            _vNegateInt @-1
              element: <none>
        set vNegateDouble= @-1
          reference: <testLibraryFragment>::@setter::vNegateDouble
          element: <none>
          parameters
            _vNegateDouble @-1
              element: <none>
        set vComplement= @-1
          reference: <testLibraryFragment>::@setter::vComplement
          element: <none>
          parameters
            _vComplement @-1
              element: <none>
  topLevelVariables
    vNegateInt
      firstFragment: <testLibraryFragment>::@topLevelVariable::vNegateInt
      type: int
      getter: <none>
      setter: <none>
    vNegateDouble
      firstFragment: <testLibraryFragment>::@topLevelVariable::vNegateDouble
      type: double
      getter: <none>
      setter: <none>
    vComplement
      firstFragment: <testLibraryFragment>::@topLevelVariable::vComplement
      type: int
      getter: <none>
      setter: <none>
  getters
    synthetic static get vNegateInt
      firstFragment: <testLibraryFragment>::@getter::vNegateInt
    synthetic static get vNegateDouble
      firstFragment: <testLibraryFragment>::@getter::vNegateDouble
    synthetic static get vComplement
      firstFragment: <testLibraryFragment>::@getter::vComplement
  setters
    synthetic static set vNegateInt=
      firstFragment: <testLibraryFragment>::@setter::vNegateInt
      parameters
        requiredPositional _vNegateInt
          type: int
    synthetic static set vNegateDouble=
      firstFragment: <testLibraryFragment>::@setter::vNegateDouble
      parameters
        requiredPositional _vNegateDouble
          type: double
    synthetic static set vComplement=
      firstFragment: <testLibraryFragment>::@setter::vComplement
      parameters
        requiredPositional _vComplement
          type: int
''');
  }

  test_initializer_referenceToFieldOfStaticField() async {
    var library = await _encodeDecodeLibrary(r'''
class C {
  static D d;
}
class D {
  int i;
}
final x = C.d.i;
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class C @6
          reference: <testLibraryFragment>::@class::C
          enclosingElement3: <testLibraryFragment>
          fields
            static d @21
              reference: <testLibraryFragment>::@class::C::@field::d
              enclosingElement3: <testLibraryFragment>::@class::C
              type: D
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::C
          accessors
            synthetic static get d @-1
              reference: <testLibraryFragment>::@class::C::@getter::d
              enclosingElement3: <testLibraryFragment>::@class::C
              returnType: D
            synthetic static set d= @-1
              reference: <testLibraryFragment>::@class::C::@setter::d
              enclosingElement3: <testLibraryFragment>::@class::C
              parameters
                requiredPositional _d @-1
                  type: D
              returnType: void
        class D @32
          reference: <testLibraryFragment>::@class::D
          enclosingElement3: <testLibraryFragment>
          fields
            i @42
              reference: <testLibraryFragment>::@class::D::@field::i
              enclosingElement3: <testLibraryFragment>::@class::D
              type: int
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::D::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::D
          accessors
            synthetic get i @-1
              reference: <testLibraryFragment>::@class::D::@getter::i
              enclosingElement3: <testLibraryFragment>::@class::D
              returnType: int
            synthetic set i= @-1
              reference: <testLibraryFragment>::@class::D::@setter::i
              enclosingElement3: <testLibraryFragment>::@class::D
              parameters
                requiredPositional _i @-1
                  type: int
              returnType: void
      topLevelVariables
        static final x @53
          reference: <testLibraryFragment>::@topLevelVariable::x
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get x @-1
          reference: <testLibraryFragment>::@getter::x
          enclosingElement3: <testLibraryFragment>
          returnType: int
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class C @6
          reference: <testLibraryFragment>::@class::C
          element: <testLibraryFragment>::@class::C
          fields
            d @21
              reference: <testLibraryFragment>::@class::C::@field::d
              element: <none>
              getter2: <testLibraryFragment>::@class::C::@getter::d
              setter2: <testLibraryFragment>::@class::C::@setter::d
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              element: <none>
          getters
            get d @-1
              reference: <testLibraryFragment>::@class::C::@getter::d
              element: <none>
          setters
            set d= @-1
              reference: <testLibraryFragment>::@class::C::@setter::d
              element: <none>
              parameters
                _d @-1
                  element: <none>
        class D @32
          reference: <testLibraryFragment>::@class::D
          element: <testLibraryFragment>::@class::D
          fields
            i @42
              reference: <testLibraryFragment>::@class::D::@field::i
              element: <none>
              getter2: <testLibraryFragment>::@class::D::@getter::i
              setter2: <testLibraryFragment>::@class::D::@setter::i
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::D::@constructor::new
              element: <none>
          getters
            get i @-1
              reference: <testLibraryFragment>::@class::D::@getter::i
              element: <none>
          setters
            set i= @-1
              reference: <testLibraryFragment>::@class::D::@setter::i
              element: <none>
              parameters
                _i @-1
                  element: <none>
      topLevelVariables
        final x @53
          reference: <testLibraryFragment>::@topLevelVariable::x
          element: <none>
          getter2: <testLibraryFragment>::@getter::x
      getters
        get x @-1
          reference: <testLibraryFragment>::@getter::x
          element: <none>
  classes
    class C
      firstFragment: <testLibraryFragment>::@class::C
      fields
        static d
          firstFragment: <testLibraryFragment>::@class::C::@field::d
          type: D
          getter: <none>
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::C::@constructor::new
      getters
        synthetic static get d
          firstFragment: <testLibraryFragment>::@class::C::@getter::d
      setters
        synthetic static set d=
          firstFragment: <testLibraryFragment>::@class::C::@setter::d
          parameters
            requiredPositional _d
              type: D
    class D
      firstFragment: <testLibraryFragment>::@class::D
      fields
        i
          firstFragment: <testLibraryFragment>::@class::D::@field::i
          type: int
          getter: <none>
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::D::@constructor::new
      getters
        synthetic get i
          firstFragment: <testLibraryFragment>::@class::D::@getter::i
      setters
        synthetic set i=
          firstFragment: <testLibraryFragment>::@class::D::@setter::i
          parameters
            requiredPositional _i
              type: int
  topLevelVariables
    final x
      firstFragment: <testLibraryFragment>::@topLevelVariable::x
      type: int
      getter: <none>
  getters
    synthetic static get x
      firstFragment: <testLibraryFragment>::@getter::x
''');
  }

  test_initializer_referenceToFieldOfStaticGetter() async {
    var library = await _encodeDecodeLibrary(r'''
class C {
  static D get d => null;
}
class D {
  int i;
}
var x = C.d.i;
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class C @6
          reference: <testLibraryFragment>::@class::C
          enclosingElement3: <testLibraryFragment>
          fields
            synthetic static d @-1
              reference: <testLibraryFragment>::@class::C::@field::d
              enclosingElement3: <testLibraryFragment>::@class::C
              type: D
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::C
          accessors
            static get d @25
              reference: <testLibraryFragment>::@class::C::@getter::d
              enclosingElement3: <testLibraryFragment>::@class::C
              returnType: D
        class D @44
          reference: <testLibraryFragment>::@class::D
          enclosingElement3: <testLibraryFragment>
          fields
            i @54
              reference: <testLibraryFragment>::@class::D::@field::i
              enclosingElement3: <testLibraryFragment>::@class::D
              type: int
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::D::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::D
          accessors
            synthetic get i @-1
              reference: <testLibraryFragment>::@class::D::@getter::i
              enclosingElement3: <testLibraryFragment>::@class::D
              returnType: int
            synthetic set i= @-1
              reference: <testLibraryFragment>::@class::D::@setter::i
              enclosingElement3: <testLibraryFragment>::@class::D
              parameters
                requiredPositional _i @-1
                  type: int
              returnType: void
      topLevelVariables
        static x @63
          reference: <testLibraryFragment>::@topLevelVariable::x
          enclosingElement3: <testLibraryFragment>
          type: int
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get x @-1
          reference: <testLibraryFragment>::@getter::x
          enclosingElement3: <testLibraryFragment>
          returnType: int
        synthetic static set x= @-1
          reference: <testLibraryFragment>::@setter::x
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _x @-1
              type: int
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class C @6
          reference: <testLibraryFragment>::@class::C
          element: <testLibraryFragment>::@class::C
          fields
            d @-1
              reference: <testLibraryFragment>::@class::C::@field::d
              element: <none>
              getter2: <testLibraryFragment>::@class::C::@getter::d
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              element: <none>
          getters
            get d @25
              reference: <testLibraryFragment>::@class::C::@getter::d
              element: <none>
        class D @44
          reference: <testLibraryFragment>::@class::D
          element: <testLibraryFragment>::@class::D
          fields
            i @54
              reference: <testLibraryFragment>::@class::D::@field::i
              element: <none>
              getter2: <testLibraryFragment>::@class::D::@getter::i
              setter2: <testLibraryFragment>::@class::D::@setter::i
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::D::@constructor::new
              element: <none>
          getters
            get i @-1
              reference: <testLibraryFragment>::@class::D::@getter::i
              element: <none>
          setters
            set i= @-1
              reference: <testLibraryFragment>::@class::D::@setter::i
              element: <none>
              parameters
                _i @-1
                  element: <none>
      topLevelVariables
        x @63
          reference: <testLibraryFragment>::@topLevelVariable::x
          element: <none>
          getter2: <testLibraryFragment>::@getter::x
          setter2: <testLibraryFragment>::@setter::x
      getters
        get x @-1
          reference: <testLibraryFragment>::@getter::x
          element: <none>
      setters
        set x= @-1
          reference: <testLibraryFragment>::@setter::x
          element: <none>
          parameters
            _x @-1
              element: <none>
  classes
    class C
      firstFragment: <testLibraryFragment>::@class::C
      fields
        synthetic static d
          firstFragment: <testLibraryFragment>::@class::C::@field::d
          type: D
          getter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::C::@constructor::new
      getters
        static get d
          firstFragment: <testLibraryFragment>::@class::C::@getter::d
    class D
      firstFragment: <testLibraryFragment>::@class::D
      fields
        i
          firstFragment: <testLibraryFragment>::@class::D::@field::i
          type: int
          getter: <none>
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::D::@constructor::new
      getters
        synthetic get i
          firstFragment: <testLibraryFragment>::@class::D::@getter::i
      setters
        synthetic set i=
          firstFragment: <testLibraryFragment>::@class::D::@setter::i
          parameters
            requiredPositional _i
              type: int
  topLevelVariables
    x
      firstFragment: <testLibraryFragment>::@topLevelVariable::x
      type: int
      getter: <none>
      setter: <none>
  getters
    synthetic static get x
      firstFragment: <testLibraryFragment>::@getter::x
  setters
    synthetic static set x=
      firstFragment: <testLibraryFragment>::@setter::x
      parameters
        requiredPositional _x
          type: int
''');
  }

  test_initializer_relational() async {
    var library = await _encodeDecodeLibrary(r'''
var vLess = 1 < 2;
var vLessOrEqual = 1 <= 2;
var vGreater = 1 > 2;
var vGreaterOrEqual = 1 >= 2;
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      topLevelVariables
        static vLess @4
          reference: <testLibraryFragment>::@topLevelVariable::vLess
          enclosingElement3: <testLibraryFragment>
          type: bool
          shouldUseTypeForInitializerInference: false
        static vLessOrEqual @23
          reference: <testLibraryFragment>::@topLevelVariable::vLessOrEqual
          enclosingElement3: <testLibraryFragment>
          type: bool
          shouldUseTypeForInitializerInference: false
        static vGreater @50
          reference: <testLibraryFragment>::@topLevelVariable::vGreater
          enclosingElement3: <testLibraryFragment>
          type: bool
          shouldUseTypeForInitializerInference: false
        static vGreaterOrEqual @72
          reference: <testLibraryFragment>::@topLevelVariable::vGreaterOrEqual
          enclosingElement3: <testLibraryFragment>
          type: bool
          shouldUseTypeForInitializerInference: false
      accessors
        synthetic static get vLess @-1
          reference: <testLibraryFragment>::@getter::vLess
          enclosingElement3: <testLibraryFragment>
          returnType: bool
        synthetic static set vLess= @-1
          reference: <testLibraryFragment>::@setter::vLess
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vLess @-1
              type: bool
          returnType: void
        synthetic static get vLessOrEqual @-1
          reference: <testLibraryFragment>::@getter::vLessOrEqual
          enclosingElement3: <testLibraryFragment>
          returnType: bool
        synthetic static set vLessOrEqual= @-1
          reference: <testLibraryFragment>::@setter::vLessOrEqual
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vLessOrEqual @-1
              type: bool
          returnType: void
        synthetic static get vGreater @-1
          reference: <testLibraryFragment>::@getter::vGreater
          enclosingElement3: <testLibraryFragment>
          returnType: bool
        synthetic static set vGreater= @-1
          reference: <testLibraryFragment>::@setter::vGreater
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vGreater @-1
              type: bool
          returnType: void
        synthetic static get vGreaterOrEqual @-1
          reference: <testLibraryFragment>::@getter::vGreaterOrEqual
          enclosingElement3: <testLibraryFragment>
          returnType: bool
        synthetic static set vGreaterOrEqual= @-1
          reference: <testLibraryFragment>::@setter::vGreaterOrEqual
          enclosingElement3: <testLibraryFragment>
          parameters
            requiredPositional _vGreaterOrEqual @-1
              type: bool
          returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      topLevelVariables
        vLess @4
          reference: <testLibraryFragment>::@topLevelVariable::vLess
          element: <none>
          getter2: <testLibraryFragment>::@getter::vLess
          setter2: <testLibraryFragment>::@setter::vLess
        vLessOrEqual @23
          reference: <testLibraryFragment>::@topLevelVariable::vLessOrEqual
          element: <none>
          getter2: <testLibraryFragment>::@getter::vLessOrEqual
          setter2: <testLibraryFragment>::@setter::vLessOrEqual
        vGreater @50
          reference: <testLibraryFragment>::@topLevelVariable::vGreater
          element: <none>
          getter2: <testLibraryFragment>::@getter::vGreater
          setter2: <testLibraryFragment>::@setter::vGreater
        vGreaterOrEqual @72
          reference: <testLibraryFragment>::@topLevelVariable::vGreaterOrEqual
          element: <none>
          getter2: <testLibraryFragment>::@getter::vGreaterOrEqual
          setter2: <testLibraryFragment>::@setter::vGreaterOrEqual
      getters
        get vLess @-1
          reference: <testLibraryFragment>::@getter::vLess
          element: <none>
        get vLessOrEqual @-1
          reference: <testLibraryFragment>::@getter::vLessOrEqual
          element: <none>
        get vGreater @-1
          reference: <testLibraryFragment>::@getter::vGreater
          element: <none>
        get vGreaterOrEqual @-1
          reference: <testLibraryFragment>::@getter::vGreaterOrEqual
          element: <none>
      setters
        set vLess= @-1
          reference: <testLibraryFragment>::@setter::vLess
          element: <none>
          parameters
            _vLess @-1
              element: <none>
        set vLessOrEqual= @-1
          reference: <testLibraryFragment>::@setter::vLessOrEqual
          element: <none>
          parameters
            _vLessOrEqual @-1
              element: <none>
        set vGreater= @-1
          reference: <testLibraryFragment>::@setter::vGreater
          element: <none>
          parameters
            _vGreater @-1
              element: <none>
        set vGreaterOrEqual= @-1
          reference: <testLibraryFragment>::@setter::vGreaterOrEqual
          element: <none>
          parameters
            _vGreaterOrEqual @-1
              element: <none>
  topLevelVariables
    vLess
      firstFragment: <testLibraryFragment>::@topLevelVariable::vLess
      type: bool
      getter: <none>
      setter: <none>
    vLessOrEqual
      firstFragment: <testLibraryFragment>::@topLevelVariable::vLessOrEqual
      type: bool
      getter: <none>
      setter: <none>
    vGreater
      firstFragment: <testLibraryFragment>::@topLevelVariable::vGreater
      type: bool
      getter: <none>
      setter: <none>
    vGreaterOrEqual
      firstFragment: <testLibraryFragment>::@topLevelVariable::vGreaterOrEqual
      type: bool
      getter: <none>
      setter: <none>
  getters
    synthetic static get vLess
      firstFragment: <testLibraryFragment>::@getter::vLess
    synthetic static get vLessOrEqual
      firstFragment: <testLibraryFragment>::@getter::vLessOrEqual
    synthetic static get vGreater
      firstFragment: <testLibraryFragment>::@getter::vGreater
    synthetic static get vGreaterOrEqual
      firstFragment: <testLibraryFragment>::@getter::vGreaterOrEqual
  setters
    synthetic static set vLess=
      firstFragment: <testLibraryFragment>::@setter::vLess
      parameters
        requiredPositional _vLess
          type: bool
    synthetic static set vLessOrEqual=
      firstFragment: <testLibraryFragment>::@setter::vLessOrEqual
      parameters
        requiredPositional _vLessOrEqual
          type: bool
    synthetic static set vGreater=
      firstFragment: <testLibraryFragment>::@setter::vGreater
      parameters
        requiredPositional _vGreater
          type: bool
    synthetic static set vGreaterOrEqual=
      firstFragment: <testLibraryFragment>::@setter::vGreaterOrEqual
      parameters
        requiredPositional _vGreaterOrEqual
          type: bool
''');
  }

  @skippedTest
  test_initializer_throw() async {
    var library = await _encodeDecodeLibrary(r'''
var V = throw 42;
''');
    checkElementText(library, r'''
Null V;
''');
  }

  test_instanceField_error_noSetterParameter() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  int x;
}
class B implements A {
  set x() {}
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        abstract class A @15
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          fields
            x @25
              reference: <testLibraryFragment>::@class::A::@field::x
              enclosingElement3: <testLibraryFragment>::@class::A
              type: int
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          accessors
            synthetic get x @-1
              reference: <testLibraryFragment>::@class::A::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: int
            synthetic set x= @-1
              reference: <testLibraryFragment>::@class::A::@setter::x
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional _x @-1
                  type: int
              returnType: void
        class B @36
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          interfaces
            A
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::B::@field::x
              enclosingElement3: <testLibraryFragment>::@class::B
              type: dynamic
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
          accessors
            set x= @59
              reference: <testLibraryFragment>::@class::B::@setter::x
              enclosingElement3: <testLibraryFragment>::@class::B
              returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @15
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          fields
            x @25
              reference: <testLibraryFragment>::@class::A::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::x
              setter2: <testLibraryFragment>::@class::A::@setter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          getters
            get x @-1
              reference: <testLibraryFragment>::@class::A::@getter::x
              element: <none>
          setters
            set x= @-1
              reference: <testLibraryFragment>::@class::A::@setter::x
              element: <none>
              parameters
                _x @-1
                  element: <none>
        class B @36
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          fields
            x @-1
              reference: <testLibraryFragment>::@class::B::@field::x
              element: <none>
              setter2: <testLibraryFragment>::@class::B::@setter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
          setters
            set x= @59
              reference: <testLibraryFragment>::@class::B::@setter::x
              element: <none>
  classes
    abstract class A
      firstFragment: <testLibraryFragment>::@class::A
      fields
        x
          firstFragment: <testLibraryFragment>::@class::A::@field::x
          type: int
          getter: <none>
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      getters
        synthetic get x
          firstFragment: <testLibraryFragment>::@class::A::@getter::x
      setters
        synthetic set x=
          firstFragment: <testLibraryFragment>::@class::A::@setter::x
          parameters
            requiredPositional _x
              type: int
    class B
      firstFragment: <testLibraryFragment>::@class::B
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::B::@field::x
          type: dynamic
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
      setters
        set x=
          firstFragment: <testLibraryFragment>::@class::B::@setter::x
''');
  }

  test_instanceField_fieldFormal() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  var f = 0;
  A([this.f = 'hello']);
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          fields
            f @16
              reference: <testLibraryFragment>::@class::A::@field::f
              enclosingElement3: <testLibraryFragment>::@class::A
              type: int
              shouldUseTypeForInitializerInference: false
          constructors
            @25
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                optionalPositional default final this.f @33
                  type: int
                  constantInitializer
                    SimpleStringLiteral
                      literal: 'hello' @37
                  field: <testLibraryFragment>::@class::A::@field::f
          accessors
            synthetic get f @-1
              reference: <testLibraryFragment>::@class::A::@getter::f
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: int
            synthetic set f= @-1
              reference: <testLibraryFragment>::@class::A::@setter::f
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional _f @-1
                  type: int
              returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          fields
            f @16
              reference: <testLibraryFragment>::@class::A::@field::f
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::f
              setter2: <testLibraryFragment>::@class::A::@setter::f
          constructors
            new @25
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
              parameters
                default this.f @33
                  element: <none>
          getters
            get f @-1
              reference: <testLibraryFragment>::@class::A::@getter::f
              element: <none>
          setters
            set f= @-1
              reference: <testLibraryFragment>::@class::A::@setter::f
              element: <none>
              parameters
                _f @-1
                  element: <none>
  classes
    class A
      firstFragment: <testLibraryFragment>::@class::A
      fields
        f
          firstFragment: <testLibraryFragment>::@class::A::@field::f
          type: int
          getter: <none>
          setter: <none>
      constructors
        new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
          parameters
            optionalPositional final f
              type: int
      getters
        synthetic get f
          firstFragment: <testLibraryFragment>::@class::A::@getter::f
      setters
        synthetic set f=
          firstFragment: <testLibraryFragment>::@class::A::@setter::f
          parameters
            requiredPositional _f
              type: int
''');
  }

  test_instanceField_fromField() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  int x;
  int y;
  int z;
}
class B implements A {
  var x;
  get y => null;
  set z(_) {}
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        abstract class A @15
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          fields
            x @25
              reference: <testLibraryFragment>::@class::A::@field::x
              enclosingElement3: <testLibraryFragment>::@class::A
              type: int
            y @34
              reference: <testLibraryFragment>::@class::A::@field::y
              enclosingElement3: <testLibraryFragment>::@class::A
              type: int
            z @43
              reference: <testLibraryFragment>::@class::A::@field::z
              enclosingElement3: <testLibraryFragment>::@class::A
              type: int
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          accessors
            synthetic get x @-1
              reference: <testLibraryFragment>::@class::A::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: int
            synthetic set x= @-1
              reference: <testLibraryFragment>::@class::A::@setter::x
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional _x @-1
                  type: int
              returnType: void
            synthetic get y @-1
              reference: <testLibraryFragment>::@class::A::@getter::y
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: int
            synthetic set y= @-1
              reference: <testLibraryFragment>::@class::A::@setter::y
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional _y @-1
                  type: int
              returnType: void
            synthetic get z @-1
              reference: <testLibraryFragment>::@class::A::@getter::z
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: int
            synthetic set z= @-1
              reference: <testLibraryFragment>::@class::A::@setter::z
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional _z @-1
                  type: int
              returnType: void
        class B @54
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          interfaces
            A
          fields
            x @77
              reference: <testLibraryFragment>::@class::B::@field::x
              enclosingElement3: <testLibraryFragment>::@class::B
              type: int
            synthetic y @-1
              reference: <testLibraryFragment>::@class::B::@field::y
              enclosingElement3: <testLibraryFragment>::@class::B
              type: int
            synthetic z @-1
              reference: <testLibraryFragment>::@class::B::@field::z
              enclosingElement3: <testLibraryFragment>::@class::B
              type: int
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
          accessors
            synthetic get x @-1
              reference: <testLibraryFragment>::@class::B::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::B
              returnType: int
            synthetic set x= @-1
              reference: <testLibraryFragment>::@class::B::@setter::x
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional _x @-1
                  type: int
              returnType: void
            get y @86
              reference: <testLibraryFragment>::@class::B::@getter::y
              enclosingElement3: <testLibraryFragment>::@class::B
              returnType: int
            set z= @103
              reference: <testLibraryFragment>::@class::B::@setter::z
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional _ @105
                  type: int
              returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @15
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          fields
            x @25
              reference: <testLibraryFragment>::@class::A::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::x
              setter2: <testLibraryFragment>::@class::A::@setter::x
            y @34
              reference: <testLibraryFragment>::@class::A::@field::y
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::y
              setter2: <testLibraryFragment>::@class::A::@setter::y
            z @43
              reference: <testLibraryFragment>::@class::A::@field::z
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::z
              setter2: <testLibraryFragment>::@class::A::@setter::z
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          getters
            get x @-1
              reference: <testLibraryFragment>::@class::A::@getter::x
              element: <none>
            get y @-1
              reference: <testLibraryFragment>::@class::A::@getter::y
              element: <none>
            get z @-1
              reference: <testLibraryFragment>::@class::A::@getter::z
              element: <none>
          setters
            set x= @-1
              reference: <testLibraryFragment>::@class::A::@setter::x
              element: <none>
              parameters
                _x @-1
                  element: <none>
            set y= @-1
              reference: <testLibraryFragment>::@class::A::@setter::y
              element: <none>
              parameters
                _y @-1
                  element: <none>
            set z= @-1
              reference: <testLibraryFragment>::@class::A::@setter::z
              element: <none>
              parameters
                _z @-1
                  element: <none>
        class B @54
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          fields
            x @77
              reference: <testLibraryFragment>::@class::B::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::B::@getter::x
              setter2: <testLibraryFragment>::@class::B::@setter::x
            y @-1
              reference: <testLibraryFragment>::@class::B::@field::y
              element: <none>
              getter2: <testLibraryFragment>::@class::B::@getter::y
            z @-1
              reference: <testLibraryFragment>::@class::B::@field::z
              element: <none>
              setter2: <testLibraryFragment>::@class::B::@setter::z
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
          getters
            get x @-1
              reference: <testLibraryFragment>::@class::B::@getter::x
              element: <none>
            get y @86
              reference: <testLibraryFragment>::@class::B::@getter::y
              element: <none>
          setters
            set x= @-1
              reference: <testLibraryFragment>::@class::B::@setter::x
              element: <none>
              parameters
                _x @-1
                  element: <none>
            set z= @103
              reference: <testLibraryFragment>::@class::B::@setter::z
              element: <none>
              parameters
                _ @105
                  element: <none>
  classes
    abstract class A
      firstFragment: <testLibraryFragment>::@class::A
      fields
        x
          firstFragment: <testLibraryFragment>::@class::A::@field::x
          type: int
          getter: <none>
          setter: <none>
        y
          firstFragment: <testLibraryFragment>::@class::A::@field::y
          type: int
          getter: <none>
          setter: <none>
        z
          firstFragment: <testLibraryFragment>::@class::A::@field::z
          type: int
          getter: <none>
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      getters
        synthetic get x
          firstFragment: <testLibraryFragment>::@class::A::@getter::x
        synthetic get y
          firstFragment: <testLibraryFragment>::@class::A::@getter::y
        synthetic get z
          firstFragment: <testLibraryFragment>::@class::A::@getter::z
      setters
        synthetic set x=
          firstFragment: <testLibraryFragment>::@class::A::@setter::x
          parameters
            requiredPositional _x
              type: int
        synthetic set y=
          firstFragment: <testLibraryFragment>::@class::A::@setter::y
          parameters
            requiredPositional _y
              type: int
        synthetic set z=
          firstFragment: <testLibraryFragment>::@class::A::@setter::z
          parameters
            requiredPositional _z
              type: int
    class B
      firstFragment: <testLibraryFragment>::@class::B
      fields
        x
          firstFragment: <testLibraryFragment>::@class::B::@field::x
          type: int
          getter: <none>
          setter: <none>
        synthetic y
          firstFragment: <testLibraryFragment>::@class::B::@field::y
          type: int
          getter: <none>
        synthetic z
          firstFragment: <testLibraryFragment>::@class::B::@field::z
          type: int
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
      getters
        synthetic get x
          firstFragment: <testLibraryFragment>::@class::B::@getter::x
        get y
          firstFragment: <testLibraryFragment>::@class::B::@getter::y
      setters
        synthetic set x=
          firstFragment: <testLibraryFragment>::@class::B::@setter::x
          parameters
            requiredPositional _x
              type: int
        set z=
          firstFragment: <testLibraryFragment>::@class::B::@setter::z
          parameters
            requiredPositional _
              type: int
''');
  }

  test_instanceField_fromField_explicitDynamic() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  dynamic x;
}
class B implements A {
  var x = 1;
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        abstract class A @15
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          fields
            x @29
              reference: <testLibraryFragment>::@class::A::@field::x
              enclosingElement3: <testLibraryFragment>::@class::A
              type: dynamic
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          accessors
            synthetic get x @-1
              reference: <testLibraryFragment>::@class::A::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: dynamic
            synthetic set x= @-1
              reference: <testLibraryFragment>::@class::A::@setter::x
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional _x @-1
                  type: dynamic
              returnType: void
        class B @40
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          interfaces
            A
          fields
            x @63
              reference: <testLibraryFragment>::@class::B::@field::x
              enclosingElement3: <testLibraryFragment>::@class::B
              type: dynamic
              shouldUseTypeForInitializerInference: true
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
          accessors
            synthetic get x @-1
              reference: <testLibraryFragment>::@class::B::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::B
              returnType: dynamic
            synthetic set x= @-1
              reference: <testLibraryFragment>::@class::B::@setter::x
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional _x @-1
                  type: dynamic
              returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @15
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          fields
            x @29
              reference: <testLibraryFragment>::@class::A::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::x
              setter2: <testLibraryFragment>::@class::A::@setter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          getters
            get x @-1
              reference: <testLibraryFragment>::@class::A::@getter::x
              element: <none>
          setters
            set x= @-1
              reference: <testLibraryFragment>::@class::A::@setter::x
              element: <none>
              parameters
                _x @-1
                  element: <none>
        class B @40
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          fields
            x @63
              reference: <testLibraryFragment>::@class::B::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::B::@getter::x
              setter2: <testLibraryFragment>::@class::B::@setter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
          getters
            get x @-1
              reference: <testLibraryFragment>::@class::B::@getter::x
              element: <none>
          setters
            set x= @-1
              reference: <testLibraryFragment>::@class::B::@setter::x
              element: <none>
              parameters
                _x @-1
                  element: <none>
  classes
    abstract class A
      firstFragment: <testLibraryFragment>::@class::A
      fields
        x
          firstFragment: <testLibraryFragment>::@class::A::@field::x
          type: dynamic
          getter: <none>
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      getters
        synthetic get x
          firstFragment: <testLibraryFragment>::@class::A::@getter::x
      setters
        synthetic set x=
          firstFragment: <testLibraryFragment>::@class::A::@setter::x
          parameters
            requiredPositional _x
              type: dynamic
    class B
      firstFragment: <testLibraryFragment>::@class::B
      fields
        x
          firstFragment: <testLibraryFragment>::@class::B::@field::x
          type: dynamic
          getter: <none>
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
      getters
        synthetic get x
          firstFragment: <testLibraryFragment>::@class::B::@getter::x
      setters
        synthetic set x=
          firstFragment: <testLibraryFragment>::@class::B::@setter::x
          parameters
            requiredPositional _x
              type: dynamic
''');
  }

  test_instanceField_fromField_generic() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A<E> {
  E x;
  E y;
  E z;
}
class B<T> implements A<T> {
  var x;
  get y => null;
  set z(_) {}
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        abstract class A @15
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          typeParameters
            covariant E @17
              defaultType: dynamic
          fields
            x @26
              reference: <testLibraryFragment>::@class::A::@field::x
              enclosingElement3: <testLibraryFragment>::@class::A
              type: E
            y @33
              reference: <testLibraryFragment>::@class::A::@field::y
              enclosingElement3: <testLibraryFragment>::@class::A
              type: E
            z @40
              reference: <testLibraryFragment>::@class::A::@field::z
              enclosingElement3: <testLibraryFragment>::@class::A
              type: E
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          accessors
            synthetic get x @-1
              reference: <testLibraryFragment>::@class::A::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: E
            synthetic set x= @-1
              reference: <testLibraryFragment>::@class::A::@setter::x
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional _x @-1
                  type: E
              returnType: void
            synthetic get y @-1
              reference: <testLibraryFragment>::@class::A::@getter::y
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: E
            synthetic set y= @-1
              reference: <testLibraryFragment>::@class::A::@setter::y
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional _y @-1
                  type: E
              returnType: void
            synthetic get z @-1
              reference: <testLibraryFragment>::@class::A::@getter::z
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: E
            synthetic set z= @-1
              reference: <testLibraryFragment>::@class::A::@setter::z
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional _z @-1
                  type: E
              returnType: void
        class B @51
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          typeParameters
            covariant T @53
              defaultType: dynamic
          interfaces
            A<T>
          fields
            x @80
              reference: <testLibraryFragment>::@class::B::@field::x
              enclosingElement3: <testLibraryFragment>::@class::B
              type: T
            synthetic y @-1
              reference: <testLibraryFragment>::@class::B::@field::y
              enclosingElement3: <testLibraryFragment>::@class::B
              type: T
            synthetic z @-1
              reference: <testLibraryFragment>::@class::B::@field::z
              enclosingElement3: <testLibraryFragment>::@class::B
              type: T
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
          accessors
            synthetic get x @-1
              reference: <testLibraryFragment>::@class::B::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::B
              returnType: T
            synthetic set x= @-1
              reference: <testLibraryFragment>::@class::B::@setter::x
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional _x @-1
                  type: T
              returnType: void
            get y @89
              reference: <testLibraryFragment>::@class::B::@getter::y
              enclosingElement3: <testLibraryFragment>::@class::B
              returnType: T
            set z= @106
              reference: <testLibraryFragment>::@class::B::@setter::z
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional _ @108
                  type: T
              returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @15
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          typeParameters
            E @17
              element: <none>
          fields
            x @26
              reference: <testLibraryFragment>::@class::A::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::x
              setter2: <testLibraryFragment>::@class::A::@setter::x
            y @33
              reference: <testLibraryFragment>::@class::A::@field::y
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::y
              setter2: <testLibraryFragment>::@class::A::@setter::y
            z @40
              reference: <testLibraryFragment>::@class::A::@field::z
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::z
              setter2: <testLibraryFragment>::@class::A::@setter::z
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          getters
            get x @-1
              reference: <testLibraryFragment>::@class::A::@getter::x
              element: <none>
            get y @-1
              reference: <testLibraryFragment>::@class::A::@getter::y
              element: <none>
            get z @-1
              reference: <testLibraryFragment>::@class::A::@getter::z
              element: <none>
          setters
            set x= @-1
              reference: <testLibraryFragment>::@class::A::@setter::x
              element: <none>
              parameters
                _x @-1
                  element: <none>
            set y= @-1
              reference: <testLibraryFragment>::@class::A::@setter::y
              element: <none>
              parameters
                _y @-1
                  element: <none>
            set z= @-1
              reference: <testLibraryFragment>::@class::A::@setter::z
              element: <none>
              parameters
                _z @-1
                  element: <none>
        class B @51
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          typeParameters
            T @53
              element: <none>
          fields
            x @80
              reference: <testLibraryFragment>::@class::B::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::B::@getter::x
              setter2: <testLibraryFragment>::@class::B::@setter::x
            y @-1
              reference: <testLibraryFragment>::@class::B::@field::y
              element: <none>
              getter2: <testLibraryFragment>::@class::B::@getter::y
            z @-1
              reference: <testLibraryFragment>::@class::B::@field::z
              element: <none>
              setter2: <testLibraryFragment>::@class::B::@setter::z
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
          getters
            get x @-1
              reference: <testLibraryFragment>::@class::B::@getter::x
              element: <none>
            get y @89
              reference: <testLibraryFragment>::@class::B::@getter::y
              element: <none>
          setters
            set x= @-1
              reference: <testLibraryFragment>::@class::B::@setter::x
              element: <none>
              parameters
                _x @-1
                  element: <none>
            set z= @106
              reference: <testLibraryFragment>::@class::B::@setter::z
              element: <none>
              parameters
                _ @108
                  element: <none>
  classes
    abstract class A
      firstFragment: <testLibraryFragment>::@class::A
      typeParameters
        E
      fields
        x
          firstFragment: <testLibraryFragment>::@class::A::@field::x
          type: E
          getter: <none>
          setter: <none>
        y
          firstFragment: <testLibraryFragment>::@class::A::@field::y
          type: E
          getter: <none>
          setter: <none>
        z
          firstFragment: <testLibraryFragment>::@class::A::@field::z
          type: E
          getter: <none>
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      getters
        synthetic get x
          firstFragment: <testLibraryFragment>::@class::A::@getter::x
        synthetic get y
          firstFragment: <testLibraryFragment>::@class::A::@getter::y
        synthetic get z
          firstFragment: <testLibraryFragment>::@class::A::@getter::z
      setters
        synthetic set x=
          firstFragment: <testLibraryFragment>::@class::A::@setter::x
          parameters
            requiredPositional _x
              type: E
        synthetic set y=
          firstFragment: <testLibraryFragment>::@class::A::@setter::y
          parameters
            requiredPositional _y
              type: E
        synthetic set z=
          firstFragment: <testLibraryFragment>::@class::A::@setter::z
          parameters
            requiredPositional _z
              type: E
    class B
      firstFragment: <testLibraryFragment>::@class::B
      typeParameters
        T
      fields
        x
          firstFragment: <testLibraryFragment>::@class::B::@field::x
          type: T
          getter: <none>
          setter: <none>
        synthetic y
          firstFragment: <testLibraryFragment>::@class::B::@field::y
          type: T
          getter: <none>
        synthetic z
          firstFragment: <testLibraryFragment>::@class::B::@field::z
          type: T
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
      getters
        synthetic get x
          firstFragment: <testLibraryFragment>::@class::B::@getter::x
        get y
          firstFragment: <testLibraryFragment>::@class::B::@getter::y
      setters
        synthetic set x=
          firstFragment: <testLibraryFragment>::@class::B::@setter::x
          parameters
            requiredPositional _x
              type: T
        set z=
          firstFragment: <testLibraryFragment>::@class::B::@setter::z
          parameters
            requiredPositional _
              type: T
''');
  }

  test_instanceField_fromField_implicitDynamic() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  var x;
}
class B implements A {
  var x = 1;
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        abstract class A @15
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          fields
            x @25
              reference: <testLibraryFragment>::@class::A::@field::x
              enclosingElement3: <testLibraryFragment>::@class::A
              type: dynamic
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          accessors
            synthetic get x @-1
              reference: <testLibraryFragment>::@class::A::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: dynamic
            synthetic set x= @-1
              reference: <testLibraryFragment>::@class::A::@setter::x
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional _x @-1
                  type: dynamic
              returnType: void
        class B @36
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          interfaces
            A
          fields
            x @59
              reference: <testLibraryFragment>::@class::B::@field::x
              enclosingElement3: <testLibraryFragment>::@class::B
              type: dynamic
              shouldUseTypeForInitializerInference: true
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
          accessors
            synthetic get x @-1
              reference: <testLibraryFragment>::@class::B::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::B
              returnType: dynamic
            synthetic set x= @-1
              reference: <testLibraryFragment>::@class::B::@setter::x
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional _x @-1
                  type: dynamic
              returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @15
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          fields
            x @25
              reference: <testLibraryFragment>::@class::A::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::x
              setter2: <testLibraryFragment>::@class::A::@setter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          getters
            get x @-1
              reference: <testLibraryFragment>::@class::A::@getter::x
              element: <none>
          setters
            set x= @-1
              reference: <testLibraryFragment>::@class::A::@setter::x
              element: <none>
              parameters
                _x @-1
                  element: <none>
        class B @36
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          fields
            x @59
              reference: <testLibraryFragment>::@class::B::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::B::@getter::x
              setter2: <testLibraryFragment>::@class::B::@setter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
          getters
            get x @-1
              reference: <testLibraryFragment>::@class::B::@getter::x
              element: <none>
          setters
            set x= @-1
              reference: <testLibraryFragment>::@class::B::@setter::x
              element: <none>
              parameters
                _x @-1
                  element: <none>
  classes
    abstract class A
      firstFragment: <testLibraryFragment>::@class::A
      fields
        x
          firstFragment: <testLibraryFragment>::@class::A::@field::x
          type: dynamic
          getter: <none>
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      getters
        synthetic get x
          firstFragment: <testLibraryFragment>::@class::A::@getter::x
      setters
        synthetic set x=
          firstFragment: <testLibraryFragment>::@class::A::@setter::x
          parameters
            requiredPositional _x
              type: dynamic
    class B
      firstFragment: <testLibraryFragment>::@class::B
      fields
        x
          firstFragment: <testLibraryFragment>::@class::B::@field::x
          type: dynamic
          getter: <none>
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
      getters
        synthetic get x
          firstFragment: <testLibraryFragment>::@class::B::@getter::x
      setters
        synthetic set x=
          firstFragment: <testLibraryFragment>::@class::B::@setter::x
          parameters
            requiredPositional _x
              type: dynamic
''');
  }

  test_instanceField_fromField_narrowType() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  num x;
}
class B implements A {
  var x = 1;
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        abstract class A @15
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          fields
            x @25
              reference: <testLibraryFragment>::@class::A::@field::x
              enclosingElement3: <testLibraryFragment>::@class::A
              type: num
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          accessors
            synthetic get x @-1
              reference: <testLibraryFragment>::@class::A::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: num
            synthetic set x= @-1
              reference: <testLibraryFragment>::@class::A::@setter::x
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional _x @-1
                  type: num
              returnType: void
        class B @36
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          interfaces
            A
          fields
            x @59
              reference: <testLibraryFragment>::@class::B::@field::x
              enclosingElement3: <testLibraryFragment>::@class::B
              type: num
              shouldUseTypeForInitializerInference: true
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
          accessors
            synthetic get x @-1
              reference: <testLibraryFragment>::@class::B::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::B
              returnType: num
            synthetic set x= @-1
              reference: <testLibraryFragment>::@class::B::@setter::x
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional _x @-1
                  type: num
              returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @15
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          fields
            x @25
              reference: <testLibraryFragment>::@class::A::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::x
              setter2: <testLibraryFragment>::@class::A::@setter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          getters
            get x @-1
              reference: <testLibraryFragment>::@class::A::@getter::x
              element: <none>
          setters
            set x= @-1
              reference: <testLibraryFragment>::@class::A::@setter::x
              element: <none>
              parameters
                _x @-1
                  element: <none>
        class B @36
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          fields
            x @59
              reference: <testLibraryFragment>::@class::B::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::B::@getter::x
              setter2: <testLibraryFragment>::@class::B::@setter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
          getters
            get x @-1
              reference: <testLibraryFragment>::@class::B::@getter::x
              element: <none>
          setters
            set x= @-1
              reference: <testLibraryFragment>::@class::B::@setter::x
              element: <none>
              parameters
                _x @-1
                  element: <none>
  classes
    abstract class A
      firstFragment: <testLibraryFragment>::@class::A
      fields
        x
          firstFragment: <testLibraryFragment>::@class::A::@field::x
          type: num
          getter: <none>
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      getters
        synthetic get x
          firstFragment: <testLibraryFragment>::@class::A::@getter::x
      setters
        synthetic set x=
          firstFragment: <testLibraryFragment>::@class::A::@setter::x
          parameters
            requiredPositional _x
              type: num
    class B
      firstFragment: <testLibraryFragment>::@class::B
      fields
        x
          firstFragment: <testLibraryFragment>::@class::B::@field::x
          type: num
          getter: <none>
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
      getters
        synthetic get x
          firstFragment: <testLibraryFragment>::@class::B::@getter::x
      setters
        synthetic set x=
          firstFragment: <testLibraryFragment>::@class::B::@setter::x
          parameters
            requiredPositional _x
              type: num
''');
  }

  test_instanceField_fromGetter() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  int get x;
  int get y;
  int get z;
}
class B implements A {
  var x;
  get y => null;
  set z(_) {}
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        abstract class A @15
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::A::@field::x
              enclosingElement3: <testLibraryFragment>::@class::A
              type: int
            synthetic y @-1
              reference: <testLibraryFragment>::@class::A::@field::y
              enclosingElement3: <testLibraryFragment>::@class::A
              type: int
            synthetic z @-1
              reference: <testLibraryFragment>::@class::A::@field::z
              enclosingElement3: <testLibraryFragment>::@class::A
              type: int
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          accessors
            abstract get x @29
              reference: <testLibraryFragment>::@class::A::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: int
            abstract get y @42
              reference: <testLibraryFragment>::@class::A::@getter::y
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: int
            abstract get z @55
              reference: <testLibraryFragment>::@class::A::@getter::z
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: int
        class B @66
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          interfaces
            A
          fields
            x @89
              reference: <testLibraryFragment>::@class::B::@field::x
              enclosingElement3: <testLibraryFragment>::@class::B
              type: int
            synthetic y @-1
              reference: <testLibraryFragment>::@class::B::@field::y
              enclosingElement3: <testLibraryFragment>::@class::B
              type: int
            synthetic z @-1
              reference: <testLibraryFragment>::@class::B::@field::z
              enclosingElement3: <testLibraryFragment>::@class::B
              type: int
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
          accessors
            synthetic get x @-1
              reference: <testLibraryFragment>::@class::B::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::B
              returnType: int
            synthetic set x= @-1
              reference: <testLibraryFragment>::@class::B::@setter::x
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional _x @-1
                  type: int
              returnType: void
            get y @98
              reference: <testLibraryFragment>::@class::B::@getter::y
              enclosingElement3: <testLibraryFragment>::@class::B
              returnType: int
            set z= @115
              reference: <testLibraryFragment>::@class::B::@setter::z
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional _ @117
                  type: int
              returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @15
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          fields
            x @-1
              reference: <testLibraryFragment>::@class::A::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::x
            y @-1
              reference: <testLibraryFragment>::@class::A::@field::y
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::y
            z @-1
              reference: <testLibraryFragment>::@class::A::@field::z
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::z
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          getters
            get x @29
              reference: <testLibraryFragment>::@class::A::@getter::x
              element: <none>
            get y @42
              reference: <testLibraryFragment>::@class::A::@getter::y
              element: <none>
            get z @55
              reference: <testLibraryFragment>::@class::A::@getter::z
              element: <none>
        class B @66
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          fields
            x @89
              reference: <testLibraryFragment>::@class::B::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::B::@getter::x
              setter2: <testLibraryFragment>::@class::B::@setter::x
            y @-1
              reference: <testLibraryFragment>::@class::B::@field::y
              element: <none>
              getter2: <testLibraryFragment>::@class::B::@getter::y
            z @-1
              reference: <testLibraryFragment>::@class::B::@field::z
              element: <none>
              setter2: <testLibraryFragment>::@class::B::@setter::z
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
          getters
            get x @-1
              reference: <testLibraryFragment>::@class::B::@getter::x
              element: <none>
            get y @98
              reference: <testLibraryFragment>::@class::B::@getter::y
              element: <none>
          setters
            set x= @-1
              reference: <testLibraryFragment>::@class::B::@setter::x
              element: <none>
              parameters
                _x @-1
                  element: <none>
            set z= @115
              reference: <testLibraryFragment>::@class::B::@setter::z
              element: <none>
              parameters
                _ @117
                  element: <none>
  classes
    abstract class A
      firstFragment: <testLibraryFragment>::@class::A
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::A::@field::x
          type: int
          getter: <none>
        synthetic y
          firstFragment: <testLibraryFragment>::@class::A::@field::y
          type: int
          getter: <none>
        synthetic z
          firstFragment: <testLibraryFragment>::@class::A::@field::z
          type: int
          getter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      getters
        abstract get x
          firstFragment: <testLibraryFragment>::@class::A::@getter::x
        abstract get y
          firstFragment: <testLibraryFragment>::@class::A::@getter::y
        abstract get z
          firstFragment: <testLibraryFragment>::@class::A::@getter::z
    class B
      firstFragment: <testLibraryFragment>::@class::B
      fields
        x
          firstFragment: <testLibraryFragment>::@class::B::@field::x
          type: int
          getter: <none>
          setter: <none>
        synthetic y
          firstFragment: <testLibraryFragment>::@class::B::@field::y
          type: int
          getter: <none>
        synthetic z
          firstFragment: <testLibraryFragment>::@class::B::@field::z
          type: int
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
      getters
        synthetic get x
          firstFragment: <testLibraryFragment>::@class::B::@getter::x
        get y
          firstFragment: <testLibraryFragment>::@class::B::@getter::y
      setters
        synthetic set x=
          firstFragment: <testLibraryFragment>::@class::B::@setter::x
          parameters
            requiredPositional _x
              type: int
        set z=
          firstFragment: <testLibraryFragment>::@class::B::@setter::z
          parameters
            requiredPositional _
              type: int
''');
  }

  test_instanceField_fromGetter_generic() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A<E> {
  E get x;
  E get y;
  E get z;
}
class B<T> implements A<T> {
  var x;
  get y => null;
  set z(_) {}
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        abstract class A @15
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          typeParameters
            covariant E @17
              defaultType: dynamic
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::A::@field::x
              enclosingElement3: <testLibraryFragment>::@class::A
              type: E
            synthetic y @-1
              reference: <testLibraryFragment>::@class::A::@field::y
              enclosingElement3: <testLibraryFragment>::@class::A
              type: E
            synthetic z @-1
              reference: <testLibraryFragment>::@class::A::@field::z
              enclosingElement3: <testLibraryFragment>::@class::A
              type: E
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          accessors
            abstract get x @30
              reference: <testLibraryFragment>::@class::A::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: E
            abstract get y @41
              reference: <testLibraryFragment>::@class::A::@getter::y
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: E
            abstract get z @52
              reference: <testLibraryFragment>::@class::A::@getter::z
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: E
        class B @63
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          typeParameters
            covariant T @65
              defaultType: dynamic
          interfaces
            A<T>
          fields
            x @92
              reference: <testLibraryFragment>::@class::B::@field::x
              enclosingElement3: <testLibraryFragment>::@class::B
              type: T
            synthetic y @-1
              reference: <testLibraryFragment>::@class::B::@field::y
              enclosingElement3: <testLibraryFragment>::@class::B
              type: T
            synthetic z @-1
              reference: <testLibraryFragment>::@class::B::@field::z
              enclosingElement3: <testLibraryFragment>::@class::B
              type: T
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
          accessors
            synthetic get x @-1
              reference: <testLibraryFragment>::@class::B::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::B
              returnType: T
            synthetic set x= @-1
              reference: <testLibraryFragment>::@class::B::@setter::x
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional _x @-1
                  type: T
              returnType: void
            get y @101
              reference: <testLibraryFragment>::@class::B::@getter::y
              enclosingElement3: <testLibraryFragment>::@class::B
              returnType: T
            set z= @118
              reference: <testLibraryFragment>::@class::B::@setter::z
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional _ @120
                  type: T
              returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @15
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          typeParameters
            E @17
              element: <none>
          fields
            x @-1
              reference: <testLibraryFragment>::@class::A::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::x
            y @-1
              reference: <testLibraryFragment>::@class::A::@field::y
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::y
            z @-1
              reference: <testLibraryFragment>::@class::A::@field::z
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::z
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          getters
            get x @30
              reference: <testLibraryFragment>::@class::A::@getter::x
              element: <none>
            get y @41
              reference: <testLibraryFragment>::@class::A::@getter::y
              element: <none>
            get z @52
              reference: <testLibraryFragment>::@class::A::@getter::z
              element: <none>
        class B @63
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          typeParameters
            T @65
              element: <none>
          fields
            x @92
              reference: <testLibraryFragment>::@class::B::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::B::@getter::x
              setter2: <testLibraryFragment>::@class::B::@setter::x
            y @-1
              reference: <testLibraryFragment>::@class::B::@field::y
              element: <none>
              getter2: <testLibraryFragment>::@class::B::@getter::y
            z @-1
              reference: <testLibraryFragment>::@class::B::@field::z
              element: <none>
              setter2: <testLibraryFragment>::@class::B::@setter::z
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
          getters
            get x @-1
              reference: <testLibraryFragment>::@class::B::@getter::x
              element: <none>
            get y @101
              reference: <testLibraryFragment>::@class::B::@getter::y
              element: <none>
          setters
            set x= @-1
              reference: <testLibraryFragment>::@class::B::@setter::x
              element: <none>
              parameters
                _x @-1
                  element: <none>
            set z= @118
              reference: <testLibraryFragment>::@class::B::@setter::z
              element: <none>
              parameters
                _ @120
                  element: <none>
  classes
    abstract class A
      firstFragment: <testLibraryFragment>::@class::A
      typeParameters
        E
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::A::@field::x
          type: E
          getter: <none>
        synthetic y
          firstFragment: <testLibraryFragment>::@class::A::@field::y
          type: E
          getter: <none>
        synthetic z
          firstFragment: <testLibraryFragment>::@class::A::@field::z
          type: E
          getter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      getters
        abstract get x
          firstFragment: <testLibraryFragment>::@class::A::@getter::x
        abstract get y
          firstFragment: <testLibraryFragment>::@class::A::@getter::y
        abstract get z
          firstFragment: <testLibraryFragment>::@class::A::@getter::z
    class B
      firstFragment: <testLibraryFragment>::@class::B
      typeParameters
        T
      fields
        x
          firstFragment: <testLibraryFragment>::@class::B::@field::x
          type: T
          getter: <none>
          setter: <none>
        synthetic y
          firstFragment: <testLibraryFragment>::@class::B::@field::y
          type: T
          getter: <none>
        synthetic z
          firstFragment: <testLibraryFragment>::@class::B::@field::z
          type: T
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
      getters
        synthetic get x
          firstFragment: <testLibraryFragment>::@class::B::@getter::x
        get y
          firstFragment: <testLibraryFragment>::@class::B::@getter::y
      setters
        synthetic set x=
          firstFragment: <testLibraryFragment>::@class::B::@setter::x
          parameters
            requiredPositional _x
              type: T
        set z=
          firstFragment: <testLibraryFragment>::@class::B::@setter::z
          parameters
            requiredPositional _
              type: T
''');
  }

  test_instanceField_fromGetter_multiple_different() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  int get x;
}
abstract class B {
  String get x;
}
class C implements A, B {
  get x => null;
}
''');
    // TODO(scheglov): test for inference failure error
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        abstract class A @15
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::A::@field::x
              enclosingElement3: <testLibraryFragment>::@class::A
              type: int
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          accessors
            abstract get x @29
              reference: <testLibraryFragment>::@class::A::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: int
        abstract class B @49
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::B::@field::x
              enclosingElement3: <testLibraryFragment>::@class::B
              type: String
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
          accessors
            abstract get x @66
              reference: <testLibraryFragment>::@class::B::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::B
              returnType: String
        class C @77
          reference: <testLibraryFragment>::@class::C
          enclosingElement3: <testLibraryFragment>
          interfaces
            A
            B
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::C::@field::x
              enclosingElement3: <testLibraryFragment>::@class::C
              type: dynamic
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::C
          accessors
            get x @103
              reference: <testLibraryFragment>::@class::C::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::C
              returnType: dynamic
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @15
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          fields
            x @-1
              reference: <testLibraryFragment>::@class::A::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          getters
            get x @29
              reference: <testLibraryFragment>::@class::A::@getter::x
              element: <none>
        class B @49
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          fields
            x @-1
              reference: <testLibraryFragment>::@class::B::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::B::@getter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
          getters
            get x @66
              reference: <testLibraryFragment>::@class::B::@getter::x
              element: <none>
        class C @77
          reference: <testLibraryFragment>::@class::C
          element: <testLibraryFragment>::@class::C
          fields
            x @-1
              reference: <testLibraryFragment>::@class::C::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::C::@getter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              element: <none>
          getters
            get x @103
              reference: <testLibraryFragment>::@class::C::@getter::x
              element: <none>
  classes
    abstract class A
      firstFragment: <testLibraryFragment>::@class::A
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::A::@field::x
          type: int
          getter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      getters
        abstract get x
          firstFragment: <testLibraryFragment>::@class::A::@getter::x
    abstract class B
      firstFragment: <testLibraryFragment>::@class::B
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::B::@field::x
          type: String
          getter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
      getters
        abstract get x
          firstFragment: <testLibraryFragment>::@class::B::@getter::x
    class C
      firstFragment: <testLibraryFragment>::@class::C
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::C::@field::x
          type: dynamic
          getter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::C::@constructor::new
      getters
        get x
          firstFragment: <testLibraryFragment>::@class::C::@getter::x
''');
  }

  test_instanceField_fromGetter_multiple_different_dynamic() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  int get x;
}
abstract class B {
  dynamic get x;
}
class C implements A, B {
  get x => null;
}
''');
    // TODO(scheglov): test for inference failure error
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        abstract class A @15
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::A::@field::x
              enclosingElement3: <testLibraryFragment>::@class::A
              type: int
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          accessors
            abstract get x @29
              reference: <testLibraryFragment>::@class::A::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: int
        abstract class B @49
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::B::@field::x
              enclosingElement3: <testLibraryFragment>::@class::B
              type: dynamic
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
          accessors
            abstract get x @67
              reference: <testLibraryFragment>::@class::B::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::B
              returnType: dynamic
        class C @78
          reference: <testLibraryFragment>::@class::C
          enclosingElement3: <testLibraryFragment>
          interfaces
            A
            B
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::C::@field::x
              enclosingElement3: <testLibraryFragment>::@class::C
              type: int
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::C
          accessors
            get x @104
              reference: <testLibraryFragment>::@class::C::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::C
              returnType: int
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @15
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          fields
            x @-1
              reference: <testLibraryFragment>::@class::A::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          getters
            get x @29
              reference: <testLibraryFragment>::@class::A::@getter::x
              element: <none>
        class B @49
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          fields
            x @-1
              reference: <testLibraryFragment>::@class::B::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::B::@getter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
          getters
            get x @67
              reference: <testLibraryFragment>::@class::B::@getter::x
              element: <none>
        class C @78
          reference: <testLibraryFragment>::@class::C
          element: <testLibraryFragment>::@class::C
          fields
            x @-1
              reference: <testLibraryFragment>::@class::C::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::C::@getter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              element: <none>
          getters
            get x @104
              reference: <testLibraryFragment>::@class::C::@getter::x
              element: <none>
  classes
    abstract class A
      firstFragment: <testLibraryFragment>::@class::A
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::A::@field::x
          type: int
          getter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      getters
        abstract get x
          firstFragment: <testLibraryFragment>::@class::A::@getter::x
    abstract class B
      firstFragment: <testLibraryFragment>::@class::B
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::B::@field::x
          type: dynamic
          getter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
      getters
        abstract get x
          firstFragment: <testLibraryFragment>::@class::B::@getter::x
    class C
      firstFragment: <testLibraryFragment>::@class::C
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::C::@field::x
          type: int
          getter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::C::@constructor::new
      getters
        get x
          firstFragment: <testLibraryFragment>::@class::C::@getter::x
''');
  }

  test_instanceField_fromGetter_multiple_different_generic() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A<T> {
  T get x;
}
abstract class B<T> {
  T get x;
}
class C implements A<int>, B<String> {
  get x => null;
}
''');
    // TODO(scheglov): test for inference failure error
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        abstract class A @15
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          typeParameters
            covariant T @17
              defaultType: dynamic
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::A::@field::x
              enclosingElement3: <testLibraryFragment>::@class::A
              type: T
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          accessors
            abstract get x @30
              reference: <testLibraryFragment>::@class::A::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: T
        abstract class B @50
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          typeParameters
            covariant T @52
              defaultType: dynamic
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::B::@field::x
              enclosingElement3: <testLibraryFragment>::@class::B
              type: T
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
          accessors
            abstract get x @65
              reference: <testLibraryFragment>::@class::B::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::B
              returnType: T
        class C @76
          reference: <testLibraryFragment>::@class::C
          enclosingElement3: <testLibraryFragment>
          interfaces
            A<int>
            B<String>
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::C::@field::x
              enclosingElement3: <testLibraryFragment>::@class::C
              type: dynamic
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::C
          accessors
            get x @115
              reference: <testLibraryFragment>::@class::C::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::C
              returnType: dynamic
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @15
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          typeParameters
            T @17
              element: <none>
          fields
            x @-1
              reference: <testLibraryFragment>::@class::A::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          getters
            get x @30
              reference: <testLibraryFragment>::@class::A::@getter::x
              element: <none>
        class B @50
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          typeParameters
            T @52
              element: <none>
          fields
            x @-1
              reference: <testLibraryFragment>::@class::B::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::B::@getter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
          getters
            get x @65
              reference: <testLibraryFragment>::@class::B::@getter::x
              element: <none>
        class C @76
          reference: <testLibraryFragment>::@class::C
          element: <testLibraryFragment>::@class::C
          fields
            x @-1
              reference: <testLibraryFragment>::@class::C::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::C::@getter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              element: <none>
          getters
            get x @115
              reference: <testLibraryFragment>::@class::C::@getter::x
              element: <none>
  classes
    abstract class A
      firstFragment: <testLibraryFragment>::@class::A
      typeParameters
        T
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::A::@field::x
          type: T
          getter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      getters
        abstract get x
          firstFragment: <testLibraryFragment>::@class::A::@getter::x
    abstract class B
      firstFragment: <testLibraryFragment>::@class::B
      typeParameters
        T
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::B::@field::x
          type: T
          getter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
      getters
        abstract get x
          firstFragment: <testLibraryFragment>::@class::B::@getter::x
    class C
      firstFragment: <testLibraryFragment>::@class::C
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::C::@field::x
          type: dynamic
          getter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::C::@constructor::new
      getters
        get x
          firstFragment: <testLibraryFragment>::@class::C::@getter::x
''');
  }

  test_instanceField_fromGetter_multiple_same() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  int get x;
}
abstract class B {
  int get x;
}
class C implements A, B {
  get x => null;
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        abstract class A @15
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::A::@field::x
              enclosingElement3: <testLibraryFragment>::@class::A
              type: int
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          accessors
            abstract get x @29
              reference: <testLibraryFragment>::@class::A::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: int
        abstract class B @49
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::B::@field::x
              enclosingElement3: <testLibraryFragment>::@class::B
              type: int
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
          accessors
            abstract get x @63
              reference: <testLibraryFragment>::@class::B::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::B
              returnType: int
        class C @74
          reference: <testLibraryFragment>::@class::C
          enclosingElement3: <testLibraryFragment>
          interfaces
            A
            B
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::C::@field::x
              enclosingElement3: <testLibraryFragment>::@class::C
              type: int
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::C
          accessors
            get x @100
              reference: <testLibraryFragment>::@class::C::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::C
              returnType: int
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @15
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          fields
            x @-1
              reference: <testLibraryFragment>::@class::A::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          getters
            get x @29
              reference: <testLibraryFragment>::@class::A::@getter::x
              element: <none>
        class B @49
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          fields
            x @-1
              reference: <testLibraryFragment>::@class::B::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::B::@getter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
          getters
            get x @63
              reference: <testLibraryFragment>::@class::B::@getter::x
              element: <none>
        class C @74
          reference: <testLibraryFragment>::@class::C
          element: <testLibraryFragment>::@class::C
          fields
            x @-1
              reference: <testLibraryFragment>::@class::C::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::C::@getter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              element: <none>
          getters
            get x @100
              reference: <testLibraryFragment>::@class::C::@getter::x
              element: <none>
  classes
    abstract class A
      firstFragment: <testLibraryFragment>::@class::A
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::A::@field::x
          type: int
          getter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      getters
        abstract get x
          firstFragment: <testLibraryFragment>::@class::A::@getter::x
    abstract class B
      firstFragment: <testLibraryFragment>::@class::B
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::B::@field::x
          type: int
          getter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
      getters
        abstract get x
          firstFragment: <testLibraryFragment>::@class::B::@getter::x
    class C
      firstFragment: <testLibraryFragment>::@class::C
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::C::@field::x
          type: int
          getter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::C::@constructor::new
      getters
        get x
          firstFragment: <testLibraryFragment>::@class::C::@getter::x
''');
  }

  test_instanceField_fromGetterSetter_different_field() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  int get x;
  int get y;
}
abstract class B {
  void set x(String _);
  void set y(String _);
}
class C implements A, B {
  var x;
  final y;
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        abstract class A @15
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::A::@field::x
              enclosingElement3: <testLibraryFragment>::@class::A
              type: int
            synthetic y @-1
              reference: <testLibraryFragment>::@class::A::@field::y
              enclosingElement3: <testLibraryFragment>::@class::A
              type: int
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          accessors
            abstract get x @29
              reference: <testLibraryFragment>::@class::A::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: int
            abstract get y @42
              reference: <testLibraryFragment>::@class::A::@getter::y
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: int
        abstract class B @62
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::B::@field::x
              enclosingElement3: <testLibraryFragment>::@class::B
              type: String
            synthetic y @-1
              reference: <testLibraryFragment>::@class::B::@field::y
              enclosingElement3: <testLibraryFragment>::@class::B
              type: String
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
          accessors
            abstract set x= @77
              reference: <testLibraryFragment>::@class::B::@setter::x
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional _ @86
                  type: String
              returnType: void
            abstract set y= @101
              reference: <testLibraryFragment>::@class::B::@setter::y
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional _ @110
                  type: String
              returnType: void
        class C @122
          reference: <testLibraryFragment>::@class::C
          enclosingElement3: <testLibraryFragment>
          interfaces
            A
            B
          fields
            x @148
              reference: <testLibraryFragment>::@class::C::@field::x
              enclosingElement3: <testLibraryFragment>::@class::C
              type: dynamic
            final y @159
              reference: <testLibraryFragment>::@class::C::@field::y
              enclosingElement3: <testLibraryFragment>::@class::C
              type: int
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::C
          accessors
            synthetic get x @-1
              reference: <testLibraryFragment>::@class::C::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::C
              returnType: dynamic
            synthetic set x= @-1
              reference: <testLibraryFragment>::@class::C::@setter::x
              enclosingElement3: <testLibraryFragment>::@class::C
              parameters
                requiredPositional _x @-1
                  type: dynamic
              returnType: void
            synthetic get y @-1
              reference: <testLibraryFragment>::@class::C::@getter::y
              enclosingElement3: <testLibraryFragment>::@class::C
              returnType: int
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @15
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          fields
            x @-1
              reference: <testLibraryFragment>::@class::A::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::x
            y @-1
              reference: <testLibraryFragment>::@class::A::@field::y
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::y
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          getters
            get x @29
              reference: <testLibraryFragment>::@class::A::@getter::x
              element: <none>
            get y @42
              reference: <testLibraryFragment>::@class::A::@getter::y
              element: <none>
        class B @62
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          fields
            x @-1
              reference: <testLibraryFragment>::@class::B::@field::x
              element: <none>
              setter2: <testLibraryFragment>::@class::B::@setter::x
            y @-1
              reference: <testLibraryFragment>::@class::B::@field::y
              element: <none>
              setter2: <testLibraryFragment>::@class::B::@setter::y
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
          setters
            set x= @77
              reference: <testLibraryFragment>::@class::B::@setter::x
              element: <none>
              parameters
                _ @86
                  element: <none>
            set y= @101
              reference: <testLibraryFragment>::@class::B::@setter::y
              element: <none>
              parameters
                _ @110
                  element: <none>
        class C @122
          reference: <testLibraryFragment>::@class::C
          element: <testLibraryFragment>::@class::C
          fields
            x @148
              reference: <testLibraryFragment>::@class::C::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::C::@getter::x
              setter2: <testLibraryFragment>::@class::C::@setter::x
            y @159
              reference: <testLibraryFragment>::@class::C::@field::y
              element: <none>
              getter2: <testLibraryFragment>::@class::C::@getter::y
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              element: <none>
          getters
            get x @-1
              reference: <testLibraryFragment>::@class::C::@getter::x
              element: <none>
            get y @-1
              reference: <testLibraryFragment>::@class::C::@getter::y
              element: <none>
          setters
            set x= @-1
              reference: <testLibraryFragment>::@class::C::@setter::x
              element: <none>
              parameters
                _x @-1
                  element: <none>
  classes
    abstract class A
      firstFragment: <testLibraryFragment>::@class::A
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::A::@field::x
          type: int
          getter: <none>
        synthetic y
          firstFragment: <testLibraryFragment>::@class::A::@field::y
          type: int
          getter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      getters
        abstract get x
          firstFragment: <testLibraryFragment>::@class::A::@getter::x
        abstract get y
          firstFragment: <testLibraryFragment>::@class::A::@getter::y
    abstract class B
      firstFragment: <testLibraryFragment>::@class::B
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::B::@field::x
          type: String
          setter: <none>
        synthetic y
          firstFragment: <testLibraryFragment>::@class::B::@field::y
          type: String
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
      setters
        abstract set x=
          firstFragment: <testLibraryFragment>::@class::B::@setter::x
          parameters
            requiredPositional _
              type: String
        abstract set y=
          firstFragment: <testLibraryFragment>::@class::B::@setter::y
          parameters
            requiredPositional _
              type: String
    class C
      firstFragment: <testLibraryFragment>::@class::C
      fields
        x
          firstFragment: <testLibraryFragment>::@class::C::@field::x
          type: dynamic
          getter: <none>
          setter: <none>
        final y
          firstFragment: <testLibraryFragment>::@class::C::@field::y
          type: int
          getter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::C::@constructor::new
      getters
        synthetic get x
          firstFragment: <testLibraryFragment>::@class::C::@getter::x
        synthetic get y
          firstFragment: <testLibraryFragment>::@class::C::@getter::y
      setters
        synthetic set x=
          firstFragment: <testLibraryFragment>::@class::C::@setter::x
          parameters
            requiredPositional _x
              type: dynamic
''');
  }

  test_instanceField_fromGetterSetter_different_getter() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  int get x;
}
abstract class B {
  void set x(String _);
}
class C implements A, B {
  get x => null;
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        abstract class A @15
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::A::@field::x
              enclosingElement3: <testLibraryFragment>::@class::A
              type: int
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          accessors
            abstract get x @29
              reference: <testLibraryFragment>::@class::A::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: int
        abstract class B @49
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::B::@field::x
              enclosingElement3: <testLibraryFragment>::@class::B
              type: String
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
          accessors
            abstract set x= @64
              reference: <testLibraryFragment>::@class::B::@setter::x
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional _ @73
                  type: String
              returnType: void
        class C @85
          reference: <testLibraryFragment>::@class::C
          enclosingElement3: <testLibraryFragment>
          interfaces
            A
            B
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::C::@field::x
              enclosingElement3: <testLibraryFragment>::@class::C
              type: int
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::C
          accessors
            get x @111
              reference: <testLibraryFragment>::@class::C::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::C
              returnType: int
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @15
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          fields
            x @-1
              reference: <testLibraryFragment>::@class::A::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          getters
            get x @29
              reference: <testLibraryFragment>::@class::A::@getter::x
              element: <none>
        class B @49
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          fields
            x @-1
              reference: <testLibraryFragment>::@class::B::@field::x
              element: <none>
              setter2: <testLibraryFragment>::@class::B::@setter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
          setters
            set x= @64
              reference: <testLibraryFragment>::@class::B::@setter::x
              element: <none>
              parameters
                _ @73
                  element: <none>
        class C @85
          reference: <testLibraryFragment>::@class::C
          element: <testLibraryFragment>::@class::C
          fields
            x @-1
              reference: <testLibraryFragment>::@class::C::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::C::@getter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              element: <none>
          getters
            get x @111
              reference: <testLibraryFragment>::@class::C::@getter::x
              element: <none>
  classes
    abstract class A
      firstFragment: <testLibraryFragment>::@class::A
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::A::@field::x
          type: int
          getter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      getters
        abstract get x
          firstFragment: <testLibraryFragment>::@class::A::@getter::x
    abstract class B
      firstFragment: <testLibraryFragment>::@class::B
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::B::@field::x
          type: String
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
      setters
        abstract set x=
          firstFragment: <testLibraryFragment>::@class::B::@setter::x
          parameters
            requiredPositional _
              type: String
    class C
      firstFragment: <testLibraryFragment>::@class::C
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::C::@field::x
          type: int
          getter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::C::@constructor::new
      getters
        get x
          firstFragment: <testLibraryFragment>::@class::C::@getter::x
''');
  }

  test_instanceField_fromGetterSetter_different_setter() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  int get x;
}
abstract class B {
  void set x(String _);
}
class C implements A, B {
  set x(_);
}
''');
    // TODO(scheglov): test for inference failure error
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        abstract class A @15
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::A::@field::x
              enclosingElement3: <testLibraryFragment>::@class::A
              type: int
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          accessors
            abstract get x @29
              reference: <testLibraryFragment>::@class::A::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: int
        abstract class B @49
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::B::@field::x
              enclosingElement3: <testLibraryFragment>::@class::B
              type: String
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
          accessors
            abstract set x= @64
              reference: <testLibraryFragment>::@class::B::@setter::x
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional _ @73
                  type: String
              returnType: void
        class C @85
          reference: <testLibraryFragment>::@class::C
          enclosingElement3: <testLibraryFragment>
          interfaces
            A
            B
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::C::@field::x
              enclosingElement3: <testLibraryFragment>::@class::C
              type: String
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::C
          accessors
            abstract set x= @111
              reference: <testLibraryFragment>::@class::C::@setter::x
              enclosingElement3: <testLibraryFragment>::@class::C
              parameters
                requiredPositional _ @113
                  type: String
              returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @15
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          fields
            x @-1
              reference: <testLibraryFragment>::@class::A::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          getters
            get x @29
              reference: <testLibraryFragment>::@class::A::@getter::x
              element: <none>
        class B @49
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          fields
            x @-1
              reference: <testLibraryFragment>::@class::B::@field::x
              element: <none>
              setter2: <testLibraryFragment>::@class::B::@setter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
          setters
            set x= @64
              reference: <testLibraryFragment>::@class::B::@setter::x
              element: <none>
              parameters
                _ @73
                  element: <none>
        class C @85
          reference: <testLibraryFragment>::@class::C
          element: <testLibraryFragment>::@class::C
          fields
            x @-1
              reference: <testLibraryFragment>::@class::C::@field::x
              element: <none>
              setter2: <testLibraryFragment>::@class::C::@setter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              element: <none>
          setters
            set x= @111
              reference: <testLibraryFragment>::@class::C::@setter::x
              element: <none>
              parameters
                _ @113
                  element: <none>
  classes
    abstract class A
      firstFragment: <testLibraryFragment>::@class::A
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::A::@field::x
          type: int
          getter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      getters
        abstract get x
          firstFragment: <testLibraryFragment>::@class::A::@getter::x
    abstract class B
      firstFragment: <testLibraryFragment>::@class::B
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::B::@field::x
          type: String
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
      setters
        abstract set x=
          firstFragment: <testLibraryFragment>::@class::B::@setter::x
          parameters
            requiredPositional _
              type: String
    class C
      firstFragment: <testLibraryFragment>::@class::C
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::C::@field::x
          type: String
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::C::@constructor::new
      setters
        abstract set x=
          firstFragment: <testLibraryFragment>::@class::C::@setter::x
          parameters
            requiredPositional _
              type: String
''');
  }

  test_instanceField_fromGetterSetter_same_field() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  int get x;
}
abstract class B {
  void set x(int _);
}
class C implements A, B {
  var x;
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        abstract class A @15
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::A::@field::x
              enclosingElement3: <testLibraryFragment>::@class::A
              type: int
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          accessors
            abstract get x @29
              reference: <testLibraryFragment>::@class::A::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: int
        abstract class B @49
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::B::@field::x
              enclosingElement3: <testLibraryFragment>::@class::B
              type: int
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
          accessors
            abstract set x= @64
              reference: <testLibraryFragment>::@class::B::@setter::x
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional _ @70
                  type: int
              returnType: void
        class C @82
          reference: <testLibraryFragment>::@class::C
          enclosingElement3: <testLibraryFragment>
          interfaces
            A
            B
          fields
            x @108
              reference: <testLibraryFragment>::@class::C::@field::x
              enclosingElement3: <testLibraryFragment>::@class::C
              type: int
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::C
          accessors
            synthetic get x @-1
              reference: <testLibraryFragment>::@class::C::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::C
              returnType: int
            synthetic set x= @-1
              reference: <testLibraryFragment>::@class::C::@setter::x
              enclosingElement3: <testLibraryFragment>::@class::C
              parameters
                requiredPositional _x @-1
                  type: int
              returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @15
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          fields
            x @-1
              reference: <testLibraryFragment>::@class::A::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          getters
            get x @29
              reference: <testLibraryFragment>::@class::A::@getter::x
              element: <none>
        class B @49
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          fields
            x @-1
              reference: <testLibraryFragment>::@class::B::@field::x
              element: <none>
              setter2: <testLibraryFragment>::@class::B::@setter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
          setters
            set x= @64
              reference: <testLibraryFragment>::@class::B::@setter::x
              element: <none>
              parameters
                _ @70
                  element: <none>
        class C @82
          reference: <testLibraryFragment>::@class::C
          element: <testLibraryFragment>::@class::C
          fields
            x @108
              reference: <testLibraryFragment>::@class::C::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::C::@getter::x
              setter2: <testLibraryFragment>::@class::C::@setter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              element: <none>
          getters
            get x @-1
              reference: <testLibraryFragment>::@class::C::@getter::x
              element: <none>
          setters
            set x= @-1
              reference: <testLibraryFragment>::@class::C::@setter::x
              element: <none>
              parameters
                _x @-1
                  element: <none>
  classes
    abstract class A
      firstFragment: <testLibraryFragment>::@class::A
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::A::@field::x
          type: int
          getter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      getters
        abstract get x
          firstFragment: <testLibraryFragment>::@class::A::@getter::x
    abstract class B
      firstFragment: <testLibraryFragment>::@class::B
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::B::@field::x
          type: int
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
      setters
        abstract set x=
          firstFragment: <testLibraryFragment>::@class::B::@setter::x
          parameters
            requiredPositional _
              type: int
    class C
      firstFragment: <testLibraryFragment>::@class::C
      fields
        x
          firstFragment: <testLibraryFragment>::@class::C::@field::x
          type: int
          getter: <none>
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::C::@constructor::new
      getters
        synthetic get x
          firstFragment: <testLibraryFragment>::@class::C::@getter::x
      setters
        synthetic set x=
          firstFragment: <testLibraryFragment>::@class::C::@setter::x
          parameters
            requiredPositional _x
              type: int
''');
  }

  test_instanceField_fromGetterSetter_same_getter() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  int get x;
}
abstract class B {
  void set x(int _);
}
class C implements A, B {
  get x => null;
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        abstract class A @15
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::A::@field::x
              enclosingElement3: <testLibraryFragment>::@class::A
              type: int
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          accessors
            abstract get x @29
              reference: <testLibraryFragment>::@class::A::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: int
        abstract class B @49
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::B::@field::x
              enclosingElement3: <testLibraryFragment>::@class::B
              type: int
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
          accessors
            abstract set x= @64
              reference: <testLibraryFragment>::@class::B::@setter::x
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional _ @70
                  type: int
              returnType: void
        class C @82
          reference: <testLibraryFragment>::@class::C
          enclosingElement3: <testLibraryFragment>
          interfaces
            A
            B
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::C::@field::x
              enclosingElement3: <testLibraryFragment>::@class::C
              type: int
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::C
          accessors
            get x @108
              reference: <testLibraryFragment>::@class::C::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::C
              returnType: int
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @15
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          fields
            x @-1
              reference: <testLibraryFragment>::@class::A::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          getters
            get x @29
              reference: <testLibraryFragment>::@class::A::@getter::x
              element: <none>
        class B @49
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          fields
            x @-1
              reference: <testLibraryFragment>::@class::B::@field::x
              element: <none>
              setter2: <testLibraryFragment>::@class::B::@setter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
          setters
            set x= @64
              reference: <testLibraryFragment>::@class::B::@setter::x
              element: <none>
              parameters
                _ @70
                  element: <none>
        class C @82
          reference: <testLibraryFragment>::@class::C
          element: <testLibraryFragment>::@class::C
          fields
            x @-1
              reference: <testLibraryFragment>::@class::C::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::C::@getter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              element: <none>
          getters
            get x @108
              reference: <testLibraryFragment>::@class::C::@getter::x
              element: <none>
  classes
    abstract class A
      firstFragment: <testLibraryFragment>::@class::A
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::A::@field::x
          type: int
          getter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      getters
        abstract get x
          firstFragment: <testLibraryFragment>::@class::A::@getter::x
    abstract class B
      firstFragment: <testLibraryFragment>::@class::B
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::B::@field::x
          type: int
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
      setters
        abstract set x=
          firstFragment: <testLibraryFragment>::@class::B::@setter::x
          parameters
            requiredPositional _
              type: int
    class C
      firstFragment: <testLibraryFragment>::@class::C
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::C::@field::x
          type: int
          getter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::C::@constructor::new
      getters
        get x
          firstFragment: <testLibraryFragment>::@class::C::@getter::x
''');
  }

  test_instanceField_fromGetterSetter_same_setter() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  int get x;
}
abstract class B {
  void set x(int _);
}
class C implements A, B {
  set x(_);
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        abstract class A @15
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::A::@field::x
              enclosingElement3: <testLibraryFragment>::@class::A
              type: int
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          accessors
            abstract get x @29
              reference: <testLibraryFragment>::@class::A::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: int
        abstract class B @49
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::B::@field::x
              enclosingElement3: <testLibraryFragment>::@class::B
              type: int
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
          accessors
            abstract set x= @64
              reference: <testLibraryFragment>::@class::B::@setter::x
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional _ @70
                  type: int
              returnType: void
        class C @82
          reference: <testLibraryFragment>::@class::C
          enclosingElement3: <testLibraryFragment>
          interfaces
            A
            B
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::C::@field::x
              enclosingElement3: <testLibraryFragment>::@class::C
              type: int
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::C
          accessors
            abstract set x= @108
              reference: <testLibraryFragment>::@class::C::@setter::x
              enclosingElement3: <testLibraryFragment>::@class::C
              parameters
                requiredPositional _ @110
                  type: int
              returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @15
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          fields
            x @-1
              reference: <testLibraryFragment>::@class::A::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          getters
            get x @29
              reference: <testLibraryFragment>::@class::A::@getter::x
              element: <none>
        class B @49
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          fields
            x @-1
              reference: <testLibraryFragment>::@class::B::@field::x
              element: <none>
              setter2: <testLibraryFragment>::@class::B::@setter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
          setters
            set x= @64
              reference: <testLibraryFragment>::@class::B::@setter::x
              element: <none>
              parameters
                _ @70
                  element: <none>
        class C @82
          reference: <testLibraryFragment>::@class::C
          element: <testLibraryFragment>::@class::C
          fields
            x @-1
              reference: <testLibraryFragment>::@class::C::@field::x
              element: <none>
              setter2: <testLibraryFragment>::@class::C::@setter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              element: <none>
          setters
            set x= @108
              reference: <testLibraryFragment>::@class::C::@setter::x
              element: <none>
              parameters
                _ @110
                  element: <none>
  classes
    abstract class A
      firstFragment: <testLibraryFragment>::@class::A
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::A::@field::x
          type: int
          getter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      getters
        abstract get x
          firstFragment: <testLibraryFragment>::@class::A::@getter::x
    abstract class B
      firstFragment: <testLibraryFragment>::@class::B
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::B::@field::x
          type: int
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
      setters
        abstract set x=
          firstFragment: <testLibraryFragment>::@class::B::@setter::x
          parameters
            requiredPositional _
              type: int
    class C
      firstFragment: <testLibraryFragment>::@class::C
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::C::@field::x
          type: int
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::C::@constructor::new
      setters
        abstract set x=
          firstFragment: <testLibraryFragment>::@class::C::@setter::x
          parameters
            requiredPositional _
              type: int
''');
  }

  test_instanceField_fromSetter() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  void set x(int _);
  void set y(int _);
  void set z(int _);
}
class B implements A {
  var x;
  get y => null;
  set z(_) {}
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        abstract class A @15
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::A::@field::x
              enclosingElement3: <testLibraryFragment>::@class::A
              type: int
            synthetic y @-1
              reference: <testLibraryFragment>::@class::A::@field::y
              enclosingElement3: <testLibraryFragment>::@class::A
              type: int
            synthetic z @-1
              reference: <testLibraryFragment>::@class::A::@field::z
              enclosingElement3: <testLibraryFragment>::@class::A
              type: int
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          accessors
            abstract set x= @30
              reference: <testLibraryFragment>::@class::A::@setter::x
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional _ @36
                  type: int
              returnType: void
            abstract set y= @51
              reference: <testLibraryFragment>::@class::A::@setter::y
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional _ @57
                  type: int
              returnType: void
            abstract set z= @72
              reference: <testLibraryFragment>::@class::A::@setter::z
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional _ @78
                  type: int
              returnType: void
        class B @90
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          interfaces
            A
          fields
            x @113
              reference: <testLibraryFragment>::@class::B::@field::x
              enclosingElement3: <testLibraryFragment>::@class::B
              type: int
            synthetic y @-1
              reference: <testLibraryFragment>::@class::B::@field::y
              enclosingElement3: <testLibraryFragment>::@class::B
              type: int
            synthetic z @-1
              reference: <testLibraryFragment>::@class::B::@field::z
              enclosingElement3: <testLibraryFragment>::@class::B
              type: int
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
          accessors
            synthetic get x @-1
              reference: <testLibraryFragment>::@class::B::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::B
              returnType: int
            synthetic set x= @-1
              reference: <testLibraryFragment>::@class::B::@setter::x
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional _x @-1
                  type: int
              returnType: void
            get y @122
              reference: <testLibraryFragment>::@class::B::@getter::y
              enclosingElement3: <testLibraryFragment>::@class::B
              returnType: int
            set z= @139
              reference: <testLibraryFragment>::@class::B::@setter::z
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional _ @141
                  type: int
              returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @15
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          fields
            x @-1
              reference: <testLibraryFragment>::@class::A::@field::x
              element: <none>
              setter2: <testLibraryFragment>::@class::A::@setter::x
            y @-1
              reference: <testLibraryFragment>::@class::A::@field::y
              element: <none>
              setter2: <testLibraryFragment>::@class::A::@setter::y
            z @-1
              reference: <testLibraryFragment>::@class::A::@field::z
              element: <none>
              setter2: <testLibraryFragment>::@class::A::@setter::z
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          setters
            set x= @30
              reference: <testLibraryFragment>::@class::A::@setter::x
              element: <none>
              parameters
                _ @36
                  element: <none>
            set y= @51
              reference: <testLibraryFragment>::@class::A::@setter::y
              element: <none>
              parameters
                _ @57
                  element: <none>
            set z= @72
              reference: <testLibraryFragment>::@class::A::@setter::z
              element: <none>
              parameters
                _ @78
                  element: <none>
        class B @90
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          fields
            x @113
              reference: <testLibraryFragment>::@class::B::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::B::@getter::x
              setter2: <testLibraryFragment>::@class::B::@setter::x
            y @-1
              reference: <testLibraryFragment>::@class::B::@field::y
              element: <none>
              getter2: <testLibraryFragment>::@class::B::@getter::y
            z @-1
              reference: <testLibraryFragment>::@class::B::@field::z
              element: <none>
              setter2: <testLibraryFragment>::@class::B::@setter::z
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
          getters
            get x @-1
              reference: <testLibraryFragment>::@class::B::@getter::x
              element: <none>
            get y @122
              reference: <testLibraryFragment>::@class::B::@getter::y
              element: <none>
          setters
            set x= @-1
              reference: <testLibraryFragment>::@class::B::@setter::x
              element: <none>
              parameters
                _x @-1
                  element: <none>
            set z= @139
              reference: <testLibraryFragment>::@class::B::@setter::z
              element: <none>
              parameters
                _ @141
                  element: <none>
  classes
    abstract class A
      firstFragment: <testLibraryFragment>::@class::A
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::A::@field::x
          type: int
          setter: <none>
        synthetic y
          firstFragment: <testLibraryFragment>::@class::A::@field::y
          type: int
          setter: <none>
        synthetic z
          firstFragment: <testLibraryFragment>::@class::A::@field::z
          type: int
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      setters
        abstract set x=
          firstFragment: <testLibraryFragment>::@class::A::@setter::x
          parameters
            requiredPositional _
              type: int
        abstract set y=
          firstFragment: <testLibraryFragment>::@class::A::@setter::y
          parameters
            requiredPositional _
              type: int
        abstract set z=
          firstFragment: <testLibraryFragment>::@class::A::@setter::z
          parameters
            requiredPositional _
              type: int
    class B
      firstFragment: <testLibraryFragment>::@class::B
      fields
        x
          firstFragment: <testLibraryFragment>::@class::B::@field::x
          type: int
          getter: <none>
          setter: <none>
        synthetic y
          firstFragment: <testLibraryFragment>::@class::B::@field::y
          type: int
          getter: <none>
        synthetic z
          firstFragment: <testLibraryFragment>::@class::B::@field::z
          type: int
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
      getters
        synthetic get x
          firstFragment: <testLibraryFragment>::@class::B::@getter::x
        get y
          firstFragment: <testLibraryFragment>::@class::B::@getter::y
      setters
        synthetic set x=
          firstFragment: <testLibraryFragment>::@class::B::@setter::x
          parameters
            requiredPositional _x
              type: int
        set z=
          firstFragment: <testLibraryFragment>::@class::B::@setter::z
          parameters
            requiredPositional _
              type: int
''');
  }

  test_instanceField_fromSetter_multiple_different() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  void set x(int _);
}
abstract class B {
  void set x(String _);
}
class C implements A, B {
  get x => null;
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        abstract class A @15
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::A::@field::x
              enclosingElement3: <testLibraryFragment>::@class::A
              type: int
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          accessors
            abstract set x= @30
              reference: <testLibraryFragment>::@class::A::@setter::x
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional _ @36
                  type: int
              returnType: void
        abstract class B @57
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::B::@field::x
              enclosingElement3: <testLibraryFragment>::@class::B
              type: String
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
          accessors
            abstract set x= @72
              reference: <testLibraryFragment>::@class::B::@setter::x
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional _ @81
                  type: String
              returnType: void
        class C @93
          reference: <testLibraryFragment>::@class::C
          enclosingElement3: <testLibraryFragment>
          interfaces
            A
            B
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::C::@field::x
              enclosingElement3: <testLibraryFragment>::@class::C
              type: dynamic
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::C
          accessors
            get x @119
              reference: <testLibraryFragment>::@class::C::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::C
              returnType: dynamic
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @15
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          fields
            x @-1
              reference: <testLibraryFragment>::@class::A::@field::x
              element: <none>
              setter2: <testLibraryFragment>::@class::A::@setter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          setters
            set x= @30
              reference: <testLibraryFragment>::@class::A::@setter::x
              element: <none>
              parameters
                _ @36
                  element: <none>
        class B @57
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          fields
            x @-1
              reference: <testLibraryFragment>::@class::B::@field::x
              element: <none>
              setter2: <testLibraryFragment>::@class::B::@setter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
          setters
            set x= @72
              reference: <testLibraryFragment>::@class::B::@setter::x
              element: <none>
              parameters
                _ @81
                  element: <none>
        class C @93
          reference: <testLibraryFragment>::@class::C
          element: <testLibraryFragment>::@class::C
          fields
            x @-1
              reference: <testLibraryFragment>::@class::C::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::C::@getter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              element: <none>
          getters
            get x @119
              reference: <testLibraryFragment>::@class::C::@getter::x
              element: <none>
  classes
    abstract class A
      firstFragment: <testLibraryFragment>::@class::A
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::A::@field::x
          type: int
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      setters
        abstract set x=
          firstFragment: <testLibraryFragment>::@class::A::@setter::x
          parameters
            requiredPositional _
              type: int
    abstract class B
      firstFragment: <testLibraryFragment>::@class::B
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::B::@field::x
          type: String
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
      setters
        abstract set x=
          firstFragment: <testLibraryFragment>::@class::B::@setter::x
          parameters
            requiredPositional _
              type: String
    class C
      firstFragment: <testLibraryFragment>::@class::C
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::C::@field::x
          type: dynamic
          getter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::C::@constructor::new
      getters
        get x
          firstFragment: <testLibraryFragment>::@class::C::@getter::x
''');
  }

  test_instanceField_fromSetter_multiple_same() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  void set x(int _);
}
abstract class B {
  void set x(int _);
}
class C implements A, B {
  get x => null;
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        abstract class A @15
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::A::@field::x
              enclosingElement3: <testLibraryFragment>::@class::A
              type: int
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          accessors
            abstract set x= @30
              reference: <testLibraryFragment>::@class::A::@setter::x
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional _ @36
                  type: int
              returnType: void
        abstract class B @57
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::B::@field::x
              enclosingElement3: <testLibraryFragment>::@class::B
              type: int
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
          accessors
            abstract set x= @72
              reference: <testLibraryFragment>::@class::B::@setter::x
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional _ @78
                  type: int
              returnType: void
        class C @90
          reference: <testLibraryFragment>::@class::C
          enclosingElement3: <testLibraryFragment>
          interfaces
            A
            B
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::C::@field::x
              enclosingElement3: <testLibraryFragment>::@class::C
              type: int
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::C
          accessors
            get x @116
              reference: <testLibraryFragment>::@class::C::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::C
              returnType: int
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @15
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          fields
            x @-1
              reference: <testLibraryFragment>::@class::A::@field::x
              element: <none>
              setter2: <testLibraryFragment>::@class::A::@setter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          setters
            set x= @30
              reference: <testLibraryFragment>::@class::A::@setter::x
              element: <none>
              parameters
                _ @36
                  element: <none>
        class B @57
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          fields
            x @-1
              reference: <testLibraryFragment>::@class::B::@field::x
              element: <none>
              setter2: <testLibraryFragment>::@class::B::@setter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
          setters
            set x= @72
              reference: <testLibraryFragment>::@class::B::@setter::x
              element: <none>
              parameters
                _ @78
                  element: <none>
        class C @90
          reference: <testLibraryFragment>::@class::C
          element: <testLibraryFragment>::@class::C
          fields
            x @-1
              reference: <testLibraryFragment>::@class::C::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::C::@getter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              element: <none>
          getters
            get x @116
              reference: <testLibraryFragment>::@class::C::@getter::x
              element: <none>
  classes
    abstract class A
      firstFragment: <testLibraryFragment>::@class::A
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::A::@field::x
          type: int
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      setters
        abstract set x=
          firstFragment: <testLibraryFragment>::@class::A::@setter::x
          parameters
            requiredPositional _
              type: int
    abstract class B
      firstFragment: <testLibraryFragment>::@class::B
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::B::@field::x
          type: int
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
      setters
        abstract set x=
          firstFragment: <testLibraryFragment>::@class::B::@setter::x
          parameters
            requiredPositional _
              type: int
    class C
      firstFragment: <testLibraryFragment>::@class::C
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::C::@field::x
          type: int
          getter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::C::@constructor::new
      getters
        get x
          firstFragment: <testLibraryFragment>::@class::C::@getter::x
''');
  }

  test_instanceField_functionTypeAlias_doesNotUseItsTypeParameter() async {
    var library = await _encodeDecodeLibrary(r'''
typedef F<T>();

class A<T> {
  F<T> get x => null;
  List<F<T>> get y => null;
}

class B extends A<int> {
  get x => null;
  get y => null;
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class A @23
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          typeParameters
            covariant T @25
              defaultType: dynamic
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::A::@field::x
              enclosingElement3: <testLibraryFragment>::@class::A
              type: dynamic Function()
                alias: <testLibraryFragment>::@typeAlias::F
                  typeArguments
                    T
            synthetic y @-1
              reference: <testLibraryFragment>::@class::A::@field::y
              enclosingElement3: <testLibraryFragment>::@class::A
              type: List<dynamic Function()>
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          accessors
            get x @41
              reference: <testLibraryFragment>::@class::A::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: dynamic Function()
                alias: <testLibraryFragment>::@typeAlias::F
                  typeArguments
                    T
            get y @69
              reference: <testLibraryFragment>::@class::A::@getter::y
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: List<dynamic Function()>
        class B @89
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          supertype: A<int>
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::B::@field::x
              enclosingElement3: <testLibraryFragment>::@class::B
              type: dynamic Function()
                alias: <testLibraryFragment>::@typeAlias::F
                  typeArguments
                    int
            synthetic y @-1
              reference: <testLibraryFragment>::@class::B::@field::y
              enclosingElement3: <testLibraryFragment>::@class::B
              type: List<dynamic Function()>
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
              superConstructor: ConstructorMember
                base: <testLibraryFragment>::@class::A::@constructor::new
                substitution: {T: int}
          accessors
            get x @114
              reference: <testLibraryFragment>::@class::B::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::B
              returnType: dynamic Function()
                alias: <testLibraryFragment>::@typeAlias::F
                  typeArguments
                    int
            get y @131
              reference: <testLibraryFragment>::@class::B::@getter::y
              enclosingElement3: <testLibraryFragment>::@class::B
              returnType: List<dynamic Function()>
      typeAliases
        functionTypeAliasBased F @8
          reference: <testLibraryFragment>::@typeAlias::F
          typeParameters
            unrelated T @10
              defaultType: dynamic
          aliasedType: dynamic Function()
          aliasedElement: GenericFunctionTypeElement
            returnType: dynamic
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @23
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          typeParameters
            T @25
              element: <none>
          fields
            x @-1
              reference: <testLibraryFragment>::@class::A::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::x
            y @-1
              reference: <testLibraryFragment>::@class::A::@field::y
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::y
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          getters
            get x @41
              reference: <testLibraryFragment>::@class::A::@getter::x
              element: <none>
            get y @69
              reference: <testLibraryFragment>::@class::A::@getter::y
              element: <none>
        class B @89
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          fields
            x @-1
              reference: <testLibraryFragment>::@class::B::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::B::@getter::x
            y @-1
              reference: <testLibraryFragment>::@class::B::@field::y
              element: <none>
              getter2: <testLibraryFragment>::@class::B::@getter::y
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
              superConstructor: ConstructorMember
                base: <testLibraryFragment>::@class::A::@constructor::new
                substitution: {T: int}
          getters
            get x @114
              reference: <testLibraryFragment>::@class::B::@getter::x
              element: <none>
            get y @131
              reference: <testLibraryFragment>::@class::B::@getter::y
              element: <none>
      typeAliases
        F @8
          reference: <testLibraryFragment>::@typeAlias::F
          element: <none>
          typeParameters
            T @10
              element: <none>
  classes
    class A
      firstFragment: <testLibraryFragment>::@class::A
      typeParameters
        T
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::A::@field::x
          type: dynamic Function()
            alias: <testLibraryFragment>::@typeAlias::F
              typeArguments
                T
          getter: <none>
        synthetic y
          firstFragment: <testLibraryFragment>::@class::A::@field::y
          type: List<dynamic Function()>
          getter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      getters
        get x
          firstFragment: <testLibraryFragment>::@class::A::@getter::x
        get y
          firstFragment: <testLibraryFragment>::@class::A::@getter::y
    class B
      firstFragment: <testLibraryFragment>::@class::B
      supertype: A<int>
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::B::@field::x
          type: dynamic Function()
            alias: <testLibraryFragment>::@typeAlias::F
              typeArguments
                int
          getter: <none>
        synthetic y
          firstFragment: <testLibraryFragment>::@class::B::@field::y
          type: List<dynamic Function()>
          getter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
          superConstructor: <none>
      getters
        get x
          firstFragment: <testLibraryFragment>::@class::B::@getter::x
        get y
          firstFragment: <testLibraryFragment>::@class::B::@getter::y
  typeAliases
    F
      firstFragment: <testLibraryFragment>::@typeAlias::F
      typeParameters
        T
      aliasedType: dynamic Function()
''');
  }

  test_instanceField_inheritsCovariant_fromSetter_field() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  num get x;
  void set x(covariant num _);
}
class B implements A {
  int x;
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        abstract class A @15
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::A::@field::x
              enclosingElement3: <testLibraryFragment>::@class::A
              type: num
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          accessors
            abstract get x @29
              reference: <testLibraryFragment>::@class::A::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: num
            abstract set x= @43
              reference: <testLibraryFragment>::@class::A::@setter::x
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional covariant _ @59
                  type: num
              returnType: void
        class B @71
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          interfaces
            A
          fields
            x @94
              reference: <testLibraryFragment>::@class::B::@field::x
              enclosingElement3: <testLibraryFragment>::@class::B
              type: int
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
          accessors
            synthetic get x @-1
              reference: <testLibraryFragment>::@class::B::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::B
              returnType: int
            synthetic set x= @-1
              reference: <testLibraryFragment>::@class::B::@setter::x
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional covariant _x @-1
                  type: int
              returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @15
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          fields
            x @-1
              reference: <testLibraryFragment>::@class::A::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::x
              setter2: <testLibraryFragment>::@class::A::@setter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          getters
            get x @29
              reference: <testLibraryFragment>::@class::A::@getter::x
              element: <none>
          setters
            set x= @43
              reference: <testLibraryFragment>::@class::A::@setter::x
              element: <none>
              parameters
                _ @59
                  element: <none>
        class B @71
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          fields
            x @94
              reference: <testLibraryFragment>::@class::B::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::B::@getter::x
              setter2: <testLibraryFragment>::@class::B::@setter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
          getters
            get x @-1
              reference: <testLibraryFragment>::@class::B::@getter::x
              element: <none>
          setters
            set x= @-1
              reference: <testLibraryFragment>::@class::B::@setter::x
              element: <none>
              parameters
                _x @-1
                  element: <none>
  classes
    abstract class A
      firstFragment: <testLibraryFragment>::@class::A
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::A::@field::x
          type: num
          getter: <none>
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      getters
        abstract get x
          firstFragment: <testLibraryFragment>::@class::A::@getter::x
      setters
        abstract set x=
          firstFragment: <testLibraryFragment>::@class::A::@setter::x
          parameters
            requiredPositional covariant _
              type: num
    class B
      firstFragment: <testLibraryFragment>::@class::B
      fields
        x
          firstFragment: <testLibraryFragment>::@class::B::@field::x
          type: int
          getter: <none>
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
      getters
        synthetic get x
          firstFragment: <testLibraryFragment>::@class::B::@getter::x
      setters
        synthetic set x=
          firstFragment: <testLibraryFragment>::@class::B::@setter::x
          parameters
            requiredPositional covariant _x
              type: int
''');
  }

  test_instanceField_inheritsCovariant_fromSetter_setter() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  num get x;
  void set x(covariant num _);
}
class B implements A {
  set x(int _) {}
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        abstract class A @15
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::A::@field::x
              enclosingElement3: <testLibraryFragment>::@class::A
              type: num
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          accessors
            abstract get x @29
              reference: <testLibraryFragment>::@class::A::@getter::x
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: num
            abstract set x= @43
              reference: <testLibraryFragment>::@class::A::@setter::x
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional covariant _ @59
                  type: num
              returnType: void
        class B @71
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          interfaces
            A
          fields
            synthetic x @-1
              reference: <testLibraryFragment>::@class::B::@field::x
              enclosingElement3: <testLibraryFragment>::@class::B
              type: int
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
          accessors
            set x= @94
              reference: <testLibraryFragment>::@class::B::@setter::x
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional covariant _ @100
                  type: int
              returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @15
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          fields
            x @-1
              reference: <testLibraryFragment>::@class::A::@field::x
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::x
              setter2: <testLibraryFragment>::@class::A::@setter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          getters
            get x @29
              reference: <testLibraryFragment>::@class::A::@getter::x
              element: <none>
          setters
            set x= @43
              reference: <testLibraryFragment>::@class::A::@setter::x
              element: <none>
              parameters
                _ @59
                  element: <none>
        class B @71
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          fields
            x @-1
              reference: <testLibraryFragment>::@class::B::@field::x
              element: <none>
              setter2: <testLibraryFragment>::@class::B::@setter::x
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
          setters
            set x= @94
              reference: <testLibraryFragment>::@class::B::@setter::x
              element: <none>
              parameters
                _ @100
                  element: <none>
  classes
    abstract class A
      firstFragment: <testLibraryFragment>::@class::A
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::A::@field::x
          type: num
          getter: <none>
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      getters
        abstract get x
          firstFragment: <testLibraryFragment>::@class::A::@getter::x
      setters
        abstract set x=
          firstFragment: <testLibraryFragment>::@class::A::@setter::x
          parameters
            requiredPositional covariant _
              type: num
    class B
      firstFragment: <testLibraryFragment>::@class::B
      fields
        synthetic x
          firstFragment: <testLibraryFragment>::@class::B::@field::x
          type: int
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
      setters
        set x=
          firstFragment: <testLibraryFragment>::@class::B::@setter::x
          parameters
            requiredPositional covariant _
              type: int
''');
  }

  test_instanceField_initializer() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  var t1 = 1;
  var t2 = 2.0;
  var t3 = null;
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          fields
            t1 @16
              reference: <testLibraryFragment>::@class::A::@field::t1
              enclosingElement3: <testLibraryFragment>::@class::A
              type: int
              shouldUseTypeForInitializerInference: false
            t2 @30
              reference: <testLibraryFragment>::@class::A::@field::t2
              enclosingElement3: <testLibraryFragment>::@class::A
              type: double
              shouldUseTypeForInitializerInference: false
            t3 @46
              reference: <testLibraryFragment>::@class::A::@field::t3
              enclosingElement3: <testLibraryFragment>::@class::A
              type: dynamic
              shouldUseTypeForInitializerInference: false
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          accessors
            synthetic get t1 @-1
              reference: <testLibraryFragment>::@class::A::@getter::t1
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: int
            synthetic set t1= @-1
              reference: <testLibraryFragment>::@class::A::@setter::t1
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional _t1 @-1
                  type: int
              returnType: void
            synthetic get t2 @-1
              reference: <testLibraryFragment>::@class::A::@getter::t2
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: double
            synthetic set t2= @-1
              reference: <testLibraryFragment>::@class::A::@setter::t2
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional _t2 @-1
                  type: double
              returnType: void
            synthetic get t3 @-1
              reference: <testLibraryFragment>::@class::A::@getter::t3
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: dynamic
            synthetic set t3= @-1
              reference: <testLibraryFragment>::@class::A::@setter::t3
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional _t3 @-1
                  type: dynamic
              returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          fields
            t1 @16
              reference: <testLibraryFragment>::@class::A::@field::t1
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::t1
              setter2: <testLibraryFragment>::@class::A::@setter::t1
            t2 @30
              reference: <testLibraryFragment>::@class::A::@field::t2
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::t2
              setter2: <testLibraryFragment>::@class::A::@setter::t2
            t3 @46
              reference: <testLibraryFragment>::@class::A::@field::t3
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::t3
              setter2: <testLibraryFragment>::@class::A::@setter::t3
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          getters
            get t1 @-1
              reference: <testLibraryFragment>::@class::A::@getter::t1
              element: <none>
            get t2 @-1
              reference: <testLibraryFragment>::@class::A::@getter::t2
              element: <none>
            get t3 @-1
              reference: <testLibraryFragment>::@class::A::@getter::t3
              element: <none>
          setters
            set t1= @-1
              reference: <testLibraryFragment>::@class::A::@setter::t1
              element: <none>
              parameters
                _t1 @-1
                  element: <none>
            set t2= @-1
              reference: <testLibraryFragment>::@class::A::@setter::t2
              element: <none>
              parameters
                _t2 @-1
                  element: <none>
            set t3= @-1
              reference: <testLibraryFragment>::@class::A::@setter::t3
              element: <none>
              parameters
                _t3 @-1
                  element: <none>
  classes
    class A
      firstFragment: <testLibraryFragment>::@class::A
      fields
        t1
          firstFragment: <testLibraryFragment>::@class::A::@field::t1
          type: int
          getter: <none>
          setter: <none>
        t2
          firstFragment: <testLibraryFragment>::@class::A::@field::t2
          type: double
          getter: <none>
          setter: <none>
        t3
          firstFragment: <testLibraryFragment>::@class::A::@field::t3
          type: dynamic
          getter: <none>
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      getters
        synthetic get t1
          firstFragment: <testLibraryFragment>::@class::A::@getter::t1
        synthetic get t2
          firstFragment: <testLibraryFragment>::@class::A::@getter::t2
        synthetic get t3
          firstFragment: <testLibraryFragment>::@class::A::@getter::t3
      setters
        synthetic set t1=
          firstFragment: <testLibraryFragment>::@class::A::@setter::t1
          parameters
            requiredPositional _t1
              type: int
        synthetic set t2=
          firstFragment: <testLibraryFragment>::@class::A::@setter::t2
          parameters
            requiredPositional _t2
              type: double
        synthetic set t3=
          firstFragment: <testLibraryFragment>::@class::A::@setter::t3
          parameters
            requiredPositional _t3
              type: dynamic
''');
  }

  test_method_error_hasMethod_noParameter_required() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  void m(int a) {}
}
class B extends A {
  void m(a, b) {}
}
''');
    // It's an error to add a new required parameter, but it is not a
    // top-level type inference error.
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          methods
            m @17
              reference: <testLibraryFragment>::@class::A::@method::m
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional a @23
                  type: int
              returnType: void
        class B @37
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          supertype: A
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
              superConstructor: <testLibraryFragment>::@class::A::@constructor::new
          methods
            m @58
              reference: <testLibraryFragment>::@class::B::@method::m
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional a @60
                  type: int
                requiredPositional b @63
                  type: dynamic
              returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          methods
            m @17
              reference: <testLibraryFragment>::@class::A::@method::m
              element: <none>
              parameters
                a @23
                  element: <none>
        class B @37
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
              superConstructor: <testLibraryFragment>::@class::A::@constructor::new
          methods
            m @58
              reference: <testLibraryFragment>::@class::B::@method::m
              element: <none>
              parameters
                a @60
                  element: <none>
                b @63
                  element: <none>
  classes
    class A
      firstFragment: <testLibraryFragment>::@class::A
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      methods
        m
          firstFragment: <testLibraryFragment>::@class::A::@method::m
          parameters
            requiredPositional a
              type: int
    class B
      firstFragment: <testLibraryFragment>::@class::B
      supertype: A
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
          superConstructor: <none>
      methods
        m
          firstFragment: <testLibraryFragment>::@class::B::@method::m
          parameters
            requiredPositional a
              type: int
            requiredPositional b
              type: dynamic
''');
  }

  test_method_error_noCombinedSuperSignature1() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  void m(int a) {}
}
class B {
  void m(String a) {}
}
class C extends A implements B {
  m(a) {}
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          methods
            m @17
              reference: <testLibraryFragment>::@class::A::@method::m
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional a @23
                  type: int
              returnType: void
        class B @37
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
          methods
            m @48
              reference: <testLibraryFragment>::@class::B::@method::m
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional a @57
                  type: String
              returnType: void
        class C @71
          reference: <testLibraryFragment>::@class::C
          enclosingElement3: <testLibraryFragment>
          supertype: A
          interfaces
            B
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::C
              superConstructor: <testLibraryFragment>::@class::A::@constructor::new
          methods
            m @100
              reference: <testLibraryFragment>::@class::C::@method::m
              enclosingElement3: <testLibraryFragment>::@class::C
              typeInferenceError: overrideNoCombinedSuperSignature
              parameters
                requiredPositional a @102
                  type: dynamic
              returnType: dynamic
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          methods
            m @17
              reference: <testLibraryFragment>::@class::A::@method::m
              element: <none>
              parameters
                a @23
                  element: <none>
        class B @37
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
          methods
            m @48
              reference: <testLibraryFragment>::@class::B::@method::m
              element: <none>
              parameters
                a @57
                  element: <none>
        class C @71
          reference: <testLibraryFragment>::@class::C
          element: <testLibraryFragment>::@class::C
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              element: <none>
              superConstructor: <testLibraryFragment>::@class::A::@constructor::new
          methods
            m @100
              reference: <testLibraryFragment>::@class::C::@method::m
              element: <none>
              parameters
                a @102
                  element: <none>
  classes
    class A
      firstFragment: <testLibraryFragment>::@class::A
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      methods
        m
          firstFragment: <testLibraryFragment>::@class::A::@method::m
          parameters
            requiredPositional a
              type: int
    class B
      firstFragment: <testLibraryFragment>::@class::B
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
      methods
        m
          firstFragment: <testLibraryFragment>::@class::B::@method::m
          parameters
            requiredPositional a
              type: String
    class C
      firstFragment: <testLibraryFragment>::@class::C
      supertype: A
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::C::@constructor::new
          superConstructor: <none>
      methods
        m
          firstFragment: <testLibraryFragment>::@class::C::@method::m
          parameters
            requiredPositional a
              type: dynamic
''');
  }

  test_method_error_noCombinedSuperSignature2() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  int foo(int x);
}

abstract class B {
  double foo(int x);
}

abstract class C implements A, B {
  Never foo(x);
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        abstract class A @15
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          methods
            abstract foo @25
              reference: <testLibraryFragment>::@class::A::@method::foo
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional x @33
                  type: int
              returnType: int
        abstract class B @55
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
          methods
            abstract foo @68
              reference: <testLibraryFragment>::@class::B::@method::foo
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional x @76
                  type: int
              returnType: double
        abstract class C @98
          reference: <testLibraryFragment>::@class::C
          enclosingElement3: <testLibraryFragment>
          interfaces
            A
            B
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::C
          methods
            abstract foo @126
              reference: <testLibraryFragment>::@class::C::@method::foo
              enclosingElement3: <testLibraryFragment>::@class::C
              typeInferenceError: overrideNoCombinedSuperSignature
              parameters
                requiredPositional x @130
                  type: dynamic
              returnType: Never
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @15
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          methods
            foo @25
              reference: <testLibraryFragment>::@class::A::@method::foo
              element: <none>
              parameters
                x @33
                  element: <none>
        class B @55
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
          methods
            foo @68
              reference: <testLibraryFragment>::@class::B::@method::foo
              element: <none>
              parameters
                x @76
                  element: <none>
        class C @98
          reference: <testLibraryFragment>::@class::C
          element: <testLibraryFragment>::@class::C
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              element: <none>
          methods
            foo @126
              reference: <testLibraryFragment>::@class::C::@method::foo
              element: <none>
              parameters
                x @130
                  element: <none>
  classes
    abstract class A
      firstFragment: <testLibraryFragment>::@class::A
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      methods
        abstract foo
          firstFragment: <testLibraryFragment>::@class::A::@method::foo
          parameters
            requiredPositional x
              type: int
    abstract class B
      firstFragment: <testLibraryFragment>::@class::B
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
      methods
        abstract foo
          firstFragment: <testLibraryFragment>::@class::B::@method::foo
          parameters
            requiredPositional x
              type: int
    abstract class C
      firstFragment: <testLibraryFragment>::@class::C
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::C::@constructor::new
      methods
        abstract foo
          firstFragment: <testLibraryFragment>::@class::C::@method::foo
          parameters
            requiredPositional x
              type: dynamic
''');
  }

  test_method_error_noCombinedSuperSignature3() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  int m() {}
}
class B {
  String m() {}
}
class C extends A implements B {
  m() {}
}
''');
    // TODO(scheglov): test for inference failure error
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          methods
            m @16
              reference: <testLibraryFragment>::@class::A::@method::m
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: int
        class B @31
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
          methods
            m @44
              reference: <testLibraryFragment>::@class::B::@method::m
              enclosingElement3: <testLibraryFragment>::@class::B
              returnType: String
        class C @59
          reference: <testLibraryFragment>::@class::C
          enclosingElement3: <testLibraryFragment>
          supertype: A
          interfaces
            B
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::C
              superConstructor: <testLibraryFragment>::@class::A::@constructor::new
          methods
            m @88
              reference: <testLibraryFragment>::@class::C::@method::m
              enclosingElement3: <testLibraryFragment>::@class::C
              typeInferenceError: overrideNoCombinedSuperSignature
              returnType: dynamic
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          methods
            m @16
              reference: <testLibraryFragment>::@class::A::@method::m
              element: <none>
        class B @31
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
          methods
            m @44
              reference: <testLibraryFragment>::@class::B::@method::m
              element: <none>
        class C @59
          reference: <testLibraryFragment>::@class::C
          element: <testLibraryFragment>::@class::C
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              element: <none>
              superConstructor: <testLibraryFragment>::@class::A::@constructor::new
          methods
            m @88
              reference: <testLibraryFragment>::@class::C::@method::m
              element: <none>
  classes
    class A
      firstFragment: <testLibraryFragment>::@class::A
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      methods
        m
          firstFragment: <testLibraryFragment>::@class::A::@method::m
    class B
      firstFragment: <testLibraryFragment>::@class::B
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
      methods
        m
          firstFragment: <testLibraryFragment>::@class::B::@method::m
    class C
      firstFragment: <testLibraryFragment>::@class::C
      supertype: A
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::C::@constructor::new
          superConstructor: <none>
      methods
        m
          firstFragment: <testLibraryFragment>::@class::C::@method::m
''');
  }

  test_method_error_noCombinedSuperSignature_generic1() async {
    var library = await _encodeDecodeLibrary(r'''
class A<T> {
  void m(T a) {}
}
class B<E> {
  void m(E a) {}
}
class C extends A<int> implements B<double> {
  m(a) {}
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          typeParameters
            covariant T @8
              defaultType: dynamic
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          methods
            m @20
              reference: <testLibraryFragment>::@class::A::@method::m
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional a @24
                  type: T
              returnType: void
        class B @38
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          typeParameters
            covariant E @40
              defaultType: dynamic
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
          methods
            m @52
              reference: <testLibraryFragment>::@class::B::@method::m
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional a @56
                  type: E
              returnType: void
        class C @70
          reference: <testLibraryFragment>::@class::C
          enclosingElement3: <testLibraryFragment>
          supertype: A<int>
          interfaces
            B<double>
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::C
              superConstructor: ConstructorMember
                base: <testLibraryFragment>::@class::A::@constructor::new
                substitution: {T: int}
          methods
            m @112
              reference: <testLibraryFragment>::@class::C::@method::m
              enclosingElement3: <testLibraryFragment>::@class::C
              typeInferenceError: overrideNoCombinedSuperSignature
              parameters
                requiredPositional a @114
                  type: dynamic
              returnType: dynamic
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          typeParameters
            T @8
              element: <none>
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          methods
            m @20
              reference: <testLibraryFragment>::@class::A::@method::m
              element: <none>
              parameters
                a @24
                  element: <none>
        class B @38
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          typeParameters
            E @40
              element: <none>
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
          methods
            m @52
              reference: <testLibraryFragment>::@class::B::@method::m
              element: <none>
              parameters
                a @56
                  element: <none>
        class C @70
          reference: <testLibraryFragment>::@class::C
          element: <testLibraryFragment>::@class::C
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              element: <none>
              superConstructor: ConstructorMember
                base: <testLibraryFragment>::@class::A::@constructor::new
                substitution: {T: int}
          methods
            m @112
              reference: <testLibraryFragment>::@class::C::@method::m
              element: <none>
              parameters
                a @114
                  element: <none>
  classes
    class A
      firstFragment: <testLibraryFragment>::@class::A
      typeParameters
        T
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      methods
        m
          firstFragment: <testLibraryFragment>::@class::A::@method::m
          parameters
            requiredPositional a
              type: T
    class B
      firstFragment: <testLibraryFragment>::@class::B
      typeParameters
        E
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
      methods
        m
          firstFragment: <testLibraryFragment>::@class::B::@method::m
          parameters
            requiredPositional a
              type: E
    class C
      firstFragment: <testLibraryFragment>::@class::C
      supertype: A<int>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::C::@constructor::new
          superConstructor: <none>
      methods
        m
          firstFragment: <testLibraryFragment>::@class::C::@method::m
          parameters
            requiredPositional a
              type: dynamic
''');
  }

  test_method_error_noCombinedSuperSignature_generic2() async {
    var library = await _encodeDecodeLibrary(r'''
class A<K, V> {
  V m(K a) {}
}
class B<T> {
  T m(int a) {}
}
class C extends A<int, String> implements B<double> {
  m(a) {}
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          typeParameters
            covariant K @8
              defaultType: dynamic
            covariant V @11
              defaultType: dynamic
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          methods
            m @20
              reference: <testLibraryFragment>::@class::A::@method::m
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional a @24
                  type: K
              returnType: V
        class B @38
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          typeParameters
            covariant T @40
              defaultType: dynamic
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
          methods
            m @49
              reference: <testLibraryFragment>::@class::B::@method::m
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional a @55
                  type: int
              returnType: T
        class C @69
          reference: <testLibraryFragment>::@class::C
          enclosingElement3: <testLibraryFragment>
          supertype: A<int, String>
          interfaces
            B<double>
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::C
              superConstructor: ConstructorMember
                base: <testLibraryFragment>::@class::A::@constructor::new
                substitution: {K: int, V: String}
          methods
            m @119
              reference: <testLibraryFragment>::@class::C::@method::m
              enclosingElement3: <testLibraryFragment>::@class::C
              typeInferenceError: overrideNoCombinedSuperSignature
              parameters
                requiredPositional a @121
                  type: dynamic
              returnType: dynamic
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          typeParameters
            K @8
              element: <none>
            V @11
              element: <none>
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          methods
            m @20
              reference: <testLibraryFragment>::@class::A::@method::m
              element: <none>
              parameters
                a @24
                  element: <none>
        class B @38
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          typeParameters
            T @40
              element: <none>
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
          methods
            m @49
              reference: <testLibraryFragment>::@class::B::@method::m
              element: <none>
              parameters
                a @55
                  element: <none>
        class C @69
          reference: <testLibraryFragment>::@class::C
          element: <testLibraryFragment>::@class::C
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              element: <none>
              superConstructor: ConstructorMember
                base: <testLibraryFragment>::@class::A::@constructor::new
                substitution: {K: int, V: String}
          methods
            m @119
              reference: <testLibraryFragment>::@class::C::@method::m
              element: <none>
              parameters
                a @121
                  element: <none>
  classes
    class A
      firstFragment: <testLibraryFragment>::@class::A
      typeParameters
        K
        V
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      methods
        m
          firstFragment: <testLibraryFragment>::@class::A::@method::m
          parameters
            requiredPositional a
              type: K
    class B
      firstFragment: <testLibraryFragment>::@class::B
      typeParameters
        T
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
      methods
        m
          firstFragment: <testLibraryFragment>::@class::B::@method::m
          parameters
            requiredPositional a
              type: int
    class C
      firstFragment: <testLibraryFragment>::@class::C
      supertype: A<int, String>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::C::@constructor::new
          superConstructor: <none>
      methods
        m
          firstFragment: <testLibraryFragment>::@class::C::@method::m
          parameters
            requiredPositional a
              type: dynamic
''');
  }

  test_method_missing_hasMethod_noParameter_named() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  void m(int a) {}
}
class B extends A {
  m(a, {b}) {}
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          methods
            m @17
              reference: <testLibraryFragment>::@class::A::@method::m
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional a @23
                  type: int
              returnType: void
        class B @37
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          supertype: A
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
              superConstructor: <testLibraryFragment>::@class::A::@constructor::new
          methods
            m @53
              reference: <testLibraryFragment>::@class::B::@method::m
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional a @55
                  type: int
                optionalNamed default b @59
                  reference: <testLibraryFragment>::@class::B::@method::m::@parameter::b
                  type: dynamic
              returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          methods
            m @17
              reference: <testLibraryFragment>::@class::A::@method::m
              element: <none>
              parameters
                a @23
                  element: <none>
        class B @37
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
              superConstructor: <testLibraryFragment>::@class::A::@constructor::new
          methods
            m @53
              reference: <testLibraryFragment>::@class::B::@method::m
              element: <none>
              parameters
                a @55
                  element: <none>
                default b @59
                  reference: <testLibraryFragment>::@class::B::@method::m::@parameter::b
                  element: <none>
  classes
    class A
      firstFragment: <testLibraryFragment>::@class::A
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      methods
        m
          firstFragment: <testLibraryFragment>::@class::A::@method::m
          parameters
            requiredPositional a
              type: int
    class B
      firstFragment: <testLibraryFragment>::@class::B
      supertype: A
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
          superConstructor: <none>
      methods
        m
          firstFragment: <testLibraryFragment>::@class::B::@method::m
          parameters
            requiredPositional a
              type: int
            optionalNamed b
              firstFragment: <testLibraryFragment>::@class::B::@method::m::@parameter::b
              type: dynamic
''');
  }

  test_method_missing_hasMethod_noParameter_optional() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  void m(int a) {}
}
class B extends A {
  m(a, [b]) {}
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          methods
            m @17
              reference: <testLibraryFragment>::@class::A::@method::m
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional a @23
                  type: int
              returnType: void
        class B @37
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          supertype: A
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
              superConstructor: <testLibraryFragment>::@class::A::@constructor::new
          methods
            m @53
              reference: <testLibraryFragment>::@class::B::@method::m
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional a @55
                  type: int
                optionalPositional default b @59
                  type: dynamic
              returnType: void
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          methods
            m @17
              reference: <testLibraryFragment>::@class::A::@method::m
              element: <none>
              parameters
                a @23
                  element: <none>
        class B @37
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
              superConstructor: <testLibraryFragment>::@class::A::@constructor::new
          methods
            m @53
              reference: <testLibraryFragment>::@class::B::@method::m
              element: <none>
              parameters
                a @55
                  element: <none>
                default b @59
                  element: <none>
  classes
    class A
      firstFragment: <testLibraryFragment>::@class::A
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      methods
        m
          firstFragment: <testLibraryFragment>::@class::A::@method::m
          parameters
            requiredPositional a
              type: int
    class B
      firstFragment: <testLibraryFragment>::@class::B
      supertype: A
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
          superConstructor: <none>
      methods
        m
          firstFragment: <testLibraryFragment>::@class::B::@method::m
          parameters
            requiredPositional a
              type: int
            optionalPositional b
              type: dynamic
''');
  }

  test_method_missing_hasMethod_withoutTypes() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  m(a) {}
}
class B extends A {
  m(a) {}
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          methods
            m @12
              reference: <testLibraryFragment>::@class::A::@method::m
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional a @14
                  type: dynamic
              returnType: dynamic
        class B @28
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          supertype: A
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
              superConstructor: <testLibraryFragment>::@class::A::@constructor::new
          methods
            m @44
              reference: <testLibraryFragment>::@class::B::@method::m
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional a @46
                  type: dynamic
              returnType: dynamic
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          methods
            m @12
              reference: <testLibraryFragment>::@class::A::@method::m
              element: <none>
              parameters
                a @14
                  element: <none>
        class B @28
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
              superConstructor: <testLibraryFragment>::@class::A::@constructor::new
          methods
            m @44
              reference: <testLibraryFragment>::@class::B::@method::m
              element: <none>
              parameters
                a @46
                  element: <none>
  classes
    class A
      firstFragment: <testLibraryFragment>::@class::A
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      methods
        m
          firstFragment: <testLibraryFragment>::@class::A::@method::m
          parameters
            requiredPositional a
              type: dynamic
    class B
      firstFragment: <testLibraryFragment>::@class::B
      supertype: A
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
          superConstructor: <none>
      methods
        m
          firstFragment: <testLibraryFragment>::@class::B::@method::m
          parameters
            requiredPositional a
              type: dynamic
''');
  }

  test_method_missing_noMember() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  int foo(String a) => null;
}
class B extends A {
  m(a) {}
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          methods
            foo @16
              reference: <testLibraryFragment>::@class::A::@method::foo
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional a @27
                  type: String
              returnType: int
        class B @47
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          supertype: A
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
              superConstructor: <testLibraryFragment>::@class::A::@constructor::new
          methods
            m @63
              reference: <testLibraryFragment>::@class::B::@method::m
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional a @65
                  type: dynamic
              returnType: dynamic
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          methods
            foo @16
              reference: <testLibraryFragment>::@class::A::@method::foo
              element: <none>
              parameters
                a @27
                  element: <none>
        class B @47
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
              superConstructor: <testLibraryFragment>::@class::A::@constructor::new
          methods
            m @63
              reference: <testLibraryFragment>::@class::B::@method::m
              element: <none>
              parameters
                a @65
                  element: <none>
  classes
    class A
      firstFragment: <testLibraryFragment>::@class::A
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      methods
        foo
          firstFragment: <testLibraryFragment>::@class::A::@method::foo
          parameters
            requiredPositional a
              type: String
    class B
      firstFragment: <testLibraryFragment>::@class::B
      supertype: A
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
          superConstructor: <none>
      methods
        m
          firstFragment: <testLibraryFragment>::@class::B::@method::m
          parameters
            requiredPositional a
              type: dynamic
''');
  }

  test_method_missing_notMethod() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  int m = 42;
}
class B extends A {
  m(a) {}
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          fields
            m @16
              reference: <testLibraryFragment>::@class::A::@field::m
              enclosingElement3: <testLibraryFragment>::@class::A
              type: int
              shouldUseTypeForInitializerInference: true
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          accessors
            synthetic get m @-1
              reference: <testLibraryFragment>::@class::A::@getter::m
              enclosingElement3: <testLibraryFragment>::@class::A
              returnType: int
            synthetic set m= @-1
              reference: <testLibraryFragment>::@class::A::@setter::m
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional _m @-1
                  type: int
              returnType: void
        class B @32
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          supertype: A
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
              superConstructor: <testLibraryFragment>::@class::A::@constructor::new
          methods
            m @48
              reference: <testLibraryFragment>::@class::B::@method::m
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional a @50
                  type: dynamic
              returnType: dynamic
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          fields
            m @16
              reference: <testLibraryFragment>::@class::A::@field::m
              element: <none>
              getter2: <testLibraryFragment>::@class::A::@getter::m
              setter2: <testLibraryFragment>::@class::A::@setter::m
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          getters
            get m @-1
              reference: <testLibraryFragment>::@class::A::@getter::m
              element: <none>
          setters
            set m= @-1
              reference: <testLibraryFragment>::@class::A::@setter::m
              element: <none>
              parameters
                _m @-1
                  element: <none>
        class B @32
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
              superConstructor: <testLibraryFragment>::@class::A::@constructor::new
          methods
            m @48
              reference: <testLibraryFragment>::@class::B::@method::m
              element: <none>
              parameters
                a @50
                  element: <none>
  classes
    class A
      firstFragment: <testLibraryFragment>::@class::A
      fields
        m
          firstFragment: <testLibraryFragment>::@class::A::@field::m
          type: int
          getter: <none>
          setter: <none>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      getters
        synthetic get m
          firstFragment: <testLibraryFragment>::@class::A::@getter::m
      setters
        synthetic set m=
          firstFragment: <testLibraryFragment>::@class::A::@setter::m
          parameters
            requiredPositional _m
              type: int
    class B
      firstFragment: <testLibraryFragment>::@class::B
      supertype: A
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
          superConstructor: <none>
      methods
        m
          firstFragment: <testLibraryFragment>::@class::B::@method::m
          parameters
            requiredPositional a
              type: dynamic
''');
  }

  test_method_OK_sequence_extendsExtends_generic() async {
    var library = await _encodeDecodeLibrary(r'''
class A<K, V> {
  V m(K a) {}
}
class B<T> extends A<int, T> {}
class C extends B<String> {
  m(a) {}
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          typeParameters
            covariant K @8
              defaultType: dynamic
            covariant V @11
              defaultType: dynamic
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          methods
            m @20
              reference: <testLibraryFragment>::@class::A::@method::m
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional a @24
                  type: K
              returnType: V
        class B @38
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          typeParameters
            covariant T @40
              defaultType: dynamic
          supertype: A<int, T>
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
              superConstructor: ConstructorMember
                base: <testLibraryFragment>::@class::A::@constructor::new
                substitution: {K: int, V: T}
        class C @70
          reference: <testLibraryFragment>::@class::C
          enclosingElement3: <testLibraryFragment>
          supertype: B<String>
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::C
              superConstructor: ConstructorMember
                base: <testLibraryFragment>::@class::B::@constructor::new
                substitution: {T: String}
          methods
            m @94
              reference: <testLibraryFragment>::@class::C::@method::m
              enclosingElement3: <testLibraryFragment>::@class::C
              parameters
                requiredPositional a @96
                  type: int
              returnType: String
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          typeParameters
            K @8
              element: <none>
            V @11
              element: <none>
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          methods
            m @20
              reference: <testLibraryFragment>::@class::A::@method::m
              element: <none>
              parameters
                a @24
                  element: <none>
        class B @38
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          typeParameters
            T @40
              element: <none>
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
              superConstructor: ConstructorMember
                base: <testLibraryFragment>::@class::A::@constructor::new
                substitution: {K: int, V: T}
        class C @70
          reference: <testLibraryFragment>::@class::C
          element: <testLibraryFragment>::@class::C
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              element: <none>
              superConstructor: ConstructorMember
                base: <testLibraryFragment>::@class::B::@constructor::new
                substitution: {T: String}
          methods
            m @94
              reference: <testLibraryFragment>::@class::C::@method::m
              element: <none>
              parameters
                a @96
                  element: <none>
  classes
    class A
      firstFragment: <testLibraryFragment>::@class::A
      typeParameters
        K
        V
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      methods
        m
          firstFragment: <testLibraryFragment>::@class::A::@method::m
          parameters
            requiredPositional a
              type: K
    class B
      firstFragment: <testLibraryFragment>::@class::B
      typeParameters
        T
      supertype: A<int, T>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
          superConstructor: <none>
    class C
      firstFragment: <testLibraryFragment>::@class::C
      supertype: B<String>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::C::@constructor::new
          superConstructor: <none>
      methods
        m
          firstFragment: <testLibraryFragment>::@class::C::@method::m
          parameters
            requiredPositional a
              type: int
''');
  }

  test_method_OK_sequence_inferMiddle_extendsExtends() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  String m(int a) {}
}
class B extends A {
  m(a) {}
}
class C extends B {
  m(a) {}
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          methods
            m @19
              reference: <testLibraryFragment>::@class::A::@method::m
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional a @25
                  type: int
              returnType: String
        class B @39
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          supertype: A
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
              superConstructor: <testLibraryFragment>::@class::A::@constructor::new
          methods
            m @55
              reference: <testLibraryFragment>::@class::B::@method::m
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional a @57
                  type: int
              returnType: String
        class C @71
          reference: <testLibraryFragment>::@class::C
          enclosingElement3: <testLibraryFragment>
          supertype: B
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::C
              superConstructor: <testLibraryFragment>::@class::B::@constructor::new
          methods
            m @87
              reference: <testLibraryFragment>::@class::C::@method::m
              enclosingElement3: <testLibraryFragment>::@class::C
              parameters
                requiredPositional a @89
                  type: int
              returnType: String
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          methods
            m @19
              reference: <testLibraryFragment>::@class::A::@method::m
              element: <none>
              parameters
                a @25
                  element: <none>
        class B @39
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
              superConstructor: <testLibraryFragment>::@class::A::@constructor::new
          methods
            m @55
              reference: <testLibraryFragment>::@class::B::@method::m
              element: <none>
              parameters
                a @57
                  element: <none>
        class C @71
          reference: <testLibraryFragment>::@class::C
          element: <testLibraryFragment>::@class::C
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              element: <none>
              superConstructor: <testLibraryFragment>::@class::B::@constructor::new
          methods
            m @87
              reference: <testLibraryFragment>::@class::C::@method::m
              element: <none>
              parameters
                a @89
                  element: <none>
  classes
    class A
      firstFragment: <testLibraryFragment>::@class::A
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      methods
        m
          firstFragment: <testLibraryFragment>::@class::A::@method::m
          parameters
            requiredPositional a
              type: int
    class B
      firstFragment: <testLibraryFragment>::@class::B
      supertype: A
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
          superConstructor: <none>
      methods
        m
          firstFragment: <testLibraryFragment>::@class::B::@method::m
          parameters
            requiredPositional a
              type: int
    class C
      firstFragment: <testLibraryFragment>::@class::C
      supertype: B
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::C::@constructor::new
          superConstructor: <none>
      methods
        m
          firstFragment: <testLibraryFragment>::@class::C::@method::m
          parameters
            requiredPositional a
              type: int
''');
  }

  test_method_OK_sequence_inferMiddle_extendsImplements() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  String m(int a) {}
}
class B implements A {
  m(a) {}
}
class C extends B {
  m(a) {}
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          methods
            m @19
              reference: <testLibraryFragment>::@class::A::@method::m
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional a @25
                  type: int
              returnType: String
        class B @39
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          interfaces
            A
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
          methods
            m @58
              reference: <testLibraryFragment>::@class::B::@method::m
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional a @60
                  type: int
              returnType: String
        class C @74
          reference: <testLibraryFragment>::@class::C
          enclosingElement3: <testLibraryFragment>
          supertype: B
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::C
              superConstructor: <testLibraryFragment>::@class::B::@constructor::new
          methods
            m @90
              reference: <testLibraryFragment>::@class::C::@method::m
              enclosingElement3: <testLibraryFragment>::@class::C
              parameters
                requiredPositional a @92
                  type: int
              returnType: String
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          methods
            m @19
              reference: <testLibraryFragment>::@class::A::@method::m
              element: <none>
              parameters
                a @25
                  element: <none>
        class B @39
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
          methods
            m @58
              reference: <testLibraryFragment>::@class::B::@method::m
              element: <none>
              parameters
                a @60
                  element: <none>
        class C @74
          reference: <testLibraryFragment>::@class::C
          element: <testLibraryFragment>::@class::C
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              element: <none>
              superConstructor: <testLibraryFragment>::@class::B::@constructor::new
          methods
            m @90
              reference: <testLibraryFragment>::@class::C::@method::m
              element: <none>
              parameters
                a @92
                  element: <none>
  classes
    class A
      firstFragment: <testLibraryFragment>::@class::A
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      methods
        m
          firstFragment: <testLibraryFragment>::@class::A::@method::m
          parameters
            requiredPositional a
              type: int
    class B
      firstFragment: <testLibraryFragment>::@class::B
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
      methods
        m
          firstFragment: <testLibraryFragment>::@class::B::@method::m
          parameters
            requiredPositional a
              type: int
    class C
      firstFragment: <testLibraryFragment>::@class::C
      supertype: B
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::C::@constructor::new
          superConstructor: <none>
      methods
        m
          firstFragment: <testLibraryFragment>::@class::C::@method::m
          parameters
            requiredPositional a
              type: int
''');
  }

  test_method_OK_sequence_inferMiddle_extendsWith() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  String m(int a) {}
}
class B extends Object with A {
  m(a) {}
}
class C extends B {
  m(a) {}
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          methods
            m @19
              reference: <testLibraryFragment>::@class::A::@method::m
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional a @25
                  type: int
              returnType: String
        class B @39
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          supertype: Object
          mixins
            A
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
          methods
            m @67
              reference: <testLibraryFragment>::@class::B::@method::m
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional a @69
                  type: int
              returnType: String
        class C @83
          reference: <testLibraryFragment>::@class::C
          enclosingElement3: <testLibraryFragment>
          supertype: B
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::C
              superConstructor: <testLibraryFragment>::@class::B::@constructor::new
          methods
            m @99
              reference: <testLibraryFragment>::@class::C::@method::m
              enclosingElement3: <testLibraryFragment>::@class::C
              parameters
                requiredPositional a @101
                  type: int
              returnType: String
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          methods
            m @19
              reference: <testLibraryFragment>::@class::A::@method::m
              element: <none>
              parameters
                a @25
                  element: <none>
        class B @39
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
          methods
            m @67
              reference: <testLibraryFragment>::@class::B::@method::m
              element: <none>
              parameters
                a @69
                  element: <none>
        class C @83
          reference: <testLibraryFragment>::@class::C
          element: <testLibraryFragment>::@class::C
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              element: <none>
              superConstructor: <testLibraryFragment>::@class::B::@constructor::new
          methods
            m @99
              reference: <testLibraryFragment>::@class::C::@method::m
              element: <none>
              parameters
                a @101
                  element: <none>
  classes
    class A
      firstFragment: <testLibraryFragment>::@class::A
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      methods
        m
          firstFragment: <testLibraryFragment>::@class::A::@method::m
          parameters
            requiredPositional a
              type: int
    class B
      firstFragment: <testLibraryFragment>::@class::B
      supertype: Object
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
      methods
        m
          firstFragment: <testLibraryFragment>::@class::B::@method::m
          parameters
            requiredPositional a
              type: int
    class C
      firstFragment: <testLibraryFragment>::@class::C
      supertype: B
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::C::@constructor::new
          superConstructor: <none>
      methods
        m
          firstFragment: <testLibraryFragment>::@class::C::@method::m
          parameters
            requiredPositional a
              type: int
''');
  }

  test_method_OK_single_extends_direct_generic() async {
    var library = await _encodeDecodeLibrary(r'''
class A<K, V> {
  V m(K a, double b) {}
}
class B extends A<int, String> {
  m(a, b) {}
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          typeParameters
            covariant K @8
              defaultType: dynamic
            covariant V @11
              defaultType: dynamic
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          methods
            m @20
              reference: <testLibraryFragment>::@class::A::@method::m
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional a @24
                  type: K
                requiredPositional b @34
                  type: double
              returnType: V
        class B @48
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          supertype: A<int, String>
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
              superConstructor: ConstructorMember
                base: <testLibraryFragment>::@class::A::@constructor::new
                substitution: {K: int, V: String}
          methods
            m @77
              reference: <testLibraryFragment>::@class::B::@method::m
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional a @79
                  type: int
                requiredPositional b @82
                  type: double
              returnType: String
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          typeParameters
            K @8
              element: <none>
            V @11
              element: <none>
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          methods
            m @20
              reference: <testLibraryFragment>::@class::A::@method::m
              element: <none>
              parameters
                a @24
                  element: <none>
                b @34
                  element: <none>
        class B @48
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
              superConstructor: ConstructorMember
                base: <testLibraryFragment>::@class::A::@constructor::new
                substitution: {K: int, V: String}
          methods
            m @77
              reference: <testLibraryFragment>::@class::B::@method::m
              element: <none>
              parameters
                a @79
                  element: <none>
                b @82
                  element: <none>
  classes
    class A
      firstFragment: <testLibraryFragment>::@class::A
      typeParameters
        K
        V
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      methods
        m
          firstFragment: <testLibraryFragment>::@class::A::@method::m
          parameters
            requiredPositional a
              type: K
            requiredPositional b
              type: double
    class B
      firstFragment: <testLibraryFragment>::@class::B
      supertype: A<int, String>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
          superConstructor: <none>
      methods
        m
          firstFragment: <testLibraryFragment>::@class::B::@method::m
          parameters
            requiredPositional a
              type: int
            requiredPositional b
              type: double
''');
  }

  test_method_OK_single_extends_direct_notGeneric() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  String m(int a) {}
}
class B extends A {
  m(a) {}
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          methods
            m @19
              reference: <testLibraryFragment>::@class::A::@method::m
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional a @25
                  type: int
              returnType: String
        class B @39
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          supertype: A
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
              superConstructor: <testLibraryFragment>::@class::A::@constructor::new
          methods
            m @55
              reference: <testLibraryFragment>::@class::B::@method::m
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional a @57
                  type: int
              returnType: String
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          methods
            m @19
              reference: <testLibraryFragment>::@class::A::@method::m
              element: <none>
              parameters
                a @25
                  element: <none>
        class B @39
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
              superConstructor: <testLibraryFragment>::@class::A::@constructor::new
          methods
            m @55
              reference: <testLibraryFragment>::@class::B::@method::m
              element: <none>
              parameters
                a @57
                  element: <none>
  classes
    class A
      firstFragment: <testLibraryFragment>::@class::A
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      methods
        m
          firstFragment: <testLibraryFragment>::@class::A::@method::m
          parameters
            requiredPositional a
              type: int
    class B
      firstFragment: <testLibraryFragment>::@class::B
      supertype: A
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
          superConstructor: <none>
      methods
        m
          firstFragment: <testLibraryFragment>::@class::B::@method::m
          parameters
            requiredPositional a
              type: int
''');
  }

  test_method_OK_single_extends_direct_notGeneric_named() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  String m(int a, {double b}) {}
}
class B extends A {
  m(a, {b}) {}
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          methods
            m @19
              reference: <testLibraryFragment>::@class::A::@method::m
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional a @25
                  type: int
                optionalNamed default b @36
                  reference: <testLibraryFragment>::@class::A::@method::m::@parameter::b
                  type: double
              returnType: String
        class B @51
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          supertype: A
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
              superConstructor: <testLibraryFragment>::@class::A::@constructor::new
          methods
            m @67
              reference: <testLibraryFragment>::@class::B::@method::m
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional a @69
                  type: int
                optionalNamed default b @73
                  reference: <testLibraryFragment>::@class::B::@method::m::@parameter::b
                  type: double
              returnType: String
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          methods
            m @19
              reference: <testLibraryFragment>::@class::A::@method::m
              element: <none>
              parameters
                a @25
                  element: <none>
                default b @36
                  reference: <testLibraryFragment>::@class::A::@method::m::@parameter::b
                  element: <none>
        class B @51
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
              superConstructor: <testLibraryFragment>::@class::A::@constructor::new
          methods
            m @67
              reference: <testLibraryFragment>::@class::B::@method::m
              element: <none>
              parameters
                a @69
                  element: <none>
                default b @73
                  reference: <testLibraryFragment>::@class::B::@method::m::@parameter::b
                  element: <none>
  classes
    class A
      firstFragment: <testLibraryFragment>::@class::A
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      methods
        m
          firstFragment: <testLibraryFragment>::@class::A::@method::m
          parameters
            requiredPositional a
              type: int
            optionalNamed b
              firstFragment: <testLibraryFragment>::@class::A::@method::m::@parameter::b
              type: double
    class B
      firstFragment: <testLibraryFragment>::@class::B
      supertype: A
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
          superConstructor: <none>
      methods
        m
          firstFragment: <testLibraryFragment>::@class::B::@method::m
          parameters
            requiredPositional a
              type: int
            optionalNamed b
              firstFragment: <testLibraryFragment>::@class::B::@method::m::@parameter::b
              type: double
''');
  }

  test_method_OK_single_extends_direct_notGeneric_positional() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  String m(int a, [double b]) {}
}
class B extends A {
  m(a, [b]) {}
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          methods
            m @19
              reference: <testLibraryFragment>::@class::A::@method::m
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional a @25
                  type: int
                optionalPositional default b @36
                  type: double
              returnType: String
        class B @51
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          supertype: A
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
              superConstructor: <testLibraryFragment>::@class::A::@constructor::new
          methods
            m @67
              reference: <testLibraryFragment>::@class::B::@method::m
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional a @69
                  type: int
                optionalPositional default b @73
                  type: double
              returnType: String
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          methods
            m @19
              reference: <testLibraryFragment>::@class::A::@method::m
              element: <none>
              parameters
                a @25
                  element: <none>
                default b @36
                  element: <none>
        class B @51
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
              superConstructor: <testLibraryFragment>::@class::A::@constructor::new
          methods
            m @67
              reference: <testLibraryFragment>::@class::B::@method::m
              element: <none>
              parameters
                a @69
                  element: <none>
                default b @73
                  element: <none>
  classes
    class A
      firstFragment: <testLibraryFragment>::@class::A
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      methods
        m
          firstFragment: <testLibraryFragment>::@class::A::@method::m
          parameters
            requiredPositional a
              type: int
            optionalPositional b
              type: double
    class B
      firstFragment: <testLibraryFragment>::@class::B
      supertype: A
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
          superConstructor: <none>
      methods
        m
          firstFragment: <testLibraryFragment>::@class::B::@method::m
          parameters
            requiredPositional a
              type: int
            optionalPositional b
              type: double
''');
  }

  test_method_OK_single_extends_indirect_generic() async {
    var library = await _encodeDecodeLibrary(r'''
class A<K, V> {
  V m(K a) {}
}
class B<T> extends A<int, T> {}
class C extends B<String> {
  m(a) {}
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          typeParameters
            covariant K @8
              defaultType: dynamic
            covariant V @11
              defaultType: dynamic
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          methods
            m @20
              reference: <testLibraryFragment>::@class::A::@method::m
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional a @24
                  type: K
              returnType: V
        class B @38
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          typeParameters
            covariant T @40
              defaultType: dynamic
          supertype: A<int, T>
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
              superConstructor: ConstructorMember
                base: <testLibraryFragment>::@class::A::@constructor::new
                substitution: {K: int, V: T}
        class C @70
          reference: <testLibraryFragment>::@class::C
          enclosingElement3: <testLibraryFragment>
          supertype: B<String>
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::C
              superConstructor: ConstructorMember
                base: <testLibraryFragment>::@class::B::@constructor::new
                substitution: {T: String}
          methods
            m @94
              reference: <testLibraryFragment>::@class::C::@method::m
              enclosingElement3: <testLibraryFragment>::@class::C
              parameters
                requiredPositional a @96
                  type: int
              returnType: String
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          typeParameters
            K @8
              element: <none>
            V @11
              element: <none>
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          methods
            m @20
              reference: <testLibraryFragment>::@class::A::@method::m
              element: <none>
              parameters
                a @24
                  element: <none>
        class B @38
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          typeParameters
            T @40
              element: <none>
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
              superConstructor: ConstructorMember
                base: <testLibraryFragment>::@class::A::@constructor::new
                substitution: {K: int, V: T}
        class C @70
          reference: <testLibraryFragment>::@class::C
          element: <testLibraryFragment>::@class::C
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              element: <none>
              superConstructor: ConstructorMember
                base: <testLibraryFragment>::@class::B::@constructor::new
                substitution: {T: String}
          methods
            m @94
              reference: <testLibraryFragment>::@class::C::@method::m
              element: <none>
              parameters
                a @96
                  element: <none>
  classes
    class A
      firstFragment: <testLibraryFragment>::@class::A
      typeParameters
        K
        V
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      methods
        m
          firstFragment: <testLibraryFragment>::@class::A::@method::m
          parameters
            requiredPositional a
              type: K
    class B
      firstFragment: <testLibraryFragment>::@class::B
      typeParameters
        T
      supertype: A<int, T>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
          superConstructor: <none>
    class C
      firstFragment: <testLibraryFragment>::@class::C
      supertype: B<String>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::C::@constructor::new
          superConstructor: <none>
      methods
        m
          firstFragment: <testLibraryFragment>::@class::C::@method::m
          parameters
            requiredPositional a
              type: int
''');
  }

  test_method_OK_single_implements_direct_generic() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A<K, V> {
  V m(K a);
}
class B implements A<int, String> {
  m(a) {}
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        abstract class A @15
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          typeParameters
            covariant K @17
              defaultType: dynamic
            covariant V @20
              defaultType: dynamic
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          methods
            abstract m @29
              reference: <testLibraryFragment>::@class::A::@method::m
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional a @33
                  type: K
              returnType: V
        class B @45
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          interfaces
            A<int, String>
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
          methods
            m @77
              reference: <testLibraryFragment>::@class::B::@method::m
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional a @79
                  type: int
              returnType: String
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @15
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          typeParameters
            K @17
              element: <none>
            V @20
              element: <none>
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          methods
            m @29
              reference: <testLibraryFragment>::@class::A::@method::m
              element: <none>
              parameters
                a @33
                  element: <none>
        class B @45
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
          methods
            m @77
              reference: <testLibraryFragment>::@class::B::@method::m
              element: <none>
              parameters
                a @79
                  element: <none>
  classes
    abstract class A
      firstFragment: <testLibraryFragment>::@class::A
      typeParameters
        K
        V
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      methods
        abstract m
          firstFragment: <testLibraryFragment>::@class::A::@method::m
          parameters
            requiredPositional a
              type: K
    class B
      firstFragment: <testLibraryFragment>::@class::B
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
      methods
        m
          firstFragment: <testLibraryFragment>::@class::B::@method::m
          parameters
            requiredPositional a
              type: int
''');
  }

  test_method_OK_single_implements_direct_notGeneric() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A {
  String m(int a);
}
class B implements A {
  m(a) {}
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        abstract class A @15
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          methods
            abstract m @28
              reference: <testLibraryFragment>::@class::A::@method::m
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional a @34
                  type: int
              returnType: String
        class B @46
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          interfaces
            A
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
          methods
            m @65
              reference: <testLibraryFragment>::@class::B::@method::m
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional a @67
                  type: int
              returnType: String
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @15
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          methods
            m @28
              reference: <testLibraryFragment>::@class::A::@method::m
              element: <none>
              parameters
                a @34
                  element: <none>
        class B @46
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
          methods
            m @65
              reference: <testLibraryFragment>::@class::B::@method::m
              element: <none>
              parameters
                a @67
                  element: <none>
  classes
    abstract class A
      firstFragment: <testLibraryFragment>::@class::A
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      methods
        abstract m
          firstFragment: <testLibraryFragment>::@class::A::@method::m
          parameters
            requiredPositional a
              type: int
    class B
      firstFragment: <testLibraryFragment>::@class::B
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
      methods
        m
          firstFragment: <testLibraryFragment>::@class::B::@method::m
          parameters
            requiredPositional a
              type: int
''');
  }

  test_method_OK_single_implements_indirect_generic() async {
    var library = await _encodeDecodeLibrary(r'''
abstract class A<K, V> {
  V m(K a);
}
abstract class B<T1, T2> extends A<T2, T1> {}
class C implements B<int, String> {
  m(a) {}
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        abstract class A @15
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          typeParameters
            covariant K @17
              defaultType: dynamic
            covariant V @20
              defaultType: dynamic
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          methods
            abstract m @29
              reference: <testLibraryFragment>::@class::A::@method::m
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional a @33
                  type: K
              returnType: V
        abstract class B @54
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          typeParameters
            covariant T1 @56
              defaultType: dynamic
            covariant T2 @60
              defaultType: dynamic
          supertype: A<T2, T1>
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
              superConstructor: ConstructorMember
                base: <testLibraryFragment>::@class::A::@constructor::new
                substitution: {K: T2, V: T1}
        class C @91
          reference: <testLibraryFragment>::@class::C
          enclosingElement3: <testLibraryFragment>
          interfaces
            B<int, String>
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::C
          methods
            m @123
              reference: <testLibraryFragment>::@class::C::@method::m
              enclosingElement3: <testLibraryFragment>::@class::C
              parameters
                requiredPositional a @125
                  type: String
              returnType: int
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @15
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          typeParameters
            K @17
              element: <none>
            V @20
              element: <none>
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          methods
            m @29
              reference: <testLibraryFragment>::@class::A::@method::m
              element: <none>
              parameters
                a @33
                  element: <none>
        class B @54
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          typeParameters
            T1 @56
              element: <none>
            T2 @60
              element: <none>
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
              superConstructor: ConstructorMember
                base: <testLibraryFragment>::@class::A::@constructor::new
                substitution: {K: T2, V: T1}
        class C @91
          reference: <testLibraryFragment>::@class::C
          element: <testLibraryFragment>::@class::C
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              element: <none>
          methods
            m @123
              reference: <testLibraryFragment>::@class::C::@method::m
              element: <none>
              parameters
                a @125
                  element: <none>
  classes
    abstract class A
      firstFragment: <testLibraryFragment>::@class::A
      typeParameters
        K
        V
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      methods
        abstract m
          firstFragment: <testLibraryFragment>::@class::A::@method::m
          parameters
            requiredPositional a
              type: K
    abstract class B
      firstFragment: <testLibraryFragment>::@class::B
      typeParameters
        T1
        T2
      supertype: A<T2, T1>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
          superConstructor: <none>
    class C
      firstFragment: <testLibraryFragment>::@class::C
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::C::@constructor::new
      methods
        m
          firstFragment: <testLibraryFragment>::@class::C::@method::m
          parameters
            requiredPositional a
              type: String
''');
  }

  test_method_OK_single_private_linkThroughOtherLibraryOfCycle() async {
    newFile('$testPackageLibPath/other.dart', r'''
import 'test.dart';
class B extends A2 {}
''');
    var library = await _encodeDecodeLibrary(r'''
import 'other.dart';
class A1 {
  int _foo() => 1;
}
class A2 extends A1 {
  _foo() => 2;
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  libraryImports
    package:test/other.dart
      enclosingElement3: <testLibraryFragment>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      libraryImports
        package:test/other.dart
          enclosingElement3: <testLibraryFragment>
      classes
        class A1 @27
          reference: <testLibraryFragment>::@class::A1
          enclosingElement3: <testLibraryFragment>
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A1::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A1
          methods
            _foo @38
              reference: <testLibraryFragment>::@class::A1::@method::_foo
              enclosingElement3: <testLibraryFragment>::@class::A1
              returnType: int
        class A2 @59
          reference: <testLibraryFragment>::@class::A2
          enclosingElement3: <testLibraryFragment>
          supertype: A1
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A2::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A2
              superConstructor: <testLibraryFragment>::@class::A1::@constructor::new
          methods
            _foo @77
              reference: <testLibraryFragment>::@class::A2::@method::_foo
              enclosingElement3: <testLibraryFragment>::@class::A2
              returnType: int
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      libraryImports
        package:test/other.dart
      classes
        class A1 @27
          reference: <testLibraryFragment>::@class::A1
          element: <testLibraryFragment>::@class::A1
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A1::@constructor::new
              element: <none>
          methods
            _foo @38
              reference: <testLibraryFragment>::@class::A1::@method::_foo
              element: <none>
        class A2 @59
          reference: <testLibraryFragment>::@class::A2
          element: <testLibraryFragment>::@class::A2
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A2::@constructor::new
              element: <none>
              superConstructor: <testLibraryFragment>::@class::A1::@constructor::new
          methods
            _foo @77
              reference: <testLibraryFragment>::@class::A2::@method::_foo
              element: <none>
  classes
    class A1
      firstFragment: <testLibraryFragment>::@class::A1
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A1::@constructor::new
      methods
        _foo
          firstFragment: <testLibraryFragment>::@class::A1::@method::_foo
    class A2
      firstFragment: <testLibraryFragment>::@class::A2
      supertype: A1
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A2::@constructor::new
          superConstructor: <none>
      methods
        _foo
          firstFragment: <testLibraryFragment>::@class::A2::@method::_foo
''');
  }

  test_method_OK_single_withExtends_notGeneric() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  String m(int a) {}
}
class B extends Object with A {
  m(a) {}
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          methods
            m @19
              reference: <testLibraryFragment>::@class::A::@method::m
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional a @25
                  type: int
              returnType: String
        class B @39
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          supertype: Object
          mixins
            A
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
          methods
            m @67
              reference: <testLibraryFragment>::@class::B::@method::m
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional a @69
                  type: int
              returnType: String
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          methods
            m @19
              reference: <testLibraryFragment>::@class::A::@method::m
              element: <none>
              parameters
                a @25
                  element: <none>
        class B @39
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
          methods
            m @67
              reference: <testLibraryFragment>::@class::B::@method::m
              element: <none>
              parameters
                a @69
                  element: <none>
  classes
    class A
      firstFragment: <testLibraryFragment>::@class::A
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      methods
        m
          firstFragment: <testLibraryFragment>::@class::A::@method::m
          parameters
            requiredPositional a
              type: int
    class B
      firstFragment: <testLibraryFragment>::@class::B
      supertype: Object
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
      methods
        m
          firstFragment: <testLibraryFragment>::@class::B::@method::m
          parameters
            requiredPositional a
              type: int
''');
  }

  test_method_OK_two_extendsImplements_generic() async {
    var library = await _encodeDecodeLibrary(r'''
class A<K, V> {
  V m(K a) {}
}
class B<T> {
  T m(int a) {}
}
class C extends A<int, String> implements B<String> {
  m(a) {}
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          typeParameters
            covariant K @8
              defaultType: dynamic
            covariant V @11
              defaultType: dynamic
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          methods
            m @20
              reference: <testLibraryFragment>::@class::A::@method::m
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional a @24
                  type: K
              returnType: V
        class B @38
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          typeParameters
            covariant T @40
              defaultType: dynamic
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
          methods
            m @49
              reference: <testLibraryFragment>::@class::B::@method::m
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional a @55
                  type: int
              returnType: T
        class C @69
          reference: <testLibraryFragment>::@class::C
          enclosingElement3: <testLibraryFragment>
          supertype: A<int, String>
          interfaces
            B<String>
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::C
              superConstructor: ConstructorMember
                base: <testLibraryFragment>::@class::A::@constructor::new
                substitution: {K: int, V: String}
          methods
            m @119
              reference: <testLibraryFragment>::@class::C::@method::m
              enclosingElement3: <testLibraryFragment>::@class::C
              parameters
                requiredPositional a @121
                  type: int
              returnType: String
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          typeParameters
            K @8
              element: <none>
            V @11
              element: <none>
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          methods
            m @20
              reference: <testLibraryFragment>::@class::A::@method::m
              element: <none>
              parameters
                a @24
                  element: <none>
        class B @38
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          typeParameters
            T @40
              element: <none>
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
          methods
            m @49
              reference: <testLibraryFragment>::@class::B::@method::m
              element: <none>
              parameters
                a @55
                  element: <none>
        class C @69
          reference: <testLibraryFragment>::@class::C
          element: <testLibraryFragment>::@class::C
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              element: <none>
              superConstructor: ConstructorMember
                base: <testLibraryFragment>::@class::A::@constructor::new
                substitution: {K: int, V: String}
          methods
            m @119
              reference: <testLibraryFragment>::@class::C::@method::m
              element: <none>
              parameters
                a @121
                  element: <none>
  classes
    class A
      firstFragment: <testLibraryFragment>::@class::A
      typeParameters
        K
        V
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      methods
        m
          firstFragment: <testLibraryFragment>::@class::A::@method::m
          parameters
            requiredPositional a
              type: K
    class B
      firstFragment: <testLibraryFragment>::@class::B
      typeParameters
        T
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
      methods
        m
          firstFragment: <testLibraryFragment>::@class::B::@method::m
          parameters
            requiredPositional a
              type: int
    class C
      firstFragment: <testLibraryFragment>::@class::C
      supertype: A<int, String>
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::C::@constructor::new
          superConstructor: <none>
      methods
        m
          firstFragment: <testLibraryFragment>::@class::C::@method::m
          parameters
            requiredPositional a
              type: int
''');
  }

  test_method_OK_two_extendsImplements_notGeneric() async {
    var library = await _encodeDecodeLibrary(r'''
class A {
  String m(int a) {}
}
class B {
  String m(int a) {}
}
class C extends A implements B {
  m(a) {}
}
''');
    checkElementText(library, r'''
library
  reference: <testLibrary>
  definingUnit: <testLibraryFragment>
  units
    <testLibraryFragment>
      enclosingElement3: <null>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          enclosingElement3: <testLibraryFragment>
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::A
          methods
            m @19
              reference: <testLibraryFragment>::@class::A::@method::m
              enclosingElement3: <testLibraryFragment>::@class::A
              parameters
                requiredPositional a @25
                  type: int
              returnType: String
        class B @39
          reference: <testLibraryFragment>::@class::B
          enclosingElement3: <testLibraryFragment>
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::B
          methods
            m @52
              reference: <testLibraryFragment>::@class::B::@method::m
              enclosingElement3: <testLibraryFragment>::@class::B
              parameters
                requiredPositional a @58
                  type: int
              returnType: String
        class C @72
          reference: <testLibraryFragment>::@class::C
          enclosingElement3: <testLibraryFragment>
          supertype: A
          interfaces
            B
          constructors
            synthetic @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              enclosingElement3: <testLibraryFragment>::@class::C
              superConstructor: <testLibraryFragment>::@class::A::@constructor::new
          methods
            m @101
              reference: <testLibraryFragment>::@class::C::@method::m
              enclosingElement3: <testLibraryFragment>::@class::C
              parameters
                requiredPositional a @103
                  type: int
              returnType: String
----------------------------------------
library
  reference: <testLibrary>
  fragments
    <testLibraryFragment>
      element: <testLibrary>
      classes
        class A @6
          reference: <testLibraryFragment>::@class::A
          element: <testLibraryFragment>::@class::A
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::A::@constructor::new
              element: <none>
          methods
            m @19
              reference: <testLibraryFragment>::@class::A::@method::m
              element: <none>
              parameters
                a @25
                  element: <none>
        class B @39
          reference: <testLibraryFragment>::@class::B
          element: <testLibraryFragment>::@class::B
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::B::@constructor::new
              element: <none>
          methods
            m @52
              reference: <testLibraryFragment>::@class::B::@method::m
              element: <none>
              parameters
                a @58
                  element: <none>
        class C @72
          reference: <testLibraryFragment>::@class::C
          element: <testLibraryFragment>::@class::C
          constructors
            synthetic new @-1
              reference: <testLibraryFragment>::@class::C::@constructor::new
              element: <none>
              superConstructor: <testLibraryFragment>::@class::A::@constructor::new
          methods
            m @101
              reference: <testLibraryFragment>::@class::C::@method::m
              element: <none>
              parameters
                a @103
                  element: <none>
  classes
    class A
      firstFragment: <testLibraryFragment>::@class::A
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::A::@constructor::new
      methods
        m
          firstFragment: <testLibraryFragment>::@class::A::@method::m
          parameters
            requiredPositional a
              type: int
    class B
      firstFragment: <testLibraryFragment>::@class::B
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::B::@constructor::new
      methods
        m
          firstFragment: <testLibraryFragment>::@class::B::@method::m
          parameters
            requiredPositional a
              type: int
    class C
      firstFragment: <testLibraryFragment>::@class::C
      supertype: A
      constructors
        synthetic new
          firstFragment: <testLibraryFragment>::@class::C::@constructor::new
          superConstructor: <none>
      methods
        m
          firstFragment: <testLibraryFragment>::@class::C::@method::m
          parameters
            requiredPositional a
              type: int
''');
  }

  Future<LibraryElementImpl> _encodeDecodeLibrary(String text) async {
    newFile(testFile.path, text);

    var analysisSession = contextFor(testFile).currentSession;
    var result = await analysisSession.getUnitElement(testFile.path);
    result as UnitElementResult;
    return result.element.library as LibraryElementImpl;
  }
}
