#!/usr/bin/env python3
"""
Script para configurar automaticamente os ícones de cada flavor no Xcode.
Modifica o arquivo project.pbxproj para usar AppIcon-[Flavor] para cada configuração.
"""

import os
import re
import sys

def main():
    print("🔧 Configurando ícones iOS por flavor no Xcode...\n")
    
    project_path = "ios/Runner.xcodeproj/project.pbxproj"
    
    if not os.path.exists(project_path):
        print(f"❌ Arquivo não encontrado: {project_path}")
        sys.exit(1)
    
    # Lê o arquivo project.pbxproj
    with open(project_path, 'r') as f:
        content = f.read()
    
    # Backup do arquivo original
    backup_path = project_path + ".backup"
    with open(backup_path, 'w') as f:
        f.write(content)
    print(f"💾 Backup criado: {backup_path}")
    
    # Configurações dos flavors
    flavors = {
        'Demo': 'AppIcon-Demo',
        'OuroPreto': 'AppIcon-OuroPreto',
        'Vicosa': 'AppIcon-Vicosa',
    }
    
    # Para cada flavor, encontrar a seção de Build Settings e atualizar ASSETCATALOG_COMPILER_APPICON_NAME
    modified = False
    
    for flavor_name, icon_set in flavors.items():
        print(f"📝 Configurando {flavor_name} para usar {icon_set}")
        
        # Padrão para encontrar as configurações de build de cada flavor
        # Procura por seções que contenham o nome da configuração
        pattern = rf'(/\* {flavor_name} \*/.*?buildSettings = \{{.*?)(ASSETCATALOG_COMPILER_APPICON_NAME = .*?;)'
        
        def replace_icon_setting(match):
            nonlocal modified
            modified = True
            before = match.group(1)
            return f'{before}ASSETCATALOG_COMPILER_APPICON_NAME = "{icon_set}";'
        
        content = re.sub(pattern, replace_icon_setting, content, flags=re.DOTALL)
        
        # Se não encontrou com o padrão acima, tenta adicionar a configuração
        # Procura por buildSettings sem ASSETCATALOG_COMPILER_APPICON_NAME para este flavor
        if not modified:
            pattern2 = rf'(/\* {flavor_name} \*/.*?buildSettings = \{{)(.*?)(\n\s*\}})'
            
            def add_icon_setting(match):
                nonlocal modified
                before = match.group(1)
                settings = match.group(2)
                after = match.group(3)
                
                # Verifica se já tem a configuração
                if 'ASSETCATALOG_COMPILER_APPICON_NAME' in settings:
                    return match.group(0)
                
                modified = True
                # Adiciona a configuração
                return f'{before}{settings}\n\t\t\t\tASSETCATALOG_COMPILER_APPICON_NAME = "{icon_set}";{after}'
            
            content = re.sub(pattern2, add_icon_setting, content, flags=re.DOTALL)
    
    # Salva o arquivo modificado
    if modified:
        with open(project_path, 'w') as f:
            f.write(content)
        print("\n✅ Arquivo project.pbxproj atualizado com sucesso!")
        print("\n📱 Configurações aplicadas:")
        for flavor_name, icon_set in flavors.items():
            print(f"   • {flavor_name}: {icon_set}")
    else:
        print("\n⚠️  Nenhuma modificação foi necessária ou não foi possível encontrar as configurações.")
        print("   Você pode precisar configurar manualmente no Xcode:")
        print("   1. Abra: open ios/Runner.xcworkspace")
        print("   2. Selecione o target Runner")
        print("   3. Vá em Build Settings")
        print("   4. Busque por 'Asset Catalog App Icon Set Name'")
        print("   5. Configure cada configuração para usar o AppIcon correto")
    
    print("\n🚀 Próximo passo:")
    print("   Teste a aplicação com cada flavor:")
    print("   flutter run --flavor demo -d <device>")
    print("   flutter run --flavor ouroPreto -d <device>")
    print("   flutter run --flavor vicosa -d <device>")

if __name__ == "__main__":
    main()

