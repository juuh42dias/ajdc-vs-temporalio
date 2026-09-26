# AJ/DC vs Temporal — runnable companion to the blog post

Same business flows, twice: once as **durable Active Job** with
[AJ/DC](https://github.com/palkan/ajdc) (this Rails app), once as
**workflows on a durable execution platform** with the
[Temporal Ruby SDK](https://github.com/temporalio/sdk-ruby) (`temporal/`).

Companion post: <https://blog.juliana.dev/blog/ajdc-vs-temporal>

| Flow | AJ/DC (Rails) | Temporal (platform) |
|---|---|---|
| Checkpointed batch import | `app/jobs/import_job.rb` (`step.advance!`) | — (every Activity is a checkpoint) |
| Money transfer saga | — | `temporal/workflows/bank_transfer_workflow.rb` (withdraw → deposit → refund) |
| Trial reminders on a timer | `app/jobs/license/lifecycle_job.rb` (`wait_until` / `wait`) | `temporal/workflows/trial_workflow.rb` (`Workflow.sleep`) |
| Human approval | `app/jobs/bulk_import_job.rb` (`await` / `wake_up`) | Trial completion via external state (or Signals) |
| One live run per key | `unique_by :license, on_conflict: :replace` | Workflow ID reuse policies |

## Prerequisites

- Ruby 4.0.6 (see `.ruby-version`), Bundler
- Docker (for PostgreSQL)
- [Temporal CLI](https://docs.temporal.io/cli) (`temporal server start-dev`) for the platform side

## Setup

```bash
# PostgreSQL
docker run -d --name ajdc-demo-postgres \
  -e POSTGRES_USER=ajdc_demo -e POSTGRES_PASSWORD=ajdc_demo \
  -e POSTGRES_DB=ajdc_vs_temporal_demo_development -p 5432:5432 postgres:17

bundle install
bin/rails db:prepare
```

## Demo 1 — AJ/DC (no extra services)

```bash
bin/rails runner script/verify_ajdc.rb
```

This exercises checkpoints (`ImportJob`), run uniqueness with replace
(`License::LifecycleJob`) and signals/scopes (`BulkImportJob`), asserting
against the `active_job_durable_runs` / `active_job_durable_steps` tables.

Explore in the console:

```ruby
ImportJob.workflow_runs.failed.at_step(:process)
License::LifecycleJob.workflow_runs.for(license).live.first.resume!
```

Crash test: run a real worker (`bin/jobs`), enqueue an import, `kill -9` the
worker mid-run, restart it — the open step resumes from its cursor. Waiting
runs (`wait` / `wait_until`) need the clock from `config/recurring.yml`:

```yaml
durable_wake:
  class: ActiveJob::Durable::WakeJob
  schedule: every minute
```

## Demo 2 — Temporal (dev server + worker)

```bash
temporal server start-dev          # localhost:7233, UI at localhost:8233
bundle exec ruby temporal/worker.rb
```

Money transfer (saga with compensation):

```bash
bundle exec ruby temporal/starter_transfer.rb A1001 B2002 100
# => Transfer complete (transaction IDs: OKW-100-A1001, OKD-100-B2002)
```

Trial reminders on a durable timer (10s interval for the demo):

```bash
bundle exec ruby temporal/starter_trial.rb dev@example.com 10
# ... watch reminders loop ...
bundle exec ruby -e "require './temporal/activities/trial_activities'; Demo::TrialStore.set_upgraded('dev@example.com', true)"
# ... workflow completes after the next check ...
```

## Notes

- `attribute` (durable job state via `ActiveJob::Attributes`) needs Rails 8.2+;
  this demo targets Rails 8.1, so progress/flags live in database columns.
- `json` is pinned to 2.x: `temporalio` 1.x parses payloads with the
  `JSON.parse` options API that json 3.x removed.
- The trial's "upgrade flag" is a file under `temporal/tmp/` (gitignored) so
  the platform side runs with zero database setup.
