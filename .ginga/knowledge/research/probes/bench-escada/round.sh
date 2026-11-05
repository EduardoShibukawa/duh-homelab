#!/bin/bash
# uso: round.sh <rodada>   (2 lanes em paralelo: NVIDIA | OpenRouter+opencode-go)
B=$(cd "$(dirname "$0")" && pwd); r=$1
$B/lane.sh nv $r pi:nvidia/mistralai/mistral-large-4-1t-a52b pi:nvidia/meta/muse-glimmer-30b pi:nvidia/nvidia/nemotron-3.5-lightning-30b-a3b pi:nvidia/stepfun-ai/step-5-preview &
$B/lane.sh or $r pi:openrouter/recursive/flint-v1.0:free pi:openrouter/cohere/north-mini-code:free pi:openrouter/openrouter/free oc:opencode-go/iceman-contributor-free &
wait
