#!/usr/bin/env bash
# Auto-grade Week 2 assignment. Writes score.json next to this script.
# Total = 100, passing = 60.
#
# The auto-grade workflow runs this from the .hyf working directory; we
# resolve the repo root so the script is robust to either invocation
# (cd .hyf && bash test.sh, or bash .hyf/test.sh from the repo root).
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

PASSING=60

# --- Task 1: Cleaner Pipeline (60 points) ---
#
# Scoring ladder (each level depends on the previous):
#   0   nothing committed
#   10  required files all present (config.py, models.py, transforms.py,
#       pipeline.py, tests/test_transforms.py, .env.example)
#   20  pipeline runs against messy_sales.csv without crashing (the
#       grader injects INPUT_PATH/OUTPUT_PATH inline; no .env touched)
#   40  output/clean_sales.csv passes structural checks (12 rows, cleaned
#       fields, revenue/vat correctly calculated)
#   60  the *code* also looks engineered: models.py defines a @dataclass
#       with __post_init__; transforms.py uses the {**row, ...} spread
#       pattern; pytest tests/ reports all tests passing.
#
# Why the introspection cap at 40: a script that hardcodes the expected
# JSON literal could pass the structural checks without doing any real
# transformation. The 60-point tier requires the chapter's actual patterns
# (dataclass, spread, tests) to be present in the source.
task1=0
task1_msg="missing required files in task-1/"

required_files=(
    "task-1/src/config.py"
    "task-1/src/models.py"
    "task-1/src/transforms.py"
    "task-1/src/pipeline.py"
    "task-1/tests/test_transforms.py"
    "task-1/.env.example"
)

all_present=true
for f in "${required_files[@]}"; do
    if [ ! -f "$f" ]; then
        all_present=false
        break
    fi
done

if [ "$all_present" = true ]; then
    task1=10
    task1_msg="files exist but pipeline failed to run"

    # Make sure the python-dotenv + pytest deps are available; if a
    # requirements.txt exists, install it quietly.
    if [ -f task-1/requirements.txt ]; then
        python3 -m pip install -q -r task-1/requirements.txt || \
            echo "WARN: pip install failed; pipeline may fail with ModuleNotFoundError" >&2
    fi

    # Force the canonical paths inline so the grader is deterministic
    # regardless of the student's local .env (which may point INPUT_PATH /
    # OUTPUT_PATH at /tmp or some other location during their own debugging).
    # The student's .env is NOT read or modified by the grader.
    PIPELINE_ERR=$(mktemp)
    if ( cd task-1 && env INPUT_PATH=data/messy_sales.csv OUTPUT_PATH=output/clean_sales.csv python3 -m src.pipeline ) >/dev/null 2>"$PIPELINE_ERR"; then
        task1=20
        task1_msg="pipeline ran but output/clean_sales.csv failed structural checks"
        STRUCT_ERR=$(mktemp)
        if python3 - <<'PY' 2>"$STRUCT_ERR"
import csv
from pathlib import Path

p = Path("task-1/output/clean_sales.csv")
assert p.exists(), "output/clean_sales.csv was not created"

with p.open() as f:
    rows = list(csv.DictReader(f))

# 15 input rows - 3 invalid (empty name #6, negative price #7, zero qty #8) = 12
assert len(rows) == 12, f"expected 12 cleaned rows, got {len(rows)}"

# Required columns
required = {"transaction_id", "product_name", "category", "price",
            "quantity", "customer_email", "date", "revenue", "vat"}
missing = required - set(rows[0].keys())
assert not missing, f"output missing columns: {missing}"

# Field-level checks
for row in rows:
    name = row["product_name"]
    assert name == name.strip() and name == name.title(), \
        f"product_name not cleaned: {name!r}"
    email = row["customer_email"]
    assert email == email.strip().lower(), \
        f"customer_email not cleaned: {email!r}"
    cat = row["category"]
    assert cat, f"category empty (should default to 'Unknown') in row {row['transaction_id']}"

# Spot-check the math: row id=1 was 999.99 * 2 = 1999.98 revenue, then
# * 0.21 = 419.9958 vat (rounded to 420.00 at 2 decimals; the 0.01
# tolerance below absorbs either rounding precision the student picks).
row_1 = next(r for r in rows if r["transaction_id"] == "1")
revenue_1 = float(row_1["revenue"])
vat_1 = float(row_1["vat"])
assert abs(revenue_1 - 1999.98) < 0.01, f"row 1 revenue wrong: {revenue_1}"
assert abs(vat_1 - 419.9958) < 0.01, f"row 1 vat wrong: {vat_1}"

# At least one row should have category="Unknown" (row 15 had empty category)
assert any(r["category"].lower() == "unknown" for r in rows), \
    "no row has category='Unknown' (row 15's empty category should default)"
