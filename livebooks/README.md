# Livebook Companions

These notebooks are the interactive entry points for the `jido_class` series.

Open them from Livebook while the repository is checked out locally. Each notebook uses a local path dependency back to its lesson directory, so the examples stay tied to the code in this repo instead of drifting into copy-pasted snippets.

## Setup

From the repo root:

```bash
./scripts/install_livebook.sh
./scripts/livebook.sh server livebooks
```

The wrapper script adds `~/.mix/escripts` and asdf shims to `PATH`, so it works even when `livebook` is not already available as a bare shell command.

## Notebooks

- [01_founder_bootstrap.livemd](./01_founder_bootstrap.livemd) for pure `cmd/2`
- [02_founder_runtime.livemd](./02_founder_runtime.livemd) for `AgentServer` and signal routing
- [03_backoffice_plugin.livemd](./03_backoffice_plugin.livemd) for plugin composition
- [04_spawn_backoffice_and_recruiter.livemd](./04_spawn_backoffice_and_recruiter.livemd) for spawned support hierarchies
- [05_hire_a_cto.livemd](./05_hire_a_cto.livemd) for domain ownership and executive summaries
- [06_engineering_org.livemd](./06_engineering_org.livemd) for fan-out and aggregation
- [07_product_design_qa_rhythm.livemd](./07_product_design_qa_rhythm.livemd) for recurring cadence loops
- [08_ai_studio_mode.livemd](./08_ai_studio_mode.livemd) for runtime AI boundaries with a fake adapter

## Opening The Series

Then open any notebook from the `livebooks/` directory.
