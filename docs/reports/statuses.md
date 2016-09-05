# Status de relatos

Para manipular os status da categoria de relato, foram criados alguns endpoints:

### Endpoints

* Listar status
* Criar status
* Editar status
* Deletar status

## Listar status

```
GET /reports/categories/:category_id/statuses
```

**Exemplo de retorno**

```
{
  "statuses": [{
    "active": true,
      "color": "#59B1DF",
      "final": false,
      "id": 10,
      "initial": true,
      "private": false,
      "title": "Em Aberto"
  },
  {
    "active": true,
    "color": "#EACD31",
    "final": false,
    "id": 11,
    "initial": false,
    "private": false,
    "title": "Em Análise Técnica"
  }]
}
```

## Criar status

```
POST /reports/categories/:category_id/statuses
```

### Parâmetros

| Parâmetro | Tipo    | Descrição                                      |
|-----------|---------|------------------------------------------------|
| title*    | String  | O título do status                             |
| color*    | String  | Cor do status, em formato hexadecimal: #ff0000 |
| initial*  | Boolean | O status é um status inicial?                  |
| final*    | Boolean | O status é um status final?                    |
| private   | Boolean | Define se o stauts é privado                   |

### Retorno

**STATUS** 201

```
  {
    "status": {
      "active": true,
      "color": "#59B1DF",
      "final": false,
      "id": 10,
      "initial": true,
      "private": false,
      "title": "Em Aberto"
    }
  }
```

## Editar status

```
PUT /reports/categories/:category_id/statuses/:status_id
```

### Parâmetros

| Parâmetro | Tipo    | Descrição                                      |
|-----------|---------|------------------------------------------------|
| title     | String  | O título do status                             |
| color     | String  | Cor do status, em formato hexadecimal: #ff0000 |
| initial   | Boolean | O status é um status inicial?                  |
| final     | Boolean | O status é um status final?                    |
| private   | Boolean | Define se o stauts é privado                   |

### Retorno

**STATUS** 200

```
{
  "status": {
    "active": true,
    "color": "#59B1DF",
    "final": false,
    "id": 10,
    "initial": true,
    "private": false,
    "title": "Em Aberto"
  }
}
```

## Deletar um status

```
DELETE /reports/categories/:category_id/statuses/:status_id
```

### Retorno

**STATUS** 200

```
{
  "status": {
    "active": true,
    "color": "#59B1DF",
    "final": false,
    "id": 10,
    "initial": true,
    "private": false,
    "title": "Em Aberto"
  }
}
```

> Observação: o status é desativado e não deletado
