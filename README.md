# IT-driftsmiljø
## Beskrivelse
Repo for all koden som blir produsert under bacheloroppgaven vår


## Førstegangsoppsett

### Steg 1: Klon repo
Klon repoet til din lokale maskin.

### Steg 2: Last ned Terraform
Om du allerede har Terraform innstallert på maskinen, kan du hoppe over dette steget. Her er en full [guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) til å innstallere terraform.




## Legge inn ny studentoppgave
### Steg 1: Laste ned og sjekke filer
Last ned git repo eller finn mappen som har blitt levert av studentene. Sjekk at mappen har denne strukturen og inneholder en config.yml fil og en Dockerfile.
```plaintext
<studentoppgavenavn>/
├── README.md      # Dokumentasjon og installasjonsinstrukser
├── src/           # Kildekode
├── testing/       # Tester
├── database/      # Databasefiler
├── dokumentasjon/ # Dokumentasjon (API, databasdesign, etc.)
├── vedlegg/       # Eventuelle eksterne ressurser/dokumenter
├── config.yml     # Konfigurasjons instillinger
└── Dockerfile     # Fil for bygging av Docker-image
```

### Steg 2: Laste opp filer til github
For å legge inn en ny studentoppgave i driftsmiljøet må man laste opp alle filene applikasjonen trenger uten noen .git filer i egen mappe med navn på oppgaven under [studentOppgaver](/studentOppgaver).
<br> 
Commit meldingen **MÅ** se slik ut:
```bash
ny studentoppgave <studentoppgavenavn>
```
Studentoppgavenavn må være skrevet helt likt som mappen som applikasjonen er i.

Dette er for å starte den første workflowen Docker-build. 




## License

[MIT](https://choosealicense.com/licenses/mit/)
