# Spec : Agents ContentFlowz Multi-LLM

> Creee le 2026-04-02 -- Source : analyse du cookbook OpenAI "Skills in API" + audit architecture ContentFlowz-lab

## Contexte

ContentFlowz-lab contient ~21 agents CrewAI dans `agents/`. Actuellement, tous utilisent un seul LLM (celui configure dans CrewAI par defaut). L'objectif est de rendre les agents compatibles avec plusieurs LLMs pour :

1. **Resilience** -- Ne pas dependre d'un seul fournisseur (pannes, changements de pricing, deprecations)
2. **Performance optimale** -- Certains LLMs sont meilleurs pour certaines taches (Claude pour le raisonnement ethique, GPT pour le code, Gemini pour la multimodalite)
3. **Compatibilite Codex** -- Permettre aux agents d'etre utilises via OpenAI Codex (environnement sandbox avec shell)
4. **Cout** -- Router les taches simples vers des modeles moins chers

## Architecture proposee

### 1. Configuration LLM par agent (niveau basique)

CrewAI supporte deja le parametre `llm` par agent. Chaque agent peut utiliser un LLM different :

```python
from crewai import Agent
from langchain_openai import ChatOpenAI
from langchain_anthropic import ChatAnthropic

# Agent SEO Research -> Claude (meilleur raisonnement analytique)
research_agent = Agent(
    role="SEO Research Analyst",
    llm=ChatAnthropic(model="claude-sonnet-4-6"),
    ...
)

# Agent Technical SEO -> GPT/Codex (meilleur pour le code/technique)
technical_agent = Agent(
    role="Technical SEO Analyst",
    llm=ChatOpenAI(model="gpt-5.3-codex"),
    ...
)

# Agent Psychology -> Claude (raisonnement ethique, nuance)
psychology_agent = Agent(
    role="Creator Psychologist",
    llm=ChatAnthropic(model="claude-opus-4-6"),
    ...
)
```

### 2. Fichier de configuration LLM centralise

Creer un fichier `config/llm_config.yaml` :

```yaml
# Configuration LLM par robot et par agent
# Chaque agent peut specifier son LLM prefere
# Le router peut override selon la disponibilite et le cout

defaults:
  provider: anthropic
  model: claude-sonnet-4-6
  temperature: 0.7
  max_tokens: 4096

agents:
  seo:
    research_analyst:
      provider: anthropic
      model: claude-sonnet-4-6
      reason: "Meilleur raisonnement analytique pour l'analyse concurrentielle"
    strategy_expert:
      provider: anthropic
      model: claude-sonnet-4-6
    copywriter:
      provider: anthropic
      model: claude-opus-4-6
      reason: "Qualite redactionnelle superieure, justifie le cout plus eleve"
    technical_analyst:
      provider: openai
      model: gpt-5.3-codex
      reason: "Meilleur pour l'analyse technique/code (robots.txt, sitemap, structured data)"
    marketing_analyst:
      provider: anthropic
      model: claude-sonnet-4-6
    editor:
      provider: anthropic
      model: claude-opus-4-6
      reason: "Revision finale necessite la meilleure qualite"

  newsletter:
    research_agent:
      provider: anthropic
      model: claude-sonnet-4-6
    writer_agent:
      provider: anthropic
      model: claude-opus-4-6

  psychology:
    creator_psychologist:
      provider: anthropic
      model: claude-opus-4-6
      reason: "Raisonnement ethique et nuance, critique pour la psychologie"
    audience_analyst:
      provider: anthropic
      model: claude-sonnet-4-6
    angle_strategist:
      provider: anthropic
      model: claude-sonnet-4-6

  social:
    platform_adapter:
      provider: openai
      model: gpt-4.1-mini
      reason: "Tache simple (adaptation de format), modele economique suffisant"

  short:
    short_form_writer:
      provider: openai
      model: gpt-4.1-mini
      reason: "Contenu court, modele economique suffisant"

fallbacks:
  anthropic: openai  # Si Claude est down, fallback sur GPT
  openai: anthropic  # Si GPT est down, fallback sur Claude
```

### 3. LLM Loader dans agents/shared/

