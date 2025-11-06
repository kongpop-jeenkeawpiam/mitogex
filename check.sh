#!/usr/bin/env bash
# MitoGEx post-install verifier (auto-detects tools via conda run)
# Run with: bash -l check_mitogex_install.sh

set -euo pipefail

ROOT="$(pwd)"
JSON=0
PIPE_ENV="mitogex"
ETE_ENV="mitogex_ete"
SOFT_DIR="${ROOT}/Software"

PASS=()
FAIL=()
ok(){ PASS+=("$1"); }
bad(){ FAIL+=("$1"); }

print_result(){
  local status="$1" msg="$2"
  if [[ $JSON -eq 1 ]]; then
    printf '{"status":"%s","check":"%s"}\n' "$status" "$msg"
  else
    if [[ "$status" == "pass" ]]; then
      printf "✅ %s\n" "$msg"
    else
      printf "❌ %s\n" "$msg"
    fi
  fi
}

check_cmd(){ local n="$1"; if command -v "$n" &>/dev/null; then print_result pass "command '$n' found at $(command -v "$n")"; ok "$n"; else print_result fail "command '$n' NOT found"; bad "$n"; fi; }
check_cmd_version(){ local n="$1"; local f="${2:---version}"; if command -v "$n" &>/dev/null; then local v; if v=$("$n" "$f" 2>/dev/null | head -n1); then print_result pass "'$n' version: ${v:-unknown}"; ok "$n"; else print_result pass "'$n' present (version probe failed)"; ok "$n"; fi else print_result fail "'$n' NOT found"; bad "$n"; fi; }
check_file_exec(){ local p="$1" l="$2"; if [[ -x "$p" ]]; then print_result pass "$l present & executable: $p"; ok "$l"; else print_result fail "$l missing or not executable: $p"; bad "$l"; fi; }
check_file_exist(){ local p="$1" l="$2"; if [[ -e "$p" ]]; then print_result pass "$l present: $p"; ok "$l"; else print_result fail "$l missing: $p"; bad "$l"; fi; }
check_dir_nonempty(){ local p="$1" l="$2"; if [[ -d "$p" ]] && [[ -n "$(ls -A "$p" 2>/dev/null || true)" ]]; then print_result pass "$l directory exists and is non-empty: $p"; ok "$l"; else print_result fail "$l directory missing or empty: $p"; bad "$l"; fi; }

check_bin_any(){
  local exe="$1" verflag="$2" envname="$3"
  if command -v "$exe" &>/dev/null; then
    check_cmd_version "$exe" "$verflag"
    return
  fi
  if command -v conda &>/dev/null && conda env list 2>/dev/null | grep -qE "^[[:space:]]*${envname}([[:space:]]|$)"; then
    if conda run -n "$envname" which "$exe" &>/dev/null; then
      local out
      if [[ -n "$verflag" ]]; then
        out=$(conda run -n "$envname" "$exe" "$verflag" 2>/dev/null | head -n1 || true)
      else
        out=$(conda run -n "$envname" "$exe" 2>&1 | head -n1 || true)
      fi
      if [[ -n "${out:-}" ]]; then
        print_result pass "'$exe' via conda env '${envname}': ${out}"
      else
        print_result pass "'$exe' via conda env '${envname}' (version probe not available)"
      fi
      ok "$exe"; return
    fi
  fi
  print_result fail "'$exe' NOT found (PATH or conda env ${envname})"; bad "$exe"
}

echo "== Checking system packages =="
check_cmd_version sudo
check_cmd_version gcc
check_cmd_version jq
check_cmd_version curl
check_cmd_version java
check_cmd_version javac
check_cmd_version iqtree2 "-v" || true
check_cmd yq || true
check_cmd glxinfo || true

echo
echo "== Checking Conda and environments =="
check_cmd conda
if command -v conda &>/dev/null; then
  if conda env list 2>/dev/null | grep -qE "^[[:space:]]*${ETE_ENV}([[:space:]]|$)"; then
    print_result pass "conda env '${ETE_ENV}' exists"; ok "env-${ETE_ENV}"
  else
    print_result fail "conda env '${ETE_ENV}' missing"; bad "env-${ETE_ENV}"
  fi
  if conda env list 2>/dev/null | grep -qE "^[[:space:]]*${PIPE_ENV}([[:space:]]|$)"; then
    print_result pass "conda env '${PIPE_ENV}' exists"; ok "env-${PIPE_ENV}"
  else
    print_result fail "conda env '${PIPE_ENV}' missing"; bad "env-${PIPE_ENV}"
  fi
fi

echo
echo "== Checking Python packages in env: mitogex_ete (ete3, slr) =="
if conda env list 2>/dev/null | grep -qE "^[[:space:]]*mitogex_ete([[:space:]]|$)"; then
  conda run -n mitogex_ete python - <<'PY'
import sys, shutil, importlib
print("Python:", sys.version)
try:
    importlib.import_module('ete3')
    print("✅ ete3 imported successfully")
except Exception as e:
    print("❌ ete3 import failed:", e)
