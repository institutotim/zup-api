# Considerações gerais

## Variáveis de ambiente:

| Nome                                     | Descrição                                                                                               | Padrão |
|------------------------------------------|---------------------------------------------------------------------------------------------------------|--------|
| `SERVER_WORKERS`                         | Quantidade de passenger workers para a API                                                              | 4      |
| `SMTP_ADDRESS`                           | Endereço do servidor SMTP para envio de e-mails                                                         |        |
| `SMTP_PORT`                              | Porta do servidor SMTP                                                                                  |        |
| `SMTP_USER`                              | Usuário para autenticação para o servidor SMTP                                                          |        |
| `SMTP_PASS`                              | Senha para autenticação para o servidor SMTP                                                            |        |
| `SMTP_TTLS`                              | Habilitar TTLS?                                                                                         | false  |
| `SMTP_AUTH`                              | Tipo de autenticação                                                                                    | plain  |
| `AWS_ACCESS_KEY_ID`                      | Chave de acesso para AWS (acesso de upload ao S3)                                                       |        |
| `AWS_SECRET_ACCESS_KEY`                  | Chave secreta de conta AWS (acesso de upload ao S3)                                                     |        |
| `AWS_DEFAULT_IMAGE_BUCKET`               | Nome do bucket no S3 para ser utilizado                                                                 |        |
| `TWITTER_CONSUMER_KEY`                   | Chave do aplicativo do Twitter para autenticação OAuth                                                  |        |
| `TWITTER_CONSUMER_SECRET`                | Chave secreta do Twitter para autenticação OAuth                                                        |        |
| `FACEBOOK_APP_ID`                        | Chave do aplicativo do Facebook para autenticação OAuth                                                 |        |
| `FACEBOOK_APP_SECRET`                    | Chave secreta do Facebook para autenticação OAuth                                                       |        |
| `GOOGLE_CLIENT_ID`                       | Chave do aplicativo do Google para autenticação OAuth                                                   |        |
| `GOOGLE_CLIENT_SECRET`                   | Chave secreta do Google para autenticação OAuth                                                         |        |
| `APNS_PEM_PATH`                          | Caminho para o arquivo .pem para notificações iOS                                                       |        |
| `APNS_PEM_PASS`                          | Senha, caso houver, do arquivo .pem                                                                     |        |
| `GCM_KEY`                                | Chave do Google Cloud Messaging para notificações Android                                               |        |
| `REDIS_URL`                              | URL completa do servidor Redis                                                                          |        |
| `API_URL`                                | URL completa, com porta, onde API estará hospedada                                                      |        |
| `WEB_URL`                                | URL completa, com porta, onde o componente Painel estará hospedada                                      |        |
| `PUBLIC_WEB_URL`                         | URL completa, com porta, onde o componente Web estará hospedada                                         |        |
| `ASSET_HOST_URL`                         | URL completa de onde estará hospedado os assets                                                         |        |
| `LIMIT_CITY_BOUNDARIES`                  | Limitar relatos e inventários por cidade                                                                | false  |
| `GEOCODM`                                | Código da cidade no shapefile                                                                           |        |
| `MAIL_HEADER_IMAGE`                      | Endereço para a imagem do header do e-mail                                                              |        |
| `MAIL_CUSTOM_GREETINGS`                  | Saudações para todos os e-mails enviados                                                                |        |
| `MAIL_CUSTOM_GREETING_MESSAGE`           | Mensagem da saudação para todos os e-mails enviados                                                     |        |
| `MAXIMUM_REPORTS_PER_USER_BY_HOUR`       | Número máximo de relatos por usuário, por hora                                                          |        |
| `MINIMUM_FLAGS_TO_MARK_REPORT_OFFENSIVE` | Número mínimo de flags para marcar um relato como ofensivo                                              |        |
| `SLACK_INCOMING_WEBHOOK_URL`             | URL do Incoming Webhook, caso deseje notificações em uma sala do [Slack](http://slack.com)              |        |
| `SENTRY_DSN_URL`                         | Endereço do DNS do Sentry, para agregar as exceções, caso você utilize o [Sentry](http://getsentry.com) |        |
| `DISABLE_EMAIL_SENDING`                  | Desativa o envio de emails pela API                                                                     |        |
| `WEBHOOK_URL`                            | URL para criação de relatos via integração                                                       |        |
| `WEBHOOK_UPDATE_URL`                     | URL para atualização e remoção de relatos via integração                                                |        |

## Escolher campos de retorno

Em todos os endpoints de listagem (ex: grupos, itens de inventário, relatos, categories, etc), você tem a opção de escolher quais campos deseja retornar da API, para isto basta utilizar o parâmetro `return_fields` na sua requisição.

Supomos que você queria o seguinte conteúdo para itens de inventário:

    {
      items: [
        {
          id: 1,
          title: 'Árvores',
          user: {
            id: 1,
            name: 'Ricardo'
          }
        },
        {
          id: 2,
          title: 'Semáforos',
          user: {
            id: 2,
            name: 'Rita'
          }
        }
      ]
    }

Você deverá passar o seguinte parâmetro pra URL do endpoint:

```
/inventory/items?return_fields=id,title,user.id,user.name
```

Nota-se que o formato é *uma string com os nomes dos campos separados por vírgulas*.
Também, para conteúdos aninhados, você deve utilizar o separador `.`, por exemplo, o campo `user.groups.name` é válido.

## Erros

Em diversos momentos e casos é esperado que a API retorne erros. Basicamente, quando ocorre um erro, o status HTTP de resposta da requisição é diferente de `200`.

O formato da resposta de erro retornada pela API é a seguinte:

    {
      "error": "...", // Pode ser uma string com a mensagem de erro ou um objeto
      "type": "..." // Tipo do erro
    }

### Status HTTP

Os seguintes status de erro retornados pela API é:

#### 403
A requisição falhou por falta de permissão.

#### 401
A requisição falhou por problemas de parâmetros.

#### 404
Algum objeto necessário não foi encontrado para a resposta da requisição ser construída.

#### 400
Problemas de validação de lógica de negócio.

### Tipos de erros

#### Não encontrado (not_found)

Caso alguma entidade necessária para a resposta da requisição não ter sido encontrada, um erro será retornado, com o `type: "not_found"`.

Exemplo de resposta:

    {
      "type": "not_found",
      "error": "Não foi encontrado"
    }

#### Erro de validação

Caso ocorra um erro de validação relacionado ao modelo de negócio, um erro do tipo `type: "model_validation"` será retornado. Comumente no atributo `"error"` virá um objeto com os campos com falhas na validação.

Exemplo de resposta:

    {
      "type": "model_validation",
      "error": {
        "name": "está vazio"
      }
    }

#### Erro de permissão

Caso o usuário logado não esteja autorizado a realizar a ação proposta pela requisição, será retornado um erro com o `type` igual a `invalid_permission`.

Exemplo de resposta:

    {
      "type": "invalid_permission",
      "error": "Usuário não pode editar: grupo"
    }

#### Erro desconhecido

Caso ocorra um erro desconhecido a resposta virá com o `type` igual a `unknown` e o `error` será a mensagem de erro:

Exemplo de resposta:

    {
      "type": "unknown",
      "error": "Erro desconhecido ocorreu, contate o suporte"
    }
