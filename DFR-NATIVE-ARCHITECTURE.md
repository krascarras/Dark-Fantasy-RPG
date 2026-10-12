# DFR Native AI — Architecture v1.0

Status: foundational design. This document is a specification, not a claim that the systems have already been implemented.

## Project commitments

- Train and own a language model from randomly initialized weights. No pretrained model weights, Qwen, Gemma, hosted inference API, or separate AI service in the finished game.
- Zero-cost development and training target. Compute availability is a constraint; never silently substitute pretrained weights or paid services.
- Phone-first development workflow. Android is the primary authoring and review device; occasional external compute may be used only when freely available. PC use is optional, not a daily requirement.
- Initial model target: medium-scale design, implemented progressively. Parameter count is not fixed until tokenizer, context length, training data, memory footprint, and Android inference benchmarks are measured.
- Final target: on-device, offline Android inference.
- Important memories persist until explicitly corrected or deleted.
- Conversational intelligence and autonomous world simulation have equal priority.
- DFR, not the language model, remains authoritative for player actions, world state, inventory, relationships, time, location, and game rules. The model proposes dialogue and actions; deterministic validators approve state changes.
- Never generate Shane's thoughts, words, feelings, decisions, or actions on the player's behalf.

## System boundaries

1. **Tokenizer and language model** — text tokenization, neural next-token generation, sampling, context handling. Trained from scratch.
2. **Conversation orchestrator** — identifies the current speaker, gathers context, retrieves memories, builds a bounded prompt, calls inference, validates output.
3. **Character agents** — stable persona, goals, beliefs, knowledge boundaries, emotional state, routines, and independent intentions. These are data and policies around the model, not separate pretrained models.
4. **Memory service** — durable episodic, semantic, relationship, personal, world, and working memory. Independent of model weights and version.
5. **World simulator** — time, locations, schedules, weather, events, and off-screen consequences.
6. **Authoritative game state** — campaign state and deterministic rules. Model output cannot directly mutate it.
7. **Android client/runtime** — offline storage, model loading, inference, UI, import/export and diagnostics.

## Memory design

Memory is campaign-scoped and character-scoped. Every record has a stable ID, campaign ID, creation time, source/provenance, confidence, importance, visibility, and optional participants/location.

Memory classes:
- **Episodic:** an event that happened; who witnessed it and where.
- **Semantic:** a fact or learned piece of knowledge, with source and confidence.
- **Relationship:** a dated relationship change and its cause; current values are validated state, not free-form prose.
- **Personal:** a character's own experience, belief, intention, or private reflection.
- **World:** durable world facts and changes.
- **Working:** short-lived current-scene context; never the sole home of an important fact.

Important memory policy:
- Importance 4 or 5 is protected from automatic pruning.
- No automatic deletion or fading of protected memories.
- Corrections create an audit entry and supersede the prior record; they do not silently rewrite history.
- Deletion is explicit and audited.
- Knowledge is not shared automatically: a character can recall only memories they witnessed, were told, or legitimately discovered.
- Rumour, belief, and confirmed fact are distinct.
- Conversation transcripts are not automatically copied into every NPC's private knowledge.

## Persistence

Use SQLite as the canonical durable store in a future native Android runtime. During the browser/PWA phase, use IndexedDB with the same logical schema. Do not use localStorage for campaign memory.

Logical tables / object stores:
- campaigns
- characters
- memories
- events
- relationships
- conversation_turns
- world_facts
- memory_links
- audit_log
- schema_meta

Every query must include campaign_id. Character-private recall must additionally filter by owner_character_id and visibility/provenance. Index by campaign, owner, type, importance, event time, and entity references.

## Memory retrieval

Retrieval is deterministic and explainable before any vector search is introduced:
1. Enforce campaign and knowledge-access filters.
2. Retrieve pinned/important memories relevant to the active character and scene.
3. Rank remaining candidates by entity match, topic match, recency, importance, confidence, and direct relevance.
4. Return provenance with every memory.
5. Keep retrieved memory within a measured token budget.
6. Record which memories were supplied to a generation, enabling debugging.

A later locally computed embedding index may improve semantic recall, but it must never bypass campaign or knowledge permissions.

## Language-model plan

Do not pick a model size based on a label such as “medium”. First implement:
- versioned tokenizer and vocabulary;
- small decoder-only Transformer reference implementation with random initialization;
- deterministic training/evaluation pipeline;
- checkpoint format and reproducible seeds;
- text-generation and perplexity evaluation;
- instruction/conversation fine-tuning using data we have rights to use;
- quantisation and Android inference benchmarks.

Scale model width, depth, context length and vocabulary only after measuring memory and compute. A medium target is an ambition, not a claim that free phone hardware can train it. Training from scratch requires substantial clean text and compute; free compute may be intermittent and may impose usage limits. No external service is required at runtime.

## Output contract

The model returns structured proposals, not direct state mutations:
- speaker
- dialogue text
- optional visible action
- addressed character(s)
- intent
- claimed knowledge references
- proposed world/relationship effects (optional)

The orchestrator validates speaker presence, knowledge provenance, player agency, scene continuity, action formatting, and allowed state transitions. Invalid output is rejected or regenerated with a bounded retry policy.

## Testing gates

1. **Memory:** campaign isolation, private knowledge, witness rules, permanent-memory retention, correction/deletion audit, relationship history, save/reload.
2. **Conversation:** direct question answering, follow-up resolution, topic changes, ambiguity clarification, emotional conversations, multi-NPC turn-taking, non-repetition.
3. **World:** NPC location/presence, schedules, off-screen events, time progression, no teleportation.
4. **Player agency:** zero authored actions/thoughts/dialogue for Shane.
5. **Long-run:** hundreds of turns, restart/reload, import/export, model-version upgrade without memory loss.
6. **Android:** offline inference, cold start, memory use, thermal behaviour, battery use, crash recovery.

## First implementation milestone

Build and independently test the memory service before training the language model. Keep it separate from the current RPG UI until its persistence, isolation, provenance, and correction behaviour pass. Only then connect it to the conversation orchestrator.
