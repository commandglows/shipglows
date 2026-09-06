"""Read only the authority branches explicitly selected by a consumer test."""
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]


def selected_authority(*branches: str) -> str:
    refs = ROOT / 'skills/references'
    core = (refs / 'mutation-plan-approval.md').read_text(encoding='utf-8')
    selected = [core]
    for branch in branches:
        if branch not in ('mutation-auto-authority', 'mutation-git-authority',
                          'mutation-approval-pressure-scenarios'):
            raise ValueError(f'Unknown authority branch: {branch}')
        if f'`{branch}.md`' not in core:
            raise AssertionError(f'Missing authority selector: {branch}')
        selected.append((refs / f'{branch}.md').read_text(encoding='utf-8'))
    return '\n'.join(selected)
