# Usage : source scripts/env.sh
#
# Sur la machine GPU, le disque système est presque plein : tout ce qui est lourd
# va sur /scratch. /scratch est à considérer comme ÉPHÉMÈRE :
#   - $HDDL_CACHE, $HF_HOME (caches, poids) : se retélécharge
#   - $HDDL_RUNS (checkpoints entraînés)    : ne se retélécharge PAS, à rapatrier si utile
#   - $HDDL_RESULTS (dans le dépôt)         : CSV, configs, figures PNG, à commiter
# Sans /scratch, tout va dans .scratch/ à la racine du dépôt (ignoré par git).

if [ -n "${BASH_SOURCE:-}" ]; then _hddl_self="${BASH_SOURCE[0]}"; else _hddl_self="$0"; fi
HDDL_ROOT="$(cd "$(dirname "$_hddl_self")/.." && pwd)"
unset _hddl_self

if [ -z "${HDDL_SCRATCH:-}" ]; then
    if [ -d /scratch ] && [ -w /scratch ]; then
        HDDL_SCRATCH=/scratch/hddl
    else
        HDDL_SCRATCH="$HDDL_ROOT/.scratch"
    fi
fi

export HDDL_ROOT HDDL_SCRATCH
export HDDL_CACHE="$HDDL_SCRATCH/cache"
export HDDL_RUNS="$HDDL_SCRATCH/runs"
export HDDL_RESULTS="$HDDL_ROOT/results"

export HF_HOME="$HDDL_SCRATCH/hf"
export TORCH_HOME="$HDDL_CACHE/torch"
export PIP_CACHE_DIR="$HDDL_CACHE/pip"
export UV_CACHE_DIR="$HDDL_CACHE/uv"
export UV_PROJECT_ENVIRONMENT="$HDDL_SCRATCH/venv"
export TMPDIR="$HDDL_SCRATCH/tmp"

mkdir -p "$HF_HOME" "$TORCH_HOME" "$PIP_CACHE_DIR" "$UV_CACHE_DIR" "$TMPDIR" "$HDDL_RUNS" "$HDDL_RESULTS"
