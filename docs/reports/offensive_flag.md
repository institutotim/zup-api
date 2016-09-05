# Relatos marcados como ofensivo

Para o bom funcionamento do ZUP com os munícipes, temos a funcionalidade de marcar um relato como ofensivo.

## Marcar um relato como ofensivo

#### Endpoint:

    PUT /reports/items/:id/offensive

#### Parâmetros

Nenhum

#### Exemplo de requisição

    PUT /reports/items/2561/offensive

Retorno

    {
      "message": "Obrigado por contribuir com a melhoria da sua cidade!"
    }

### Erros

#### Usuário já reportou o relato

Caso o usuário já tenha reportado o relato, não será permitido ocorrer uma segunda reportagem, nesse caso a API retornará um erro que deverá ser tratado pelo cliente conforme a especificação.

O status da requisição será `400` e o retorno em JSON será:

    {
      "type": "model_validation",
      "error": "Você já reportou esse relato!"
    }

#### Usuário ultrapassou o limite de reportagem na hora

O ZUP limita a reportagem de relatos por um certo número por hora, definido pela API, caso esse limite seja ultrapassado, essa requisição retornará o seguinte erro que deverá ser tratado pelo cliente conforme a especificação.

O status da requisição será `400` e o retorno em JSON será:

    {
      "type": "model_validation",
      "error": "Você já atingiu o limite de reportagem de relatos por hora, aguarde antes de reportar outros relatos."
    }

## Desmarcar um relato como ofensivo

Para esse endpoint, o usuário necessita ter permissão para editar o relato.

#### Endpoint:

    DELETE /reports/items/:id/offensive

#### Parâmetros

Nenhum

#### Exemplo de requisição

    DELETE /reports/items/2561/offensive

Retorno

    {
      "message": "O relato foi marcado como apropriado novamente."
    }