PY
        then
            rm -f "$STRUCT_ERR"
            task1=40
            task1_msg="output passes structural checks but code is missing required engineering patterns (see below)"

            # Introspection caps. The full 60 requires:
            #  - models.py imports `dataclass` AND defines a __post_init__ method
            #  - transforms.py uses the {**row, ...} spread pattern (no mutation)
            #  - pytest tests/test_transforms.py passes (all student tests green)
            models_has_dataclass=$(grep -cE "^[[:space:]]*from dataclasses\b|^[[:space:]]*import dataclasses\b" task-1/src/models.py || true)
            models_has_post_init=$(grep -cE "^[[:space:]]*def __post_init__" task-1/src/models.py || true)
            transforms_has_spread=$(grep -cE '\{\*\*' task-1/src/transforms.py || true)

            tests_pass=false
            if ( cd task-1 && python3 -m pytest tests/ -q ) >/dev/null 2>&1; then
                tests_pass=true
            fi

            if [ "$models_has_dataclass" -gt 0 ] && \
               [ "$models_has_post_init" -gt 0 ] && \
               [ "$transforms_has_spread" -gt 0 ] && \
               [ "$tests_pass" = true ]; then
                task1=60
                task1_msg="output and code structure both pass; tests green"
            else
                missing=()
                [ "$models_has_dataclass" -eq 0 ] && missing+=("from dataclasses import ... in models.py")
                [ "$models_has_post_init" -eq 0 ] && missing+=("__post_init__ in models.py")
                [ "$transforms_has_spread" -eq 0 ] && missing+=("{**row, ...} spread pattern in transforms.py")
                [ "$tests_pass" = false ] && missing+=("pytest tests/ all green")
                task1_msg="output passes but code missing: $(IFS=, ; echo "${missing[*]}")"
            fi
        else
            # Structural checks failed: surface the assertion message.
            err=$(tail -3 "$STRUCT_ERR" | tr '\n' ' ' | sed 's/  */ /g' | sed 's/^ //;s/ $//')
            [ -n "$err" ] && task1_msg="structural check failed: $err"
            rm -f "$STRUCT_ERR"
        fi
    else
        # Pipeline crashed: surface the last few stderr lines.
        err=$(tail -3 "$PIPELINE_ERR" | tr '\n' ' ' | sed 's/  */ /g' | sed 's/^ //;s/ $//')
        [ -n "$err" ] && task1_msg="pipeline failed to run: $err"
    fi
    rm -f "$PIPELINE_ERR"
fi

# --- Task 2: AI Debug Report (20 points) ---
task2=0
task2_msg="missing task-2/AI_DEBUG.md"
if [ -s task-2/AI_DEBUG.md ]; then
    task2=5
    task2_msg="AI_DEBUG.md exists but missing required sections"
    if grep -q "^## The Error" task-2/AI_DEBUG.md && \
       grep -q "^## The Prompt" task-2/AI_DEBUG.md && \
       grep -q "^## The Solution" task-2/AI_DEBUG.md && \
       grep -q "^## Reflection" task-2/AI_DEBUG.md; then
        task2=10
        task2_msg="all sections present but file looks too short to be filled in"
        # Empty template ships at ~1500 chars. Filled-in report should have
        # meaningfully more content; threshold = template + ~600 chars
        # of student writing (4 sections * ~150 chars each).
        if [ "$(wc -c < task-2/AI_DEBUG.md)" -gt 2100 ]; then
            task2=20
            task2_msg="AI_DEBUG.md is filled in"
        fi
    fi
fi

# --- Task 3: Azure Blob Storage Upload (20 points) ---
# Screenshot is required (10 pts); blob_url.txt with a valid Azure Storage
# URL earns the remaining 10 pts. Both checks live inside the screenshot
# branch — no screenshot means 0/20 regardless of blob_url.txt.
task3=0
task3_msg="missing task-3/assets/azure_blob_week2.png (or .jpg/.jpeg)"
for ext in png jpg jpeg; do
    if [ -s "task-3/assets/azure_blob_week2.$ext" ]; then
        task3=10
        if [ -s "task-3/assets/blob_url.txt" ]; then
            # Require at least <container>/<blob> after the host so a bare
            # storage-account root URL doesn't satisfy the check.
            if grep -qE "https://[a-z0-9]+\.blob\.core\.windows\.net/[^/]+/[^/]+" task-3/assets/blob_url.txt; then
                task3=20
                task3_msg="screenshot and blob URL both present"
            else
                task3_msg="blob_url.txt present but URL format is wrong — expected https://<account>.blob.core.windows.net/<container>/<blob>"
            fi
        else
            task3_msg="screenshot present but task-3/assets/blob_url.txt is missing"
        fi
        break
    fi
done

score=$((task1 + task2 + task3))
if [ "$score" -ge "$PASSING" ]; then pass=true; else pass=false; fi

cat > "$SCRIPT_DIR/score.json" <<EOF
{
  "score": $score,
  "pass": $pass,
  "passingScore": $PASSING
}
EOF

echo "Task 1 (Cleaner Pipeline): $task1/60 — $task1_msg"
echo "Task 2 (AI Debug Report):  $task2/20 — $task2_msg"
echo "Task 3 (Azure Blob Upload): $task3/20 — $task3_msg"
echo "----------------------------------------"
echo "Total: $score/100 — pass=$pass (passing threshold: $PASSING)"
