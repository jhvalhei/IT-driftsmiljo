# IT-driftsmiljø
## Beskrivelse
Repo for all koden som blir produsert under bacheloroppgaven vår. Inneholder Terraform konfigurasjon til et IT-driftsmiljø og workflows for utrulling/fjerning av studentoppgaver.

## Forhåndskrav
- Azure abonnement
- Github bruker

## Krav til studentoppgaver
For at en studenoppgave skal kunne utrulles i driftsmiljøet må følgende krav være oppfyllt:

- Må være "Dockerized"
- Må inneholde en Dockerfile
- Dersom studentoppgaven trenger lagring, må dette være implementert med PostgreSQL
- Passord til databasen må hentes fra miljøvariablen "DBSECRET"

## Førstegangsoppsett
De følgende stegene utføres kun første gang driftsmiljøet skal tas i bruk.
### Steg 1: Lag service principle i Azure
Dette steget oppretter en identitet i Azure som brukes til autentisering når du bygger infrastruktur med terraform.



1. Opprett service principle. Denne kommandoen kjøres i Azure cli som du finner i Azure portalen, til høyre for søkebaren.
```
az ad sp create-for-rbac --scopes /subscriptions/<SUBSCRIPTION_ID> --role contributor
```
Ta vare på objektet som returneres, da du ikke får hentet dette ut igjen.

2. Tildel roller: 
   
- "Key Vault Administrator":
```
az role assignment create \
  --assignee <APPID> \
  --role "Key Vault Administrator" \
  --scope /subscriptions/<SUBSCRIPTION_ID>
```

- "Key Vault Data Access Administrator"
```
az role assignment create \
  --assignee <APPID> \
  --role "Key Vault Data Access Administrator" \
  --scope /subscriptions/<SUBSCRIPTION_ID>

```
- Storage Blob Data Contributor
```
az role assignment create \
  --assignee <APPID> \
  --role "Storage Blob Data Contributor" \
  --scope "/subscriptions/<SUBSCRIPTION_ID>
```




### Steg 2: Sett opp repo

1. Fork repoet https://github.com/Bachelorgruppe117-NTNU-Gjovik/IT-driftsmiljo

2. Opprett token til Github Container Registry
- opprett classic tokeen
- gi følgende rettigheter:
  - repo
  - write:packages
  - delete:packages

3. Opprett secrets i Github repo

Workflowsene i løsningen er avhengig av at visse verdier lagres som secrets. Disse kan opprettes i Github grensesnittet, under "settings" i repoet. Merk at verdien til secretsene som begynner med ARM hentes fra service principle objektet fra steg 1.  Opprett følgende secrets med tilhørende verdier:

- ARM_CLIENT_ID      //kalles "client_id" i service principle objektet.
- ARM_CLIENT_SECRET     //kalles "password" i service principle objektet
- ARM_SUBSCRIPTION_ID
- ARM_TENANT_ID
- REG_TOKEN       //token til Github Container Registry
- REG_UNAME       //Github brukernavn
- ALLOWED_IP_RANGE   //offentlig IP-adresse i CIDR format

Merk at ALLOWED_IP_RANGE brukes til studentoppgaver som skal konfigureres med begrenset nettverkstilgang. Slike studentoppgaver vil kun være tilgjengelige fra hoster innenfor nettverket som ligger i ALLOWED_IP_RANGE.

4. Tillat Github Actions -
gjøres i Github grensesnittet under "Actions" i repoet.

5. Tilpass workflows -
workflowsene remove.yml og docker-build.yml bruker linken til github repoet. Siden linken inneholder brukernavnet til eieren av repoet, må riktig brukernavn settes inn. I remove.yml settes brukernavn inn i steget "Delete package via API" og "startWF". I docker-build.yml settes riktig brukernavn inn i steget "startWf".




### Steg 3: Logg inn med service principle
Utfør dette steget i Hvis du allerede har installert Azure CLIet kan du hoppe over punkt nr. 1.

