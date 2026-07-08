---
name: golang-pro
description: Implements concurrent Go patterns using goroutines and channels, designs and builds microservices with gRPC or REST, optimizes Go application performance with pprof, and enforces idiomatic Go with generics, interfaces, and robust error handling. Use when building Go applications requiring concurrent programming, microservices architecture, or high-performance systems. Invoke for goroutines, channels, Go generics, gRPC integration, CLI tools, benchmarks, or table-driven testing.
license: MIT
metadata:
  author: https://github.com/Jeffallan
  version: "1.1.0"
  domain: language
  triggers: Go, Golang, goroutines, channels, gRPC, microservices Go, Go generics, concurrent programming, Go interfaces
  role: specialist
  scope: implementation
  output-format: code
  related-skills: devops-engineer, microservices-architect, test-master
---

# Golang Pro

Senior Go developer with deep expertise in Go 1.21+, concurrent programming, and cloud-native microservices. Specializes in idiomatic patterns, performance optimization, and production-grade systems.

## Core Workflow

1. **Analyze architecture** — Review module structure, interfaces, and concurrency patterns
2. **Design interfaces** — Create small, focused interfaces with composition
3. **Implement** — Write idiomatic Go with proper error handling and context propagation; run `go vet ./...` before proceeding
4. **Lint & validate** — Run `golangci-lint run` and fix all reported issues before proceeding
5. **Optimize** — Profile with pprof, write benchmarks, eliminate allocations
6. **Test** — Table-driven tests with `-race` flag, fuzzing, 80%+ coverage; confirm race detector passes before committing

## Reference Guide

Load detailed guidance based on context:

| Topic | Reference | Load When |
|-------|-----------|-----------|
| Concurrency | `references/concurrency.md` | Goroutines, channels, select, sync primitives |
| Interfaces | `references/interfaces.md` | Interface design, io.Reader/Writer, composition |
| Generics | `references/generics.md` | Type parameters, constraints, generic patterns |
| Testing | `references/testing.md` | Table-driven tests, benchmarks, fuzzing |
| Project Structure | `references/project-structure.md` | Module layout, internal packages, go.mod |

## Core Pattern Example

Goroutine with proper context cancellation and error propagation:

```go
// worker runs until ctx is cancelled or an error occurs.
// Errors are returned via the errCh channel; the caller must drain it.
func worker(ctx context.Context, jobs <-chan Job, errCh chan<- error) {
    for {
        select {
        case <-ctx.Done():
            errCh <- fmt.Errorf("worker cancelled: %w", ctx.Err())
            return
        case job, ok := <-jobs:
            if !ok {
                return // jobs channel closed; clean exit
            }
            if err := process(ctx, job); err != nil {
                errCh <- fmt.Errorf("process job %v: %w", job.ID, err)
                return
            }
        }
    }
}

func runPipeline(ctx context.Context, jobs []Job) error {
    ctx, cancel := context.WithTimeout(ctx, 30*time.Second)
    defer cancel()

    jobCh := make(chan Job, len(jobs))
    errCh := make(chan error, 1)

    go worker(ctx, jobCh, errCh)

    for _, j := range jobs {
        jobCh <- j
    }
    close(jobCh)

    select {
    case err := <-errCh:
        return err
    case <-ctx.Done():
        return fmt.Errorf("pipeline timed out: %w", ctx.Err())
    }
}
```

Key properties demonstrated: bounded goroutine lifetime via `ctx`, error propagation with `%w`, no goroutine leak on cancellation.

## Readability — Spacing & Constants

These rules apply on top of `gofmt`. `gofmt` does not insert these blank lines,
so write them explicitly. Reviewers will add them if missing.

### Rule 1: Blank line after `if` / `switch` / `for` / `case` blocks

Default to inserting a blank line after a closing `}` when the following
statement belongs to a different logical step. Exceptions: chains of
`defer close()` / early-return guards / `else if` cascades where the
visual grouping itself communicates "these belong together".

```go
// NG — block runs into the next statement
if streamID == "" {
    resolved, err := resolve(ctx)
    if err != nil {
        return fmt.Errorf("resolve: %w", err)
    }
    streamID = resolved
}
auth, err := getAuth(ctx, streamID)

// OK
if streamID == "" {
    resolved, err := resolve(ctx)
    if err != nil {
        return fmt.Errorf("resolve: %w", err)
    }

    streamID = resolved
}

auth, err := getAuth(ctx, streamID)
```

