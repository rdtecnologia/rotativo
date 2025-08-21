import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:rotativo/providers/register_form_provider.dart';

void main() {
  group('RegisterFormProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state should have acceptTerms as false', () {
      final state = container.read(registerFormProvider);
      expect(state.acceptTerms, false);
      expect(state.validationError, null);
      expect(state.hasValidationError, false);
      expect(state.isFormValid, false);
    });

    test('setAcceptTerms should update acceptTerms state', () {
      final notifier = container.read(registerFormProvider.notifier);
      
      notifier.setAcceptTerms(true);
      
      final state = container.read(registerFormProvider);
      expect(state.acceptTerms, true);
      expect(state.isFormValid, true);
    });

    test('toggleAcceptTerms should toggle acceptTerms state', () {
      final notifier = container.read(registerFormProvider.notifier);
      
      // Toggle from false to true
      notifier.toggleAcceptTerms();
      expect(container.read(registerFormProvider).acceptTerms, true);
      
      // Toggle from true to false
      notifier.toggleAcceptTerms();
      expect(container.read(registerFormProvider).acceptTerms, false);
    });

    test('setValidationError should set validation error', () {
      final notifier = container.read(registerFormProvider.notifier);
      const errorMessage = 'Erro de validação';
      
      notifier.setValidationError(errorMessage);
      
      final state = container.read(registerFormProvider);
      expect(state.validationError, errorMessage);
      expect(state.hasValidationError, true);
      expect(state.isFormValid, false);
    });

    test('clearValidationError should clear validation error', () {
      final notifier = container.read(registerFormProvider.notifier);
      
      // Set error first
      notifier.setValidationError('Erro de teste');
      expect(container.read(registerFormProvider).hasValidationError, true);
      
      // Clear error
      notifier.clearValidationError();
      expect(container.read(registerFormProvider).hasValidationError, false);
      
      // isFormValid should still be false because terms are not accepted
      expect(container.read(registerFormProvider).isFormValid, false);
    });

    test('validateTerms should return current acceptTerms value', () {
      final notifier = container.read(registerFormProvider.notifier);
      
      expect(notifier.validateTerms(), false);
      
      notifier.setAcceptTerms(true);
      expect(notifier.validateTerms(), true);
    });

    test('validateForm should return false when terms not accepted', () {
      final notifier = container.read(registerFormProvider.notifier);
      final formKey = GlobalKey<FormBuilderState>();
      
      final isValid = notifier.validateForm(formKey);
      
      expect(isValid, false);
      expect(container.read(registerFormProvider).hasValidationError, true);
    });

    test('reset should clear all state', () {
      final notifier = container.read(registerFormProvider.notifier);
      
      // Set some state
      notifier.setAcceptTerms(true);
      notifier.setValidationError('Erro de teste');
      
      // Reset
      notifier.reset();
      
      final state = container.read(registerFormProvider);
      expect(state.acceptTerms, false);
      expect(state.validationError, null);
      expect(state.hasValidationError, false);
      expect(state.isFormValid, false);
    });

    test('isFormValid should be true only when terms accepted and no errors', () {
      final notifier = container.read(registerFormProvider.notifier);
      
      // Initially false
      expect(container.read(registerFormProvider).isFormValid, false);
      
      // Accept terms - should be true
      notifier.setAcceptTerms(true);
      expect(container.read(registerFormProvider).isFormValid, true);
      
      // Set error - should be false
      notifier.setValidationError('Erro');
      expect(container.read(registerFormProvider).isFormValid, false);
      
      // Clear error - should be true again (because terms are still accepted)
      notifier.clearValidationError();
      expect(container.read(registerFormProvider).isFormValid, true);
    });
  });
}
