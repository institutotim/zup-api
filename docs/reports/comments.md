# Comentários dos Relatos

Os relatos podem ter comentários, efetuados tanto pelos munícipes tanto pelos usuários do painel.

## Índice

* [Atributos do comentário](#attributes)
* [Criar um comentário](#create)
* [Listar comentários](#list)


## Atributos do comentário <a name="attributes"></a>

Um exemplo de comentário em JSON é:

    {
      "id": 1,
      "reports_item_id": 2,
      "visibility: 1,
      "author": {
        ...
      },
      "message": "Isso é um comentário"
      "created_at": ""
    }

## Criar um comentário <a name="create"></a>

Para criar um comentário, utilizar o seguinte endpoint:

`POST /reports/:id/comments`

### Parâmetros de entrada

| Nome        | Tipo    | Obrigatório | Descrição                             |
|-------------|---------|-------------|---------------------------------------|
| visibility* | Integer | Sim         | 0 = Público, 1 = Privado, 2 = Interno |
| message     | String  | Sim         | O comentário em si                    |

\* __Como funciona a visibilidade?__

* Público  (0): Todos os usuários podem ver esse comentário
* Privado  (1): Apenas o autor do relato e os usuários do painel podem visualizar
* Interno (2): Apenas usuários do painel podem visualizar esse comentário

### Status HTTP

| Código | Descrição              |
|--------|------------------------|
| 400    | Parâmetros inválidos.  |
| 401    | Acesso não autorizado. |
| 201    | Criado com sucesso.    |

### Exemplo de requisição

    {
      "visibility": 1,
      "message": "Esse relato é muito útil"
    }

## Listar comentários <a name="list"></a>

Para listar os comentários de um relato, utilizar o seguinte endpoint:

`GET /reports/:id/comments`
