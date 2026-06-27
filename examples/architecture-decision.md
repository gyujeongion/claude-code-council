# Example: architecture decision

**You:**

> /council should I use a message queue or just a database table as a job queue
> for ~50 jobs/minute, single service, Postgres already in stack?

**Claude (chairman):**

> **Agreement (Gemini, GPT):** At 50 jobs/min with Postgres already present,
> a DB-backed queue (`SELECT ... FOR UPDATE SKIP LOCKED`) is enough. Adding
> Kafka/RabbitMQ now is premature infrastructure.
>
> **Disagreement:**
> - (GPT) flagged that you'll want a dedicated queue once you need fan-out to
>   multiple consumers or cross-service events.
> - (Gemini) emphasized `SKIP LOCKED` + a `status`/`attempts` column and didn't
>   raise the migration path.
>
> **Verdict (Claude — chair):** Ship the Postgres table now — `FOR UPDATE SKIP
> LOCKED`, a `status` enum, `attempts`, and a `visible_at` column for retries/backoff.
> Revisit a real broker only when you hit multi-consumer fan-out or >1k jobs/min.
> (GPT's caveat is the right trigger to watch for, not a reason to adopt Kafka today.)