Creer `agents/shared/llm_loader.py` :

```python
import yaml
from pathlib import Path
from langchain_openai import ChatOpenAI
from langchain_anthropic import ChatAnthropic

def load_llm_config():
    config_path = Path(__file__).parent.parent.parent / "config" / "llm_config.yaml"
    with open(config_path) as f:
        return yaml.safe_load(f)

def get_llm(robot: str, agent_name: str):
    """Retourne l'instance LLM configuree pour un agent donne."""
    config = load_llm_config()

    # Chercher config specifique a l'agent
    agent_config = config.get("agents", {}).get(robot, {}).get(agent_name)
    if not agent_config:
        agent_config = config["defaults"]

    provider = agent_config["provider"]
    model = agent_config["model"]
    temperature = agent_config.get("temperature", config["defaults"]["temperature"])
    max_tokens = agent_config.get("max_tokens", config["defaults"]["max_tokens"])

    if provider == "anthropic":
        return ChatAnthropic(model=model, temperature=temperature, max_tokens=max_tokens)
    elif provider == "openai":
        return ChatOpenAI(model=model, temperature=temperature, max_tokens=max_tokens)
    else:
        raise ValueError(f"Provider inconnu: {provider}")
```

### 4. Router intelligent (phase 2)

Creer `agents/shared/llm_router.py` qui choisit dynamiquement le LLM selon :
- La tache (code -> Codex, redaction -> Claude Opus, simple -> GPT Mini)
- Le cout cumule de la session (si budget depasse -> downgrade vers modeles moins chers)
- La disponibilite (si un provider est down -> fallback automatique)
- La latence (si une reponse est urgente -> modele plus rapide)

### 5. Compatibilite OpenAI Codex

Pour que les agents soient utilisables dans l'environnement Codex (sandbox shell) :
- Les prompts externalises en YAML (voir P0.1 du TASKS.md) sont un prerequis
- Le manifeste SKILL.md par agent permet a Codex de comprendre ce que fait chaque agent
- Les agents doivent pouvoir tourner en mode CLI (pas seulement via API FastAPI)
- Ajouter un script `run_agent.py` en CLI :
  ```bash
  python run_agent.py --robot seo --task research --topic "keyword research" --llm openai
  ```

## Plan d'implementation

### Phase 1 : Configuration (2-3h)
- [ ] Creer `config/llm_config.yaml` avec la config ci-dessus
- [ ] Creer `agents/shared/llm_loader.py`
- [ ] Modifier chaque `*_crew.py` pour utiliser `get_llm(robot, agent_name)` au lieu du LLM hardcode
- [ ] Tester chaque agent avec Claude ET GPT pour verifier que les prompts fonctionnent sur les deux

### Phase 2 : Router intelligent (4-6h)
- [ ] Creer `agents/shared/llm_router.py`
- [ ] Ajouter le tracking de cout par session
- [ ] Implementer le fallback automatique
- [ ] Ajouter des metriques de qualite par LLM/agent pour optimiser le routing

### Phase 3 : CLI mode + Codex (3-4h)
- [ ] Creer `run_agent.py` en CLI
- [ ] Creer un SKILL.md par robot pour la compatibilite Codex
- [ ] Tester l'execution dans un sandbox Codex
- [ ] Documenter les differences de comportement entre LLMs

## Dependances

- P0.1 (prompts YAML) doit etre fait avant -- les prompts hardcodes en f-strings ne sont pas portables entre LLMs
- P0.3 (tools coquilles vides) devrait etre fait avant -- les tools vides n'apportent rien quel que soit le LLM
- `langchain-anthropic` et `langchain-openai` doivent etre dans les dependances Python

## Risques

- **Drift de prompts** : un prompt optimise pour Claude peut donner des resultats mediocres sur GPT et vice-versa. Il faudra potentiellement maintenir des variantes de prompts par LLM.
- **Cout imprevu** : le routing vers des modeles plus chers (Opus) sans controle peut exploser les couts. Le budget tracking est essentiel.
- **Coherence de style** : si l'agent copywriter utilise Claude et l'editeur utilise GPT, le style peut etre incoherent. Garder le meme LLM au sein d'un pipeline de redaction.
