import json,sys
from pathlib import Path
state=json.loads(Path('/work/run/synthetic-project/fictional_delivery_state.json').read_bytes())
sys.stdout.write('CSR_COMPACT_GUARD_ALLOW_01601: current exact diagnostic delivery proved.\n' if state['valid'] is True else 'CSR_COMPACT_GUARD_DENY_01601: delivery invalid after compaction; exact reread required.\n')
sys.stdout.flush()
sys.exit(0 if state['valid'] is True else 41)
