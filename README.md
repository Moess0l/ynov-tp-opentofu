# NimbusShop sur Azure avec OpenTofu

Site vitrine de NimbusShop hébergé sur Azure : deux VM nginx derrière un Load Balancer Standard,
une jumpbox pour l'administration, une alerte CPU et un Key Vault. Toute l'infrastructure est
décrite en OpenTofu : un `tofu apply` crée tout, un `tofu destroy` supprime tout.

Binôme Paco et Joud, groupe 3 (le numéro de groupe sert d'identifiant de binôme dans les noms).

## Architecture

```
Internet ── HTTP 80 ──> Load Balancer Standard (IP publique, sonde GET /sante)
                             │
                             ▼
              ┌───── VNet 10.3.0.0/16 ──────────────────────────┐
              │  snet-web 10.3.1.0/24 (NSG)                     │
              │     vm-web-1    vm-web-2   (sans IP publique)   │
              │          ▲ SSH                                  │
              │  snet-admin 10.3.2.0/24 (NSG)                   │
              │     jumpbox  <── SSH 22 depuis notre IP ────────┼── Internet
              └─────────────────────────────────────────────────┘

rg-tfstate-nimbus-3 : compte de stockage du state (bootstrap/)
```

| Fichier | Contenu |
|---------|---------|
| `versions.tf`, `providers.tf` | versions, backend azurerm, provider |
| `variables.tf`, `locals.tf` | entrées, noms, tags, plan d'adressage |
| `main.tf` | groupe de ressources |
| `network.tf` | VNet, subnets, NSG et associations |
| `web.tf`, `cloud-init/web.yaml` | VM web et leur configuration nginx |
| `lb.tf` | Load Balancer, sonde, règle HTTP, règle sortante |
| `jumpbox.tf` | jumpbox et son IP publique |
| `monitoring.tf` | groupe d'actions et alertes CPU |
| `keyvault.tf` | mot de passe aléatoire et Key Vault |
| `bootstrap/` | compte de stockage du state distant, state local |

## Prérequis

- OpenTofu 1.10 ou plus (testé en 1.13.9), Azure CLI.
- Un abonnement Azure for Students.
- Une clé SSH dédiée : `ssh-keygen -t ed25519 -f ~/.ssh/nimbus`.

```bash
az login --use-device-code
az account show --query id -o tsv   # ID d'abonnement pour les tfvars
curl -s https://ifconfig.me          # IP à autoriser en SSH, à suffixer de /32
```

## Déploiement

1. Compte de stockage du state (une seule fois) :

   ```bash
   cd bootstrap
   cp terraform.tfvars.example terraform.tfvars   # puis renseigner les valeurs
   tofu init
   tofu apply
   tofu output -raw backend_hcl > ../backend.hcl
   cd ..
   ```

2. Infrastructure :

   ```bash
   cp terraform.tfvars.example terraform.tfvars   # puis renseigner les valeurs
   tofu init -backend-config=backend.hcl
   tofu fmt -check -recursive
   tofu validate
   tofu apply
   ```

L'URL du site sort en output (`url_site`). Laisser une à deux minutes à cloud-init pour installer
nginx avant de tester.

## Vérifications

```bash
URL=$(tofu output -raw url_site)

# Le nom d'hôte alterne entre vm-web-1 et vm-web-2
for i in $(seq 1 10); do curl -s "$URL" | grep -o 'vm-web-[0-9]'; done

# Page de santé utilisée par la sonde
curl -s "$URL/sante"   # OK-nimbus

# SSH par la jumpbox
tofu output ssh_web
ssh -i ~/.ssh/nimbus -J azureuser@<ip_jumpbox> azureuser@<ip_privee_web>
```

Haute disponibilité : arrêter une VM web dans le portail. La sonde la sort du pool en une dizaine
de secondes et le site reste servi par l'autre.

Le mot de passe du Key Vault se lit avec le CLI, il n'est dans aucun output :

```bash
az keyvault secret show --vault-name "$(tofu output -raw key_vault_name)" --name app-admin-password --query value -o tsv
```

## Suppression

```bash
tofu destroy
cd bootstrap && tofu destroy
```

Dans cet ordre : le state de l'infrastructure vit dans le compte de stockage, on le supprime en
dernier.

## Choix techniques

- **Nommage** : `<type>-nimbus-<binome>`, avec un index pour les ressources multiples
  (`vm-web1-nimbus-3`). Le nom d'hôte des VM reste court (`vm-web-1`). Le compte de stockage
  et le Key Vault prennent un suffixe aléatoire : leur nom est unique dans tout Azure (et le compte
  de stockage n'accepte pas de tiret).
- **for_each plutôt que count** : les VM sont indexées par une clé (`"1"`, `"2"`). Retirer une VM ne
  renumérote pas les autres, alors qu'avec `count` OpenTofu détruirait et recréerait celles qui
  suivent.
- **NSG de snet-web** : les règles par défaut d'Azure laissent entrer tout le trafic interne au VNet.
  Une règle `deny-all-inbound` en priorité 4096 les court-circuite. La sonde du LB arrive de
  l'adresse `AzureLoadBalancer` (168.63.129.16), d'où sa règle dédiée.
- **Accès sortant** : `default_outbound_access_enabled = false` sur snet-web coupe l'accès sortant
  implicite d'Azure. La sortie passe par la règle sortante du LB, et la règle HTTP a
  `disable_outbound_snat = true` pour ne pas faire doublon.
- **Groupe à haute disponibilité** : les deux VM web sont dans un availability set (deux domaines de
  panne et de mise à jour), une maintenance Azure ne les arrête pas en même temps.
- **Sonde /sante** : servie directement par nginx (`return 200 "OK-nimbus"`), sans fichier sur
  disque.
- **Key Vault** : politique d'accès plutôt que RBAC, parce qu'une attribution de rôle met plusieurs
  minutes à se propager et fait échouer l'écriture du secret au premier apply. Le mot de passe est
  absent du code et des outputs, mais présent dans le state : c'est une raison de plus pour garder
  le state dans un compte de stockage privé et hors du dépôt.
  `purge_soft_delete_on_destroy` libère le nom du coffre au destroy, sinon il reste réservé 7 jours.
- **State distant** : le compte de stockage ne peut pas être créé par la configuration qui l'utilise
  comme backend. Il vit dans `bootstrap/`, avec un state local, et la configuration principale le
  référence par `backend.hcl`. Le versioning des blobs permet de revenir à un state précédent.
- **Provider azurerm 5.x** : aucun fournisseur de ressources n'est enregistré par défaut,
  `resource_providers_to_register` liste ceux qu'on utilise.

## Ce qui n'est pas dans le dépôt

`terraform.tfstate`, `terraform.tfvars`, `backend.hcl` et le dossier `.terraform/` sont ignorés par
git. Les fichiers `.example` donnent le format attendu. L'authentification passe par `az login`.