p = shutil.which('slr')
print(f"✅ slr found at {p}" if p else "❌ slr not found in PATH")
PY
  if conda run -n mitogex_ete bash -lc '[[ -f "$CONDA_PREFIX/bin/ete3_apps/bin/Slr" ]]'; then
    conda run -n mitogex_ete bash -lc '
      SRC="$CONDA_PREFIX/bin/ete3_apps/bin/Slr"
      chmod +x "$SRC" 2>/dev/null || true
      ln -sf "$SRC" "$CONDA_PREFIX/bin/slr"
      ln -sf "$SRC" "$CONDA_PREFIX/bin/SLR"
      echo "✅ Linked $SRC → $CONDA_PREFIX/bin/slr"
      command -v slr >/dev/null && echo "✅ slr available at $(command -v slr)"
    '
    ok "mitogex_ete"
  else
    print_result fail "Slr binary missing in mitogex_ete"; bad "mitogex_ete"
  fi
else
  print_result fail "conda env 'mitogex_ete' not found"; bad "mitogex_ete"
fi

echo
echo "== Checking Python packages & CLIs in env: mitogex (multiqc, fastqc, fastp, qualimap, samtools, bwa) =="

if conda env list 2>/dev/null | grep -qE "^[[:space:]]*mitogex([[:space:]]|$)"; then
  echo "Running checks via conda run in env 'mitogex'..."

  # create the python checker
  cat > /tmp/_check_mitogex.py <<'PY'
import sys, shutil, importlib
print("Python:", sys.version)
mods = ['multiqc','PyQt6','packaging']
for m in mods:
    try:
        importlib.import_module(m)
        print(f"✅ {m} imported successfully")
    except Exception as e:
        print(f"❌ {m} import failed: {e}")
for exe in ['fastqc','fastp','qualimap','samtools','bwa','multiqc']:
    p = shutil.which(exe)
    print(f"✅ {exe} found at {p}" if p else f"❌ {exe} not found in PATH")
PY

  # run it inside the env, headless + timeout, capture all output
  TMPFILE=$(mktemp)
  if conda run -n mitogex bash -lc 'unset DISPLAY; export QT_QPA_PLATFORM=offscreen; timeout 20s python -u /tmp/_check_mitogex.py' >"$TMPFILE" 2>&1; then
    cat "$TMPFILE"
    ok "mitogex"
  else
    echo "❌ Python execution failed or timed out in env 'mitogex'"
    echo "--- captured output ---"; cat "$TMPFILE"; echo "-----------------------"
    # quick sanity probes to help debug
    conda run -n mitogex bash -lc 'which python || true'
    conda run -n mitogex bash -lc 'python -V || true'
    bad "mitogex"
  fi
  rm -f "$TMPFILE"
else
  print_result fail "conda env 'mitogex' not found"; bad "mitogex"
fi




echo
echo "== Checking third-party binaries (PATH or conda env ${PIPE_ENV}) =="
check_bin_any fastqc   "--version" "${PIPE_ENV}"
check_bin_any fastp    "--version" "${PIPE_ENV}"
check_bin_any qualimap "-v"        "${PIPE_ENV}"
check_bin_any samtools "--version" "${PIPE_ENV}"
check_bin_any bwa      ""          "${PIPE_ENV}"
check_bin_any multiqc  "--version" "${PIPE_ENV}"

echo
echo "== Checking assets under ${SOFT_DIR} =="
check_file_exec "${SOFT_DIR}/bwa-mem2/bwa-mem2" "bwa-mem2"
check_file_exec "${SOFT_DIR}/gatk/gatk" "GATK launcher"
check_file_exist "${SOFT_DIR}/picard/picard.jar" "Picard JAR"
check_file_exec "${SOFT_DIR}/haplogrep3/haplogrep3" "Haplogrep3 binary"
check_dir_nonempty "${SOFT_DIR}/haplogrep3/trees/phylotree-fu-rcrs/1.2" "Haplogrep3 trees"
check_file_exist "${SOFT_DIR}/mtdnaserver/haplocheckCLI.jar" "haplocheckCLI JAR"
check_dir_nonempty "${SOFT_DIR}/annovar" "ANNOVAR directory"
check_file_exist "${SOFT_DIR}/annovar/annotate_variation.pl" "annotate_variation.pl"
check_file_exist "${SOFT_DIR}/annovar/table_annovar.pl" "table_annovar.pl"
check_dir_nonempty "${SOFT_DIR}/References/hg38" "hg38 references"
check_dir_nonempty "${SOFT_DIR}/References/chrM" "rCRS chrM references"
check_dir_nonempty "${SOFT_DIR}/scripts" "scripts directory"

echo
echo "== Optional graphics OpenGL libraries =="
if ldconfig -p 2>/dev/null | grep -q 'libGL.so'; then
  print_result pass "libGL present"; ok "libGL"
else
  print_result fail "libGL not found"; bad "libGL"
fi

echo
echo "== Summary =="
printf "Passed: %d\n" "${#PASS[@]}"
printf "Failed: %d\n" "${#FAIL[@]}"
if [[ ${#FAIL[@]} -gt 0 ]]; then
  echo "Missing/Problems:"
  for f in "${FAIL[@]}"; do echo " - $f"; done
fi

[[ ${#FAIL[@]} -eq 0 ]]

