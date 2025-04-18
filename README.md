# IT-driftsmiljø
## Beskrivelse
Repo for all koden som blir produsert under bacheloroppgaven vår

## Krav
- Azure abonnement
- Github bruker


## Førstegangsoppsett

### Steg x: Lag service principle i Azure
Dette steget oppretter en identitet i Azure som brukes til autentisering når du bygger infrastruktur med terraform.

1. Opprett service principle. Denne kommandoen kjøres i Azure cli som du finner i Azure portalen, til høyre for søkebaren.
```
az ad sp create-for-rbac --Scopes /subscriptions/<SUBSCRIPTION_ID> --role contributor
```
Ta vare på objektet som kommer i retur, da du ikke får hentet dette ut igjen.

2. Tildel roller: 
   
   "Storage blob data contributor":
```
az role assignment create \
  --assignee <APPID> \
  --role "Storage Blob Contributor" \
  --scope "/subscriptions/<SUBSCRIPTION_ID>/resourceGroups/<rg-variablestorage>/providers/Microsoft.Storage/storageAccounts/<envstoragegjovik246>"
```

   "Key Vault Administrator":
```
az role assignment create \
  --assignee <appId> \
  --role "Key Vault Administrator" \
  --scope /subscriptions/<SUBSCRIPTION_ID>
```

   "Key Vaul Data Access Administrator" (sjekk om denne er nødvendig)
```
az role assignment create \
  --assignee <APPID> \
  --role "Key Vault Data Access Administrator" \
  --scope /subscriptions/<SUBSCRIPTION_ID>

```

### Steg x: Logg inn med service principle
Hvis du allerede har innstallert Azure CLIet kan du hoppe over punkt nr. 1.
1. [Installer](https://learn.microsoft.com/nb-no/cli/azure/install-azure-cli) Azure CLI
2. Logg inn med service principle:
   ```
   az login --service-principal --username <appId> --password <password> --tenant <tenant>
   ```
3. Sett miljøvariabler:
   
   Eksempel i Powershell:
   ```
   $env:ARM_CLIENT_ID="APPID"
   $env:ARM_CLIENT_SECRET="password"
   $env:ARM_TENANT_ID = "tenant"
   $env:ARM_SUBSCRIPTION_ID = "SUBSCRIPTIONID"
   ```


### Steg x: Sett opp repo

1. Klon repoet til lokal maskin.

```
git clone https://github.com/Bachelorgruppe117-NTNU-Gjovik/IT-driftsmiljo.git
```
2. Set secrets i github repo

### Steg x: Last ned Terraform
Om du allerede har Terraform innstallert på maskinen, kan du hoppe over dette steget. Her er en full [guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) til å innstallere terraform.

### Steg x: Apply backend konfigurasjon
Disse stegene kan gjøres både i en linux terminal og Powershell.

1. Naviger til /terraform/backend mappen. 
2. Sett inn subscription ID i "provider "azurerm"" blokken.
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

1. Åpne /terraform/infrastruktur/main.tf.
2. I blokken "backend "azurerm"", sett "storage_account_name" til navnet på backend storage accounten. Dette navnet finner du i azure under resource groups -> rg-backend.
3. Naviger til /terraform/infrastruktur.
4. Repeter punkt nr. 3, 4 og 5 fra forrige steg.

## Legge inn ny studentoppgave
### Steg 1: Laste ned og sjekke filer
Last ned git repo eller finn mappen som har blitt levert av studentene. Sjekk at mappen har en Dockerfil og en databasemappe i root dersom studentoppgaven trenger en database. Databasemappen kan være tom, men den skal bare være der for å vise at studentoppgaven inneholder en database. Legg studentoppgave inn i /studentOppgaver/ mappen. Husk å eventuelle git filer i studentoppgavemappen, f.eks. .git.
```plaintext
<studentoppgavenavn>/
├── README.md      # Dokumentasjon og installasjonsinstrukser
├── database/      # Databasefiler
└── Dockerfile     # Fil for bygging av Docker-image
```

### Steg 2: Laste opp filer til github
For å legge inn en ny studentoppgave i driftsmiljøet benyttes Github workflows. Etter at studentoppgaven er plassert i /studentOppgaver/, kjøres /terraform/infrastruktur/scripts/newApp.py. Dette scriptet pusher den nye studentoppgaven til remote repoet og aktiverer workflowsene.
<br> 
```bash
python newApp.py <studentoppgavenavn> -a <public/private>
```
Studentoppgavenavn er mappenavnet til studentoppgaven. 

Dette aktiverer først workflowen Docker-build.yml. Den lager et nytt Docker image og lagrer det i Githubs container register tilknyttet brukeren repoet tilhører. Deretter aktiveres buildTerraform.yml som legger til nye verdier i Terraform og applyer den nye konfigurasjonen.

For å se utførelse av workflows, gå til Actions fanen på repoets Github side.

## Fjerne studentoppgave
Fjerning av studentoppgave fra dritfsmiljøet skjer via workflowsene remove.yml og buildTerraform.yml. For å aktivere disse må repoet pushes til remote med commit meldingen:

```
fjern studentoppgave <studentoppgavenavn>
```
De aktiverte workflowsene vil fjerne studentoppgavens Docker image fra Github, redigere Terraform koden og kjøre en ny Terraform apply.



## License

[MIT](https://choosealicense.com/licenses/mit/)
