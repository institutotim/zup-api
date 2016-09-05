# Permissões de grupo

## Índice
* [Retornar permissões de um grupo](#)
* [Adicionar permissão(ões) em um grupo](#)
* [Remover permissão de um grupo](#)

### Retornar permissões de um grupo

Para retornar as pemrissões de um grupo, basta utilizar o seguinte endpoint:

    GET /groups/:group_id/permissions

o retorno desta requisição é o seguinte:

    [
      {
        "permission_type": "inventory",
        "object": { // Inventory category info },
        "permission_names": ["inventory_categories_can_edit", "inventory_categories_can_view"]
      },
      {
        "permission_type": "report",
        "permission_names": "manage_reports"
      }
    ]

Caso não há a propriedade object, a permissão é booleana e o valor é `true`.

### Adicionar permissão(ões) em um grupo

Para adicionar uma ou mais permissões para um grupo, utilizar o seguinte endpoint:

    POST /groups/:id/permissions/:permission_type

#### Parâmetros

| Nome        | Tipo           | Obrigatório | Descrição                                                 |
|-------------|----------------|-------------|-----------------------------------------------------------|
| objects_ids | Array[Integer] | Não         | Array de ids dos objetos relacionados às permissões       |
| permissions | Array[String]  | Sim         | Array de string com as permissões para adicionar ao grupo |

#### Tipos de permissões disponíveis

| Nome      | Descrição         |
|-----------|-------------------|
| flow      | Casos e fluxos    |
| report    | Relatos           |
| inventory | Inventário        |
| group     | Grupos            |
| user      | Usuários          |
| other     | Outras permissões |

Esse tipo deve ser espresso na URL do endpoint.

#### Exemplo de requisição

    {
      "objects_ids": [1, 3],
      "permissions": ["inventory_categories_can_edit", "inventory_categories"]
    }

#### Exemplo de retorno

    {
      message: "Permissões adicionadas com sucesso"
    }

### Remover permissão de um grupo

Para remover uma permissão de um grupo, utilizar o seguinte endpoint:

    DELETE /groups/:id/permissions/:permission_type

#### Parâmetros

| Nome       | Tipo    | Obrigatório | Descrição                                                                 |
|------------|---------|-------------|---------------------------------------------------------------------------|
| permission | String  | Sim         | Nome da permissão                                                         |
| object_id  | Integer | Não         | Caso a permissão seja relacionada à algum objeto, utilizar esse parâmetro |

#### Exemplo de requisição

    {
      "permission": "inventory_categories_can_edit",
      "object_id": 2
    }

#### Exemplo de retorno

    {
      "message": "Permissão removida com sucesso"
    }
