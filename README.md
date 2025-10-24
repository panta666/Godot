# Godot Projekt

## Installation

Besuche die [Godot Webseite](https://godotengine.org/download/) und lade die richtige Version herunter. Achte dabei auf Betriebssystem und ob es mit .Net oder ohne sein soll. In unserem Fall nimm die Godot Version ohne .Net.

Installiere Godot Engine und öffne es.

### Git good
github.com/godotengine/godot-git-plugin/wiki/Git-plugin-v3

### Export
Mit Github Actions kann entweder manuell oder automatisch beim pullen ein build erstellt werden.
In unserem Fall werden wir erstmal manuell das build erstellen. Es kann zwischen Windows, Linux der beidem gewählt 
werden.

Es wird als erstes eine Ordnerstrukr erstellt:
- .github/workflows
- export/Linux
- export/Windows

In die Ordner Linux und Windows erstellen wir eine leere Datei namens .gitkeep damit die Ordner auch leer hochgeladen 
werden können.

Im Ordner .github/workflows erstellen wir nun zwei Dateien:
- build_debug.yml
- build_release.yml

Die beiden .yml Dateien sagen github welche Actions vorhanden sind und wie gebuat wird.

## Ideenphase
Wir haben uns Gedanken gemacht welche Elemente in unser Spiel einfließen können: [Dokument](https://docs.google.com/document/d/1tbJDoIl8Td4ONdNFHV6nYKuIKZrESmLNq2ERpz86UJI/edit?tab=t.0#heading=h.uuaadedxe2fx)
Konzept: Hubworld mit HSD Design. Einzelene Räume freischalten. Level als 2D Sidescroller/Platformer ala Deadcells wenn Player im jeweiligen Raum einschläft.

## Contibutors
Aktuell haben sich folgende Spezifizierungen ergeben. Diese können sich im Laufe des Projekts noch ändern.
- Jonas: Character & Level Design
- David: Development - Player Movement (Upgrades)
- Dennis Hubworld Design
- Sebastian W.: Enemy Design + Programmierung
- Sebastian R.: Programmierung, Background musik, SFX Regler, options menu, persistierung, git gud


