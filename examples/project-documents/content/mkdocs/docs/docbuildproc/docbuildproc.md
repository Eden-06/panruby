# Create Documents with Toolchain

> In most Projects you need to deploy different documents in different formats. Often, the content overlaps, so you end up with the same content in two places. That's difficult to maintain, since you often have to keep both areas consistent. So it would be easier to have a single source of truth.
> Another problem is that artifacts are created using different tools in different locations. For example, you might use a web-based LaTeX editor to collaborate on a requirements specification. At the same time, you want to create documentation. This documentation should be provided as a PDF upon handoff. But there should also be a wiki containing this documentation. Finally, a project report must be submitted, to which all artifacts are attached in addition to the report itself. This can quickly become confusing. On top of that, maintaining consistency during team collaboration becomes complicated - based on a true story.
> We build this toolchain with panruby, pandoc, mkdocs and latex to present a approach to manage our information in projects and their different outputs and output formats.

## Construction

>
![toolchain overview](./../images/panruby-graph.svg){#toolchainarchitecture width=100%}

[Figure](#toolchainarchitecture) shows the structure of different parts of the build-process and how they called. All calls are initiated by MKDocs and Make([Mkdocs](#mkdocsfunctions){#mkdocsfunctions} und [Makefunctions](#makefunctions){#makefunctions}).

## Requirements

Following installations are necessary

- Make: for Makefile
- Java JRE or JRE: to use plantuml.jar
- LaTeX: for LaTeX targets
- Graphviz: for some PlantUML diagrams and  Graphviz diagrams
- Inkscape: to convert `*.svg` to `*.pdf`
- Ruby: to convert `*.md.erb` to Markdown
- Pandoc: to convert `*.md` to `*.tex`

For PlantUML download `plantuml.jar` and move it to `tools/`.

### Images

**PlantUML**

- textueller Grafikeditor zum erstellen von UML-Diagrammen und anderen Diagrammen der Modellierung
- genutzt für Diagramme der Anforderungsanalyse, Modellierung und des Entwurfs

**Graphviz**

- textueller Grafikeditor zum erstellen von Diagrammen für
- eignet sich für das Darstellen von Automaten und Graphen

**Inkscape**

- für das erstellen von Bildern
- genutzt um Bilder von `*.svg` in `*.pdf` zu konvertieren

### Dokumente

**Panruby**  

- Ruby-Skript, welche mittels Template-Engine eine Befehlserweiterung des Markdown-Befehlssatzes ermöglicht
- genutzt um Markdown-Dateien in Markdown-Dateien einzubinden (ähnlich Latex: `\include{}`)
- genutzt zum erstellen und verwalten der Dateipfade für Resourcen (Bilder, andere Dokumente)

**Pandoc**

- Programm zum konvertieren zwischen diviersen Dokumentenformaten unter Zuhilfenahme benutzerdefinierter Regeln in Form von Extentions, Lua-Filtern und Variablen
- genutzt zum konvertieren von `*.md` zu `*.tex`

**LaTeX**

- textsatzprogramm zum Erstellen von PDF-Dokumenten aus TeX-Code (WYSIWYM)
- genutzt zum Erstellen der PDF-Dokumentation

## Mkdocs {#mkdocsfunctions}

> Für die Nutzung ist es notwendig im selben Verzeichnis wie die Datei `mkdocs.yml` zu sein

- `mkdocs serve` - startet den in Echtzeit nachladenden Server
    - *Befehl inkorrekthier werden Änderungen erst nach erneutem Ausführen des Befehls sichtbar*
    - der Befehl stammt aus der Dokumentaion von Mkdocs
* `mkdocs serve --livereload -w './docs'` - Mit diesem Befehl werden Änderungen in den Markdown-Dateien durch `Strg + S` automatisch in der Browser-Sitzung angezeigt
* `mkdocs build` - bauen der Dokumentations-Website
* `mkdocs -h` - Gibt Beschreibung und Optionen des Befehls `mkdocs` aus

**Project layout**

    mkdocs.yml    # The configuration file.
    docs/
        index.md  # The documentation homepage.
        ...       # Other markdown pages, images and other files.

## Makefile {#makefunctions}

> Eine toolchain zur automation des build-prozess von LaTeX-Dokumenten und Bildern.

### Lösung durch den Makfile

Der Makefile beschreibt Targets/Ziel, die für den Build-Prozess notwendig sind. Dabei werden immer nur jene Prozesse ausgeführt, welche für die Herstellung des Targets notwendig sind. Wurden beispielsweise nur einzelne Dateien angepasst, werden nur davon abhängige Prozesse ausgeführt und nicht alle. Es gibt auch Aufgaben zum sauberen Entfernen der (temporären) Dateien. Das Entfernen oder Aufräumen (clean) sorgt für effiziente Nutzung des Repositories.

## Aufruf
Nun kann man für das Erstellen der unterschiedlichen Dokumente und Bilder die einzelnen Tasks aufrufen. Hierfür eine Shell in dem Verzeichnis `tools/` öffnen. Dort kann man die Tasks mit

```
make ARG=<PH|DOC> <taskname>
```

aufrufen. So würde man die Task zum Erstellen der Bilder für das Pflichtenheft beispielsweise mit

```
make ARG=PH images
```
aufrufen.

## Argumente und Variablen über ARG

Der Aufruf des Makefile erfordert die Angabe des kürzels des Artefakts als Argument über `ARG`. Derzeit stehen Pflichtenheft (`PH`) und Dokumentation (`DOC`) zur Verfügung
Über die Angabe eines Wertes für `ARG` werden die bezüglich des Artefakts korrekten Dateipfade zum Quellverzeichnis der Template-Datei, Quelldatei und Grafiken gewählt. Durch die Angabe von `ARG`wird für jedes mögliche Target immer das gewünschte Ergebnis abhängig vom Artefakt erziehlt.

In dieser Version bedarf es **keiner Änderung der in der Make-Datei** angegebenen Pfade.

## Targets im Überblick

**`images`:**

- erstellt aus allen Bildern in `*.puml`-, `*.dot`-Format ein `*.png`, `*.svg` und `*.pdf` im Pfad `IMG_DIR`
- erstellt aus allen `*.svg` eine `*.pdf` im Pfad `IMG_DIR`

**`cleansoft`:**

Für PH, DOC: Es löscht temporäre Dateien des Latex-Build-Prozess und aus PlantUML erstellte PNG-Dateien.

**`clean4git`:**

Für PH, DOC: Es löscht alles mit `cleansoft` und aus SVGs erstellte Bild-PDFs und mit Latex erstellte PDF-Dokumente. Bild-PDFs, die nicht generiert wurden bleiben erhalten.

**`cleanall`:**

Für PH: Es löscht alles mit `clean4git` und mit Graphviz oder PlantUML erstellte Bild-SVGs. Bild-SVGs, die nicht generiert wurden bleiben erhalten.

Für DOC: Es löscht alles mit `clean4git` und die `*.tex`-Datei, welche mit Pandoc generiert wurde und mit Graphviz oder PlantUML erstellte Bild-SVGs. Bild-SVGs, die nicht generiert wurden bleiben erhalten. *Die Löschung der `*.tex`erfolgt rein nach der Endung. Sie wird nicht bezüglich ihres Ursprungs betrachtet (Vorsicht bei der Erstellung neuer Routinen für neue Artefakte!).

**`cimpng`:** löscht alle durch PlantUML erstellten PNG-Dateien

**`cimsvg`:** löscht alle durch PlantUML oder Graphviz erstellten PNG-Dateien

**`cimpdf`:** löscht alle durch Inkscape erstellten PDF-Bild-Dateien

**`ctemp`:** löscht alle temporären Dateien, des Latex-Buildprozess

**`cpdfd`:** löscht das durch Latex erstellte PDF-Dokument 

**`ctex`:** löscht die durch `panruby.rb` (Pandoc) erstellte `*.tex`-Datei.

**`latex`:** aufruf des Latex-Compilers zum erstellen des PDF-Dokuments aus der `*.tex`-Datei

**`pandoc`:** aufruf von `panruby.rb` zur Anwendung des Panruby-Skriptes auf die `*.md.erb`-Datei und Anwendung von Pandoc auf das erstellte Zwischenergebnis (Aufruf von Pandoc geschieht intern im Skript)

**`all`:** 

Für PH: erarbeitet die Targets `images` und `latex` in dieser Reihenfolge

Für DOC: erarbeitet die Targets `images`, `pandoc` und `latex` in dieser Reihenfolge

- entfernt alle `.*svg`, `*.png` und behält `*.puml`, `*.dot`, `*.pdf` im Pfad `IMG_DIR`

## Markdown Eigenheiten: Pandoc

### Bilder und Referenzen

Bilder werden in Markdown generell als

```markdown
![Bildbezeichnung](./relativerPfadzum/Bild.svg)
```

eingebunden. Jedoch besitzt diese Angabe keine Skalierung, die wir für die konveriterung in PDF über Latex als Information mitgeben müssen. Ebenso fehlt ein Label für die Referenz auf das Bild. Daher kann man in Pandoc folgendes hinzufügen

```markdown
![Bildbezeichnung](./relativerPfadzum/Bild.svg){#einspeziellesTestbild width=50%}
```
Hierbei ist `einspeziellesTestbild` das Label. Auf diese kann man wie folgt referenzieren:

```markdown
[Grafik](#einspezielleTestbild) für Referenzen in der selben Markdown-Datei
[Grafik](./datei.md#einspezielleTestbild) für Referenzen in einer Markdown-Datei im selben Verzeichnis
[Grafik](./relativerPfad/datei.md#einspezielleTestbild) für Referenzen in einer Markdown-Datei in anderen Verzeichnis
```

Mit `{width=50%}` wird die Breite des Bildes auf die hälfte skaliert.

Mit dem Hinzufügen von Attributen in geschweiften Klammern verschwindet bei der Ausgabe in Latex die Bildunterschrift. Um diese zu behalten setzt man ein `>` in die vorhergehende Zeile.

```markdown
>
![Bildbezeichnung](./relativerPfadzum/Bild.svg){#einspeziellesTestbild width=50%}
```

Oberhalb und Unterhalb des Blocks muss eine Lehrzeile stehen.

### Überschriften und Referenzen

Man kann Querverweise auf Überschriften nutzen. Dafür muss die Überschrift mit einem Label versehen werden.

```Markdown
# Beispiel Überschrift {#labelderueberschrift}
```

Auf diese Überschrift kann dann referenziert werden mit

```Markdown
[Kapitel](#labelderueberschrift) für Referenzen in der selben Markdown-Datei
[Kapitel](./datei.md#labelderueberschrift) für Referenzen in einer Markdown-Datei im selben Verzeichnis
[Kapitel](./relativerPfad/datei.md#labelderueberschrift) für Referenzen in einer Markdown-Datei in anderen Verzeichnis
```

### Markdown-ERB

Konvention zur Pfadnavigation

Mittels Panruby kann man in einer `*.md.erb`-Datei Ruby als Template-Engine nutzen. Die `*.md.erb`-Datei wird nach Interpretation des Ruby-Codes in eine Markdown-Datei umgewandelt und in Latex übersetzt.

Dabei gibt es zwei wichtige Arten von gekennzeichneten Bereichen

```ruby
<% Ruby code  %>
<%= Ruby expression %>
```

Bei der Verwendung von `<% code %>` wird dieser Teil anschließend durch eine leere Zeichenkette ersetzt. Dies eignet sich zum Beispiel für If-Abfragen im Template, welche für die Logik des Templates nötig sind, aber nicht in der Ausgabe enthalten sein sollen.

Bei der Verwendung von `<%= code >` wird dieser Teil mit dem Ergebnis des Ausdrucks `code` ersetzt. Dies ist für die Generierung von Inhalten mittels der Templatesprache gedacht.

Der hier relevante Befehl ist

```ruby
 load ("./relativerPfad/vondieserERBdatei/zudieser/DateiB.md")
```

Mit diesem Befehl können wir eine weitere Markdown-Datei in die `*.md.erb` einfügen. Hierbei ist jedoch wichtig: 

**Als Pfad muss jeweils der relative Pfad angegeben werden, welcher von der `*.md.erb`-Datei, in welcher der `load`-Befehl steht, zu der Datei, welche per `load`-Befehl integriert werden soll, navigiert.**

Oder kurz: Es muss immer der relative Pfad von der aufrufenden Datei zur aufgerufenen Datei angegeben werden.

## Markdown Eigenheiten: Mkdocs

**Listen:** Für das Einrücken von Listen müssen pro Stufe vier Leerzeichen zum Einrücken verwendet werden.
