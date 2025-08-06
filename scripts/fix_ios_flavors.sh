#!/bin/bash

echo "🛠️  Corrigindo configurações de iOS flavors..."

# Flavors para criar
flavors=("demo" "patosDeMinas" "janauba" "conselheiroLafaiete" "capaoBonito" "joaoMonlevade" "itarare" "passos" "ribeiraoDasNeves" "igarape" "ouroPreto")

# Fazer backup do projeto
echo "📋 Fazendo backup do projeto..."
cp ios/Runner.xcodeproj/project.pbxproj ios/Runner.xcodeproj/project.pbxproj.backup.$(date +%s)

# Função para adicionar configuração
add_build_config() {
    local flavor=$1
    local base_config=$2
    local new_config="$base_config-$flavor"
    
    echo "➕ Adicionando configuração: $new_config"
    
    # Usar PlistBuddy para adicionar a configuração
    /usr/libexec/PlistBuddy -c "Add :objects:97C146E61CF9000F007C117D:buildConfigurationList:buildConfigurations: string ${new_config}" ios/Runner.xcodeproj/project.pbxproj 2>/dev/null || true
}

# Método mais direto: modificar o arquivo project.pbxproj
echo "🔧 Modificando arquivo de projeto do Xcode..."

# Ler o arquivo atual
PBXPROJ_FILE="ios/Runner.xcodeproj/project.pbxproj"

# Para cada flavor, adicionar as configurações necessárias
for flavor in "${flavors[@]}"; do
    echo "📱 Processando flavor: $flavor"
    
    # Vamos usar uma abordagem mais simples: adicionar as configurações no final da seção
    # Primeiro, encontrar onde adicionar as configurações
    
    # Adicionar as configurações de build usando sed
    sed -i '' "/\/\* End XCBuildConfiguration section \*\//i\\
\\
\t\t${flavor}Debug /* Debug-${flavor} */ = {\\
\t\t\tisa = XCBuildConfiguration;\\
\t\t\tbuildSettings = {\\
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;\\
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;\\
\t\t\t\tCLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;\\
\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = \"gnu++14\";\\
\t\t\t\tCLANG_CXX_LIBRARY = \"libc++\";\\
\t\t\t\tCLANG_ENABLE_MODULES = YES;\\
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;\\
\t\t\t\tCLANG_ENABLE_OBJC_WEAK = YES;\\
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;\\
\t\t\t\tENABLE_TESTABILITY = YES;\\
\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu11;\\
\t\t\t\tGCC_DYNAMIC_NO_PIC = NO;\\
\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;\\
\t\t\t\tGCC_OPTIMIZATION_LEVEL = 0;\\
\t\t\t\tGCC_PREPROCESSOR_DEFINITIONS = (\\
\t\t\t\t\t\"DEBUG=1\",\\
\t\t\t\t\t\"\$(inherited)\",\\
\t\t\t\t);\\
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 12.0;\\
\t\t\t\tMTL_ENABLE_DEBUG_INFO = INCLUDE_SOURCE;\\
\t\t\t\tMTL_FAST_MATH = YES;\\
\t\t\t\tONLY_ACTIVE_ARCH = YES;\\
\t\t\t\tSDKROOT = iphoneos;\\
\t\t\t\tTARGETED_DEVICE_FAMILY = \"1,2\";\\
\t\t\t\tFLUTTER_BUILD_MODE = debug;\\
\t\t\t};\\
\t\t\tname = \"Debug-${flavor}\";\\
\t\t};\\
\t\t${flavor}Release /* Release-${flavor} */ = {\\
\t\t\tisa = XCBuildConfiguration;\\
\t\t\tbuildSettings = {\\
\t\t\t\tALWAYS_SEARCH_USER_PATHS = NO;\\
\t\t\t\tCLANG_ANALYZER_NONNULL = YES;\\
\t\t\t\tCLANG_ANALYZER_NUMBER_OBJECT_CONVERSION = YES_AGGRESSIVE;\\
\t\t\t\tCLANG_CXX_LANGUAGE_STANDARD = \"gnu++14\";\\
\t\t\t\tCLANG_CXX_LIBRARY = \"libc++\";\\
\t\t\t\tCLANG_ENABLE_MODULES = YES;\\
\t\t\t\tCLANG_ENABLE_OBJC_ARC = YES;\\
\t\t\t\tCLANG_ENABLE_OBJC_WEAK = YES;\\
\t\t\t\tENABLE_STRICT_OBJC_MSGSEND = YES;\\
\t\t\t\tGCC_C_LANGUAGE_STANDARD = gnu11;\\
\t\t\t\tGCC_NO_COMMON_BLOCKS = YES;\\
\t\t\t\tIPHONEOS_DEPLOYMENT_TARGET = 12.0;\\
\t\t\t\tMTL_ENABLE_DEBUG_INFO = NO;\\
\t\t\t\tMTL_FAST_MATH = YES;\\
\t\t\t\tSDKROOT = iphoneos;\\
\t\t\t\tTARGETED_DEVICE_FAMILY = \"1,2\";\\
\t\t\t\tVALIDATE_PRODUCT = YES;\\
\t\t\t\tFLUTTER_BUILD_MODE = release;\\
\t\t\t};\\
\t\t\tname = \"Release-${flavor}\";\\
\t\t};\\
" "$PBXPROJ_FILE"

done

echo ""
echo "✅ Configurações iOS adicionadas!"
echo ""
echo "⚠️  IMPORTANTE: Para completar a configuração:"
echo "1. Abra o Xcode: open ios/Runner.xcworkspace"
echo "2. No projeto Runner, vá em 'Info' -> 'Configurations'"
echo "3. Verifique se as configurações foram adicionadas"
echo ""
echo "🎉 Depois você pode usar:"
echo "   flutter run --flavor patosDeMinas -d 'iPhone 16 Pro'"
echo ""
echo "💡 Alternativamente, continue usando a abordagem simples:"
echo "   dart scripts/build_city.dart patos 'Rotativo Patos'"
echo "   flutter run -d 'iPhone 16 Pro'  # SEM --flavor"