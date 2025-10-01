#!/usr/bin/env bash
# Apex Monitoring Solutions
# Autor: ranlens.denck
# hard_ssh.sh
# Hardening completo do SSH e auditoria do Linux
# Uso: hard_ssh.sh --user <usuario> [--dry-run|--apply|--show|--help]
#
# Funcionalidades:
# - Coleta inventário do SO, versão, distro
# - Detecta firewall ativo
# - Verifica porta SSH e altera para 4022
# - Instala auditd caso não exista
# - Cria usuário informado com sudo sem senha
# - Desabilita login root por SSH com senha
# - Permite SSH somente para usuário criado
# ------------------------------------------------------------------------------------
set -euo pipefail
IFS=$'\n\t'

SCRIPT_NAME="$(basename "$0")"
USER_TO_ADD=""
DRY_RUN=false
APPLY=false
SHOW_ONLY=false
SSH_PORT_NEW=4022

trap 'rc=$?; if [ $rc -ne 0 ]; then echo "[ERROR] Erro no script: código $rc"; fi' EXIT

require_root() {
  if [ "$(id -u)" -ne 0 ]; then
    echo "Este script precisa ser executado como root. Use sudo." >&2
    exit 1
  fi
}

parse_args() {
  if [ $# -eq 0 ]; then
    print_help
    exit 0
  fi

  while [ $# -gt 0 ]; do
    case "$1" in
      --user) USER_TO_ADD="$2"; shift 2 ;;
      --dry-run) DRY_RUN=true; shift ;;
      --apply) APPLY=true; shift ;;
      --show) SHOW_ONLY=true; shift ;;
      --help) print_help; exit 0 ;;
      *) echo "Opção desconhecida: $1"; print_help; exit 1 ;;
    esac
  done

  if [[ -z "$USER_TO_ADD" ]] && [[ "$APPLY" = true ]]; then
    echo "Erro: usuário não informado. Use --user <usuario>"
    exit 1
  fi
}

collect_inventory() {
  echo "=== INVENTÁRIO DO SISTEMA ==="
  echo "Hostname: $(hostname -f 2>/dev/null || hostname)"
  echo "Data: $(date -u +"%Y-%m-%d %H:%M:%SZ")"
  echo
  echo "-- SISTEMA OPERACIONAL --"
  if [ -f /etc/os-release ]; then
    . /etc/os-release
    echo "Distribuição: $NAME"
    echo "Versão: $VERSION"
    echo "ID: $ID"
  fi
  echo
  echo "-- FIREWALL --"
  if command -v ufw &>/dev/null; then
    echo "ufw ativo: $(ufw status verbose)"
  elif command -v firewall-cmd &>/dev/null; then
    echo "firewalld ativo: $(firewall-cmd --state 2>/dev/null || echo 'inativo')"
  else
    echo "Nenhum firewall detectado."
  fi
  echo
  echo "-- SSH --"
  SSH_CURRENT_PORT=$(ss -tlnp | grep sshd || true)
  echo "SSH listener atual: $SSH_CURRENT_PORT"
  echo
  echo "-- AUDITD --"
  if systemctl is-active auditd &>/dev/null; then
    echo "auditd ativo"
  else
    echo "auditd não instalado ou inativo"
  fi
  echo "=============================="
}

install_auditd() {
  if ! systemctl is-active auditd &>/dev/null; then
    echo "[*] Instalando auditd..."
    if [[ -f /etc/debian_version ]]; then
      apt-get update && apt-get install -y auditd audispd-plugins
    elif [[ -f /etc/redhat-release ]]; then
      yum install -y audit audit-libs
    fi
    systemctl enable auditd
    systemctl start auditd
    echo "[*] auditd instalado e iniciado"
  else
    echo "[*] auditd já está ativo"
  fi
}

configure_ssh() {
  SSH_CONFIG="/etc/ssh/sshd_config"
  cp "$SSH_CONFIG" "${SSH_CONFIG}.bak.$(date +%Y%m%d_%H%M%S)"
  sed -i "s/^#Port 22/Port $SSH_PORT_NEW/" "$SSH_CONFIG"
  sed -i "s/^Port .*/Port $SSH_PORT_NEW/" "$SSH_CONFIG"
  sed -i "s/^PermitRootLogin yes/PermitRootLogin no/" "$SSH_CONFIG"
  sed -i "s/^PasswordAuthentication yes/PasswordAuthentication no/" "$SSH_CONFIG"
  # Permitir apenas o usuário especificado
  if grep -q "^AllowUsers" "$SSH_CONFIG"; then
    sed -i "s/^AllowUsers.*/AllowUsers $USER_TO_ADD/" "$SSH_CONFIG"
  else
    echo "AllowUsers $USER_TO_ADD" >> "$SSH_CONFIG"
  fi
  systemctl restart sshd || systemctl restart ssh || true
  echo "[*] SSH configurado para porta $SSH_PORT_NEW, root e senha desabilitados, apenas $USER_TO_ADD pode conectar"
}

create_user() {
  if id "$USER_TO_ADD" &>/dev/null; then
    echo "[*] Usuário $USER_TO_ADD já existe"
  else
    useradd -m -s /bin/bash "$USER_TO_ADD"
    echo "[*] Usuário $USER_TO_ADD criado"
  fi
  # Adiciona sudo sem senha
  if [[ -f /etc/sudoers.d/$USER_TO_ADD ]]; then
    echo "[*] Sudoers já configurado para $USER_TO_ADD"
  else
    echo "$USER_TO_ADD ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$USER_TO_ADD
    chmod 440 /etc/sudoers.d/$USER_TO_ADD
    echo "[*] Usuário $USER_TO_ADD adicionado ao sudo sem senha"
  fi
}

do_show() {
  collect_inventory
}

do_dry_run() {
  collect_inventory
  echo
  echo "=== DRY RUN ==="
  echo "O script faria as seguintes ações se executado com --apply:"
  echo "- Instalar auditd caso não esteja ativo"
  echo "- Alterar porta SSH para $SSH_PORT_NEW"
  echo "- Desabilitar login root via SSH e senha"
  echo "- Criar usuário $USER_TO_ADD e permitir sudo sem senha"
  echo "- Restringir login SSH somente para $USER_TO_ADD"
}

do_apply() {
  require_root
  collect_inventory
  install_auditd
  create_user
  configure_ssh
  echo "[*] Hardening SSH completo aplicado com sucesso"
}

print_help() {
  cat <<EOF
Uso: $SCRIPT_NAME --user <usuario> [--dry-run|--apply|--show|--help]

--user      : usuário que terá acesso SSH e privilégios sudo sem senha
--show      : mostra inventário e configurações atuais
--dry-run   : mostra o que seria feito sem aplicar
--apply     : aplica o hardening SSH completo
--help      : esta ajuda
EOF
}

# --- Main ---
parse_args "$@"

if [ "$SHOW_ONLY" = true ]; then
  do_show
  exit 0
fi

if [ "$DRY_RUN" = true ]; then
  do_dry_run
  exit 0
fi

if [ "$APPLY" = true ]; then
  do_apply
  exit 0
fi

print_help
exit 1
