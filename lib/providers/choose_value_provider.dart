import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChooseValueState {
  final bool isCustomValueValid;
  final double? customValue;
  final String customValueText;

  const ChooseValueState({
    this.isCustomValueValid = false,
    this.customValue,
    this.customValueText = '',
  });

  ChooseValueState copyWith({
    bool? isCustomValueValid,
    double? customValue,
    String? customValueText,
  }) {
    return ChooseValueState(
      isCustomValueValid: isCustomValueValid ?? this.isCustomValueValid,
      customValue: customValue ?? this.customValue,
      customValueText: customValueText ?? this.customValueText,
    );
  }
}

class ChooseValueNotifier extends StateNotifier<ChooseValueState> {
  ChooseValueNotifier() : super(const ChooseValueState());

  void updateCustomValue(String text) {
    if (text.isEmpty) {
      state = state.copyWith(
        isCustomValueValid: false,
        customValue: null,
        customValueText: text,
      );
      return;
    }

    final value = int.tryParse(text);
    if (value != null && value >= 1 && value <= 100) {
      state = state.copyWith(
        isCustomValueValid: true,
        customValue: value.toDouble(),
        customValueText: text,
      );
    } else {
      state = state.copyWith(
        isCustomValueValid: false,
        customValue: null,
        customValueText: text,
      );
    }
  }

  void reset() {
    state = const ChooseValueState();
  }
}

final chooseValueProvider =
    StateNotifierProvider<ChooseValueNotifier, ChooseValueState>((ref) {
  return ChooseValueNotifier();
});
