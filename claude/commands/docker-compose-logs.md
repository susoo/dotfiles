---
allowed-tools: Bash(docker compose logs:*)
description: Check docker compose logs
argument-hint: [n] [service]
---

# Context

!`docker compose logs -n ${1:-20} $2`