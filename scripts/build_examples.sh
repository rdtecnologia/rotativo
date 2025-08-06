#!/bin/bash

echo "🚀 Rotativo Digital - Build Examples"
echo "===================================="
echo ""

echo "📱 Available build commands:"
echo ""

echo "1. Main (Demonstração):"
echo "   dart scripts/build_city.dart main \"Rotativo\""
echo "   flutter build apk --flavor main --release"
echo ""

echo "2. Patos de Minas:"
echo "   dart scripts/build_city.dart patos \"Rotativo Patos\""
echo "   flutter build apk --flavor patosDeMinas --release"
echo ""

echo "3. Janaúba:"
echo "   dart scripts/build_city.dart janauba \"Rotativo Janaúba\""
echo "   flutter build apk --flavor janauba --release"
echo ""

echo "4. Conselheiro Lafaiete:"
echo "   dart scripts/build_city.dart lafaiete \"Rotativo Lafaiete\""
echo "   flutter build apk --flavor conselheiroLafaiete --release"
echo ""

echo "5. All cities available:"
for city in main patos janauba lafaiete capao monlevade itarare passos neves igarape ouropreto; do
    echo "   - $city"
done
echo ""

echo "💡 Tip: Run 'dart scripts/build_city.dart' to see all available options"
echo ""

echo "🔧 To build and test quickly:"
echo "   dart scripts/build_city.dart patos \"Rotativo Patos\""
echo "   flutter run --flavor patosDeMinas"
echo ""

echo "📦 For production builds:"
echo "   flutter build appbundle --flavor main --release"
echo "   flutter build appbundle --flavor patosDeMinas --release"