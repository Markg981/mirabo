# Mirabò

Storie e piccoli passi per crescere. App gratuita per tablet (iOS 15+, Android 8+) per bambini dai 3 ai 10 anni: storie su temi importanti, attività di avvicinamento alla scuola, un compagno che cresce con il bambino. Tutto funziona offline; il cloud è una scelta del genitore.

Codice e contenuti sono proprietari: vedi `LICENSE`.

## Struttura

```
app/       Flutter app (iOS + Android)
content/   Storie, compagni e schema dei pacchetti (sorgente editoriale)
studio/    Script dello studio editoriale: validazione, impacchettamento, firma
docs/      Specifica, formato delle storie, guida di stile
```

## Primi passi su Windows

1. Installa Flutter nella versione esatta indicata in `app/pubspec.yaml` (campo `flutter:` sotto `environment`, la stessa che usa la CI) seguendo <https://docs.flutter.dev/get-started/install/windows>, più Android Studio e un emulatore tablet (es. Pixel Tablet API 34) oppure un tablet Android con il debug USB. Serve anche Python: versione di riferimento e minima 3.12 (`.python-version`, la usa la CI); la CI prova anche 3.14.
2. Le cartelle `app/android/` e `app/ios/` sono già nel repository: non eseguire `flutter create .`.
3. Prepara i contenuti. `app/assets/` è ignorata da git e `pubspec.yaml` ne dichiara le cartelle, quindi senza questo passo l'app parte senza storie (o la build fallisce). Dalla radice del repository:

   ```
   pip install -r studio/requirements.txt
   python studio/keygen.py                        # una volta sola: coppia di chiavi di firma
   python studio/sync_assets.py --include-drafts  # sviluppo: anche le storie non ancora revisionate
   ```

   Senza `--include-drafts` vengono copiate solo le storie pubblicate. Rilanciare il comando quando cambia `content/`.
4. Dipendenze e avvio:

   ```
   cd app
   flutter pub get
   flutter run
   ```

La build iOS richiede macOS: la fa la CI (`.github/workflows/ci.yml`) su un runner macOS.

## Contenuti

Ogni storia è una cartella in `content/stories/<id>/` con un `story.json` (metadati) e un file per fascia d'età (`3-5.json`, `6-7.json`, `8-10.json`). Il formato è in `docs/story-format.md` e lo schema in `content/schema/`.

```
python studio/validate.py            # controlla tutti i pacchetti
python studio/keygen.py              # una volta sola: genera la coppia di chiavi (privata fuori dal repo!)
python studio/pack.py --sign         # produce i pacchetti firmati in dist/ (solo storie e attività published)
python studio/catalog.py             # inventario, catalogo di lancio e cosa manca a ogni posto
python studio/pack.py --release --sign   # solo il catalogo di lancio, tutto approvato sulla versione esatta
```

`pack.py` impacchetta solo storie e attività con `status: published` e un'approvazione valida nel registro (vedi `docs/pedagogical-review.md` e `docs/launch-catalog.md`). Per provare in sviluppo i contenuti non ancora revisionati: `--include-drafts` (anche su `sync_assets.py`).

L'app accetta solo pacchetti firmati con la chiave pubblica inclusa in `app/lib/content/trusted_key.dart`.