1. [Installer](https://learn.microsoft.com/nb-no/cli/azure/install-azure-cli) Azure CLI
2. Logg inn med service principle i terminal:
   ```
   az login --service-principal --username <APPID> --password <PASSWORD> --tenant <TENANTID>
   ```
3. Klon repo

### Steg 4: Klargjør terraform.tfvars.json

1. Plasser terraform.tfvars.json i /IT-driftsmiljo/terraform/infrastruktur

2. For at varsling skal fungere, må det settes inn en e-post adresse og et telefonnummer som skal motta varslene. Sett inn verdier for følgende variabler i terraform.tfvars.json:
   - "alert_name"
   - "email_address"
   - "sms_number"

Merk at du ikke trenger å skrive landskode på mobilnummeret. Landskoden er allerede satt til +47.


### Steg 5: Last ned Terraform
Om du allerede har Terraform installert på maskinen, kan du hoppe over dette steget. Her er en full [guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) til å installere terraform.





### Steg 6: Apply backend
Disse stegene gjøres i terminalen.

1. Naviger til /terraform/backend.
2. Gå til main.tf og sett inn subscription ID i "provider "azurerm"" blokken.
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

### Steg 7: Sett variabler:
   
   Sett følgende miljøvariabler i terminalen. Merk at variablene som begynner med "ARM_" hentes fra service principle objektet i steg 1.
   
   ```
   ARM_CLIENT_ID
   ARM_CLIENT_SECRET
   ARM_TENANT_ID 
   ARM_SUBSCRIPTION_ID

   TF_VAR_reguname   //brukernavn til Github Container Registry
   TF_VAR_regtoken   //token til Github Container Registry
   TF_VAR_rootPath   //full path til mappen IT-dritfsmiljø (bruk '/' til å skille mellom mappene, f.eks. "C:/Users/user1/IT-driftsmiljo")
   ```

### Steg 8: Apply infrastruktur

1. Åpne /terraform/infrastruktur/main.tf.
2. I blokken "backend "azurerm"", sett "storage_account_name" til navnet på backend storage accounten. Dette navnet finner du i azure under resource groups -> rg-backend.
3. Naviger til /terraform/infrastruktur.
4. Repeter punkt nr. 3, 4 og 5 fra steg 6.

## Utrulling av ny studentoppgave
De følgende stegene utføres for å utrulle en studentoppgave til driftsmiljøet.
### Steg 1: Laste ned og sjekke filer
Last ned git repo eller finn mappen som har blitt levert av studentene. Sjekk at mappen har en Dockerfil og en databasemappe i root dersom studentoppgaven trenger en database. Databasemappen kan være tom, men den skal bare være der for å vise at studentoppgaven inneholder en database. Legg studentoppgave inn i /studentOppgaver/ mappen. Husk å slette eventuelle git filer i studentoppgavemappen, f.eks. .git.
```plaintext
<studentoppgavenavn>/
├── README.md            # Dokumentasjon og installasjonsinstrukser
├── database/            # Databasefiler
│   ├── *DDL*.txt        # Database skjema (CREATE, ALTER, osv.)
│   └── *DML*.txt        # Database data (INSERT, UPDATE, osv.)
├── Dockerfile           # Fil for bygging av Docker image
└── ...                  # Andre filer for studentoppgaven
```
Studentoppgaver som trenger databasetilgang må 

### Steg 2: Laste opp filer til github
For å legge inn en ny studentoppgave i driftsmiljøet benyttes Github workflows. Etter at studentoppgaven er plassert i /studentOppgaver/, kjøres /terraform/infrastruktur/scripts/newApp.py. Dette scriptet pusher den nye studentoppgaven til remote repoet og aktiverer workflowsene docker-build.yml og buildTerraform.yml.
<br> 
```bash
python newApp.py <studentoppgavenavn> -a <public/private>
```
Studentoppgavenavn er mappenavnet til studentoppgaven. 

Dette aktiverer først workflowen Docker-build.yml. Den lager et nytt Docker image og lagrer det i Githubs container register tilknyttet brukeren repoet tilhører. Deretter aktiveres buildTerraform.yml som legger til nye verdier i Terraform og applyer den nye konfigurasjonen.

For å se utførelse av workflows, gå til Actions fanen på repoets Github side.

### Steg 3: Initiere database
Dette seteget utføres kun hvis studentoppgaven trenger tilgang til en database.

1. Legg DDL og DML filer inn i databasemappen til den aktuelle studentoppgaven:
```plaintext
<studentoppgavenavn>/
├── database/
│   ├── *DDL*.txt
│   └── *DML*.txt
```
2. Naviger til /terraform/infrastruktur/scripts. Kjør scriptet "jmphost.py". Merk at "APPID" og "PASSWORD" tilhører service principle som ble opprettet tidligere. Pass på at filene deleteJmpHost.py, executeSqlConfig.sh og installRequirments.sh
```bash
python jmphost.py <studentoppgavenavn> <database-adminbrukernavn> <APPID> <PASSWORD> <TENANTID> init
```

1. Restart container appen. Dette kan gjøres i Azure portalen.

## Fjerne studentoppgave
Fjerning av studentoppgave fra dritfsmiljøet skjer via workflowsene remove.yml og buildTerraform.yml. For å aktivere disse må følgende kommandoer kjøres:

```
git commit --allow-empty -am "fjern studentoppgave <studentoppgavenavn>"
git push origin main
```
De aktiverte workflowsene vil fjerne studentoppgavens Docker image fra Github, redigere Terraform koden og kjøre en ny Terraform apply.



## License

[MIT](https://choosealicense.com/licenses/mit/)
