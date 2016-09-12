# Histórico de mudanças

## 1.2.2 - 12/09/2016
### Correções
- [Relatórios] Corrige o uso da data de criação como dimensão horizontal para Casos
- [Localidade] Corrige a geração de estado para categorias de relato na migração de localidade
- [Relatos] Corrige a criação de configurações locais para categorias de relatos globais
- [Geral] Corrigido teste para o módulo `ImportShapefile`
- [Inventário] Corrigido teste para categoria de inventário
- [Casos] Corrige a exclusão de casos para não ser mais exibido na listagem de casos finalizados

## 1.2.1 - 09/09/2016
### Novas funcionalidades
- [Permissões] Adicionado label da localidade de cada item na tela de edição de permissões
- [Notificações] Adicionado polling e corrigido link de notificações de mensagens no chat

### Melhorias
- [Chat] Leva em consideração a localidade atual para listar os usuários no sistema de menções do chat

### Correções
- [Relatos] Ao remover um grupo do sistema que esteja marcado como solucionar em algum categoria, resetar.
- [Cubes] Corrigido comando de reinicio do slicer server
- [Casos] Não exibir casos desativados na listagem

## 1.2.0 - 05/09/2016
### Novas funcionalidades
- [Relatórios] Novo sistema de relatórios baseado em OLAP
- [Localidades] Implementação de limite de acesso a recursos baseado em localidades (namespaces).
- [Inventário] Possibilidade de selecionar um campo para ser usado como título do item
- [Relatos] Implementado campos personalizáveis

### Correções
- [Fluxos e casos] Correção de diversos problemas com permissionamento e avanço de etapas

## 1.1.11 - 10/06/2016
### Melhorias
- [Erros] Melhoria na detecção de erros
- [Logs] Melhoria nos logs gerais da aplicação
- [Inventário] Melhorias na performance de fórmulas
- [Geral] Atualização de bibliotecas
- [Documentação] Melhorias na documentação
### Correções
- [Serviços] Corrige ordenação
- [Serviços] Corrige busca por serviços desativados
- [Inventário] Corrige a validação das permissões ao adicionar uma opção a um campo

## 1.1.10 - 16/05/2016
### Novas funcionalidades
- [Aplicações] Agora aplicações podem ser cadastradas para o consumo externo da API do ZUP
### Melhorias
- [Perímetros] Possibilidade de inativar um perímetro
- [Perímetros] Adiciona funcionalidade de ordenação por prioridade
- [Inventário] Melhoria na performance de cálculo de fórmulas
- [Relatos] Nova configuração: poder esconder seção de resposta ao solicitante
- Atualização de dependências: grape
### Correções
- [Autenticação] Corrige validação do token no endpoint de autenticação

## 1.1.9 - 26/04/2016
### Melhorias
- [Usuários] Melhoria na performance da busca dos usuários
### Correções
- [Notificações Push] Corrige as notificações push

## 1.1.8 - 18/04/2016
### Novas funcionalidades
- [Inventário] Análise de item de inventários por ponto
### Correções
- [Usuário] Corrige permissionamento relacionado a usuários


## 1.1.7 - 13/04/2016
### Melhorias
- [Usuário] Adicionado validação de unicidade para o documento
- [Usuário] Aumenta a sensibilidade da pesquisa por similaridade
- [Relatos] Adicionado numero a ordenação de endereço
- [Relatos] Retorna denúncias no endpoint de relato
### Correções
- [Inventário] Corrigido erro ao editar status de item com categoria recém criada

## 1.1.6 - 29/03/2016
### Melhorias
- [Busca] Melhoria do algoritmo de busca no sistema

## 1.1.5 - 15/03/2016
### Melhorias
- [Usuário] Adiciona validação na aplicação de email único
- [Atualização] Atualização de bibliotecas relacionadas à trabalho assíncronos15
### Correções
- [Relatos] Aceita campo CEP vazio
- [Setup] Corrigir duplicação de usuário ao fazer setup de uma nova instância

## 1.1.4 - 01/03/2016
### Adições
- [Relatos] Nova funcionalidade de excluir relatos via webhook
### Correções
- [Inventário] Retorna os dados de campos já deletados
- [Inventário] Retorna o campo título em branco
- [Permissões] Correções gerais nas permissões dos usuários
- [Relatos] Corrige número do protocolo em branco no e-mail enviado ao usuário
- [Fórmulas] Correção ao executar fórmulas dentro do inventário

