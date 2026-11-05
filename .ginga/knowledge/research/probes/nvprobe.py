import json,os,sys,time,urllib.request,concurrent.futures as cf
k=json.load(open(os.path.expanduser('~/.pi/agent/auth.json')))['nvidia']['key']
tools=[{"type":"function","function":{"name":"run_bash","description":"Run a shell command","parameters":{"type":"object","properties":{"cmd":{"type":"string"}},"required":["cmd"]}}}]
def probe(m):
    body={"model":m,"messages":[{"role":"user","content":"Use the run_bash tool to run: echo ok"}],"tools":tools,"tool_choice":"auto","max_tokens":512,"temperature":0}
    t=time.time()
    try:
        r=urllib.request.Request('https://integrate.api.nvidia.com/v1/chat/completions',json.dumps(body).encode(),{'Authorization':'Bearer '+k,'Content-Type':'application/json'})
        j=json.load(urllib.request.urlopen(r,timeout=90))
        msg=j['choices'][0]['message']; tc=msg.get('tool_calls')
        return m,round(time.time()-t,1),'TOOLCALL '+json.dumps(tc[0]['function']) if tc else 'NOTOOL '+str(msg.get('content'))[:80]
    except Exception as e:
        return m,round(time.time()-t,1),'ERR '+str(e)[:100]
ms=sys.argv[1:]
with cf.ThreadPoolExecutor(8) as ex:
    for r in ex.map(probe,ms): print(*r,sep=' | ',flush=True)
