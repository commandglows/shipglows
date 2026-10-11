
import base64,errno,importlib.util,json,os,pathlib,socket,sys
spec=importlib.util.spec_from_file_location("parent_transport","/relay-transport.py")
m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
bootstrap=m.decoded(m.read_frame(sys.stdin.buffer,8192))
assert set(bootstrap)=={"channel_key","body_b64","synthetic_parent_probe_path"}
key=base64.b64decode(bootstrap["channel_key"],validate=True)
body=base64.b64decode(bootstrap["body_b64"],validate=True)
interfaces=[line.split(":",1)[0].strip() for line in pathlib.Path("/proc/net/dev").read_text().splitlines()[2:]]
with socket.socket(socket.AF_INET,socket.SOCK_STREAM) as s:
 s.settimeout(.2);error=s.connect_ex(("203.0.113.1",9))
probe=pathlib.Path(bootstrap["synthetic_parent_probe_path"])
diagnostic={"interfaces":interfaces,"nonloopback_errno":error,"parent_sentinel_visible":probe.exists(),
 "mnt_visible":pathlib.Path("/mnt").exists(),"host_run_visible":pathlib.Path("/run").exists(),
 "environment_keys":sorted(os.environ),"credential_or_evaluator_environment_present":any(k in os.environ for k in ("OPENAI_API_KEY","PARENT_FAKE_CREDENTIAL","EVALUATOR_FAKE_STATE")),
 "mountinfo":pathlib.Path("/proc/self/mountinfo").read_text(),"relay_source_sha256":m.sha(pathlib.Path("/relay.py").read_bytes()),
 "transport_source_sha256":m.sha(pathlib.Path("/relay-transport.py").read_bytes())}
assert interfaces==["lo"] and error==errno.ENETUNREACH
assert not diagnostic["parent_sentinel_visible"] and not diagnostic["credential_or_evaluator_environment_present"]
assert not diagnostic["mnt_visible"] and not diagnostic["host_run_visible"]
sys.stdout.buffer.write(m.frame(m.packed({"type":"preflight","diagnostic":diagnostic})));sys.stdout.buffer.flush()
raw=m.make_request("relay-os-one","responses-fixture",body,key)
sys.stdout.buffer.write(m.frame(raw));sys.stdout.buffer.flush()
wire=m.read_frame(sys.stdin.buffer,8192)
response=m.read_response(wire,key,"relay-os-one")
payload=m.decoded(response["body"])
assert response["status"]==200 and base64.b64decode(payload["synthetic_echo_b64"],validate=True)==body
result={"type":"relay_complete","exact_request_body_sha256":m.sha(body),"exact_response_body_sha256":m.sha(response["body"]),
 "response_frame_sha256":m.sha(wire),"parent_response_hmac_verified":True,"mock_only":True}
sys.stdout.buffer.write(m.frame(m.packed(result)));sys.stdout.buffer.flush()
