# IT-driftsmiljø
## Beskrivelse
Repo for all koden som blir produsert under bacheloroppgaven vår

## Krav
- Azure abonnement
- Github bruker


## Førstegangsoppsett

### Steg x: Lag service principle i Azure
Dette steget oppretter en identitet i Azure som brukes til autentisering når du bygger infrastruktur med terraform.

1. Opprett service principle. Denne kommandoen kjøres i Azure cli som du finner i Azure portalen.
```
az ad sp create-for-rbac --Scopes /subscriptions/<subscriptionId> --role contributor
```
Ta vare på objektet som kommer i retur, da du ikke får hentet dette ut igjen.

2. Tildel rollen "Storage blob data contributor"
```
az role assignment create \
  --assignee <appId> \
  --role "Storage Blob Contributor" \
  --scope "/subscriptions/<subscriptionId>/resourceGroups/<rg-variablestorage>/providers/Microsoft.Storage/storageAccounts/<envstoragegjovik246>"
```

### Steg x: Logg inn med service principle
Hvis du allerede har installert Azure CLIet kan du hoppe over første punkt nr. 1.
1. [Installer](https://learn.microsoft.com/nb-no/cli/azure/install-azure-cli) Azure CLI
2. Logg inn med service principle:
   ```
   az login --service-principal --username <appId> --password <password> --tenant <tenant>
   ```
3. Sett miljøvariabler:
   
   For Powershell:
   ```
   $env:ARM_CLIENT_ID="appId"
   $env:ARM_CLIENT_SECRET="password"
   $env:ARM_TENANT_ID = "tenant"
   $env:ARM_SUBSCRIPTION_ID = "subscriptionId"
   ```

   For linux:
   ```
   ```

### Steg x: Sett opp repo

1. Klon repoet til din lokale maskin.
2. Set secrets i github repo

### Steg x: Last ned Terraform
Om du allerede har Terraform installert på maskinen, kan du hoppe over dette steget. Her er en full [guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) til å innstallere terraform.

### Steg x: Apply backend konfigurasjon
Disse stegene kan gjøres både i en linux terminal og Powershell.

1. Naviger til /terraform/backend mappen. 
2. Sette inn subscription ID i 
3. Initialiser terraform:
   ```bash
   terraform init
   ```
4. Lag plan filen
   ```bash
   terraform plan -out="main.tfplan"
   ```
5. Bygg konfigurasjon
   ```bash
   terraform apply "main.tfplan
   ```
### Steg 4: Apply infrastruktur


## Legge inn ny studentoppgave
### Steg 1: Laste ned og sjekke filer
Last ned git repo eller finn mappen som har blitt levert av studentene. Sjekk at mappen har en Dockerfil og en databasemappe i root. Databasemappen kan være tom, men den skal bare være der for å vise at studentoppgaven inneholder en database.
```plaintext
<studentoppgavenavn>/
├── README.md      # Dokumentasjon og installasjonsinstrukser
├── database/      # Databasefiler
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
