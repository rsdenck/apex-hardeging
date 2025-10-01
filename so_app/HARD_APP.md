# `hard_app.sh`

## 📌 Visão Geral

O `hard_app.sh` é um script Bash para **tunagem de desempenho e hardening de sistemas Linux** dedicados a **aplicações de Middleware**, tais como:

- Servidores de aplicação: **WildFly, JBoss, WebLogic, WebSphere, Tomcat, .NET**  
- Camadas de API: **JDBC, ODBC, JMX**  
- Containers e microserviços: **Docker, Kubernetes runtimes**  
- Servidores web/reverso proxy: **Nginx, Apache, HAProxy**  

O objetivo é ajustar **parâmetros de kernel e do sistema operacional** para garantir:  
- **Alta performance sob cargas massivas** (muitas conexões simultâneas).  
- **Redução de latência em redes e sockets TCP**.  
- **Melhor gerenciamento de memória e cache**.  
- **Isolamento e priorização de workloads de middleware** (sem interferência de processos desnecessários).  

O script é seguro para **produção** porque:  
- Gera **inventário** de recursos (CPU, memória, conexões).  
- Calcula **recomendações dinâmicas** com base no hardware.  
- Aplica ajustes em `/etc/sysctl.d/` e `/etc/security/limits.d/`.  
- Faz **backup automático** antes de alterações.  
- Permite **dry-run, revert e relatórios detalhados**.  

---

## 🚀 Recursos

- **Inventário completo**:  
  - CPUs físicas e threads lógicas  
  - Memória total e swap  
  - Conexões TCP  
  - Processos ativos  

- **Ajustes de Kernel para Middleware**:  
  - Buffers de rede (`net.core.*`, `net.ipv4.tcp_*`).  
  - Aumento de filas de conexões (`somaxconn`, `backlog`).  
  - Redução de latência (`tcp_low_latency`, `tcp_tw_reuse`).  
  - Ajustes de memória compartilhada (`shmmax`, `shmall`).  
  - Ajustes de file descriptors (limite de conexões simultâneas).  

- **Segurança e reversibilidade**:  
  - Backup automático em `/var/backups/hardening/`.  
  - Opção de **rollback** (`--revert`).  
  - Inventário armazenado para auditoria.  

---

## ⚙️ Uso

### 📥 Instalação
Copie o script para `/usr/local/bin`:

```bash
sudo cp hard_app.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/hard_app.sh
```
---
## 📌 Sintaxe
```bash
hard_app.sh [OPÇÃO]
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
sudo hard_app.sh --show
```
- **Testar recomendações sem alterar o sistema**:
```bash
sudo hard_app.sh --dry-run
```

- **Aplicar tunagem para Middleware**:
```bash
sudo hard_app.sh --apply
```
- **Reverter para estado original**:
```bash
sudo hard_app.sh --revert
```
---
## 🔍 O que o script altera?

O script foca em otimizações que reduzem a latência e aumentam a capacidade de concorrência, vitais para o Middleware.

### 📌 Rede e Conexões TCP

| Parâmetro | Alteração de Desempenho |
| :--- | :--- |
| `net.core.somaxconn` | Aumenta drasticamente a fila de conexões pendentes para alta carga. |
| `net.ipv4.tcp_max_syn_backlog` | Melhora a resiliência do handshake TCP sob alta carga. |
| `net.ipv4.ip_local_port_range` | Expande o *pool* de portas efêmeras para suportar mais conexões simultâneas. |
| `net.ipv4.tcp_tw_reuse` | Habilita o reaproveitamento de conexões no estado `TIME_WAIT`. |
| `net.ipv4.tcp_fin_timeout` | Reduz o tempo de espera para conexões fechadas, liberando recursos. |
| `net.ipv4.tcp_low_latency` | Habilita um perfil de baixa latência para o tráfego TCP. |

### 📌 Memória e Buffers

| Parâmetro | Alteração de Desempenho |
| :--- | :--- |
| `net.core.rmem_max`, `net.core.wmem_max` | Aumentam os buffers máximos de rede. |
| `net.ipv4.tcp_rmem`, `net.ipv4.tcp_wmem` | Ajustam a alocação de memória para buffers TCP. |
| `vm.swappiness=10` | Evita o uso agressivo de **SWAP** (disco), mantendo a maior parte dos dados críticos na RAM. |
| `vm.max_map_count` | Aumenta o limite de mapeamentos de memória (importante para serviços baseados em JVM, como ElasticSearch). |

### 📌 Processos e Arquivos

| Parâmetro | Alteração de Desempenho |
| :--- | :--- |
| `nofile` (limite de file descriptors) | Aumenta a capacidade de conexões e arquivos abertos simultaneamente. |
| `nproc` | Aumenta o número máximo de processos/threads por usuário. |

---

## 📂 Estrutura de Arquivos

| Tipo de Arquivo | Localização |
| :--- | :--- |
| **Configurações Aplicadas (sysctl):** | `/etc/sysctl.d/99-hard-app.conf` |
| **Configurações Aplicadas (limits):** | `/etc/security/limits.d/99-hard-app.conf` |
| **Backups Originais:** | `/var/backups/hardening/` |
| **Logs de Execução:** | `/var/log/hard_app.log` |

---

## 🛑 Cuidados

* **Ambiente:** Execute apenas em servidores dedicados a Middleware ou Backends de alta performance.
* **Homologação:** Teste primeiro em ambiente de homologação (`--dry-run` é fortemente recomendado).
* **Documentação:** Documente os ajustes junto aos times de DBAs e DevOps/SRE.

## 📜 Licença

Distribuído sob licença MIT. Uso livre para ambientes pessoais e corporativos.