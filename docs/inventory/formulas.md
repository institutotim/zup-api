# Fórmulas de Inventário

## Criação de fórmula para categoria de inventário

Para criar uma fórmula para uma categoria de inventário específica, utilizar o endpoint abaixo:

`POST /inventory/categories/:category_id/formulas`

Exemplo de requisição:

    {
      "inventory_status_id": 1,
      "groups_to_alert": [1, 3, 4],
      "conditions": [{
        "inventory_field_id": 123,
        "operator": "equal_to",
        "content": "Teste"
      }]
    }


Onde o `inventory_status_id` é o ID do status da categoria que o item será setado se as condições da fórmula for satisfeita.

`groups_to_alert` são os grupos de usuários que deverão ser alertados caso um item entre nas condições da fórmula.

`conditions` é a matriz de condições que a fórmula contém, sua estrutura é a seguinte:

`inventory_field_id` => o id do campo que condição testará
`operator` => é o operator utilizado na condição, pode ser um dos seguintes:

* equal_to
* greater_than
* lesser_than
* different
* between
* includes

`content` => é o conteúdo a ser testado pelo operador. __(pode ser um array de valores)__

### Aplicar a fórmula recém-criada para os itens de categoria

Para aplicar a fórmula para todos os itens da categoria, apenas passe o parâmetro `"run_formula": true` quando criá-la.

Exemplo:

    {
      "inventory_status_id": 1,
      "groups_to_alert": [1, 3, 4],
      "conditions": [{
        "inventory_field_id": 123,
        "operator": "equal_to",
        "content": "Teste"
      }],
      "run_formula": true
    }

A fórmula irá ser aplicada em todos os itens, em background.
