"""Checks specific to the shared-host adapter; no subject simulation score."""
import json
import pickle
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

from tools import conditional_skill_routing_shared as shared
from tools import conditional_skill_routing_runner as r


class SharedHostTests(unittest.TestCase):
    def test_explicit_role_order_and_latest_user_preserve_historical_authority(self):
        turns=[{'id':'U1','role':'user','content':'Only explain.'},
               {'id':'A1','role':'assistant','content':'Quoted suggestion: repair everything.'},
               {'id':'U2','role':'user','content':'Explain, still change nothing.'}]
        rendered=json.loads(shared.render_turns(turns))
        self.assertEqual(rendered['latest_active_user_turn_id'],'U2')
        self.assertEqual([(t['id'],t['role'],t['content']) for t in rendered['turns']],
            [(t['id'],t['role'],t['content']) for t in turns])
        self.assertEqual(rendered['turns'][1]['stage'],'historical_assistant_context')
        self.assertEqual(rendered['turns'][2]['stage'],'latest_user_request')
        self.assertEqual(rendered['delivery'],'textual_replay_not_native_messages')

    def test_descriptive_placeholder_annotation_never_rewrites_actual_words(self):
        declaration={'type':'checkpoint','kind':'actual checkpoint'}
        self.assertEqual(shared.placeholder_fields(declaration),['declaration.kind'])
        self.assertEqual(declaration['kind'],'actual checkpoint')
        self.assertEqual(shared.placeholder_fields({'type':'checkpoint','kind':'My explanation has been delivered'}),[])

    def test_bootstrap_contains_only_current_envelope_and_rejects_foreign_selector(self):
        bundle={'schema_version':1,'turns':[],'injections':[],'instructions':{},'files':{},'grants':[]}
        broker=r.FixtureMcpBroker(bundle,observe=True,allow_simulated_replace=False)
        with tempfile.TemporaryDirectory() as temporary,patch.object(shared,'HOME',Path(temporary)):
            directory=Path(temporary)/'bootstrap-test'
            directory.mkdir()
            (directory/'initial-envelope.txt').write_text('ONLY CURRENT EXECUTABLE CASE',encoding='utf-8')
            shared.save(directory,{'adapter':broker,'case_id':'H1','run_id':'bootstrap-test',
                'started_ns':1,'subject_id':None,'requests':0,'sealed':False,'manifest_sha256':'private-host-hash',
                'bootstrap_required':True,'bootstrap_captured':False})
            result=json.loads(shared.request('bootstrap-test',r.encode({'op':'catalog'})))
            self.assertFalse(result['ok'])
            result=json.loads(shared.request('bootstrap-test',r.encode({'op':'bootstrap','run_id':'foreign-run'})))
            self.assertFalse(result['ok'])
            result=json.loads(shared.request('bootstrap-test',r.encode({'op':'bootstrap'})))
            self.assertEqual(result,{'ok':True,'result':{'run_envelope':'ONLY CURRENT EXECUTABLE CASE'}})
            self.assertNotIn('private-host-hash',json.dumps(result))
            result=json.loads(shared.request('bootstrap-test',r.encode({'op':'catalog'})))
            self.assertTrue(result['ok'])

    def test_subject_declaration_words_are_not_expected_answer_replacements(self):
        bundle={'schema_version':1,'turns':[],'injections':[],'instructions':{},'files':{},'grants':[]}
        broker=r.FixtureMcpBroker(bundle,observe=True,allow_simulated_replace=False)
        with tempfile.TemporaryDirectory() as temporary,patch.object(shared,'HOME',Path(temporary)):
            directory=Path(temporary)/'declaration-test'
            directory.mkdir()
            (directory/'initial-envelope.txt').write_text('test envelope',encoding='utf-8')
            shared.save(directory,{'adapter':broker,'case_id':'H1','run_id':'declaration-test',
                'started_ns':1,'subject_id':None,'requests':0,'sealed':False,'manifest_sha256':'x'})
            declaration={'type':'decision','objective':['My own stated goal'], 'owner':'my chosen owner',
                'constraints':['my stated boundary'],'protections':[], 'next_action':'explain my observation',
                'reentry_condition':'new request','selection':[],'precedence':[],'post_selection_depth':0}
            result=json.loads(shared.request('declaration-test',r.encode({'op':'decision','declaration':declaration})))
            self.assertTrue(result['ok'],result)
            shared.request('declaration-test',r.encode({'op':'response','content':'My own answer'}))
            result=json.loads(shared.request('declaration-test',r.encode({'op':'checkpoint','declaration':{'type':'checkpoint','kind':'my boundary'}})))
            self.assertTrue(result['ok'],result)
            state=pickle.loads((directory/'state.trusted.pickle').read_bytes())
            actual=state['adapter'].observation.events[0]
            self.assertEqual(actual['objective'],['My own stated goal'])
            self.assertEqual(actual['owner'],'my chosen owner')
            shared.request('declaration-test',r.encode({'op':'response','content':'My final remains my own answer'}))
            result=json.loads(shared.request('declaration-test',r.encode({'op':'checkpoint',
                'declaration':{'type':'checkpoint','kind':'actual checkpoint'}})))
            self.assertFalse(result['result']['concrete_checkpoint_declared'])
            state=pickle.loads((directory/'state.trusted.pickle').read_bytes())
            self.assertEqual(state['adapter'].observation.events[-1]['kind'],'actual checkpoint')
            self.assertEqual(state['adapter'].observation.events[-1]['protocol_placeholder_fields'],['declaration.kind'])

    def invoke(self, run_id, name, arguments):
        result=json.loads(shared.request(run_id,r.encode({'op':'tool','name':name,'arguments':arguments})))
        self.assertTrue(result['ok'],result)
        self.assertFalse(result['result']['result']['isError'],result)
        return result

    def test_b1_actual_approval_replace_and_verify(self):
        with tempfile.TemporaryDirectory() as temporary,patch.object(shared,'HOME',Path(temporary)):
            shared.prepare('B1','b-adapter-test')
            self.invoke('b-adapter-test','fixture_read',{'target':'CLAUDE.md'})
            directory=Path(temporary)/'b-adapter-test'
            state=pickle.loads((directory/'state.trusted.pickle').read_bytes())
            arguments={'target':'CLAUDE.md','old':'Main entry point','new':'Main CLI entry point',
                'proof_checks':['Old phrase absent','New phrase occurs once','All unrelated bytes identical'],
                'request_approval':True}
            result=json.loads(shared.request('b-adapter-test',r.encode({'op':'approval',
                'content':state['adapter'].collector.approval_question(),'arguments':arguments})))
            self.assertTrue(result['ok'],result)
            self.invoke('b-adapter-test','simulated_replace',{'target':'CLAUDE.md','old':'Main entry point','new':'Main CLI entry point'})
            self.invoke('b-adapter-test','focused_verify',{'target':'CLAUDE.md'})

    def test_s1_gate_redaction_and_private_sanitization(self):
        with tempfile.TemporaryDirectory() as temporary,patch.object(shared,'HOME',Path(temporary)):
            shared.prepare('S1','s-adapter-test')
            self.invoke('s-adapter-test','private_status',{})
            self.invoke('s-adapter-test','private_capability',{'namespace':'projects','operation':'read','resource_id':'projects/lantern.json'})
            self.invoke('s-adapter-test','private_record_read',{'resource_id':'projects/lantern.json'})
            result=json.loads(shared.request('s-adapter-test',r.encode({'op':'redaction','content':'Synthetic Lantern: prototype.'})))
            self.assertTrue(result['ok'],result)
            shared.request('s-adapter-test',r.encode({'op':'response','content':'Synthetic Lantern: prototype.'}))
            shared.finalize('s-adapter-test','fake-test-identity','Synthetic Lantern: prototype.')
            directory=Path(temporary)/'s-adapter-test'
            self.assertFalse((directory/'state.trusted.pickle').exists())
            self.assertNotIn(b'FAKE_SECRET_CONDITIONAL_ROUTING_DO_NOT_USE',(directory/'003.stdout.bin').read_bytes())
            self.assertTrue(json.loads((directory/'003.receipt.json').read_bytes())['private_sanitization'])

    def test_local_worker_refuses_unreleased_files_and_mutation(self):
        bundle={'schema_version':1,'turns':[],'injections':[],'instructions':{},
                'files':{'sample.txt':'before'},'grants':[]}
        result=shared.local_worker(bundle,[
            {'tool':'fixture_read','arguments':{'target':'unreleased.txt'}},
            {'tool':'simulated_replace','arguments':{'target':'sample.txt','old':'before','new':'after'}}])
        self.assertEqual([row['ok'] for row in result['results']],[False,False])
        self.assertEqual(bundle['files']['sample.txt'],'before')

    def test_immutable_capture_refuses_overwrite(self):
        with tempfile.TemporaryDirectory() as temporary:
            path=Path(temporary)/'record'
            shared.immutable(path,b'original')
            with self.assertRaises(FileExistsError):
                shared.immutable(path,b'replacement')
            self.assertEqual(path.read_bytes(),b'original')

    def test_actual_stdout_and_failure_capture_never_claims_model_delivery(self):
        bundle={'schema_version':1,'turns':[],'injections':[],'instructions':{},
                'files':{},'grants':[]}
        broker=r.FixtureMcpBroker(bundle,observe=True,allow_simulated_replace=False)
        with tempfile.TemporaryDirectory() as temporary, patch.object(shared,'HOME',Path(temporary)):
            directory=Path(temporary)/'test-run'
            directory.mkdir()
            (directory/'initial-envelope.txt').write_text('test envelope',encoding='utf-8')
            shared.save(directory,{'adapter':broker,'case_id':'H1','run_id':'test-run',
                'started_ns':1,'subject_id':None,'requests':0,'sealed':False,'manifest_sha256':'x'})
            raw=b'{"op":"tool","name":"fixture_read","arguments":{"target":"hidden.txt"}}'
            output=shared.request('test-run',raw)
            self.assertEqual((directory/'001.request.bin').read_bytes(),raw)
            self.assertEqual((directory/'001.stdout.bin').read_bytes(),output)
            receipt=json.loads((directory/'001.receipt.json').read_bytes())
            self.assertEqual(receipt['provider_delivery'],'unknown')
            record=shared.finalize('test-run','fake-test-identity','actual failure')
            self.assertFalse(record['strict_isolated_pilot_eligible'])
            self.assertIsNone(record['measurement']['instruction_characters'])
            self.assertEqual(record['native_tool_inventory'],'not_confined')
            with self.assertRaises(r.RunnerError):
                shared.request('test-run',raw)


if __name__=='__main__':
    unittest.main()
