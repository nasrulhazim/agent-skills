# GitHub Actions Patterns

## Debugging Failed Workflows

### Step-by-step Debug Process

1. **List failed runs:**

```bash
gh run list --status failure --limit 5
```

2. **View the failed run:**

```bash
gh run view 12345
```

3. **View only failed step logs:**

```bash
gh run view 12345 --log-failed
```

4. **View full logs (if failed step logs aren't enough):**

```bash
gh run view 12345 --log
```

5. **Re-run with debug logging:**

```bash
gh run rerun 12345 --debug
```

### Common Failure Patterns

| Error Pattern | Likely Cause | Fix |
|---|---|---|
| `Process completed with exit code 1` | Test failure or lint error | Check test output in logs |
| `Resource not accessible by integration` | Missing permissions | Add `permissions:` to workflow |
| `No space left on device` | Large build artifacts | Add cleanup step or use larger runner |
| `rate limit exceeded` | Too many API calls | Add caching or reduce API calls |
| `Could not resolve host` | Network issue | Retry the run |
| `The process '/usr/bin/git' failed with exit code 128` | Shallow clone issue | Set `fetch-depth: 0` |

## Artifact Management

### Upload Artifacts in Workflow

```yaml
- name: Upload test results
  uses: actions/upload-artifact@v4
  if: always()
  with:
    name: test-results
    path: |
      storage/logs/
      tests/coverage/
    retention-days: 7
```

### Download Artifacts via CLI

```bash
# Download all artifacts from a run
gh run download 12345

# Download specific artifact
gh run download 12345 --name test-results --dir ./test-results

# List artifacts for a run
gh api repos/{owner}/{repo}/actions/runs/12345/artifacts \
  --jq '.artifacts[] | "\(.name) \(.size_in_bytes) bytes"'
```

### Delete Old Artifacts

```bash
# List all artifacts
gh api repos/{owner}/{repo}/actions/artifacts --paginate \
  --jq '.artifacts[] | "\(.id) \(.name) \(.created_at)"'

# Delete a specific artifact
gh api repos/{owner}/{repo}/actions/artifacts/67890 --method DELETE
```

## Workflow Dispatch with Inputs

### Define in Workflow

```yaml
on:
  workflow_dispatch:
    inputs:
      environment:
        description: 'Target environment'
        required: true
        type: choice
        options:
          - staging
          - production
      version:
        description: 'Version to deploy'
        required: true
        type: string
      dry_run:
        description: 'Dry run (no actual deployment)'
        required: false
        type: boolean
        default: false
```

### Trigger via CLI

```bash
gh workflow run deploy.yml \
  --field environment=staging \
  --field version=1.2.3 \
  --field dry_run=true
```

## Caching Strategies

### Check Cache Usage

```bash
# List caches
gh api repos/{owner}/{repo}/actions/caches \
  --jq '.actions_caches[] | "\(.key) \(.size_in_bytes) \(.last_accessed_at)"'

# Delete a cache
gh api repos/{owner}/{repo}/actions/caches?key=composer-cache-abc123 --method DELETE
```

## Runner Management (Self-hosted)

```bash
# List self-hosted runners
gh api repos/{owner}/{repo}/actions/runners --jq '.runners[] | "\(.id) \(.name) \(.status)"'

# List organisation runners
gh api orgs/{org}/actions/runners --jq '.runners[] | "\(.id) \(.name) \(.status)"'
```

## Workflow Run Comparison

```bash
# Compare last 2 runs of the same workflow
RUNS=$(gh run list --workflow ci.yml --limit 2 --json databaseId --jq '.[].databaseId')
RUN1=$(echo "$RUNS" | head -1)
RUN2=$(echo "$RUNS" | tail -1)

echo "Latest run: $RUN1"
gh run view "$RUN1" --json jobs --jq '.jobs[] | "\(.name): \(.conclusion) (\(.steps | length) steps)"'

echo "Previous run: $RUN2"
gh run view "$RUN2" --json jobs --jq '.jobs[] | "\(.name): \(.conclusion) (\(.steps | length) steps)"'
```

## Monitoring Workflow Status

```bash
# Watch current run (blocks until complete)
gh run watch

# Get status of latest run on current branch
gh run list --branch "$(git branch --show-current)" --limit 1 \
  --json databaseId,status,conclusion \
  --jq '.[0] | "\(.status) \(.conclusion)"'
```
