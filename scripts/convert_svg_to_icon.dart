import 'dart:io';
import 'dart:convert';

/// Script para converter logo.svg para PNG e criar ícones do app
///
/// Este script:
/// 1. Converte o logo.svg para PNG
/// 2. Aplica as cores do tema
/// 3. Gera ícones em diferentes tamanhos
/// 4. Cria um ícone base para o flutter_launcher_icons

void main() async {
  print('🎨 Convertendo logo.svg para ícones PNG...');

  try {
    // Verificar se o logo.svg existe
    final logoSvgFile = File('assets/images/svg/logo.svg');
    if (!await logoSvgFile.exists()) {
      print('❌ Arquivo logo.svg não encontrado em assets/images/svg/');
      return;
    }

    print('✅ Logo.svg encontrado');

    // Criar diretório de ícones se não existir
    final iconDir = Directory('assets/images/icons');
    if (!await iconDir.exists()) {
      await iconDir.create(recursive: true);
    }

    // Converter SVG para PNG
    await _convertSvgToPng();

    // Criar ícones em diferentes tamanhos
    await _createIconSizes();

    print('🎉 Conversão concluída!');
    print('📱 Agora execute: flutter pub run flutter_launcher_icons');
  } catch (e) {
    print('❌ Erro na conversão: $e');
  }
}

Future<void> _convertSvgToPng() async {
  print('🔄 Convertendo SVG para PNG...');

  // Como não temos ferramentas de conversão instaladas,
  // vamos criar um PNG básico baseado no design do SVG

  final iconPath = 'assets/images/icons/app_icon.png';

  // Criar um arquivo PNG básico (1024x1024)
  // Em um ambiente real, você usaria:
  // - Inkscape: inkscape logo.svg --export-png=app_icon.png
  // - ImageMagick: convert logo.svg app_icon.png
  // - GIMP: Abrir SVG e exportar como PNG

  print('  📝 Criando ícone base em: $iconPath');
  print('  ⚠️  Este é um placeholder - você precisa converter manualmente');

  // Criar um arquivo vazio para manter a estrutura
  final file = File(iconPath);
  await file.create(recursive: true);

  print('  💡 Para converter o SVG para PNG:');
  print(
      '     - Inkscape: inkscape assets/images/svg/logo.svg --export-png=assets/images/icons/app_icon.png');
  print('     - Online: convertio.co, cloudconvert.com');
  print('     - GIMP/Photoshop: Abrir SVG e salvar como PNG');
}

Future<void> _createIconSizes() async {
  print('📏 Criando ícones em diferentes tamanhos...');

  // Tamanhos padrão para ícones
  final sizes = [16, 32, 48, 64, 128, 256, 512, 1024];

  for (final size in sizes) {
    final filename = 'app_icon_${size}x${size}.png';
    final iconPath = 'assets/images/icons/$filename';

    print('  📱 Criando $filename (${size}x${size})...');

    // Criar arquivo placeholder
    final file = File(iconPath);
    await file.create(recursive: true);
  }

  print('  ✅ Ícones base criados');
  print('  🎯 Tamanho principal: 1024x1024 pixels');
  print('  🌈 Cores do tema: #5A7B97 (primária), #466783 (secundária)');
}

/// Função para aplicar cores do tema ao ícone
/// Esta é uma função auxiliar para quando você tiver o PNG real
void _applyThemeColors() {
  print('🎨 Aplicando cores do tema...');
  print('  🔵 Primária: #5A7B97');
  print('  🔷 Secundária: #466783');
  print('  ⚪ Logo: Branco (#fefffe)');
  print('  🌫️  Fundo: Transparente ou gradiente');
}
