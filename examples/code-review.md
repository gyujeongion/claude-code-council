# Example: code review

**You:**

> /council review this for concurrency bugs:
> ```go
> var cache = map[string]int{}
> func Get(k string) int { return cache[k] }
> func Set(k string, v int) { cache[k] = v }
> ```

**Claude (chairman)** sends the identical prompt to both panels in parallel, then:

> **Agreement (Gemini, GPT):** The `map` is accessed concurrently with no
> synchronization — `Get`/`Set` from multiple goroutines is a data race and can
> panic ("concurrent map read and map write").
>
> **Disagreement:**
> - (Gemini) suggested a `sync.RWMutex`.
> - (GPT) suggested `sync.Map` for a read-heavy cache.
>
> **Verdict (Claude — chair):** Use `sync.RWMutex` here. `sync.Map` only pays off
> for disjoint key sets across goroutines; for a general string→int cache an
> `RWMutex` is simpler and faster. Corrected version:
> ```go
> var (
>     mu    sync.RWMutex
>     cache = map[string]int{}
> )
> func Get(k string) int { mu.RLock(); defer mu.RUnlock(); return cache[k] }
> func Set(k string, v int) { mu.Lock(); defer mu.Unlock(); cache[k] = v }
> ```
