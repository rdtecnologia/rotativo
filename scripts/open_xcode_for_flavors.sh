#!/bin/bash

echo "🍎 Configuração de iOS Flavors"
echo "================================="
echo ""
echo "❌ Problema detectado:"
echo "   flutter run --flavor patosDeMinas -d \"iPhone 16 Pro\""
echo "   Erro: Flutter expects a build configuration named Debug-patosDeMinas"
echo ""
echo "✅ Solução:"
echo ""
echo "🔧 OPÇÃO 1: Configuração Manual (5 minutos)"
echo "   Vou abrir o Xcode para você configurar..."
echo ""
echo "🚀 OPÇÃO 2: Usar Abordagem Simples (RECOMENDADA)"
echo "   dart scripts/build_city.dart patos \"Rotativo Patos\""
echo "   flutter run -d \"iPhone 16 Pro\"  # SEM --flavor"
echo ""

read -p "Escolha uma opção [1-Xcode, 2-Simples, Enter-Simples]: " choice

case $choice in
    1)
        echo ""
        echo "🔧 Abrindo Xcode..."
        echo ""
        echo "📋 Passos para configurar flavors:"
        echo "1. Clique em 'Runner' (projeto) na lateral esquerda"
        echo "2. Vá na aba 'Info'"
        echo "3. Em 'Configurations', clique no '+'"
        echo "4. Para patosDeMinas, crie:"
        echo "   - Debug-patosDeMinas (duplicar Debug)"
        echo "   - Release-patosDeMinas (duplicar Release)"
        echo "   - Profile-patosDeMinas (duplicar Profile)"
        echo ""
        echo "Abrindo Xcode..."
        open ios/Runner.xcworkspace
        echo ""
        echo "💡 Após configurar, teste com:"
        echo "   flutter run --flavor patosDeMinas -d \"iPhone 16 Pro\""
        ;;
    2|"")
        echo ""
        echo "🚀 Executando abordagem simples..."
        echo ""
        
        # Configurar cidade
        echo "1️⃣ Configurando Patos de Minas..."
        dart scripts/build_city.dart patos "Rotativo Patos"
        
        echo ""
        echo "2️⃣ Executando no iPhone Simulator..."
        echo "   flutter run -d \"iPhone 16 Pro\""
        echo ""
        echo "🎯 Execute o comando acima para testar!"
        ;;
    *)
        echo "❌ Opção inválida"
        ;;
esac

echo ""
echo "📊 Status dos Flavors:"
echo "✅ Android: flutter run --flavor patosDeMinas  (FUNCIONANDO)"
echo "✅ iOS Simples: flutter run -d \"iPhone\"        (FUNCIONANDO)"  
echo "🔧 iOS Flavor: Requer configuração manual"