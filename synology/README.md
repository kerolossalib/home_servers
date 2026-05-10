# Synology Home Server - GitOps

Gestione Docker su Synology tramite GitOps.

## Setup iniziale

```bash
# 1. Connettiti via SSH al Synology
ssh tuo_utente@192.168.1.185

# 2. Clona il repo
cd /volume1/docker
git clone git@github.com:kerolossalib/home_servers.git

# 3. Primo deploy manuale
cd home_servers/synology
bash deploy.sh
```

## Task Scheduler (auto-deploy)

Su DSM: **Pianificazione Attività → Crea → Attività pianificata → Script definito dall'utente**

- **Nome**: `homelab-gitops`
- **Utente**: `root`
- **Pianificazione**: ogni 5 minuti
- **Script**:
  ```bash
  bash /volume1/docker/home_servers/synology/deploy.sh
  ```
