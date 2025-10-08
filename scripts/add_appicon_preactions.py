#!/usr/bin/env python3
"""
Script para adicionar PreActions aos schemes do iOS para copiar o AppIcon correto.
"""

import os
import xml.etree.ElementTree as ET
from xml.dom import minidom

def prettify_xml(elem):
    """
    Retorna uma string XML bem formatada.
    """
    rough_string = ET.tostring(elem, 'utf-8')
    reparsed = minidom.parseString(rough_string)
    return reparsed.toprettyxml(indent="   ")

def add_appicon_preaction(scheme_path, flavor_name):
    """
    Adiciona ou atualiza o PreAction para copiar o AppIcon no scheme.
    """
    # Parse o arquivo do scheme
    tree = ET.parse(scheme_path)
    root = tree.getroot()
    
    # Encontra ou cria a seção BuildAction
    build_action = root.find('BuildAction')
    if build_action is None:
        print(f"   ⚠️  BuildAction não encontrada em {scheme_path}")
        return False
    
    # Encontra ou cria PreActions
    pre_actions = build_action.find('PreActions')
    if pre_actions is None:
        pre_actions = ET.SubElement(build_action, 'PreActions')
    
    # Remove PreActions existentes de copy_appicon.sh para evitar duplicatas
    for action in list(pre_actions):
        action_content = action.find('ActionContent')
        if action_content is not None:
            title = action_content.get('title', '')
            if 'AppIcon' in title or 'copy_appicon' in action_content.get('scriptText', ''):
                pre_actions.remove(action)
    
    # Cria o novo ExecutionAction
    execution_action = ET.SubElement(pre_actions, 'ExecutionAction')
    execution_action.set('ActionType', 'Xcode.IDEStandardExecutionActionsCore.ExecutionActionType.ShellScriptAction')
    
    # Cria o ActionContent
    action_content = ET.SubElement(execution_action, 'ActionContent')
    action_content.set('title', f'Copy AppIcon for {flavor_name}')
    script_text = f'cd "${{SRCROOT}}"&#10;${{SRCROOT}}/Scripts/copy_appicon.sh {flavor_name}'
    action_content.set('scriptText', script_text)
    
    # Adiciona EnvironmentBuildable
    env_buildable = ET.SubElement(action_content, 'EnvironmentBuildable')
    buildable_ref = ET.SubElement(env_buildable, 'BuildableReference')
    buildable_ref.set('BuildableIdentifier', 'primary')
    buildable_ref.set('BlueprintIdentifier', '97C146ED1CF9000F007C117D')
    buildable_ref.set('BuildableName', 'Runner.app')
    buildable_ref.set('BlueprintName', 'Runner')
    buildable_ref.set('ReferencedContainer', 'container:Runner.xcodeproj')
    
    # Lê o conteúdo original para preservar a formatação
    with open(scheme_path, 'r') as f:
        original_content = f.read()
    
    # Escreve o arquivo atualizado
    tree.write(scheme_path, encoding='utf-8', xml_declaration=True)
    
    # Adiciona a quebra de linha após a declaração XML se necessário
    with open(scheme_path, 'r') as f:
        content = f.read()
    
    # Garante que tenha quebra de linha após declaração XML
    if not content.startswith('<?xml version'):
        content = '<?xml version="1.0" encoding="UTF-8"?>\n' + content
    
    with open(scheme_path, 'w') as f:
        f.write(content)
    
    return True

def main():
    print("🔧 Adicionando PreActions para copiar AppIcons...\n")
    
    schemes_path = "ios/Runner.xcodeproj/xcshareddata/xcschemes"
    
    if not os.path.exists(schemes_path):
        print(f"❌ Diretório não encontrado: {schemes_path}")
        return
    
    # Mapeia schemes para nomes de flavor
    # Capitaliza o primeiro caractere para corresponder ao nome do AppIcon
    scheme_to_flavor = {
        'main.xcscheme': 'Demo',  # ou Main
        'ouroPreto.xcscheme': 'OuroPreto',
        # Adicione outros schemes conforme necessário
    }
    
    # Lista todos os schemes
    all_schemes = [f for f in os.listdir(schemes_path) if f.endswith('.xcscheme')]
    
    # Adiciona schemes automaticamente baseados no nome
    for scheme_file in all_schemes:
        if scheme_file not in scheme_to_flavor and scheme_file != 'Runner.xcscheme':
            # Extrai o nome do flavor do nome do arquivo
            flavor_base = scheme_file.replace('.xcscheme', '')
            # Capitaliza a primeira letra
            flavor_name = flavor_base[0].upper() + flavor_base[1:] if flavor_base else ''
            if flavor_name:
                scheme_to_flavor[scheme_file] = flavor_name
    
    print(f"📝 Schemes encontrados: {len(scheme_to_flavor)}")
    print()
    
    success_count = 0
    
    for scheme_file, flavor_name in scheme_to_flavor.items():
        scheme_path = os.path.join(schemes_path, scheme_file)
        
        if not os.path.exists(scheme_path):
            print(f"⚠️  Scheme não encontrado: {scheme_file}")
            continue
        
        print(f"📱 Processando {scheme_file} -> Flavor: {flavor_name}")
        
        try:
            if add_appicon_preaction(scheme_path, flavor_name):
                print(f"   ✅ PreAction adicionado\n")
                success_count += 1
            else:
                print(f"   ⚠️  Não foi possível adicionar PreAction\n")
        except Exception as e:
            print(f"   ❌ Erro: {e}\n")
    
    print(f"\n✨ Processo concluído!")
    print(f"   {success_count}/{len(scheme_to_flavor)} schemes atualizados")
    print("\n🚀 Próximo passo:")
    print("   Teste a aplicação com cada flavor:")
    print("   flutter run --flavor ouroPreto -d <device>")
    print("   flutter run --flavor main -d <device>")

if __name__ == "__main__":
    main()

