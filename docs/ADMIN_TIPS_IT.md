# Suggerimenti per amministratori e curatori

*English version: [ADMIN_TIPS.md](ADMIN_TIPS.md).*

Cose che l'applicazione fa da sola, limiti che possono sorprendere e il modo corretto di svolgere alcune operazioni abituali. Queste note valgono per l'attuale `develop` e vengono aggiornate nella stessa PR di ogni modifica che le riguarda.

## Accesso e password

- **Le vecchie password vengono aggiornate in modo silenzioso.** Gli account importati dal vecchio sito possono avere ancora un hash MD5. Questi utenti accedono con la loro solita password, e a quel login l'hash viene sostituito con uno moderno. Nessuno deve reimpostare la password. Un hash MD5 resta nel database finché il suo proprietario non accede di nuovo, quindi gli account inattivi lo mantengono.
- **Blocco dopo password errate.** Dopo 5 accessi falliti per lo stesso nome utente dallo stesso indirizzo IP in 15 minuti, l'accesso viene rifiutato, anche con la password giusta, finché non sono passati i 15 minuti. Un accesso riuscito azzera il conteggio, e ogni blocco viene scritto una volta nel log di sistema. Per sbloccare subito un utente, cancella i file in `misc/_login_attempts/`. "Svuota cache" non azzera i contatori. I limiti sono `$_FN['login_max_attempts']` e `$_FN['login_lockout_minutes']`.
- **Dietro un reverse proxy (Caddy, nginx), imposta `trusted_proxies`.** Se non è impostato, tutti i visitatori risultano con l'indirizzo IP del proxy. Cinque password errate da chiunque bloccano allora quel nome utente per tutti, amministratore compreso.
- **Dopo l'aggiornamento di sicurezza tutti vengono disconnessi una volta**, perché i cookie di sessione ora sono firmati con `misc/secret.key.php`. Includi quel file nei backup. Se va perso, tutti vengono disconnessi di nuovo.
- **I link di recupero password** funzionano una sola volta e scadono dopo 60 minuti. I link inviati prima dell'aggiornamento non funzionano più.
- **Un utente disattivato** viene disconnesso al clic successivo, non solo al login successivo.
- **I nomi utente vengono salvati in minuscolo.** "Ricordami" dura 30 giorni.

## Gruppi e permessi

- **L'accesso alle sezioni** (chi vede o modifica una sezione) dipende dalle impostazioni delle sezioni salvate nel database (`fn_sections`). Aggiornare il codice non lo cambia.
- **Visibilità dei record.** Un record riservato a un gruppo (per esempio le grotte nascoste) è visibile solo ai membri di quel gruppo e agli amministratori. Rinominare o eliminare un gruppo nasconde quei record ai suoi ex membri, senza alcun avviso.
- **Mappa pubblica.** Chi non può aprire una sezione riservata vede sulla mappa pubblica solo le grotte con **Visibile sulla mappa pubblica** = Si. Le grotte nuove ed esistenti partono da No, quindi sono i curatori a decidere quali grotte sono pubbliche. Le restrizioni per gruppo (`groupview`) valgono comunque.
- **Gli amministratori** (livello 10) superano i controlli sui gruppi, compreso quello sulle chiavi API qui sotto.

## Server MCP e chiavi API

- **Chi può usare una chiave API:** solo gli amministratori e i membri di `mcp_users` (o dei gruppi in `OPENKIS_APIKEY_GROUPS` nel `.env`). Le chiavi degli altri utenti vengono rifiutate, e la loro chiave non compare nel profilo.
- **Sola lettura per impostazione predefinita.** Le chiavi dei non amministratori sono in sola lettura. Gli strumenti di scrittura (inserimento, modifica, caricamento, cancellazione) richiedono l'appartenenza a `mcp_write`, o al gruppo in `OPENKIS_MCP_WRITE_GROUP`.
- Gli amministratori abilitano gli utenti in **Configurazione > Server MCP**. Quella pagina crea i gruppi `mcp_users` e `mcp_write` se mancano.
- **La chiave condivisa legacy** (`OPENKIS_MCP_APIKEY`) dà accesso completo come l'utente indicato in `OPENKIS_MCP_USER`. Lasciala vuota se non serve.

## Mappe e cache

- **Le esportazioni delle mappe sono in cache** (KML, GPX, JSON, marker). La cache viene eliminata automaticamente quando un record viene salvato da OpenKIS, e comunque dopo un'ora al massimo.
- **Dopo modifiche fatte direttamente nel database** (un import SQL o un `UPDATE` a mano), esegui **Pannello di controllo > Utilità > Aggiorna dati mappa**, oppure `php refresh-cache.php` nel container. Così le mappe si aggiornano, le coordinate vengono ricalcolate e i contatori degli id dei record vengono riallineati. Senza questo passaggio le mappe possono mostrare dati vecchi, e un nuovo record può ricevere un id già usato.
- **La struttura delle tabelle resta in cache fino a 10 minuti.** Dopo aver aggiunto o modificato una colonna a mano, usa "Svuota cache" o riavvia il container web, perché la modifica sia vista subito.

## Modifiche allo schema del database

- **Le colonne mancanti vengono aggiunte automaticamente.** Quando la definizione di una tabella riceve un nuovo campo, OpenKIS aggiunge la colonna alla prima pagina che apre quella tabella. Sulle tabelle grandi quella pagina sarà lenta una volta. Per gli import grandi, esegui prima l'SQL di migrazione, prima che il container web parta.
