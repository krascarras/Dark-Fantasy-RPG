PRAGMA foreign_keys = ON;

CREATE TABLE IF NOT EXISTS campaigns (
  campaign_id TEXT PRIMARY KEY,
  name TEXT NOT NULL,
  scenario_id TEXT NOT NULL,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  schema_version INTEGER NOT NULL DEFAULT 1
);

CREATE TABLE IF NOT EXISTS characters (
  campaign_id TEXT NOT NULL,
  character_id TEXT NOT NULL,
  display_name TEXT NOT NULL,
  canonical_name TEXT NOT NULL,
  persona_json TEXT NOT NULL DEFAULT '{}',
  created_at TEXT NOT NULL,
  PRIMARY KEY (campaign_id, character_id),
  FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS events (
  campaign_id TEXT NOT NULL,
  event_id TEXT NOT NULL,
  event_type TEXT NOT NULL,
  occurred_at TEXT NOT NULL,
  location_id TEXT,
  summary TEXT NOT NULL,
  source_type TEXT NOT NULL,
  source_id TEXT,
  importance INTEGER NOT NULL DEFAULT 3 CHECK (importance BETWEEN 1 AND 5),
  metadata_json TEXT NOT NULL DEFAULT '{}',
  PRIMARY KEY (campaign_id, event_id),
  FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS memories (
  campaign_id TEXT NOT NULL,
  memory_id TEXT NOT NULL,
  memory_type TEXT NOT NULL CHECK (memory_type IN ('episodic','semantic','relationship','personal','world','working')),
  owner_character_id TEXT,
  subject_character_id TEXT,
  content TEXT NOT NULL,
  fact_status TEXT NOT NULL DEFAULT 'confirmed' CHECK (fact_status IN ('confirmed','belief','rumour','hypothesis')),
  visibility TEXT NOT NULL DEFAULT 'private' CHECK (visibility IN ('private','shared','campaign')),
  source_type TEXT NOT NULL,
  source_id TEXT,
  event_id TEXT,
  importance INTEGER NOT NULL DEFAULT 3 CHECK (importance BETWEEN 1 AND 5),
  confidence REAL NOT NULL DEFAULT 1.0 CHECK (confidence BETWEEN 0.0 AND 1.0),
  pinned INTEGER NOT NULL DEFAULT 0 CHECK (pinned IN (0,1)),
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  supersedes_memory_id TEXT,
  deleted_at TEXT,
  metadata_json TEXT NOT NULL DEFAULT '{}',
  PRIMARY KEY (campaign_id, memory_id),
  FOREIGN KEY (campaign_id, owner_character_id) REFERENCES characters(campaign_id, character_id),
  FOREIGN KEY (campaign_id, subject_character_id) REFERENCES characters(campaign_id, character_id),
  FOREIGN KEY (campaign_id, event_id) REFERENCES events(campaign_id, event_id),
  FOREIGN KEY (campaign_id, supersedes_memory_id) REFERENCES memories(campaign_id, memory_id)
);

CREATE TABLE IF NOT EXISTS memory_witnesses (
  campaign_id TEXT NOT NULL,
  memory_id TEXT NOT NULL,
  character_id TEXT NOT NULL,
  witness_basis TEXT NOT NULL CHECK (witness_basis IN ('witnessed','told','discovered','inferred')),
  recorded_at TEXT NOT NULL,
  PRIMARY KEY (campaign_id, memory_id, character_id),
  FOREIGN KEY (campaign_id, memory_id) REFERENCES memories(campaign_id, memory_id) ON DELETE CASCADE,
  FOREIGN KEY (campaign_id, character_id) REFERENCES characters(campaign_id, character_id)
);

CREATE TABLE IF NOT EXISTS relationships (
  campaign_id TEXT NOT NULL,
  relationship_id TEXT NOT NULL,
  character_a_id TEXT NOT NULL,
  character_b_id TEXT NOT NULL,
  affection REAL NOT NULL DEFAULT 0,
  trust REAL NOT NULL DEFAULT 0,
  current_state_json TEXT NOT NULL DEFAULT '{}',
  updated_at TEXT NOT NULL,
  PRIMARY KEY (campaign_id, relationship_id),
  UNIQUE (campaign_id, character_a_id, character_b_id),
  FOREIGN KEY (campaign_id, character_a_id) REFERENCES characters(campaign_id, character_id),
  FOREIGN KEY (campaign_id, character_b_id) REFERENCES characters(campaign_id, character_id),
  CHECK (character_a_id <> character_b_id)
);

CREATE TABLE IF NOT EXISTS relationship_history (
  campaign_id TEXT NOT NULL,
  change_id TEXT NOT NULL,
  relationship_id TEXT NOT NULL,
  event_id TEXT,
  affection_delta REAL NOT NULL DEFAULT 0,
  trust_delta REAL NOT NULL DEFAULT 0,
  reason TEXT NOT NULL,
  source_type TEXT NOT NULL,
  created_at TEXT NOT NULL,
  PRIMARY KEY (campaign_id, change_id),
  FOREIGN KEY (campaign_id, relationship_id) REFERENCES relationships(campaign_id, relationship_id),
  FOREIGN KEY (campaign_id, event_id) REFERENCES events(campaign_id, event_id)
);

CREATE TABLE IF NOT EXISTS conversation_turns (
  campaign_id TEXT NOT NULL,
  turn_id TEXT NOT NULL,
  scene_id TEXT NOT NULL,
  speaker_character_id TEXT,
  addressed_character_id TEXT,
  content TEXT NOT NULL,
  turn_index INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  metadata_json TEXT NOT NULL DEFAULT '{}',
  PRIMARY KEY (campaign_id, turn_id),
  UNIQUE (campaign_id, scene_id, turn_index),
  FOREIGN KEY (campaign_id, speaker_character_id) REFERENCES characters(campaign_id, character_id),
  FOREIGN KEY (campaign_id, addressed_character_id) REFERENCES characters(campaign_id, character_id)
);

CREATE TABLE IF NOT EXISTS memory_links (
  campaign_id TEXT NOT NULL,
  from_memory_id TEXT NOT NULL,
  to_memory_id TEXT NOT NULL,
  link_type TEXT NOT NULL,
  PRIMARY KEY (campaign_id, from_memory_id, to_memory_id, link_type),
  FOREIGN KEY (campaign_id, from_memory_id) REFERENCES memories(campaign_id, memory_id),
  FOREIGN KEY (campaign_id, to_memory_id) REFERENCES memories(campaign_id, memory_id),
  CHECK (from_memory_id <> to_memory_id)
);

CREATE TABLE IF NOT EXISTS audit_log (
  campaign_id TEXT NOT NULL,
  audit_id TEXT NOT NULL,
  entity_type TEXT NOT NULL,
  entity_id TEXT NOT NULL,
  operation TEXT NOT NULL CHECK (operation IN ('create','update','correct','delete','restore','relationship_change','memory_retrieved')),
  actor_id TEXT,
  reason TEXT,
  before_json TEXT,
  after_json TEXT,
  created_at TEXT NOT NULL,
  PRIMARY KEY (campaign_id, audit_id),
  FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id) ON DELETE CASCADE
);

CREATE INDEX IF NOT EXISTS idx_memories_campaign_owner_type ON memories(campaign_id, owner_character_id, memory_type);
CREATE INDEX IF NOT EXISTS idx_memories_campaign_importance ON memories(campaign_id, importance DESC, pinned DESC);
CREATE INDEX IF NOT EXISTS idx_memories_campaign_subject ON memories(campaign_id, subject_character_id);
CREATE INDEX IF NOT EXISTS idx_memories_campaign_event ON memories(campaign_id, event_id);
CREATE INDEX IF NOT EXISTS idx_events_campaign_time ON events(campaign_id, occurred_at);
CREATE INDEX IF NOT EXISTS idx_turns_campaign_scene ON conversation_turns(campaign_id, scene_id, turn_index);
CREATE INDEX IF NOT EXISTS idx_audit_campaign_entity ON audit_log(campaign_id, entity_type, entity_id, created_at);
