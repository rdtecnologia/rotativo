import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/choose_value_provider.dart';

class CustomValueSection extends ConsumerStatefulWidget {
  final VoidCallback onPurchase;

  const CustomValueSection({
    super.key,
    required this.onPurchase,
  });

  @override
  ConsumerState<CustomValueSection> createState() => _CustomValueSectionState();
}

class _CustomValueSectionState extends ConsumerState<CustomValueSection> {
  final TextEditingController _customValueController = TextEditingController();
  final FocusNode _customValueFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _customValueController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _customValueController.dispose();
    _customValueFocusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    ref
        .read(chooseValueProvider.notifier)
        .updateCustomValue(_customValueController.text);
  }

  @override
  Widget build(BuildContext context) {
    final chooseValueState = ref.watch(chooseValueProvider);

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Máximo R\$ 100,00',
            style: TextStyle(
              fontSize: 14,
              color: Colors.green.shade700,
            ),
          ),
          const SizedBox(height: 16),

          // Campo de valor e botão de compra
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _customValueController,
                  focusNode: _customValueFocusNode,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+$')),
                  ],
                  decoration: InputDecoration(
                    hintText: '0',
                    prefixText: 'R\$ ',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: chooseValueState.isCustomValueValid
                            ? Colors.green
                            : Colors.grey.shade400,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: chooseValueState.isCustomValueValid
                            ? Colors.green
                            : Theme.of(context).primaryColor,
                        width: 2,
                      ),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: Colors.red, width: 2),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 16),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: chooseValueState.isCustomValueValid
                    ? widget.onPurchase
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'COMPRAR',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),

          // Mensagem de validação
          if (chooseValueState.customValueText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  chooseValueState.isCustomValueValid
                      ? Icons.check_circle
                      : Icons.error,
                  color: chooseValueState.isCustomValueValid
                      ? Colors.green
                      : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    chooseValueState.isCustomValueValid
                        ? 'Valor válido! Clique em COMPRAR para continuar.'
                        : 'Valor deve ser um número inteiro entre R\$ 1,00 e R\$ 100,00',
                    style: TextStyle(
                      fontSize: 12,
                      color: chooseValueState.isCustomValueValid
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
