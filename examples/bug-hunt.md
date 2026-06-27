# Example: stress-test a claim (challenge mode)

**You:**

> /council challenge: "our retry logic is fine because we retry 3 times with
> exponential backoff."

**Claude (chairman)** sends a challenge-mode prompt to both panels:

> **Agreement (Gemini, GPT):** "3 retries + backoff" says nothing about
> *idempotency*. If the operation isn't idempotent, retries can double-charge,
> double-send, or duplicate writes — backoff doesn't help.
>
> **Additional points:**
> - (GPT) No jitter → synchronized retries cause a thundering herd after an outage.
> - (Gemini) No mention of which errors are retryable; retrying a 400/validation
>   error is wasted work and hides bugs.
>
> **Verdict (Claude — chair):** The claim is unsound as stated. Before calling
> retry logic "fine" you need: (1) idempotency keys on the operation, (2) jitter
> on the backoff, (3) a retryable-vs-terminal error classification. Add those, then
> the claim holds.
