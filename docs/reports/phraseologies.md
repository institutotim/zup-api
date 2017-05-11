# Fraseologias

### Criando uma fraseologia

`POST /phraseologies`

    {
      "reports_category_id": 1000,
      "title": "Fraseologia padrão",
      "description": "Fraseologia..."
    }

#### Exemplo de retorno de sucesso

    {
      "phraseology": {
        "id": 1000,
        "title": "Fraseologia padrão",
        "description": "Fraseologia...",
        "category": {
          "id": 1000,
          "title": "Categoria"
        }
      }
    }

### Atualizando uma fraseologia

`PUT /phraseologies/{id}`

    {
      "title": "Fraseologia",
      "description": "Fraseologia Editada"
    }

### Listando fraseologias

`GET /phraseologies`

#### Parâmetros:

|Campo                |Tipo    |Obrigatório|Padrão|Descrição                                                      |
|---------------------|--------|-----------|------|---------------------------------------------------------------|
|`grouped`            |Boolean |Não        |`true`|Define se as fraseologias serão agrupadas ou não pela categoria|
|`reports_category_id`|Integer |Não        |      |Retorna fraseologias da categoria e as públicas                |

#### Exemplo de retorno desagrupado

    {
      "phraseologies": [
        {
          "id": 1000,
          "title": "Fraseologia padrão",
          "description": "Fraseologia...",
          "category": {
            "id": 1000,
            "title": "Categoria"
          }
        },
        ...
      ]
    }

#### Exemplo de retorno agrupado

    {
      "phraseologies": [
        "Categoria": [
          {
            "id": 1000,
            "title": "Fraseologia padrão",
            "description": "Fraseologia...",
            "reports_category_id": 1000
          }
        ]
      ]
    }
### Consultando uma fraseologia

`GET /phraseologies/{id}`

#### Exemplo de retorno

    {
      "phraseology": {
        "id": 1000,
        "title": "Fraseologia padrão",
        "description": "Fraseologia...",
        "category": {
          "id": 1000,
          "title": "Categoria"
        }
      }
    }

#### Removendo uma Fraseologia

`DELETE /phraseologies/{id}`
