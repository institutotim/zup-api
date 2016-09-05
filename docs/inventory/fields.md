# Campos de categorias de inventário

Um campo no formulário de uma categoria de inventário é uma entidade que representa um dado que o usuário pode inserir no formulário.

## Permissões

Você pode definir quais grupos podem ver ou podem editar um campo específico através do parâmetro `permissions`, exemplo
na requisição:

    {
      "sections": [{
        ...
        "fields": [{
          ...
          "permissions": {
            "groups_can_view": "1,4,5",
            "groups_can_edit": "2,5,6"
          }
        }]
      }]
    }

Você deve passar os ids no formato de exemplo acima, separado por vírgulas.

__Isso serve também para `sections`__

## Tipos de campos

Um campo deve ser um dos `kind` disponíveis:

    "text" => string
    "integer" => inteiro
    "decimal" => decimal
    "meters" => inteiro
    "centimeters" => inteiro
    "kilometers" => inteiro
    "years" => inteiro
    "months" => inteiro
    "days" => inteiro
    "hours" => inteiro
    "seconds" => inteiro "angle" => inteiro "date" => data e hora (formato iso)
    "time" => tempo (hora, minutos, segundos)
    "cpf" => string
    "cnpj" => string
    "url" => string,
    "email" => string,
    "images" => array,
    "checkbox" => array,
    "radio" => string

A associação descreve para qual tipo o conteúdo desse campo será convertido, dependendo do kind.

Por exemplo, se você tem um campo do com o `kind` igual a `integer`, se o usuário preencher esse campo com `2323`, o valor dele no sistema será de 2323 (inteiro), e irá ser validado sua **numericalidade** (se é realmente um número ou não).

Para todos os kinds descritos, há coerção de tipo, ou seja, será feito o cast para o tipo necessário.

## Validações

Hoje, temos as seguintes validações para os campos dinâmicos:

### maximum

Limita o valor máximo do conteúdo campo.

### minimum

Limita o valor mínimo do conteúdo do campo.

## Campos com valores especiais

### images

Images, aceita como conteúdo um array de objetos representando imagens, exemplo:

    {
      "content": [{
        "content": "conteúdo da imagem encodada em base64 aqui"
      }, ...]
    }

Para deletar uma imagem que já existe, basta passar o id com o attributo `destroy` como true:

    {
      "content": [{
        "id": 12314,
        "destroy": true
      }, ...]
    }

Esse id da imagem é retornado quando você obtém informações sobre o item.


### checkbox e radio

Quando utilizar um campo do tipo `checkbox` ou `radio`, você precisa passar um array com os ids de escolha de campo no `content`:

    {
      "data": {
        "id do campo": [13, 24]
      }
    }
