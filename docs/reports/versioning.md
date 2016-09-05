# Versionamento de relatos
===

Para a possibilidade de sincronização de relatos _offline_, foram feitas incrementos e melhorias na API de forma que os relatos possam ser validados contra sobrescrição acidental.

### Nova coluna em `reports_items`

Foram criada duas novas colunas:

* `version` - o número da versão que o relato se encontra
* `last_version_at` - data e hora que foi criada a versão atual do relato

### Modificação de relatos

No endpoint `PUT /reports/:category_id/items/:id` foi criado um novo parâmetro que é opcional chamado `version`.

Caso a edição do relato tenha sido feita _offline_, o cliente deverá enviar o parâmetro `version` atualizado localmente (`version` anterior mais 1).

Neste caso, o endpoint validará se a versão do relato procede ou se o relato foi atualizado no meio tempo.

Caso o relato já tenha sido atualizado antes e a versão que foi modificada localmente esteja desatualizada, a API retornará um erro do tipo `version_mismatch`, conforme exemplo abaixo:

    {
      "type": "version_mismatch",
      "error": "A manipulação do relato é improcedente, nova versão foi inserida no servidor, atualize a sua versão local"
    }
    
Caso a atualização esteja ok, inclusive a validação da versão, o status será `200 OK` e o corpo da requisição será da entidade atualizada do relato.

**Observação importante:** todo cliente com a funcionalidade de edição _offline_ e sincronização deverá considerar e fazer as manipulação acima descritas do `version`. No futuro o parâmetro `version` será obrigatório em todos os clientes.
