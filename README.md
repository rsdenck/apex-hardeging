# Hardening Linux

<div align="center">
  <img src="img/linux-hardening.png" alt="Linux Hardening" style="width: 100%; max-width: 800px; height: auto;"/>
</div>

## Visão Geral

- Este repositório contém **manuais técnicos e scripts de automação** para hardening de sistemas Linux.  
- O objetivo é fornecer um conjunto de práticas recomendadas e ferramentas que auxiliem na melhoria da segurança, padronização de ambientes e mitigação de riscos operacionais.

## Objetivos

- Reduzir a superfície de ataque em servidores Linux.  
- Estabelecer políticas de segurança consistentes.  
- Automatizar processos de configuração segura.
- Ajustar desempenho de servidores Linux, de acordo com o seu trabalho.  
- Servir como base de conhecimento para equipes de infraestrutura e segurança.  

## Estrutura do Repositório

```bash
hardening/
├── docs/ 
│   ├── sistema-operacional/   # Guias específicos por distribuição
│   ├── servicos/              # Hardening de serviços (SSH, Apache, etc.)
│   ├── redes/                 # Configurações de rede e firewall
│   └── compliance/            # Políticas e benchmarks de segurança
├── scripts/                   # Scripts de automação para hardening
│   ├── sistema/               # Scripts de hardening do SO
│   ├── servicos/              # Scripts para serviços específicos
│   └── auditoria/             # Scripts de verificação e compliance
├── configs/                   # Exemplos de arquivos de configuração
│   ├── sysctl/                # Configurações de kernel
│   ├── audit/                 # Regras de auditoria
│   └── firewall/              # Regras de firewall
├── img/ 
└── README.md                  # Este arquivo
```
---

## Conteúdo Técnico

### Documentação
- **Sistema Operacional**: Guias de hardening para Sistemas Operacionais Linux, Database, Middleware.
- **Desempenho e Performance**: Hardening de Kernel, e recursos de SO, para melhor desempenho.

### Scripts de Automação
- **hard_ssh.sh**: Configurações de hardening para serviço SSH
- **hard_db.sh**: Realiza auditoria de segurança do sistema
- **hard_app.sh**: Verifica conformidade com políticas de segurança

### Instalação e Uso

- **Clone o repositório**:
```bash
git clone https://github.com/seu-usuario/hardening.git
cd hardening
