# Relatórios

Para a criação de relatório nós trabalhamos com duas entidades: `BusinessReport` e `Chart`.

## Permissões

Foram criadas duas permissões para gerenciar os relatórios: `business_reports_edit` e `business_reports_view`.

* `business_reports_edit`: é uma permissão **booleana** onde dá ao grupo permissão para criar, editar e deletar relatórios
* `business_reports_view`: é uma permissão associada à ids de `BusinessReport`, onde dá permissão do grupo visualizá-los

## BusinessReport

`BusinessReport` contém os dados do relatório em si, o título, o criador do relatório, o sumário e etc. Cada `BusinessReport` contém os gráficos do relatório, `Chart`.

### Endpoints

Os endpoints para criar, editar, visualizar e deletar relatórios são um CRUD básico composto pelos seguintes endpoints:

    GET /business_reports
    POST /business_reports
    PUT /business_reports/:id
    DELETE /business_reports/:id

Para os endpoints `POST` e `PUT` temos os seguintes parâmetros:

| Atributo   | Tipo   | Requerido | Descrição                                        |
|------------|--------|-----------|--------------------------------------------------|
| title      | String | Sim       | Título do relatório                              |
| summary    | String | Não       | Pequeno sumário do relatório                     |
| begin_date | Date   | Não       | A data inicial para exibir os dados do relatório |
| end_date   | Date   | Não       | A data inicial para exibir os dados do relatório |

## Chart

Cada `Chart` é uma entidade que representa os gráficos em um relatório. Após criado, um _background job_ é disparado para a população dos dados desse gráfico, onde será retornado no atributo `data` de retorno.

### Endpoints

Os endpoints para criar, editar, visualizar e deletar gráficos são um CRUD básico composto pelos seguintes endpoints:

    GET /business_reports/:id/charts
    POST /business_reports/:id/charts
    PUT /business_reports/:id/charts/:id
    DELETE /business_reports/:id/charts/:id

Os atributos para os endpoints `POST` e `PUT` são os seguintes:

| Atributo       | Tipo           | Requerido | Descrição                                                        |
|----------------|----------------|-----------|------------------------------------------------------------------|
| metric         | String         | Sim       | A métrica que será utilizada para popular o gráfico              |
| chart_type     | String         | Sim       | Pode ser 'pie' ou 'line'                                         |
| title          | String         | Sim       | O título que será exibido junto ao gráfico                       |
| description    | String         | Não       | Uma descrição que poderá ser exibida junto ao gráfico            |
| begin_date     | Date           | Não       | A data inicial para exibir os dados no gráfico                   |
| end_date       | Date           | Não       | A data final para exibir os dados no gráfico                     |
| categories_ids | Array[Integer] | Não       | Os ids das categorias para filtrar os dados dentro de um gráfico |

> **Importante:** os atributos `begin_date` e `end_date` são necessário para a entidade, ele não é obrigatório
> nesse _endpoint_ pois ele tentará usar o `begin_date` e `end_date` do relatório, se ele estiver vazio também,
> retornará um erro de validação.

E o retorno tem essa estrutura:

    {
      "id": 1,
      "metric": "total-reports-by-category"
      "chart_type": "line",
      "title": "Gráfico de relatos por categoria",
      "description": "Este é um gráfico de linha",
      "data": {
        "content": [
          ["Categoria", "Total"],
          ["Categoria 1", 4590],
          ["Categoria 2", 1231],
          ...
        ]
      }
    }

Note que no atributo `data` será populado os dados do gráfico correspondentes ao período selecionado.

### Métricas

As métricas que estão disponíveis para os gráficos são:

| Métrica                                  | Descricão                                                                   |
|------------------------------------------|-----------------------------------------------------------------------------|
| total-reports-by-category                | Total de relatos criados por categoria                                      |
| total-reports-by-status                  | Total de relatos por seu status                                             |
| total-reports-overdue-by-category        | Total de relatos atrasados por categoria                                    |
| total-reports-overdue-by-category-per-day | Total de relatos atrasados por categoria e por quantidade de dias em atraso |
| total-reports-assigned-by-category       | Total de relatos que foram associados por categoria                         |
| total-reports-assigned-by-group          | Total de relatos que foram associados, por grupo                            |
| total-reports-unassigned-to-user         | Total de relatos que não foram associados à nenhum usuário                  |
| average-resolution-time-by-category      | Média de tempo de resolução por categoria                                   |
| average-resolution-time-by-group         | Média de tempo de resolução por grupo associado                             |
| average-overdue-time-by-category         | Média de atraso por categoria                                               |
| average-overdue-time-by-group            | Média de tempo de atraso por grupo                                          |