## 1.1.3 - 13/01/2016
### Correções
- [Relatos] Correção nos relatos marcados como atrasados indevidamente
- [Relatos] Correção na validação de relatos que podem receber feedback do usuário solicitante
- [Relatos] Correção de pesquisa por período, prazo e vencimento para relatos e notificações
- [Usuário] Corrigido validação de confirmação de senha na redefinação de senha
- [Usuário] Correção no cache
- [Usuário] Correção de permissões
- [Usuário] Correção na validação de cidade do perfil do usuário
- [Inventário] Correção nos campos antigos enviados ao aplicativo técnico
- [Inventário] Correção no cache
- [Inventário] Correção na busca por número de sequência

### Mudanças
- [Relatos] Adicionado filtro para retornar apenas as categorias de relato que o usuário pode criar relatos

## 1.1.2 - 19/12/2015
### Correcões
- [Inventário] Corrigido pesquisa do inventário quando o usuário não tem permissão na categoria
- [Inventário] Corrige a atualização de seção obrigatória
- [Relatos] Correção nos caches das categorias de relato
- [Relatos] Correção no e-mail de relato enviado ao munícipe

### Mudanças
- [Webhook] Melhorias no webhook

## 1.1.1 - 27/11/2015
### Correções
- [Relatos] Correção no agendamento da tarefa para extrair dados do EXIFF

## 1.1.0 - 20/11/2015
### Adições
- [Relatos] Adicionado filtro de perímetros para pesquisa de relatos
- [Perímetros] Adicionado pesquisa por título e ordenação para o endpoint dos perímetros
- [Perímetros] Adicionado grupo solucionador padrão para os perímetros

### Mudanças
- [Relatos/Históricos] Adicionado novo tipo de histórico para identificar quando um relato é encaminhado para um perímetro

### Correções
- [Testes] Corrigido testes que falhavam aleatoriamente
- [Notificações] Alterado notificações para o prazo padrão aceitar valores nulos
- [Notificações] Adicionado categoria do relato no retorno da pesquisa de notificações

### Correções
- [Relatos] Corrigido pesquisa por dias em atraso para notificações vencidas

### Correções
- Corrigido traduções para português

### Correções
- [Etapas] Alterado etapas para listar os gatilhos na ordem correta

### Correções
- [Gatilhos] Corrige a atualização de gatilhos e condições

## 1.0.6
### Mudanças
- Atualização da dependência dos trabalhos assíncronos

## 1.0.5
## Mudanças
- [Relatos/Perímetros] Alterada paginação de perímetros para opcional

### Correções
- [Usuários] Alterado a data de nascimento para opcional no cadastro de usuário

## 1.0.4
## Adições
- [Relatos] Adicionada a funcionalidade de Perímetros
- [Usuários] Adicionado campos extras
- [Fluxos] Corrige problema que impedia a exibição de campos permissionados na listagem de todos os campos de um Fluxo

## Mudanças
- [Notificações] Alterado notificações para o prazo padrão poder ser opcional
- [Relatos] Alterado placeholder de endereço para usar o endereço completo ao invés de somente o logradouro
- [Relatos] Alterado pesquisa de endereço para filtrar pelos campos de logradouro, bairro e CEP

### Correções
- [Usuários] Adicionado validação de confirmação de senha

## 1.0.3
## Adições
- Adicionado legenda e data para as imagens dos relatos

### Correções
- [Relatos] Normalizado tempo de resposta na pesquisa de notificações

## 1.0.2
## Adições
- Adicionada nova funcionalidade de notificações para as categorias de relato

### Melhorias
- [Specs] Quebrando spec do apis/cases em vários arquivos para rodar mais rapidamente no CI;
- [Fluxos] O gerenciamento de permissões de etapas agora é feito inteiramente pelo endpoint `PUT /flows/:id/steps/:id/permissions`;
- [Specs] Aumentada cobertura dos models Field e Step;
- [Specs] Atualizado relatório do knapsack;
- [Casos] Parâmetros de pesquisa e filtragem em listagem de casos;

## Mudanças
- [Fluxos/Casos] Retornar versão corrente se o fluxo não está em rascunho e foi solicitado um rascunho
- [Relatos] Criar histórico quando a referência de um relato for alterada

### Correções
- [Fluxos/Casos] Bug em Field#add_field_on_step
- [Fluxos/Casos] Bug em Step#set_draft
- [Specs] Factories: Field e Step
- [Gitlab CI] Corrigido build no Gitlab CI e aumentando o número de nodes para 5
- [Relatos/Relatórios] Corrigido diferença de quantidade de relatos encontrados entre os Relatórios e a pesquisa de Relatos
- [Relatos/Categorias] Corrigido a listagem de categorias privadas, que estavam sendo exibidas para os usuários não-logados

## 1.0.0
Versão estável inicial
