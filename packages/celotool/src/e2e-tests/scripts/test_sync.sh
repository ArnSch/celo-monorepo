#!/bin/bash -u
# Usage: test_sync.sh <network> <syncmode> <namespace>

network=$1
syncmode=$2
namespace=$3

if [[ "$OSTYPE" == "linux-gnu" ]]; then
    aliassed=sed
elif [[ "$OSTYPE" == "darwin"* ]]; then
    aliassed=gsed
fi
# Loads some envs
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
if [[ -f $DIR/../../../.env.${network} ]]; then 
  source $DIR/../../../.env.${network}
else
  source $DIR/../../../.env
fi

forno_url=https://$env-forno.$CLUSTER_DOMAIN_NAME.org
node_pod="${network}-${namespace}-${syncmode}-node-0"

test_sync_blocknumber() {
  local target=$(curl -X POST -s --data '{"jsonrpc":"2.0","method":"eth_blockNumber","params":[],"id":1}' ${forno_url} -H 'Content-Type: application/json' | jq -r .result)
  target=$((target))
  target=${target//[$'\t\r\n ']}

  local current=$(kubectl -n ${namespace} exec -it ${node_pod} -- geth attach --exec 'eth.blockNumber' | $aliassed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")
  current=${current//[$'\t\r\n ']}

  local current_prev=$(kubectl -n ${namespace} exec -it ${node_pod} -- geth attach --exec 'eth.blockNumber' | $aliassed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")
  current_prev=${current_prev//[$'\t\r\n ']}
  synced=false
  syncing=true
  local loop_time="60"
  while [ "${synced}" != "true" ] && [ "${syncing}" == "true" ]; do
    sleep $loop_time
    current=$(kubectl -n ${namespace} exec -it ${node_pod} -- geth attach --exec 'eth.blockNumber' | $aliassed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")
    current=${current//[$'\t\r\n ']}
    if (( current >= target )); then
      echo "Full node synced at block ${target}"
      synced=true
    elif (( current <= current_prev )); then
      echo "Full node is not syncing. Stopped at block ${current}"
      syncing=false
      # exit 1
    else
      echo "Full node Syncing. Current block ${current}. Target block ${target}"
      current_prev="${current}"
    fi
  done
}

test_syn_syncing() {
  local target=$(kubectl -n $namespace exec -it ${node_pod} -- geth attach --exec 'eth.syncing' | grep highestBlock | cut -d' ' -f4 | tr -d ',' | $aliassed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")
  target=${target//[$'\t\r\n ']}

  local current=$(kubectl -n $namespace exec -it ${node_pod} -- geth attach --exec 'eth.syncing' | grep currentBlock | cut -d' ' -f4 | tr -d ',' | $aliassed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")
  current=${current//[$'\t\r\n ']}
  
  local current_prev=$(kubectl -n $namespace exec -it ${node_pod} -- geth attach --exec 'eth.syncing' | grep currentBlock | cut -d' ' -f4 | tr -d ',' | $aliassed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")
  current_prev=${current_prev//[$'\t\r\n ']}

  synced=false
  syncing=true
  local loop_time="60"
  while [ "$synced" != "true" ] && [ "$syncing" == "true" ]; do
    sleep $loop_time
    current=$(kubectl -n "${namespace}" exec -it "${node_pod}" -- geth attach --exec 'eth.syncing' | grep currentBlock | cut -d' ' -f4 | tr -d ',' | $aliassed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")
    current=${current//[$'\t\r\n ']}
    
    if (( current >= target )); then
      echo "Full node synced at block ${target}"
      synced=true
    elif (( current <= current_prev )); then
      echo "Full node is not syncing. Stopped at block ${current} <= ${current_prev}"
      syncing=false
      # exit 1
    else
      echo "Full node Syncing. Current block ${current}. Target block ${target}"
      current_prev="${current}"
    fi
  done
}

#kubectl port-forward -n $namespace ${network}-${namespace}-${syncmode}-node-0 8545 & >/dev/null 2>&1
# Lets wait until pod starts
while [[ $(kubectl get pods "${node_pod}" -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 10; done

case ${syncmode} in
  full)
    test_syn_syncing
    ;;
  fast)
    test_syn_syncing
    ;;
  light)
    test_syn_syncing
    ;;
  lightest)
    test_syn_syncing
    ;;
  *)
    echo "${syncmode} incorrect. Valid values: [full, fast, light, lightest]"
esac
