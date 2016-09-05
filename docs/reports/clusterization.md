# Clusterização dos Relatos

No endpoint `GET /search/reports/items` você pode pedir a versão clusterizada quando buscando pelo mapa, para isso, basta passar `clusterize: true` nos parâmetros:

    ...
    &clusterize=true

## Retorno

Quando você passar esse parâmetro, o JSON de resposta que será retornado terá uma estrutura diferente:

    {
      "clusters": [...]
      "reports": [...]
    }

### Clusters

Os **clusters** são entidades mais simples que representam um conjunto de relatos, seus atributos são os seguintes:

    {
      "items_ids": [1, 2, 3],
      "position": [-23.5546875, -46.636962890625],
      "category_id": 2, // ID da categoria de relato
      "count": 3
    }

* `items_ids` são os ids dos relatos que estão sendo representados
* `position` são as coordenadas geográficas das categorias de relato
* `category_id`* o id da categoria de relato
* `count` é o número de itens de inventário que o cluster está representando

> * Dependendo do nível do zoom, a API pode agrupar ou não mais de uma categoria no mesmo cluster, quando isso ocorrer, será retornado o parâmetro `categories_ids` ao invés do `category_id`