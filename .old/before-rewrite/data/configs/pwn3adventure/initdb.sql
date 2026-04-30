DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS teams CASCADE;
DROP TABLE IF EXISTS team_state CASCADE;
DROP TABLE IF EXISTS characters CASCADE;
DROP TABLE IF EXISTS char_items CASCADE;
DROP TABLE IF EXISTS char_slots CASCADE;
DROP TABLE IF EXISTS char_quests CASCADE;
DROP TABLE IF EXISTS char_pickups CASCADE;
DROP TABLE IF EXISTS names CASCADE;
DROP TABLE IF EXISTS info CASCADE;

CREATE TABLE users (id SERIAL, team INTEGER, name VARCHAR(32), canonical_name VARCHAR(32), password VARCHAR(96), user_type INTEGER);
CREATE TABLE teams (id SERIAL, name VARCHAR(32), canonical_name VARCHAR(32), hash VARCHAR(72), admin INTEGER);
CREATE TABLE team_state (team_id INTEGER, state_id INTEGER, val INTEGER);
CREATE TABLE characters (id SERIAL, user_id INTEGER, name VARCHAR(32), canonical_name VARCHAR(32), avatar INTEGER, color1 INTEGER, color2 INTEGER, color3 INTEGER, color4 INTEGER, location INTEGER, active_slot INTEGER, active_quest INTEGER);
CREATE TABLE char_items (char_id INTEGER, item_id INTEGER, item_count INTEGER, loaded_ammo INTEGER);
CREATE TABLE char_slots (char_id INTEGER, slot INTEGER, item_id INTEGER);
CREATE TABLE char_quests (char_id INTEGER, quest_id INTEGER, state_id INTEGER, kills INTEGER);
CREATE TABLE char_pickups (char_id INTEGER, state_id INTEGER);
CREATE TABLE names (id SERIAL, name VARCHAR(32));
CREATE TABLE info (name VARCHAR(32), contents VARCHAR(256));
CREATE UNIQUE INDEX idx_user_names ON users(canonical_name);
CREATE UNIQUE INDEX idx_char_names ON characters(canonical_name);
CREATE INDEX idx_user_chars ON characters(user_id);
CREATE UNIQUE INDEX idx_team_names ON teams(canonical_name);
CREATE UNIQUE INDEX idx_team_hashes ON teams(hash);
CREATE INDEX idx_team_members ON users(team);
CREATE INDEX idx_team_state ON team_state(team_id);
CREATE INDEX idx_char_items ON char_items(char_id);
CREATE INDEX idx_char_quests ON char_quests(char_id);
CREATE INDEX idx_char_pickups ON char_pickups(char_id);
CREATE INDEX idx_char_slots ON char_slots(char_id);
CREATE UNIQUE INDEX idx_names ON names(name);
CREATE UNIQUE INDEX idx_info ON info(name);

INSERT INTO info(name, contents) VALUES ('login_title', 'Custom Server');
INSERT INTO info(name, contents) VALUES ('login_text', 'This is a custom server, refer to the documentation for setup instructions.');

-- Create gameserver account
-- Useranme: GameServer
-- Password: PasswordForGameServer!!!
INSERT INTO teams(name, canonical_name, hash, admin) VALUES ('server_c9b168294ec96242', 'serverc9b168294ec96242', '2d0f4275153657463ab28b37456836bd', 0);
INSERT INTO users(team, name, canonical_name, password, user_type) VALUES (1, 'server_c9b168294ec96242', 'serverc9b168294ec96242', 'bd533dc45e0a74bf:333b5fdea32223bdd6bc7cebbb7900e4dab6f26437eedd1073de36af3c541e7b', 2);

-- Create admin team
-- Join with the hash db1e797da308f027c876c61786682f3b
INSERT INTO teams(name, canonical_name, hash, admin) VALUES ('WeAreRoot', 'weareroot', 'db1e797da308f027c876c61786682f3b', 1);