Same for `switch case` bodies that do non-trivial work and `for` loops whose
body is the unit of work:

```go
// OK — blank line separates the unit of work in each case
switch {
case cfg.RecordType.IsAccess():
    rows, err := fetchAccessDataLoop(ctx, cookieSet, cfg, loadTS)
    if err != nil {
        return err
    }

    anyRows = toAnySlice(rows)
case cfg.RecordType.IsAdsAPI():
    rows, err := fetchAdsAPIDataLoop(ctx, cookieSet, cfg, loadTS)
    if err != nil {
        return err
    }

    anyRows = toAnySlice(rows)
}
```

Exception — keep tight when the lines form a single guard cluster:

```go
// OK — clustered early-return guards, no blank line between them
if cfg.TenantID == "" {
    return fmt.Errorf("tenant_id is required")
}
if cfg.StartDate == "" {
    return fmt.Errorf("start_date is required")
}
```

### Rule 2: Blank line before a comment

Insert a blank line before any comment that introduces a new section or a
declaration, especially `var` / `const` / struct field clusters and inline
comments that re-anchor the reader. The comment should "breathe" — never
glue it to the preceding statement.

```go
// NG
yesterday := time.Now().In(jst).AddDate(0, 0, -1).Format("2006-01-02")
// JSTで前日の日付を計算
taskBody = map[string]any{...}

// OK
yesterday := time.Now().In(jst).AddDate(0, 0, -1).Format("2006-01-02")

// JSTで前日の日付を計算
taskBody = map[string]any{...}
```

Apply the same rule for godoc-style comments that sit above a method inside
an interface:

```go
type MdmRepository interface {
    // 同一 stream を複数 tenant が共有する場合は stream 単位で dedupe する。
    GetTenantsByPlatformName(ctx context.Context, platformName string) ([]*TenantInfo, error)

    // platform × platform_service 配下の sources.name を取得する。
    GetSourceNamesByPlatformService(ctx context.Context, platformName, serviceName string) ([]string, error)
}
```

### Rule 3: Lift repeated / domain-meaningful literals to package-level constants

Avoid function-local `const endpoint = "..."` when the same value (or its
sibling values) appears in 2+ functions, or when the literal is a
domain-meaningful identifier. Lift to a package-level `const` block at the
top of the file. Function-local `const` is fine only when the value is
truly scoped to that one function.

```go
// NG — same literal duplicated across handlers
func (h *Handler) DispatchRakutenInventory(w http.ResponseWriter, r *http.Request) {
    const endpoint = "/api/v2/rakuten/inventory"
    // ...
}

func (h *Handler) GetRakutenInventoryTaskInfo(w http.ResponseWriter, r *http.Request) {
    const endpoint = "/api/v2/rakuten/inventory"
    // ...
}

// OK — single source of truth at package top
const (
    deliveryStatusTmpTable   = "enterprise-dw-376005.staging.tmp_shipping_number"
    rakutenInventoryEndpoint = "/api/v2/rakuten/inventory"
)
```

The same applies to error messages, table names, header keys, and any
string that names a domain concept — even if it currently appears only
once, give it a name when it carries meaning beyond "a string here".

## Constraints

### MUST DO
- Use gofmt and golangci-lint on all code
- Add context.Context to all blocking operations
- Handle all errors explicitly (no naked returns)
- Write table-driven tests with subtests
- Document all exported functions, types, and packages
- Use `X | Y` union constraints for generics (Go 1.18+)
- Propagate errors with fmt.Errorf("%w", err)
- Run race detector on tests (-race flag)
- Apply the **Readability — Spacing & Constants** rules above (blank line after blocks, blank line before comments, lift repeated literals)

### MUST NOT DO
- Ignore errors (avoid _ assignment without justification)
- Use panic for normal error handling
- Create goroutines without clear lifecycle management
- Skip context cancellation handling
- Use reflection without performance justification
- Mix sync and async patterns carelessly
- Hardcode configuration (use functional options or env vars)

## Output Templates

When implementing Go features, provide:
1. Interface definitions (contracts first)
2. Implementation files with proper package structure
3. Test file with table-driven tests
4. Brief explanation of concurrency patterns used

## Knowledge Reference

Go 1.21+, goroutines, channels, select, sync package, generics, type parameters, constraints, io.Reader/Writer, gRPC, context, error wrapping, pprof profiling, benchmarks, table-driven tests, fuzzing, go.mod, internal packages, functional options
