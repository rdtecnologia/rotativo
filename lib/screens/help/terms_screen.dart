import 'package:flutter/material.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Termos de Uso'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              '1. DAS DEFINIÇÕES',
              [
                '1.1. São aplicáveis as seguintes definições:',
                '(I) AUTO-ATENDIMENTO: utilização de facilidades e serviços do sistema, sem a necessidade de falar diretamente com atendentes ou telefonistas;',
                '(II) FALE CONOSCO: canal de comunicação no qual o USUÁRIO poderá retirar dúvidas, obter informações e registrar reclamações;',
                '(III) ROTATIVO DIGITAL: Sistema de Pagamento Eletrônico para o Estacionamento Rotativo Público, regulamentado pelos Decretos Municipais;',
                '(IV) USUÁRIO: pessoa física e/ou pessoa jurídica aderente ao ROTATIVO DIGITAL que realizou o seu cadastro e informou seus dados pessoais através do site ou aplicativo;',
                '(V) NÚMERO DO CPF: número do CPF com 11 dígitos, cadastrado no campo "CPF" do cadastro pessoal de cada usuário e utilizado para acessar sua conta no aplicativo ou site;',
                '(VI) SALDO E ATIVAÇÕES: documento eletrônico exibido no aplicativo do ROTATIVO DIGITAL e no site, onde são discriminados o saldo e as últimas ativações de rotativo efetuadas;',
                '(VII) SENHA: assinatura por meio eletrônico, formada por caracteres numéricos, criada e modificada a qualquer momento, unicamente pelo USUÁRIO;',
                '(VIII) TERMO DE ADESÃO E USO: o presente instrumento;',
                '(IX) TRANSAÇÃO: toda e qualquer utilização eletrônica, aquisição de serviços efetuados no sistema, incluindo outros lançamentos previstos neste TERMO DE ADESÃO E USO;',
                '(X) PONTOS DE VENDAS (PDV): estabelecimentos credenciados para venda do ROTATIVO DIGITAL aos usuários do sistema de estacionamento rotativo nas vias, logradouros e áreas públicas do município, utilizando tecnologia digital (máquinas POS);',
                '(XI) OPERADORA DE CARTÃO DE CRÉDITO: empresa operadora da "bandeira" do Cartão de crédito do USUÁRIO;',
                '(XII) CRÉDITO PRÉ-PAGO: valor adquirido pelo USUÁRIO através do aplicativo "ROTATIVO DIGITAL", Revendedores Credenciados, site ou PDV (Ponto de Venda), que será utilizado pelo USUÁRIO ao estacionar seu(s) veículo(s) relacionado(s) em seu cadastro em área(s) identificada(s) como estacionamento "ROTATIVO DIGITAL";',
                '(XIII) ATIVAÇÃO AUTOMÁTICA: ativação automática do crédito pré-pago para veículo(s) estacionado(s) em área(s) ROTATIVO DIGITAL sem o devido crédito ativo.',
                '(XIV) As definições e disposições deste TERMO DE ADESÃO E USO se aplicam às palavras e expressões no singular ou no plural.',
              ],
            ),

            const SizedBox(height: 24),

            _buildSection(
              '2. DA COMPRA, ADESÃO E USO DO ROTATIVO DIGITAL',
              [
                'Sistema de Pagamento Eletrônico para o Estacionamento Rotativo Público.',
                'A Ti.Mob Tecnologia e Soluções em Mobilidade Ltda. fornece ao USUÁRIO, sujeito aos Termos de Uso abaixo, que podem ser modificados a qualquer momento, a prestação de serviços para o ROTATIVO DIGITAL, tudo disponível no aplicativo "ROTATIVO DIGITAL" e site por meio eletrônico de transmissão à distância de dados via Internet.',
                'Os SERVIÇOS poderão ser modificados ou extintos a qualquer momento. Em qualquer hipótese de modificação ou extinção dos SERVIÇOS, o USUÁRIO será devidamente informado deste ato quando do acesso de consulta do site, o que obriga o USUÁRIO a rever esse TERMO DE ADESÃO e uso de tempos em tempos, restando claro que o USUÁRIO se subordina à aceitação do TERMO DE ADESÃO E USO vigente no momento de seu acesso ou faz uso dos serviços.',
              ],
            ),

            const SizedBox(height: 24),

            _buildSection(
              '3. DO CADASTRO E USO',
              [
                'Para utilizar os serviços do ROTATIVO DIGITAL, o USUÁRIO deverá realizar seu cadastro pessoal, fornecendo dados verdadeiros, completos e atualizados.',
                'O USUÁRIO é responsável pela veracidade e atualização dos dados fornecidos, bem como pela confidencialidade de sua senha de acesso.',
                'O USUÁRIO concorda em não compartilhar suas credenciais de acesso com terceiros e em notificar imediatamente qualquer uso não autorizado de sua conta.',
              ],
            ),

            const SizedBox(height: 24),

            _buildSection(
              '4. DOS SERVIÇOS',
              [
                'O ROTATIVO DIGITAL oferece os seguintes serviços:',
                '- Compra de créditos para estacionamento rotativo',
                '- Ativação de estacionamento por veículo',
                '- Consulta de saldo e histórico de transações',
                '- Suporte técnico e atendimento ao usuário',
                'Os serviços estão disponíveis 24 horas por dia, 7 dias por semana, exceto em casos de manutenção programada ou força maior.',
              ],
            ),

            const SizedBox(height: 24),

            _buildSection(
              '5. DA PRIVACIDADE E SEGURANÇA',
              [
                'O ROTATIVO DIGITAL compromete-se a proteger a privacidade e segurança dos dados pessoais do USUÁRIO, em conformidade com a Lei Geral de Proteção de Dados (LGPD).',
                'Os dados pessoais coletados são utilizados exclusivamente para a prestação dos serviços contratados e não são compartilhados com terceiros sem o consentimento expresso do USUÁRIO.',
                'O USUÁRIO concorda em receber comunicações relacionadas aos serviços contratados, incluindo notificações de transações e atualizações do sistema.',
              ],
            ),

            const SizedBox(height: 24),

            _buildSection(
              '6. DAS DISPOSIÇÕES GERAIS',
              [
                'Este Termo de Uso constitui o acordo completo entre o USUÁRIO e o ROTATIVO DIGITAL.',
                'Qualquer modificação nestes termos será comunicada ao USUÁRIO através do aplicativo ou site.',
                'O uso continuado dos serviços após a modificação dos termos constitui aceitação das novas condições.',
                'Este Termo de Uso é regido pelas leis brasileiras e qualquer controvérsia será resolvida no foro da comarca do domicílio do USUÁRIO.',
              ],
            ),

            const SizedBox(height: 32),

            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Última atualização',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DateTime.now().year.toString(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                item,
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.4,
                  color: Colors.black54,
                ),
              ),
            )),
      ],
    );
  }
}
