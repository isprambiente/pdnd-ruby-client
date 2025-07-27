# pdnd-ruby-client

Client Ruby per autenticazione e interazione con le API della Piattaforma Digitale Nazionale Dati (PDND).

## Licenza

MIT

## Requisiti

- Ruby >= 3.2 (versioni precedenti sono [EOL](https://endoflife.date/ruby))

## Installazione

1. Installa la libreria via composer:
   ```bash
   gem install pdnd-ruby-client
   ```

2. Configura il file JSON con i parametri richiesti (esempio in `configs/sample.json`):
   ```json
    {
      "collaudo": {
        "kid": "kid",
        "issuer": "issuer",
        "clientId": "clientId",
        "purposeId": "purposeId",
        "privKeyPath": "/tmp/key.priv"
      },
      "produzione": {
        "kid": "kid",
        "issuer": "issuer",
        "clientId": "clientId",
        "purposeId": "purposeId",
        "privKeyPath": "/tmp/key.priv"
      }
    }
   ```
## Istruzioni base

```ruby
require "pdnd_ruby_client"

# Inizializza la configurazione
# Load the configuration from the specified JSON file and environment key.
config = PDND::ConfigLoader.load("configs/sample.json")
jwt = PDND::JWTGenerator.new(config)
token, exp = jwt.generate_token
client = PDND::Client.new(config)
client.token = token
client.token_exp = exp
client.api_url="https://www.tuogateway.example.it/indirizzo/della/api"
client.filters="id=1234"
code, body = client.get_api

# Stampa il risultato
puts body

```

## Leggi e Salva il token

```ruby

require "pdnd_ruby_client"

# Inizializza la configurazione
# Load the configuration from the specified JSON file and environment key.
config = PDND::ConfigLoader.load("configs/sample.json")
# Inizializza il TokenManager per caricare o salvare i token su file esterno
token_mgr = PDND::TokenManager.new
# Carica il file salvato
token, exp = token_mgr.load
# Verifica se il token è stato precedentemente salvato ed è valido
if token.nil? || !token_mgr.valid?(exp)
  # Se non è valido, genera un nuovo token
  jwt = PDND::JWTGenerator.new(config)
  token, exp = jwt.generate_token
  # Salva il nuovo token
  token_mgr.save(token, exp)
end
# Inizializza il client passando il token e la dada e ora di scadenza
client = PDND::Client.new(config)
client.token = token
client.token_exp = exp
# Imposta l'url dell'API
client.api_url="https://www.tuogateway.example.it/indirizzo/della/api"
# Imposta i paramentri per filtrare
#   I parametri possono essere:
#      - Stringa: "parametro1=1&parametro2=test&..."
#      - Array: ["parametro1=1", "parametro2=test", ...]
#      - Hash: {"parametro1" => 1, "parametro2" => "test", ... }
# sarà la funzione a verificare la tipologia e a convertire i filtri nel formato corretto.
# se il formato non fosse corretto, la funzione "get_api" restituisce errore.
client.filters="id=1234"
# Richiama la api
# @return code Number
# @return body Json
code, body = client.get_api

# Stampa il risultato
puts body

```

### Funzionalità aggiuntive

**Disabilita verifica certificato SSL**

La funzione `client.verify_ssl = false` Disabilita verifica SSL per ambiente impostato (es. collaudo).
Default: true

**Salva il token**

La funzione `token_mgr.save(token, exp)` consente a PDND::TokenManager di memorizzare il token e la scadenza e non doverlo richiedere a ogni chiamata.

**Carica il token salvato**

La funzione `token_mgr.load()` consente a PDND::TokenManager di richiamare il token precedentemente salvato.

**Valida il token salvato**

La funzione `token_mgr.valid?` PDND::TokenManager verifica la validità del token salvato.

**Imposta nome al token file**

La funzione `token_mgr.path("tmp/tuofile.json")` PDND::TokenManager imposta un nome personalizzato al file.

## Utilizzo da CLI

Esegui il client dalla cartella principale:

```ruby
ruby bin/pdnd_client.rb --api-url "https://api.pdnd.example.it/resource" --config /configs/sample.json
```

### Opzioni disponibili

- `--env` : Specifica l'ambiente da usare (es. collaudo, produzione). Default: `produzione`
- `--config` : Specifica il percorso completo del file di configurazione (es: `--config /configs/sample.json`)
- `--debug` : Abilita output dettagliato
- `--api-url` : URL dell’API da chiamare dopo la generazione del token
- `--api-url-filters` : Filtri da applicare all'API (es. ?parametro=valore)
- `--status-url` : URL dell’API di status per verificare la validità del token
- `--json`: Stampa le risposte delle API in formato JSON
- `--save`: Salva il token per evitare di richiederlo a ogni chiamata
- `--no-verify-ssl`: Disabilita la verifica SSL (utile per ambienti di collaudo)
- `--help`: Mostra questa schermata di aiuto

### Esempi

**Chiamata API generica:**
```bash
ruby bin/pdnd_client.rb --api-url="https://api.pdnd.example.it/resource" --config /configs/sample.json
```

**Verifica validità token:**
```bash
ruby bin/pdnd_client.rb --status-url="https://api.pdnd.example.it/status" --config /configs/sample.json
```

**Debug attivo:**
```bash
ruby bin/pdnd_client.rb --debug --api-url="https://api.pdnd.example.it/resource"
```

### Opzione di aiuto

Se esegui il comando con `--help` oppure senza parametri, viene mostrata una descrizione delle opzioni disponibili e alcuni esempi di utilizzo:

```bash
ruby bin/pdnd_client.rb --help
```

**Output di esempio:**
```
Utilizzo:
  ruby bin/pdnd_client.rb -c /percorso/config.json [opzioni]

Opzioni:
  --env             Specifica l'ambiente da usare (es. collaudo, produzione)
                    Default: produzione
  --config          Specifica il percorso completo del file di configurazione
  --debug           Abilita output dettagliato
  --api-url         URL dell’API da chiamare dopo la generazione del token
  --api-url-filters Filtri da applicare all'API (es. ?parametro=valore)
  --status-url      URL dell’API di status per verificare la validità del token
  --json            Stampa le risposte delle API in formato JSON
  --save            Salva il token per evitare di richiederlo a ogni chiamata
  --no-verify-ssl   Disabilita la verifica SSL (utile per ambienti di collaudo)
  --help            Mostra questa schermata di aiuto

Esempi:
  ruby bin/pdnd_client.rb --api-url="https://api.pdnd.example.it/resource" --config /percorso/config.json
  ruby bin/pdnd_client.rb --status-url="https://api.pdnd.example.it/status" --config /percorso/config.json
  ruby bin/pdnd_client.rb --debug --api-url="https://api.pdnd.example.it/resource"
```

## Variabili di ambiente supportate

Se un parametro non è presente nel file di configurazione, puoi definirlo come variabile di ambiente:

- `PDND_KID`
- `PDND_ISSUER`
- `PDND_CLIENT_ID`
- `PDND_PURPOSE_ID`
- `PDND_PRIVKEY_PATH`

## Note

- Il token viene salvato in un file temporaneo e riutilizzato finché è valido.
- Gli errori specifici vengono gestiti tramite la classe `PdndException`.

## Esempio di configurazione minima

```json
{
  "produzione": {
    "kid": "kid",
    "issuer": "issuer",
    "clientId": "clientId",
    "purposeId": "purposeId",
    "privKeyPath": "/tmp/key.pem"
  }
}
```
## Esempio di configurazione per collaudo e prosuzione

```json
{
  "collaudo": {
    "kid": "kid",
    "issuer": "issuer",
    "clientId": "clientId",
    "purposeId": "purposeId",
    "privKeyPath": "/tmp/key.pem"
  },
  "produzione": {
    "kid": "kid",
    "issuer": "issuer",
    "clientId": "clientId",
    "purposeId": "purposeId",
    "privKeyPath": "/tmp/key.pem"
  }
}
```
---

## Contribuire

Le pull request sono benvenute! Per problemi o suggerimenti, apri una issue.
