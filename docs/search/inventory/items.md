# Busca por items de inventário

## Busca por conteúdo nos campos

Você pode efetuar buscas por conteúdos em campos específicos de uma categoria de inventário.
__Lembre-se: você só pode buscar por campos se não efetuar a busca por mais de uma categoria diferente__

Para filtrar por conteúdos nos campos, a base do request é essa:

    {
      "fields": {
        "id_do_campo": {
          // Filtros aqui
        }
      }
    }

### Filtro "maior que"

__Apenas para campos de valor numérico__

Exemplo:

    {
      "fields": {
        "id_do_campo": {
          "greater_than": 20
        }
      }
    }

No exemplo acima, irá retornar itens de inventário que o valor do campo
sejam maior que 20. (para campos numéricos)

### Filtro "menor que"

__Apenas para campos de valor numérico__

Exemplo:

    {
      "fields": {
        "id_do_campo": {
          "lesser_than": 20
        }
      }
    }

No exemplo acima, irá retornar itens de inventário que o valor do campo
sejam menos que 20.

### Filtro "iqual a"

__Apenas para campos com valor numérico ou de texto__

Exemplo:

    {
      "fields": {
        "id_do_campo": {
          "equal_to": "test"
        }
      }
    }

No exemplo acima, irá retornar itens de inventário que o valor do campo
sejam exatamente igual a `test`.

### Filtro "diferente de"

__Apenas para campos com valor numérico ou de texto__

Exemplo:

    {
      "fields": {
        "id_do_campo": {
          "different": "test"
        }
      }
    }

No exemplo acima, irá retornar itens de inventário que o valor do campo
sejam diferente de `test`.

### Filtro "parecido com"

__Apenas para campos com valor numérico ou de texto__

Exemplo:

    {
      "fields": {
        "id_do_campo": {
          "like": "test"
        }
      }
    }

No exemplo acima, irá retornar itens de inventário que o valor do campo
contenham `test` no seu valor.

### Filtro "inclui"

__Apenas para campos que tenham um array como conteúdo (ex.: checkboxes)__

Exemplo:

   ?fields[id_do_campo][includes][0]=1234&fields[id_do_campo][includes][1]=2356

No exemplo acima, irá retornar itens de inventário que o valor do campo
contenham os itens que selecionaram a opção de campo com id *1234* e *2356*.

### Filtro "não inclui"

__Apenas para campos que tenham um array como conteúdo (ex.: checkboxes)__

Exemplo:

   ?fields[id_do_campo][excludes][0]=1234&fields[id_do_campo][excludes][1]=2356

No exemplo acima, irá retornar itens de inventário que o valor do campo
__NÃO__ contenham os itens que selecionaram a opção de campo com id *1234* e *2356*.
