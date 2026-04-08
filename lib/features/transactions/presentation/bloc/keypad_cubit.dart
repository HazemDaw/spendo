import 'package:flutter_bloc/flutter_bloc.dart';

class KeypadCubit extends Cubit<String> {
  KeypadCubit() : super('');

  void setExpression(String value) {
    emit(value);
  }

  void appendChar(String char) {
    if (char == '=') {
      evaluate();
      return;
    }

    emit('$state$char');
  }

  void backspace() {
    if (state.isEmpty) {
      return;
    }

    emit(state.substring(0, state.length - 1));
  }

  void clear() {
    emit('');
  }

  void evaluate() {
    final double? value = parseValue();
    if (value == null) {
      return;
    }

    emit(value % 1 == 0 ? value.toInt().toString() : value.toString());
  }

  double? parseValue() {
    final String expression = _normalizeExpression(state);
    if (expression.isEmpty) {
      return null;
    }

    final List<String> tokens = <String>[];
    final StringBuffer current = StringBuffer();

    for (int index = 0; index < expression.length; index++) {
      final String char = expression[index];
      final bool isUnaryMinus =
          char == '-' && (index == 0 || _isOperator(expression[index - 1]));

      if (_isOperator(char) && !isUnaryMinus) {
        if (current.isEmpty) {
          return null;
        }
        tokens
          ..add(current.toString())
          ..add(char);
        current.clear();
      } else {
        current.write(char);
      }
    }

    if (current.isNotEmpty) {
      tokens.add(current.toString());
    }

    if (tokens.isEmpty) {
      return null;
    }

    final List<String> reduced = <String>[tokens.first];
    int index = 1;
    while (index < tokens.length) {
      final String operator = tokens[index];
      final double? left = double.tryParse(reduced.last);
      final double? right = double.tryParse(tokens[index + 1]);
      if (left == null || right == null) {
        return null;
      }

      if (operator == '*' || operator == '/') {
        if (operator == '/' && right == 0) {
          return null;
        }
        reduced[reduced.length - 1] =
            (operator == '*' ? left * right : left / right).toString();
      } else {
        reduced
          ..add(operator)
          ..add(right.toString());
      }
      index += 2;
    }

    final double? initialResult = double.tryParse(reduced.first);
    if (initialResult == null) {
      return null;
    }
    double result = initialResult;

    index = 1;
    while (index < reduced.length) {
      final String operator = reduced[index];
      final double? value = double.tryParse(reduced[index + 1]);
      if (value == null) {
        return null;
      }
      result = operator == '+' ? result + value : result - value;
      index += 2;
    }

    return result;
  }

  String _normalizeExpression(String input) {
    return input
        .replaceAll(' ', '')
        .replaceAll(',', '.')
        .replaceAll('Г—', '*')
        .replaceAll('×', '*')
        .replaceAll('x', '*')
        .replaceAll('X', '*')
        .replaceAll('Г·', '/')
        .replaceAll('÷', '/');
  }

  bool _isOperator(String value) {
    return value == '+' || value == '-' || value == '*' || value == '/';
  }
}
