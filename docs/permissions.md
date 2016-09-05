# Permissões

## Como funcionam as permissões

As permissões no ZUP são modulares e podem ser de dois tipos: **booleanas ou relativas à entidades**.

### Como são estruturadas

Elas são estruturadas de forma que cada `Group` tenha um `GroupPermission`, e cada permissão é representada por uma coluna nessa tabela. Dependendo da permissão, essa coluna pode ser `boolean` ou `integer[]`.

### Hierarquia das permissões

Cada coluna (ou atributo) que armazena uma informação de permissão, pertence à uma categoria, dentro de `app/models/group_permission.rb` você pode ver como está organizado:

    # Types of permissions
    TYPES = {
      flow: {
        'manage_flows' => Boolean,
        'flow_can_view_all_steps' => Array,
        'flow_can_execute_all_steps' => Array,
        # "can_view_step" => Array,
        # "can_execute_step" => Array,
        'flow_can_delete_all_cases' => Array,
        'flow_can_delete_own_cases' => Array
      },

      chat: {
        'manage_chat_rooms' => Boolean,
        'chat_rooms_read' => Array
      },

      user: {
        'users_full_access' => Boolean
      },
      ...
    }

Isso é utilizado na classe `Groups::PermissionManager`, onde essas permissões são adicionadas/removidas dos grupos.

### Configuração das permissões

As permissões são configuradas dentro da classe `UserAbility`, em `app/models/user_ability.rb`, é utilizado o [CanCanCan](https://github.com/CanCanCommunity/cancancan)

### Utilização das permissões

Para utilizar a validação das permissões temos duas possibilidades:

* Você pode instanciar a classe `UserAbility` manualmente (ex.: `UserAbility.new(user)`)
* Você pode utilizar o helper criado para os endpoints da API chamado `validate_permission!(action, model)`

# Endpoints

Para adicionar (ou remover) permissões de um grupo, utilizar o seguinte endpoint com o id do grupo:

`PUT /groups/1/permissions`

## Permissões de administração

Existem as seguintes permissões disponíveis para administração.
Seus valores são booleanos (true/false) e ela sobrepõe qualquer outra permissão
do grupo:

```
manage_users
manage_inventory_categories
manage_inventory_items
manage_groups
manage_reports_categories
manage_reports
manage_flows
view_categories
view_sections
```

Podem ser passadas como parâmetros, exemplo:

    {
      "manage_users": true,
      "manage_groups": false
    }


## Permissões para seções de categorias

Utilizar os seguintes identificadores: `inventory_sections_can_view` e `inventory_sections_can_edit`

Exemplo de requisição:

    {
      "inventory_sections_can_view": [1,2,3,4],
      "inventory_sections_can_edit": [1,3,4,5]
    }

## Permissões para campos de categorias de inventário

Utilizar os seguintes identificadores: `inventory_fields_can_view` e `inventory_fields_can_edit`

Exemplo de requisição:

    {
      "inventory_fields_can_view": [1,2,3,4],
      "inventory_fields_can_edit": [1,4,6,5]
    }
