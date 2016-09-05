# Escolhas dos campos de inventário

Para manter a consistência dos campos de inventários e seus itens, foi criada uma estrutura nova para armazenar e listar as escolhas dos campos de inventário.

## Índice

* [Atributos do campo de inventário](#attributes)
* [Listar escolhas de um campo](#list)


## Atributos da escolha <a id="attributes"></a>

Um exemplo de campo de inventário em JSON é:

    {
      "id": 1,
      "inventory_field_id": 2,
      "disabled": false,
      "value": "Isso é uma escolha",
      "created_at": "..."
    }

## Listar escolhas de um campo <a id="list"></a>

Para listar as escolhas de um campo, utilizar esse endpoint:

`GET /inventory/fields/:id/options`

## Criar uma escolha para um campo <a id="create"></a>

Para criar uma escolha para um campo, utilizar o seguinte endpoint:

`POST /inventory/fields/:id/options`

### Parâmetros de entrada

| Nome  | Tipo          | Obrigatório | Descrição                                |
|-------|---------------|-------------|------------------------------------------|
| value | String/Array  | Sim         | O valor da opção, ou um array de valores |

### Status HTTP de resposta

| Código | Descrição              |
|--------|------------------------|
| 400    | Parâmetros inválidos.  |
| 401    | Acesso não autorizado. |
| 201    | Criado com sucesso.    |

### Exemplo de requisição

    {
      "value": "Isto é uma escolha"
    }

## Atualizar uma escolha para um campo <a id="update"></a>

Para atualizar uma escolha para o campo, utilizar o seguinte endpoint:

`PUT /inventory/fields/:field_id/options/:option_id`

### Parâmetros de entrada

| Nome  | Tipo    | Obrigatório | Descrição        |
|-------|---------|-------------|------------------|
| value | String  | Sim         | O valor da opção |

### Status HTTP de resposta

| Código | Descrição              |
|--------|------------------------|
| 400    | Parâmetros inválidos.  |
| 401    | Acesso não autorizado. |
| 200    | Atualizado com sucesso.|

### Exemplo de requisição

    {
      "value": "Isto é uma escolha com outro valor"
    }

## Remover escolha de um campo <a id="update"></a>

Para remover uma escolha para o campo, utilizar o seguinte endpoint:

`DELETE /inventory/fields/:field_id/options/:option_id`

### Status HTTP de resposta

| Código | Descrição              |
|--------|------------------------|
| 401    | Acesso não autorizado. |
| 200    | Removido com sucesso.  |

> **Nota**: essa escolha não irá ser removida de verdade, será apenas desativada, para manter a consistência com itens de inventário que estão referenciando essa escolha.

