# Documentação ZUP-API - Fluxos - Etapas - Campos

## Protocolo

O protocolo usado é REST e recebe como parâmetro um JSON, é necessário executar a chamada de autênticação e utilizar o TOKEN nas chamadas desse Endpoint.
Necessário criação de uma Etapa para utilização correta desse endpoint.

Endpoint Staging: `http://staging.zup.sapience.io/flows/:flow_id/steps/:step_id/fields`

Exemplo de como realizar um request usando a ferramenta cURL:

```bash
curl -X POST --data-binary @field-data.json -H 'Content-Type:application/json' -H 'X-App-Token:TOKEN' http://staging.zup.sapience.io/flows/:flow_id/steps/:step_id/fields
```
Ou
```bash
curl -X POST --data-binary '{"campo":"valor"}' -H 'Content-Type:application/json' -H 'X-App-Token:TOKEN' http://staging.zup.sapience.io/flows/:flow_id/steps/:step_id/fields
```

## Serviços

### Índice

* [Listagem](#list)
* [Criação](#create)
* [Edição](#update)
* [Deleção](#delete)
* [Redefinir Ordenação](#order)

___

### Listagem <a name="list"></a>

Endpoint: `/flows/:flow_id/steps/:step_id/fields`

Method: get

#### Parâmetros de Entrada

| Nome          | Tipo   | Obrigatório | Descrição                                     |
|---------------|--------|-------------|-----------------------------------------------|
| display_type  | String | Não         | Para retornar todos os dados utilizar 'full'. |

#### Status HTTP

| Código | Descrição                          |
|--------|------------------------------------|
| 401    | Acesso não autorizado.             |
| 200    | Exibe listagem (com zero ou mais). |

#### Exemplo

##### Response
```
Status: 200
Content-Type: application/json
```

###### FieldObject
| Nome                     | Tipo       | Descrição                                                                                          |
|--------------------------|------------|----------------------------------------------------------------------------------------------------|
| id                       | Interger   | ID do objeto.                                                                                      |
| list_versions            | Array      | Array contento todas as versões do objeto.                                                         |
| created_at               | DateTime   | Data e horário da criação do objeto.                                                               |
| updated_at               | DateTime   | Data e horário da última atualização do objeto.                                                    |
| title                    | String     | Título do Objeto.                                                                                  |
| previous_field           | Object     | Exibir campo anterior.                                                                             |
| active                   | Boolean    | Se o objeto esta ativo.                                                                            |
| field_type               | String     | Tipo do Campo (vide tipos de campos no Cadastro)                                                   |
| origin_field_id          | Integer    | ID do Campo de origen (somente se field_type for previous_field)                                   |
| origin_field_version     | Integer    | ID da Versão do Campo de origen (somente se field_type for previous_field)                                   |
| category_inventory       | Integer    | Item de Inventário (somente se o field_type for category_inventory)                          |
| category_inventory_field | Integer    | Campo de Item de Inventário (somente se o field_type for category_inventory_field)                          |
| category_report          | Integer    | Item de Relato (somente se o field_type for category_report)                                 |
| filter                   | Array      | Filtros para inclusão, ex.: "jpg,png" (somente se o field_type for image ou attachment)            |
| requirements             | Hash       | Requerimentos (presença, mínimo/máximo)                                                            |
| values                   | Hash       | Values (para os tipo select, checkbox e radio), ex: {key:value, key:value}                         |
| version_id               | Interger   | ID da Versão do objeto.                                                                            |

###### Requirements
| Nome      | Tipo    | Descrição                                                                     |
|-----------|---------|-------------------------------------------------------------------------------|
| presence  | Boolean | Se o campo é obrigatório                                                      |
| minimum   | Integer | Valor mínimo para o campo ou tamanho no caso de campo texto                   |
| maximum   | Integer | Valor máximo para o campo ou tamanho no caso de campo texto                   |

```json
{
  "fields": [
    {
      "list_versions": null,
      "last_version_id": null,
      "last_version": 1,
      "updated_at": "2014-05-17T13:40:18.039-03:00",
      "created_at": "2014-05-17T13:40:18.039-03:00",
      "active": true,
      "id": 1,
      "title": "age",
      "field_type": "integer",
      "filter": null,
      "origin_field": null,
      "category_inventory": null,
      "category_report": null,
      "requirements": null
    }
  ]
}
```
___

### Redefinir Ordenação <a name="order"></a>

Endpoint: `/flows/:flow_id/steps/:step_id/fields`

Method: put

#### Parâmetros de Entrada

| Nome | Tipo  | Obrigatório | Descrição                                   |
|------|-------|-------------|---------------------------------------------|
| ids  | Array | Sim         | Array com ids dos Campos na ordem desejada. |

#### Status HTTP

| Código | Descrição                  |
|--------|----------------------------|
| 400    | Parâmetros inválidos.      |
| 401    | Acesso não autorizado.     |
| 200    | Exibe mensagem de sucesso. |

#### Exemplo

##### Request

```json
{
  "ids": [3,1,2]
}
```

##### Response
```
Status: 200
Content-Type: application/json
```

```json
{
  "message": "Ordem dos Campos atualizado com sucesso"
}
```
___

### Criação <a name="create"></a>

Endpoint: `/flows/:flow_id/steps/:step_id/fields`

Method: post

#### Parâmetros de Entrada

| Nome                  | Tipo    | Obrigatório | Descrição                                                                 |
|-----------------------|---------|-------------|---------------------------------------------------------------------------|
| title                 | String  | Sim         | Título. (até 100 caracteres)                                              |
| field_type            | String  | Sim         | Tipo do campo. (vide Tipos de Campos)                                     |
| origin_field_id       | Integer | Não         | ID do Campo de origen (somente se field_type for previous_field)          |
| category_inventory_id | Integer | Não         | ID do Item de Inventário (somente se o field_type for category_inventory) |
| category_report_id    | Integer | Não         | ID do Item de Relato (somente se o field_type for category_report)        |
| filter                | Array   | Não         | Filtros para inclusão, ex.: "jpg,png" (somente se o field_type for image ou attachment)   |
| requirements          | Hash    | Não         | Requerimentos (presença, mínimo/máximo)                                   |
| values                | Hash    | Não         | Values (para os tipo select, checkbox e radio), ex: {key:value, key:value}|

##### Tipos de Campos
| Tipo                          | Descrição                                                                     | Valor a ser utilizado no preenchimento da Etapa do Caso               |
|-------------------------------|-------------------------------------------------------------------------------|-----------------------------------------------------------------------|
| angle                         | Angulo (de 0 a 360º).                                                         | Valor inteiro com range de 0 a 360.                                   |
| date                          | Data (dd/mm/yyyy).                                                            | Valor string no formato de data dd/mm/yyyy.                           |
| time                          | Horário (hh:mm:ss).                                                           | Valor string no formato de horário hh:mm:ss.                          |
| cpf                           | CPF.                                                                          | Valor string com ou sem pontos.                                       |
| cnpj                          | CNPJ.                                                                         | Valor string com ou sem pontos/barra.                                 |
| url                           | URL.                                                                          | Valor string com formato de URL completo (com http(s)/ftp/udp).       |
| email                         | E-mail.                                                                       | Valor string com formato de e-mail.                                   |
| image                         | Image.                                                                        | Array de Hash com file_name e content (base64 do conteúdo da imagem). |
| attachment                    | Anexo.                                                                        | Array de Hash com file_name e content (base64 do conteúdo).           |
| text                          | Texto.                                                                        | Valor string.                                                         |
| integer                       | Inteiro.                                                                      | Valor inteiro.                                                        |
| decimal                       | Decimal.                                                                      | Valor decimal/float.                                                  |
| meter                         | Metros.                                                                       | Valor decimal/float.                                                  |
| centimeter                    | Centimetros.                                                                  | Valor decimal/float.                                                  |
| kilometer                     | Kilometros.                                                                   | Valor decimal/float.                                                  |
| year                          | Anos.                                                                         | Valor inteiro.                                                        |
| month                         | Meses.                                                                        | Valor inteiro.                                                        |
| day                           | Dias.                                                                         | Valor inteiro.                                                        |
| hour                          | Horas.                                                                        | Valor inteiro.                                                        |
| minute                        | Minutos.                                                                      | Valor inteiro.                                                        |
| second                        | Segundos.                                                                     | Valor inteiro.                                                        |
| previous_field                | Campo anterior (deve ser informado o ID do campo em origin_field_id).         | Valor de acordo com o tipo do campo informado no origin_field_id.     |
| category_inventory            | Categorias de Inventário (deve ser informado o ID da Categoria).              | Array de IDs dos Itens de Inventário selecionados.                    |
| category_inventory_field      | Campo Inventário (deve ser informado o ID do campo em origin_field_id).       | Valor de acordo com o tipo do campo informado no origin_field_id.     |
| category_report               | Categorias de Relato (deve ser informado o ID da categoria).                  | Array de IDs dos Relatos selecionados.                                |
| checkbox                      | Checkbox (deve informar os valores em 'values' com {key:value,key:value}).    | Array de chaves selecionados.                                         |
| select                        | Select (deve informar os valores em 'values' com {key:value, key:value}).     | Valor string com a chave selecionada.                                 |
| radio                         | Radio (deve informar os valores em 'values' com {key:value, key:value}).      | Valor string com a chave selecionada.                                 |


##### Requirements
| Nome      | Tipo    | Obrigatório | Descrição                                                                     |
|-----------|---------|-------------|-------------------------------------------------------------------------------|
| presence  | Boolean | Não         | Se o campo é obrigatório                                                      |
| minimum   | Integer | Não         | Valor mínimo para o campo ou tamanho no caso de campo texto                   |
| maximum   | Integer | Não         | Valor máximo para o campo ou tamanho no caso de campo texto                   |

#### Status HTTP

| Código | Descrição                  |
|--------|----------------------------|
| 400    | Parâmetros inválidos.      |
| 401    | Acesso não autorizado.     |
| 201    | Se foi criado com sucesso. |

#### Exemplo

##### Request
```json
{
  "title":"age",
  "field_type":"integer"
}
```

##### Response
```
Status: 201
Content-Type: application/json
```

| Nome         | Tipo   | Descrição                               |
|--------------|--------|-----------------------------------------|
| field        | Object | Campo (vide FieldObject no get /fields) |

```json
{
  "field": {
    "list_versions": null,
    "previous_field": null,
    "created_at": "2015-03-03T13:30:29.082-03:00",
    "updated_at": "2015-03-03T13:30:29.082-03:00",
    "version_id": null,
    "active": true,
    "values": null,
    "id": 1,
    "title": "Campo 1",
    "field_type": "text",
    "filter": null,
    "origin_field_id": null,
    "category_inventory": null,
    "category_report": null,
    "requirements": {
      "presence": "true"
    }
  },
  "message": "Campo criado com sucesso"
}
```
___

### Edição <a name="update"></a>

Endpoint: `/flows/:flow_id/steps/:step_id/fields/:id`

Method: put

#### Parâmetros de Entrada

| Nome                  | Tipo    | Obrigatório | Descrição                                                                 |
|-----------------------|---------|-------------|---------------------------------------------------------------------------|
| title                 | String  | Sim         | Título. (até 100 caracteres)                                              |
| field_type            | String  | Sim         | Tipo do campo. (vide Tipos de Campos)                                     |
| origin_field_id       | Integer | Não         | ID do Campo de origen (somente se field_type for previous_field)          |
| category_inventory_id | Integer | Não         | ID do Item de Inventário (somente se o field_type for category_inventory) |
| category_report_id    | Integer | Não         | ID do Item de Relato (somente se o field_type for category_report)        |
| filter                | Array   | Não         | Filtros para inclusão, ex.: "jpg,png" (somente se o field_type for image ou attachment)   |
| requirements          | Hash    | Não         | Requerimentos (presença, mínimo/máximo)                                   |
| values                | Hash    | Não         | Values (para os tipo select, checkbox e radio), ex: {key:value, key:value}|

##### Tipos de Campos
| Tipo                          | Descrição                                                                     |
|-------------------------------|-------------------------------------------------------------------------------|
| angle                         | Angulo (de 0 a 360º).                                                         |
| date                          | Data (dd/mm/yyyy).                                                            |
| time                          | Horário (hh:mm:ss).                                                           |
| cpf                           | CPF.                                                                          |
| cnpj                          | CNPJ.                                                                         |
| url                           | URL.                                                                          |
| email                         | E-mail.                                                                       |
| image                         | Image.                                                                        |
| attachment                    | Anexo.                                                                        |
| text                          | Texto.                                                                        |
| integer                       | Inteiro.                                                                      |
| decimal                       | Decimal.                                                                      |
| meter                         | Metros.                                                                       |
| centimeter                    | Centimetros.                                                                  |
| kilometer                     | Kilometros.                                                                   |
| year                          | Anos.                                                                         |
| month                         | Meses.                                                                        |
| day                           | Dias.                                                                         |
| hour                          | Horas.                                                                        |
| minute                        | Minutos.                                                                      |
| second                        | Segundos.                                                                     |
| previous_field                | Campo anterior (deve ser informado o ID do campo em origin_field_id).         |
| category_inventory            | Campo Inventário (deve ser informado o ID do campo em category_inventory_id). |
| category_report               | Campo Relato (deve ser informado o ID do campo em category_report_id).        |
| checkbox                      | Checkbox (deve informar os valores em 'values' com {key:value,key:value}).    |
| select                        | Select (deve informar os valores em 'values' com {key:value, key:value}).     |
| radio                         | Radio (deve informar os valores em 'values' com {key:value, key:value}).      |


##### Requirements
| Nome      | Tipo    | Obrigatório | Descrição                                                                     |
|-----------|---------|-------------|-------------------------------------------------------------------------------|
| presence  | Boolean | Não         | Se o campo é obrigatório                                                      |
| minimum   | Integer | Não         | Valor mínimo para o campo ou tamanho no caso de campo texto                   |
| maximum   | Integer | Não         | Valor máximo para o campo ou tamanho no caso de campo texto                   |

#### Status HTTP

| Código | Descrição                      |
|--------|--------------------------------|
| 400    | Parâmetros inválidos.          |
| 401    | Acesso não autorizado.         |
| 404    | Não existe.                    |
| 200    | Se foi atualizado com sucesso. |

#### Exemplo

##### Request
```json
{
  "title": "Novo Título"
}
```

##### Response
```
Status: 200
Content-Type: application/json
```

```json
{
  "message": "Campo atualizado com sucesso"
}
```
___

### Deleção <a name="delete"></a>

Endpoint: `/flows/:flow_id/steps/:step_id/fields/:id`

Method: delete

Se houver algum Caso criado para o Fluxo pai da Etapa desse Campo (pode ver com a opção GET do Fluxo e o atributo "total_cases")
o Campo não poderá ser apagado e será inativado, caso não possua Casos será excluido fisicamente.

#### Parâmetros de Entrada

Nenhum parâmetro de entrada, apenas o **id** na url.

#### Status HTTP

| Código | Descrição                   |
|--------|-----------------------------|
| 401    | Acesso não autorizado.      |
| 404    | Não existe.                 |
| 200    | Se foi apagada com sucesso. |

#### Exemplo

##### Response
```
Status: 200
Content-Type: application/json
```

```json
{
  "message": "Campo apagado com sucesso"
}
```
