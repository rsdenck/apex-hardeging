# `hard_db.sh`

## 📌 Visão Geral

O `hard_db.sh` é um script Bash para **tunagem de desempenho e hardening de sistemas Linux** dedicados a **bancos de dados** de alta performance, tais como:

- **PostgreSQL, MySQL/MariaDB, Oracle Database, Redis, SQLite, MongoDB**  
- **SGBDs corporativos e workloads críticos**  

O foco é ajustar **parâmetros de kernel e do sistema operacional** para garantir:  
- **Baixa latência em operações de I/O**.  
- **Maior throughput em consultas complexas**.  
- **Gerenciamento eficiente de memória, cache e swap**.  
- **Execução exclusiva de workloads de banco de dados**, eliminando gargalos.  

O script é seguro para **produção** porque:  
- Gera **inventário** de recursos (CPU, memória, conexões, processos).  
- Calcula **recomendações dinâmicas** de tunning com base no hardware.  
- Aplica ajustes em `/etc/sysctl.d/` e `/etc/security/limits.d/`.  
- Faz **backup automático** antes de alterações.  
- Permite **dry-run, revert e relatórios detalhados**.  
- Desabilita **Transparent HugePages (THP)**, que prejudica desempenho de bancos.  

---

## 🚀 Recursos

- **Inventário completo**:  
  - CPUs físicas e threads lógicas  
  - Memória total, swap e cache  
  - Conexões TCP  
  - Processos ativos  

- **Ajustes de Kernel para Bancos de Dados**:  
  - Buffers de I/O e cache.  
  - Ajustes de memória compartilhada (`shmmax`, `shmall`).  
  - Redução de uso de swap (`vm.swappiness`).  
  - Ajustes em processos e file descriptors.  
  - Desabilita **THP** (Transparent HugePages).  

- **Segurança e reversibilidade**:  
  - Backup automático em `/var/backups/hardening/`.  
  - Opção de **rollback** (`--revert`).  
  - Inventário armazenado para auditoria.  

---

## ⚙️ Uso

### 📥 Instalação
Copie o script para `/usr/local/bin`:

```bash
sudo cp hard_db.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/hard_db.sh
```
---
## 📌 Sintaxe
```bash
hard_db.sh [OPÇÃO]
```
### 🔧 Opções disponíveis

| Opção     | Descrição                                                                 |
|-----------|---------------------------------------------------------------------------|
| --show    | Mostra o inventário de hardware e recomendações sem aplicar.             |
| --dry-run | Mostra o que seria alterado no sistema sem aplicar mudanças.             |
| --apply   | Aplica as configurações de hardening e salva em /etc/sysctl.d/.          |
| --revert  | Restaura configurações originais a partir do backup.                     |
| --help    | Exibe a ajuda detalhada do script.                                       |

---
## 📊 Exemplos
- **Mostrar inventário do sistema**:
```bash
sudo hard_db.sh --show
```
- **Testar recomendações sem alterar o sistema**:
```bash
sudo hard_db.sh --dry-run
```

- **Aplicar tunagem para Middleware**:
```bash
sudo hard_db.sh --apply
```
- **Reverter para estado original**:
```bash
sudo hard_db.sh --revert
```
---
## 🔍 O que o script altera?

O foco é otimizar o servidor Linux para execução exclusiva de bancos de dados, garantindo eficiência em I/O, memória e processos.

### 📌 Memória e Cache

| Parâmetro | Alteração de Desempenho |
| :--- | :--- |
| `vm.swappiness=10` | **Reduz o uso de SWAP**, priorizando a RAM para o cache do banco de dados. |
| `vm.dirty_ratio` | Controla a porcentagem máxima da memória que pode ser usada para páginas sujas antes do *flush* em disco (operações síncronas). |
| `vm.dirty_background_ratio` | Define o limite para o início do *flush* assíncrono de páginas sujas. |
| `vm.overcommit_memory=1` | Permite a alocação de memória de forma mais agressiva (útil para SGBDs que gerenciam sua própria memória). |
| `vm.max_map_count` | Aumenta o número de mapeamentos de memória (essencial para SGBDs com muitos *threads* e estruturas de dados). |

### 📌 Kernel e I/O

| Parâmetro | Alteração de Desempenho |
| :--- | :--- |
| `fs.aio-max-nr` | Ajusta o máximo de operações assíncronas de I/O, melhorando a eficiência de leitura/escrita. |
| `kernel.shmmax` | Define o tamanho máximo do segmento de memória compartilhada (crucial para grandes instâncias de DBs como Oracle/PostgreSQL). |
| `kernel.shmall` | Define o total de páginas de memória compartilhada disponíveis no sistema. |
| `THP (Transparent HugePages)` | **Desabilitado** para evitar picos de latência e instabilidade conhecidos em cargas de trabalho de banco de dados. |

### 📌 Processos e Arquivos

| Parâmetro | Alteração de Desempenho |
| :--- | :--- |
| `nofile` (limite de file descriptors) | Aumenta o limite para suportar um grande número de conexões e arquivos de log abertos simultaneamente. |
| `nproc` | Aumenta o número máximo de processos/threads por usuário. |

---

## 📂 Estrutura de Arquivos

| Tipo de Arquivo | Localização |
| :--- | :--- |
| **Configurações Aplicadas (sysctl):** | `/etc/sysctl.d/99-hard-db.conf` |
| **Configurações Aplicadas (limits):** | `/etc/security/limits.d/99-hard-db.conf` |
| **Backups Originais:** | `/var/backups/hardening/` |
| **Logs de Execução:** | `/var/log/hard_db.log` |

---

## 🛑 Cuidados

* **Ambiente:** Execute apenas em servidores dedicados a Banco de Dados de alta performance.
* **Homologação:** Teste primeiro em ambiente de homologação (`--dry-run` é fortemente recomendado).
* **Documentação:** Documente os ajustes junto aos times de DBAs e DevOps/SRE.

## 📜 Licença

Distribuído sob licença MIT. Uso livre para ambientes pessoais e corporativos.