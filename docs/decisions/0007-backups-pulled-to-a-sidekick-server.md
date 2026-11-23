# 0007: Backups encrypted on the node, pulled by a small sidekick server

- **Status:** accepted – takes effect with the production node (phase 7)
- **Date:** 2026-11-23
- **Decision-maker:** DimiJonas

## Context and problem

Today the server makes the nightly backup itself – a database dump and every original photo,
encrypted with age to a public key, so the server can't read its own backups – and the admin
laptop pulls the files with a read-only key. That works, but it depends on remembering to pull,
it fills the laptop's disk, and the server keeps every encrypted photo a second time, forever.
A small older server is available besides the production node. Where are the backups made, and
where do they go?

## Decision drivers

- the backups out of the node's reach: an attacker on the node can't change or delete the copies
  (threat T-46)
- no plain data leaving the node; the private key only with the admin (T-45)
- no manual step that can be forgotten; failures noticed (T-47)
- disk space on the node and on the laptop
- the restore test keeps working without the private key on any server

## Considered options

1. As today: encrypted on the node, pulled by the admin laptop by hand
2. Encrypted on the node, pulled automatically by a separate sidekick server with a read-only key;
   the laptop pulls from the sidekick when convenient
3. Made by the sidekick server: it connects to the database and reads the photos over the network,
   then encrypts them itself

## Decision

**Chosen option: 2.** The backup job on the node writes age-encrypted files, as today. The
sidekick – the small older server, **not** a cluster node – pulls them every night over SSH with a
key that can only read the backup folder. It keeps the versions (dumps: 7 days plus one per month
for 12 months; photos: append-only, never removed). The node keeps only the last few days, enough
to bridge a night the sidekick misses. The laptop copies from the sidekick when convenient. The
monthly restore test stays on the node, where the plain dump exists for a moment before it's
encrypted, so no server ever needs the private key.

**Reasoning:** Only ciphertext moves, so the sidekick holds nothing readable and needs no access
to the database. The pull happens without anyone having to remember it, and the history no longer
fills the laptop's disk or doubles the photos on the node. Letting the sidekick make the backups
itself would send plain data over the network and give a second machine the database credentials.
Today's way is not bad, but it depends on a manual step. The change only becomes possible once the
production node exists, so the decision is recorded now and carried out in phase 7.

## Consequences

- Good: the node's disk no longer grows with a second, encrypted copy of every photo
  ([budget](../resource-budget.md#disk)).
- Good: a compromised node can't reach the sidekick's copies – the sidekick connects to the node,
  never the other way.
- Good: the same pull pattern as today (R-43, R-44), only automatic.
- Bad: a second machine to keep patched and hardened – dk-srv's hardening, SSH by key only, no
  services open to the internet.
- Bad: the read-only key on the sidekick can read the node's backup folder – ciphertext only, so
  accepted.
- Bad: if the sidekick misses more nights than the node keeps, copies are missing on the sidekick.
  Two guards: a failed or missing pull raises an alert (R-45), and the restore test's photo check
  (every photo has its encrypted copy) moves to the sidekick, which compares its copy with the
  node's list of photos; a gap is closed by letting the backup job encrypt the missing photos
  again.
- Until phase 7 the laptop pulls as today.
- Revisit when: object storage off the node is set up (phase 8 or a second node) – a bucket with
  write-once retention could replace the sidekick.

## Confirmation

- On the node, the pull key can only read the backup folder (a write attempt with it fails).
- The node can't log in to the sidekick (no key, no open port).
- A skipped pull raises an alert the next morning (tested once in phase 7).
- The monthly restore test still passes.

## The options in detail

### 1. As today: the laptop pulls by hand

- For: nothing new to run; the copies are on a device that is usually offline.
- Against: forgotten pulls mean old backups; the laptop's disk fills; the node keeps everything
  forever.

### 2. Encrypted on the node, pulled by the sidekick

- For: automatic; only ciphertext moves; the node's copies can be short-lived.
- Against: a second server to maintain; the sidekick must report its pulls.

### 3. Made by the sidekick

- For: the node holds no backups at all.
- Against: plain data over the network; the sidekick needs database credentials and access to
  the photos – a second machine that can read everything; the restore test would need the data
  in plain form on the sidekick as well.

## More information

- Today's backup: storybook `ops/backup.sh` and `ops/README.md`, "Backups"
- [Threat model, g. Backup and restore](../threat-model.md#g-backup-and-restore); requirements
  R-43 to R-45
- [age](https://github.com/FiloSottile/age)
- Roadmap step 0.6; where ntfy and the outside uptime check run (the sidekick is a candidate) is an
  open decision for phase 6
