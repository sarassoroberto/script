#!/bin/bash

GREEN='\033[0;32m'
NC='\033[0m' # No Color

echo -e "${GREEN}🔐 [1] Copio chiave su TeoUserAurumServer_Produzione_2025${NC}"
ssh-copy-id -i ~/.ssh/id_rsa.pub teo@185.205.244.102
echo -e "${GREEN}✅ Test connessione TeoUserAurumServer_Produzione_2025${NC}"
ssh -o BatchMode=yes teo@185.205.244.102 "echo '✅ Connessione riuscita a TeoUserAurumServer_Produzione_2025'"

echo -e "${GREEN}🔐 [2] Copio chiave su ROOT_TeoUserAurumServer_Produzione_2025${NC}"
ssh-copy-id -i ~/.ssh/id_rsa.pub root@185.205.244.102
echo -e "${GREEN}✅ Test connessione ROOT_TeoUserAurumServer_Produzione_2025${NC}"
ssh -o BatchMode=yes root@185.205.244.102 "echo '✅ Connessione riuscita a ROOT_TeoUserAurumServer_Produzione_2025'"

echo -e "${GREEN}🔐 [3] Copio chiave su 161.97.76.57 (utente teo)${NC}"
ssh-copy-id -i ~/.ssh/id_rsa.pub teo@161.97.76.57
echo -e "${GREEN}✅ Test connessione 161.97.76.57${NC}"
ssh -o BatchMode=yes teo@161.97.76.57 "echo '✅ Connessione riuscita a 161.97.76.57'"

echo -e "${GREEN}🔐 [4] Copio chiave su 161.97.135.136 (utente teo, porta 2099)${NC}"
ssh-copy-id -p 2099 -i ~/.ssh/id_rsa.pub teo@161.97.135.136
echo -e "${GREEN}✅ Test connessione 161.97.135.136 (teo)${NC}"
ssh -p 2099 -o BatchMode=yes teo@161.97.135.136 "echo '✅ Connessione riuscita a 161.97.135.136 (teo)'"

echo -e "${GREEN}🔐 [5] Copio chiave su 161.97.135.136 (utente root, porta 2099)${NC}"
ssh-copy-id -p 2099 -i ~/.ssh/id_rsa.pub root@161.97.135.136
echo -e "${GREEN}✅ Test connessione 161.97.135.136 (root)${NC}"
ssh -p 2099 -o BatchMode=yes root@161.97.135.136 "echo '✅ Connessione riuscita a 161.97.135.136 (root)'"

echo -e "${GREEN}🎉 Tutte le operazioni completate. Premi INVIO per uscire.${NC}"
read -p "pausa"