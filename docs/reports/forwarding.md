# Encaminhamento de relatos

No ZUP, temos uma funcionalidade para encaminhamento de relatos, para isso, foram adicionadas novas funcionalidades e endpoints na API.

## Permissões

Temos 4 novas permissões:

* `reports_items_forward` - Grupo pode encaminhar item de relato da categoria atribuída
* `reports_items_create_internal_comment` - Grupo pode inserir uma observação interna nos relatos da categoria atribuída
* `reports_items_alter_status` - Grupo pode alterar status de releato da categoria atribuída
* `reports_items_create_comment` - Grupo pode adicionar comentário público ou privado nos relatos da categoria atribuída

## Endpoints

### Encaminhar relato para grupo

Endpoint:

    PUT '/reports/:category_id/items/:id/forward'

Parâmetros:

| Parâmetro | Tipo    | Obrigatório | Descrição                                        |
|-----------|---------|-------------|--------------------------------------------------|
| group_id  | Integer | Sim         | Id do grupo para encaminhar o relato             |
| comment   | String  | Não*        | Observação interna que será adicionada ao relato |

* O `comment` será obrigatório se a flag `comment_required_when_forwarding` da categoria de relato estiver ativa.

### Associar relato à um usuário

Endpoint:

    PUT '/reports/:category_id/items/:id/assign'

Parâmetros:

| Parâmetro | Tipo    | Obrigatório | Descrição                            |
|-----------|---------|-------------|--------------------------------------|
| user_id   | Integer | Sim         | Id do grupo para encaminhar o relato |

### Alterar status de um relato

Endpoint:

    PUT '/reports/:category_id/items/:id/update_status'

Parâmetros:

| Parâmetro          | Tipo    | Obrigatório | Descrição                                             |
|--------------------|---------|-------------|-------------------------------------------------------|
| status_id          | Integer | Sim         | Id do novo status para o relato                       |
| comment            | String  | Não*        | Comentário que será adicionado ao relato              |
| comment_visibility | Integer | Não**       | Visibilidade do comentário, 0 = Público e 1 = Privado |

* O `comment` será obrigatório se a flag `comment_required_when_updating_status` da categoria de relato estiver ativa.
** O `comment_visibility` será obrigatório se `comment` estiver presente.

## Flags

Foram adicionadas 2 novas flags à categoria de relato:

* `comment_required_when_forwarding` - Será necessária uma observação interna ao encaminhar um relato
* `comment_required_when_updating_status` - Será necessária um comentário público ou privado ao atualizar um relato

Essas flags podem ser atribuídas normalmente nos endpoints já feitos de criação e edição de categoria de relato.

## Histórico

Existem dois novos tipos de histórico para itens de relato agora: `forward` e `user_assign`.

Estes dois novos tipos podem ser utilizados para buscar entradas no histórico do relato.

## Grupos solucionadores

Para cada categoria de relato, é possível cadastrar grupos que são solucionadores responsáveis pelos relatos, para isso, foi criado um atributo `solver_groups_ids`, em que são salvos os ids dos grupos solucionadores.

Com isso, foi criado um outro atributo chamado `default_solver_group_id`, que salvará o grupo padrão para qual um relato é primeiramente encaminhado.

Ambos os atributos podem ser passados como parâmetros nos endpoints já existentes de criação e edição de categoria de relato.

Lembrando que, um grupo solucionador padrão deverá ser selecionado caso algum grupo seja cadastrado como solucionador na categoria.

## Filtros

Para melhorar a experiência do usuário na navegação, foram criados dois filtros novos, que podem ser passados como parâmetros no endpoint de busca de relatos (`/search/reports/items`):

### assigned_to_my_group

Ao passar esse parâmetro como `true` na requisição, a busca só retornará relatos associados aos grupos solucionadores aos quais o usuário pertence.

### assigned_to_me

Ao passar esse parâmetro como `true` na requisição, a busca só retornará relatos associados ao usuário logado.
