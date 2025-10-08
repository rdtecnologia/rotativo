#!/usr/bin/env python3
"""
Script para atualizar ASSETCATALOG_COMPILER_APPICON_NAME para cada configuração de flavor no iOS.
"""

import os
import re
import sys

def update_appicon_for_config(content, config_name, appicon_name):
    """
    Atualiza o ASSETCATALOG_COMPILER_APPICON_NAME para uma configuração específica.
    """
    # Padrão para encontrar a seção de configuração
    # Procura por: /* config_name */ = { ... ASSETCATALOG_COMPILER_APPICON_NAME = ... }
    pattern = rf'(/\*\s*{re.escape(config_name)}\s*\*/\s*=\s*\{{[^}}]*?ASSETCATALOG_COMPILER_APPICON_NAME\s*=\s*)[^;]*?(;)'
    
    replacement = rf'\1{appicon_name}\2'
    
    new_content, count = re.subn(pattern, replacement, content, flags=re.DOTALL)
    
    return new_content, count

def main():
    print("🔧 Atualizando ícones iOS por flavor...\n")
    
    project_path = "ios/Runner.xcodeproj/project.pbxproj"
    
    if not os.path.exists(project_path):
        print(f"❌ Arquivo não encontrado: {project_path}")
        sys.exit(1)
    
    # Lê o arquivo project.pbxproj
    with open(project_path, 'r') as f:
        content = f.read()
    
    # Backup do arquivo original
    backup_path = project_path + ".backup2"
    with open(backup_path, 'w') as f:
        f.write(content)
    print(f"💾 Backup criado: {backup_path}\n")
    
    # Configurações dos flavors
    # Format: configuration_name -> appicon_name
    flavor_configs = {
        # OuroPreto
        'Debug-ouroPreto': 'AppIcon-OuroPreto',
        'Release-ouroPreto': 'AppIcon-OuroPreto',
        'Profile-ouroPreto': 'AppIcon-OuroPreto',
        
        # Vicosa  
        'Debug-vicosa': 'AppIcon-Vicosa',
        'Release-vicosa': 'AppIcon-Vicosa',
        'Profile-vicosa': 'AppIcon-Vicosa',
        
        # Demo/Main
        'Debug-demo': 'AppIcon-Demo',
        'Release-demo': 'AppIcon-Demo',
        'Profile-demo': 'AppIcon-Demo',
    }
    
    total_updates = 0
    
    for config_name, appicon_name in flavor_configs.items():
        print(f"📝 Atualizando {config_name} -> {appicon_name}")
        content, count = update_appicon_for_config(content, config_name, appicon_name)
        
        if count > 0:
            print(f"   ✅ {count} ocorrência(s) atualizada(s)")
            total_updates += count
        else:
            print(f"   ⚠️  Configuração não encontrada (pode não existir)")
        print()
    
    # Salva o arquivo modificado
    if total_updates > 0:
        with open(project_path, 'w') as f:
            f.write(content)
        print(f"\n✅ Arquivo atualizado com sucesso! ({total_updates} configurações alteradas)")
    else:
        print("\n⚠️  Nenhuma configuração foi atualizada.")
        print("   Verifique se as configurações de flavor existem no project.pbxproj")
    
    print("\n🚀 Próximo passo:")
    print("   Teste a aplicação com cada flavor:")
    print("   flutter run --flavor ouroPreto -d <device>")
    print("   flutter run --flavor vicosa -d <device>")
    print("   flutter run --flavor demo -d <device>")

if __name__ == "__main__":
    main()

