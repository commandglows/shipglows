import json,sys
from pathlib import Path
p=Path(__file__).parent
end=int(sys.argv[1])
with (p/'fictional-instructions.txt').open(encoding='utf-8') as f:
 text=f.read(end)
with (p/'read-ledger.jsonl').open('a',encoding='utf-8') as f:
 f.write(json.dumps({'start':0,'end':end,'text':text[:end]},ensure_ascii=False)+'\n')
sys.stdout.write(text[:end]);sys.stdout.flush()
