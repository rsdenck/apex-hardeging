# `hard_ssh.sh`

## 📌 Visão Geral

O `hard_ssh.sh` é um script Bash para **hardening completo do SSH e auditoria do Linux**, com foco em **alta segurança e acesso controlado**.

Objetivos:  
- **Alterar porta SSH padrão** (22 → 4022).  
- **Desabilitar login root via SSH e senha**.  
- **Criar usuário autorizado** e permitir sudo sem senha.  
- **Restringir acesso SSH apenas ao usuário criado**.  
- **Verificar/instalar auditd** silenciosamente.  
- **Detectar firewall ativo e informações da distribuição**.  

Ideal para ambientes de produção e servidores críticos.

---

## 🚀 Recursos

- **Inventário completo:** versão do SO, tipo de distro (.deb/.rpm), firewall, portas SSH, auditd.  
- **Segurança:** login root desabilitado, senha desativada, acesso restrito.  
- **Auditoria:** instalação automática do auditd, logs de auditoria mantidos.  
- **Automação:** criação de usuário com sudo sem senha, SSH configurado automaticamente.  

---

## ⚙️ Uso

### 📥 Instalação
Copie o script para `/usr/local/bin`:

```bash
sudo cp hard_ssh.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/hard_ssh.sh
```
## 📌 Sintaxe
```bash
hard_ssh.sh --user <usuario> [--dry-run|--apply|--show|--help]
```
## 🔧 Opções Disponíveis

| Opção     | Descrição                                            |
| --------- | ---------------------------------------------------- |
| --user    | Usuário que terá acesso SSH e sudo sem senha         |
| --show    | Mostra inventário e configurações atuais             |
| --dry-run | Mostra ações que seriam feitas, sem aplicar mudanças |
| --apply   | Aplica o hardening completo de SSH e auditoria       |
| --help    | Exibe ajuda detalhada                                |

---
## 📊 Exemplos
- **Mostrar inventário do sistema**:
```bash
sudo hard_ssh.sh --show
```

- **Testar recomendações sem alterar o sistema**:
```bash
sudo hard_ssh.sh --user rsdenck --dry-run
```
- **Aplicar hardening Completa**:
```bash
sudo hard_ssh.sh --user rsdenck --apply
```
---

## 🔍 O que o script altera?

### 📌 SSH

| Parâmetro          | Alteração |
| :---               | :--- |
| Porta SSH          | Alterada de 22 para 4022 |
| PermitRootLogin    | Desabilitado (no) |
| PasswordAuthentication | Desabilitado (no) |
| AllowUsers         | Apenas o usuário especificado em --user pode conectar |

### 📌 Usuário

| Ação               | Alteração |
| :---               | :--- |
| Criação de usuário | Usuário informado em --user é criado (se não existir) |
| Sudo               | Usuário criado adicionado ao sudo sem necessidade de senha |
| Restrição SSH      | Somente o usuário criado tem permissão de login via SSH |

### 📌 Auditoria

| Componente         | Alteração |
| :---               | :--- |
| auditd             | Instalado automaticamente se não existir |
| Serviço ativo      | Garantido que auditd esteja habilitado e iniciado |
| Logs               | Todas as ações do sistema auditadas pelo auditd |

### 📌 Firewall (detecção)

| Ação               | Alteração |
| :---               | :--- |
| Detecta firewall ativo | Mostra se ufw ou firewalld estão ativos |
| Configuração SSH    | Certifica que a porta SSH alterada está liberada no firewall (manual se necessário) |

---

## 📂 Estrutura de Arquivos

| Tipo de Arquivo                  | Localização |
| :---                             | :--- |
| **Backup SSH**                   | `/etc/ssh/sshd_config.bak.<timestamp>` |
| **Sudoers do usuário**           | `/etc/sudoers.d/<usuario>` |
| **Logs de execução**             | `/var/log/hard_ssh.log` |
| **Backups auditd/configurações** | `/var/backups/hardening/` |

---

## 🛑 Cuidados

* **Ambiente:** Execute apenas em servidores dedicados e críticos.  
* **Homologação:** Teste primeiro em ambiente de homologação (`--dry-run` recomendado).  
* **Documentação:** Registre os usuários e alterações junto ao time de segurança.  
* **SSH:** Após alteração da porta, ajuste clientes SSH para se conectar na nova porta (4022).  

## 📜 Licença

Distribuído sob licença MIT. Uso livre para ambientes pessoais e corporativos.
