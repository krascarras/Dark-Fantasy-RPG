# DFR Native AI — Milestones and acceptance criteria

## M0 — Architecture lock
- Freeze system boundaries and data contracts.
- Confirm campaign IDs, character IDs, memory visibility and provenance rules.
- Keep the existing RPG source backed up and unchanged during prototype work.

## M1 — Durable memory core
- IndexedDB implementation for browser prototype; SQLite-compatible logical schema for Android migration.
- Atomic event + memory + relationship writes.
- Campaign isolation on every read and write.
- Character-private knowledge filtering.
- Importance 4–5 memories are protected from automatic pruning.
- Corrections supersede old records and create audit entries.
- Explicit deletion is audited.
- Export/import preserves IDs, timestamps, provenance and relationships.
- Automated tests cover save/reload and simulated interrupted writes.

Exit gate: all memory tests pass, including two campaigns with similarly named characters and deliberately conflicting facts.

## M2 — Language-model research prototype
- Train tokenizer from project-owned/licensed text corpus.
- Implement decoder-only Transformer with random initialization.
- Prove loss decreases on a small controlled corpus and generation is reproducible.
- Save/load checkpoints and resume training.
- No pretrained weights or pretrained model hidden in the pipeline.

Exit gate: reproducible training run and documented compute/memory requirements. Do not claim useful RPG dialogue until conversational evaluations support it.

## M3 — Conversation evaluation
- Dataset includes direct questions, follow-up questions, corrections, topic changes, emotional scenes, multi-party scenes and ambiguity.
- Score answer relevance, factual consistency, character voice, memory use, repetition and player-agency violations.
- Maintain a regression set based on Morningstar scenes.

Exit gate: the model answers the question asked, uses only permitted knowledge, and passes the player-agency checks at agreed thresholds.

## M4 — Character and world simulation
- NPC goals, schedules, intentions, relationships and local knowledge.
- Off-screen simulation is bounded and deterministic where state changes matter.
- NPCs can initiate events without forcing the player's response.

Exit gate: long-run campaign tests preserve location, knowledge and relationship consistency.

## M5 — Android integration
- On-device inference with no network dependency.
- Quantized model format and measured RAM/latency/battery use.
- Durable memory migration and crash recovery.

Exit gate: airplane-mode play, close/reopen persistence, import/export and extended campaign soak tests pass on target phone.

## Working rule
No milestone is considered complete because code exists or syntax passes. Each milestone needs executable tests, measured results and a documented list of limitations.
