# Content & Backend Architecture Decisions

Status: decided, not yet implemented in code unless noted.

## Requirements

1. Offline ready — articles and their media must be usable without network.
2. Multimedia — images, video, audio, and interactive widgets.
3. Editable via a portal — block-based editor (Notion/AppFlowy style), not raw Markdown as the primary format. Portal saves to the cloud; the app pulls updates from there.

## Content Model

- Canonical storage is a **versioned structured document made of typed blocks** (JSON), not Markdown.
- Markdown is supported only as an **import/export** format for the structured document, not canonical storage.
- Hierarchy is fixed at **3 levels**: `subject -> topic -> article`.
- `Interactives` is not a subject. It is a cross-cutting content type/filter; an interactive can stand alone or be referenced from an article.
- Interactive **implementations are native Flutter code** living in `lib/features/interactives/...`. The backend/Markdown never stores executable code — only a `widgetId` + JSON `config` that selects a pre-registered Flutter widget at render time.

### Block types (initial set)

```text
paragraph
heading
image
video
audio
interactive   (widgetId + config only — no code)
callout
divider
```

### Markdown embedding syntax (directive blocks)

```md
:::interactive{widget="solar-system"}
{ "initialView": "overview", "showOrbits": true }
:::

:::video
asset: mesopotamia-documentary
poster: mesopotamia-poster
:::
```

Parsed once at import time into the same block JSON used everywhere else — the renderer never parses Markdown directives at display time.

## BaaS Decision: Supabase

Chosen over PocketBase for: relational subject/topic/article hierarchy, revisions/publishing workflow, storage for large media, row-level security, and a clearer growth path.

- **Supabase Auth** — portal users (editors), later app user accounts if needed.
- **Supabase Postgres** — subjects, topics, articles, revisions, media metadata.
- **Supabase Storage** — images, video, audio, downloadable assets.
- **Edge Functions** — publishing/validation/webhooks (later).
- Local **SQLite (Drift)** in the Flutter app — offline-first read cache; the UI reads from here, never directly from Supabase.

### Schema

```sql
create table subjects (
  id uuid primary key default gen_random_uuid(),
  slug text unique not null,
  name text not null,
  icon text,
  color text
);

create table topics (
  id uuid primary key default gen_random_uuid(),
  subject_id uuid references subjects(id) on delete cascade,
  slug text not null,
  name text not null,
  sort_order int not null default 0,
  unique (subject_id, slug)
);

create table articles (
  id uuid primary key default gen_random_uuid(),
  topic_id uuid references topics(id) on delete cascade,
  slug text not null,
  status text not null default 'draft', -- draft | review | published | archived
  current_revision_id uuid,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (topic_id, slug)
);

create table article_revisions (
  id uuid primary key default gen_random_uuid(),
  article_id uuid references articles(id) on delete cascade,
  revision_number int not null,
  document_json jsonb not null, -- { title, blocks: [...] }
  created_by uuid,
  created_at timestamptz not null default now(),
  published_at timestamptz,
  unique (article_id, revision_number)
);

create table media_assets (
  id uuid primary key default gen_random_uuid(),
  storage_path text not null,
  mime_type text not null,
  checksum text not null,
  size_bytes bigint not null,
  width int,
  height int,
  duration_ms int
);

create table article_assets (
  article_revision_id uuid references article_revisions(id) on delete cascade,
  media_asset_id uuid references media_assets(id) on delete cascade,
  primary key (article_revision_id, media_asset_id)
);
```

`document_json` holds the full block array for that revision:

```json
{
  "title": "Mesopotamia",
  "blocks": [
    { "id": "intro", "type": "paragraph", "text": "..." },
    {
      "id": "map",
      "type": "image",
      "assetId": "mesopotamia-map",
      "caption": "..."
    },
    {
      "id": "sim",
      "type": "interactive",
      "widgetId": "solar-system",
      "config": { "showOrbits": true }
    }
  ]
}
```

Published revisions are immutable. A new edit creates a new revision; `articles.current_revision_id` points at the latest published one. The app can keep using an older cached revision while a newer one downloads.

### Offline storage on device

```text
SQLite (Drift)        -> subjects, topics, articles, revisions (document_json), media metadata, sync state
App documents dir      -> actual media files, keyed by media_asset id, verified by checksum
```

Manifest-driven download: fetch revision JSON, then fetch/verify each referenced asset, then mark the article `availableOffline`. Never overwrite a cached working revision until the new one and all its assets are fully verified.

## Not Yet Implemented

- No Supabase client in `pubspec.yaml`.
- No Drift/local DB in `pubspec.yaml`.
- No live article/topic data — current app uses static `SubjectDefinition` lists.
- `SolarSystem` interactive is a placeholder widget.
