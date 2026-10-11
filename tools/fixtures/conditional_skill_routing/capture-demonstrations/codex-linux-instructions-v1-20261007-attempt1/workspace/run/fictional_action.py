import json,sys
from pathlib import Path
p=Path(__file__).parent
reads=[json.loads(line) for line in (p/'read-ledger.jsonl').read_text(encoding='utf-8').splitlines()]
covered=any(row['start']==0 and row['end'] >= 102 for row in reads)
if not covered:
 sys.stdout.write("fictional-action-refused: incomplete normative coverage\n");sys.exit(41)
(p/'action-completed.txt').write_text('synthetic only',encoding='utf-8')
sys.stdout.write("fictional-action-success: exact coverage established\n")
