# GitLab Corpus

This directory vendors selected Ruby files from `gitlab-org/gitlab` for offline
corpus verification in the CodeKeeper test suite.

- Source repository: https://gitlab.com/gitlab-org/gitlab
- Source revision: `85ed8239cfc6fe3cf5d5bde5975fe2f6d687ff6d`
- Location in this repository: `spec/fixtures/corpus/gitlab/`
- License notice: see `LICENSE`, copied from the same source revision.

The selected files are outside GitLab's `ee/`, `jh/`, and `doc/` directories.
Do not add files from those directories to this corpus. At the recorded source
revision, `ee/` and `jh/` are covered by proprietary licenses and `doc/` is
covered by CC BY-SA 4.0. Files outside those directories are covered by the
MIT Expat license notice included here.

## File List

- `app/models/project.rb`
- `app/models/merge_request.rb`
- `app/models/concerns/has_repository.rb`
- `app/services/merge_requests/create_service.rb`
- `app/services/ci/create_pipeline_service.rb`
- `app/graphql/types/project_type.rb`
- `app/policies/project_policy.rb`
- `lib/gitlab/ci/config/entry/job.rb`
- `lib/gitlab/ci/config/entry/rules.rb`
- `lib/gitlab/ci/pipeline/chain/validate/abilities.rb`
- `lib/gitlab/background_migration/backfill_award_emoji_sharding_key.rb`
- `lib/gitlab/database/migrations/runner_backoff/communicator.rb`
- `config/routes.rb`
- `app/models/ability.rb`
- `app/models/concerns/issuable.rb`
- `app/models/release_highlight.rb`
- `app/models/concerns/ignorable_columns.rb`
- `app/models/concerns/from_set_operator.rb`
- `app/models/concerns/ci/partitionable.rb`
- `spec/models/ability_spec.rb`

## Golden Reports

Committed golden reports live under `spec/fixtures/golden_reports/gitlab/`.
There is one pretty-printed JSON report per corpus file, and report paths are
recorded with repository-relative corpus paths.

Regenerate them only as an explicit out-of-band maintenance task:

```bash
bundle exec rake corpus:regenerate_golden_reports
```

This regeneration task is not part of CI. Review the resulting JSON diff before
committing it.
