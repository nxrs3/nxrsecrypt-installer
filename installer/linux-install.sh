#!/bin/bash
set -e

# ── Colors ───────────────────────────────────────────────────────────────────
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()    { echo -e "${CYAN}[*]${NC} $1"; }
success() { echo -e "${GREEN}[✓]${NC} $1"; }
warn()    { echo -e "${YELLOW}[!]${NC} $1"; }
error()   { echo -e "${RED}[✗]${NC} $1"; exit 1; }

# ── Dependencies ─────────────────────────────────────────────────────────────
info "Checking dependencies..."
command -v git     &>/dev/null || error "git is not installed. Install it with your package manager."
command -v python3 &>/dev/null || error "python3 is not installed. Install it with your package manager."
success "Dependencies OK"

# ── Clone or update ──────────────────────────────────────────────────────────
if [ -d "$HOME/nxrsecrypt" ]; then
    warn "~/nxrsecrypt already exists, pulling latest..."
    git -C "$HOME/nxrsecrypt" pull
else
    info "Cloning nxrsecrypt..."
    git clone https://github.com/nxrs3/nxrsecrypt "$HOME/nxrsecrypt"
    success "Cloned successfully"
fi

# ── Venv + deps ──────────────────────────────────────────────────────────────
info "Setting up virtual environment..."
cd "$HOME/nxrsecrypt"
python3 -m venv venv
source venv/bin/activate
info "Upgrading pip..."
pip install --upgrade pip -q
info "Installing requirements..."
pip install -r requirements.txt -q
deactivate
success "Dependencies installed"

# ── Shell function ────────────────────────────────────────────────────────────
FUNC='nxrsecrypt() { cd "$HOME/nxrsecrypt" || exit 1; . venv/bin/activate; python3 "$HOME/nxrsecrypt/main.py"; deactivate; }'

# Bash (.bashrc + .bash_profile for login shell compat)
for FILE in "$HOME/.bashrc" "$HOME/.bash_profile"; do
    touch "$FILE"
    grep -q "nxrsecrypt()" "$FILE" || echo "$FUNC" >> "$FILE"
done

# Zsh
FILE="$HOME/.zshrc"
touch "$FILE"
grep -q "nxrsecrypt()" "$FILE" || echo "$FUNC" >> "$FILE"

# Fish (only if installed)
if command -v fish &>/dev/null; then
    FISH_DIR="$HOME/.config/fish/functions"
    mkdir -p "$FISH_DIR"
    cat > "$FISH_DIR/nxrsecrypt.fish" << 'EOF'
function nxrsecrypt
    cd $HOME/nxrsecrypt; or exit 1
    . venv/bin/activate.fish
    python3 $HOME/nxrsecrypt/main.py
    deactivate
    cd ~
end
EOF
    success "Fish function installed"
fi

success "Shell function registered"

# ── Done ──────────────────────────────────────────────────────────────────────
cd ~
echo ""
echo -e "${GREEN}Install complete!${NC} Restart your terminal or run:"
echo -e "  ${CYAN}source ~/.bashrc${NC}   # Bash"
echo -e "  ${CYAN}source ~/.zshrc${NC}    # Zsh"
