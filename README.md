## How to Install
#### 1. Allow action to process script
```
cd aztec
chmod +x aztec.sh
```
#### Run Script
```
./aztec.sh
```
---
##### Note  
U must entry pk with (0x)  
U must entry L1 rpc, u can get on https://dashboard.alchemy.com/  
U must entry L1 beacon, u can request on https://drpc.org/ and search Beacon choose sepolia

---
### Check logs
````
aztec-node-node-1
````
#### To check block number
```
curl -s -X POST -H 'Content-Type: application/json' \
-d '{"jsonrpc":"2.0","method":"node_getL2Tips","params":[],"id":67}' \
http://localhost:8080 | jq -r ".result.proven.number"
```
#### To check proff
```
curl -s -X POST -H 'Content-Type: application/json' \
-d '{"jsonrpc":"2.0","method":"node_getArchiveSiblingPath","params":["URBlock","URBlock"],"id":67}' \
http://localhost:8080 | jq -r ".result"
```
Note
U must change "URBLOCK" with result ur block

