---
name: mini-review
description: Silent multi-agent code review. Finds bugs, security issues, and best-practice violations. Output caveman-compressed, one line per finding, severity-tagged. No prose, no summaries. Use when user says /mini-review, wants a quick thorough review, wants silent agents to audit code, or wants to catch bugs before pushing.
---

# mini-review

4 agents silencieux en parallèle → chacun un job → findings fusionnés → output caveman → corrige ou reporte.

## Quick start

```
/mini-review              # revue du diff courant
/mini-review src/auth/    # revue d'un chemin précis
/mini-review --fix        # revue + applique corrections CRIT/HIGH
```

## Agents déployés (silencieux, parallèles)

Spawn 4 agents via Agent tool — aucun output intermédiaire visible.

| Agent | Job | Outils |
|---|---|---|
| `bug-hunter` | Erreurs logiques, null paths, edge cases, off-by-ones, exceptions non gérées | Read, Grep, Glob |
| `security-scanner` | OWASP top 10, injections, auth, secrets hardcodés, XSS, CSRF | Read, Grep, WebSearch |
| `best-practices` | Standards stack fetchés live sur le web — compare code au consensus actuel | WebSearch, Read |
| `arch-probe` | Couplage, complexité cyclomatique, modules trop larges, abstractions prématurées | Read, Grep, Glob |

## Format de sortie

Aucune louange. Aucun résumé. Aucune phrase d'intro. Juste les findings.

```
path:line: 🔴 CRIT: <problème>. <correctif>.
path:line: 🟠 HIGH: <problème>. <correctif>.
path:line: 🟡 MED: <problème>. <correctif>.
path:line: 🔵 LOW: <problème>. <correctif>.

CRIT: N  HIGH: N  MED: N  LOW: N
```

## Processus

1. Détecter stack (package.json, go.mod, Cargo.toml, requirements.txt…)
2. Identifier cible : diff courant (`git diff HEAD`) ou chemin passé en arg
3. Spawner 4 agents en parallèle — tous promptés en caveman
4. Chaque agent retourne tableau findings `{path, line, severity, problem, fix}`
5. Merger → dédupliquer (même path+line) → trier sévérité DESC
6. Si > 20 findings total : supprimer LOW
7. Afficher findings format ci-dessus
8. Si `--fix` : appliquer CRIT + HIGH, lancer tests si disponibles, reporter résultat

## Budget tokens

- Agents travaillent en caveman interne (aucune réflexion verbose)
- **Max 2 WebSearch par agent** (`best-practices` + `security-scanner` uniquement)
- Agents Read/Grep/Glob uniquement — pas de Write sauf si `--fix`
- Aucun output intermédiaire remonté au thread principal
- Si > 20 findings : LOW supprimés pour économiser

## Prompts agents (internes)

### bug-hunter
```
Caveman mode. Review this code for logic errors, null paths, edge cases,
off-by-ones, unhandled exceptions. Return findings array only:
{path, line, severity (CRIT/HIGH/MED/LOW), problem, fix}.
No prose. No praise.
[CODE]
```

### security-scanner
```
Caveman mode. Scan for OWASP top 10: injection, broken auth, sensitive data
exposure, XXE, broken access control, security misconfiguration, XSS,
insecure deserialization, known vuln components, insufficient logging.
Also: hardcoded secrets, missing input validation, unsafe deps.
You may run max 2 WebSearch to verify current CVEs or known vuln patterns.
Return findings array: {path, line, severity, problem, fix}. No prose.
[CODE]
```

### best-practices
```
Caveman mode. Stack: [DETECTED_STACK].
Run max 2 WebSearch to find current best practices for this stack (year 2025+).
Compare code against findings. Return violations array:
{path, line, severity, problem, fix}. No prose. Actionable only.
[CODE]
```

### arch-probe
```
Caveman mode. Analyze: cyclomatic complexity, coupling, module depth,
premature abstractions, god objects, feature envy, dead code.
Read CONTEXT.md if present. Return findings array:
{path, line, severity, problem, fix}. No prose.
[CODE]
```

## Skills fused

- `caveman` → compression output ~75% tokens
- `code-review` → patterns revue de base
- `security-review` → couche sécurité OWASP
- `diagnose` → méthodologie bug-hunting
- `verify` → (mode --fix) validation après correction
