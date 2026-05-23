# ultra-review-lite

Custom Claude Code skills.

## Install

**Mac / Linux / Windows Git Bash:**
```bash
curl -sSL https://raw.githubusercontent.com/nik121212T/ultra-review-lite/main/install.sh | bash
```

**Windows PowerShell (natif):**
```powershell
irm https://raw.githubusercontent.com/nik121212T/ultra-review-lite/main/install.ps1 | iex
```

Requires `git`. Restart Claude Code after install.

## Update

Same command — re-run anytime to pull latest skills.

## Skills

### `/mini-review`

Silent multi-agent code review. Finds bugs, security issues, and best-practice violations.
Output caveman-compressed, one line per finding, severity-tagged.

```bash
/mini-review                     # current diff
/mini-review src/auth/           # specific path
/mini-review /absolute/path/     # external project
/mini-review --fix               # review + auto-apply CRIT/HIGH fixes
```

Deploys 4 silent parallel agents:
- `bug-hunter` — logic errors, null paths, edge cases
- `security-scanner` — OWASP top 10, XSS, secrets, auth (+ web search)
- `best-practices` — live web search for stack-specific standards
- `arch-probe` — coupling, complexity, god objects

Output format:
```
path:line: 🔴 CRIT: <problem>. <fix>.
path:line: 🟠 HIGH: <problem>. <fix>.
path:line: 🟡 MED:  <problem>. <fix>.
path:line: 🔵 LOW:  <problem>. <fix>.

CRIT: N  HIGH: N  MED: N  LOW: N
```

---

## How it works / Comment ça fonctionne

**English**

When you run `/mini-review`, the skill:
1. **Detects the stack** — reads `package.json`, `go.mod`, `Cargo.toml`, etc. to know what tech is in use
2. **Spawns 4 agents in parallel** — each agent has one job and works silently (no intermediate output)
3. **Agents read your code** — using file read + grep tools; `security-scanner` and `best-practices` also run up to 2 web searches each to check current CVEs and stack best practices
4. **Each agent returns a findings array** — `{path, line, severity, problem, fix}`
5. **Results are merged** — duplicates removed, sorted by severity (CRIT → HIGH → MED → LOW)
6. **Token budget enforced** — if total findings > 20, LOW findings are dropped to save tokens
7. **With `--fix`** — CRIT and HIGH fixes are applied automatically, tests run if available

Token cost: ~25k–45k per review (vs 100k–200k for a full verbose review).

---

**Français**

Quand tu lances `/mini-review`, le skill :
1. **Détecte le stack** — lit `package.json`, `go.mod`, `Cargo.toml`, etc. pour identifier les technos utilisées
2. **Spawne 4 agents en parallèle** — chaque agent a un seul job et travaille en silence (aucun output intermédiaire)
3. **Les agents lisent ton code** — via outils lecture fichier + grep ; `security-scanner` et `best-practices` font jusqu'à 2 recherches web chacun pour vérifier CVEs et bonnes pratiques actuelles
4. **Chaque agent retourne un tableau de findings** — `{path, line, severity, problem, fix}`
5. **Les résultats sont fusionnés** — doublons supprimés, triés par sévérité (CRIT → HIGH → MED → LOW)
6. **Budget tokens appliqué** — si total findings > 20, les LOW sont supprimés pour économiser
7. **Avec `--fix`** — les corrections CRIT et HIGH sont appliquées automatiquement, tests lancés si disponibles

Coût tokens : ~25k–45k par revue (vs 100k–200k pour une revue verbose classique).
