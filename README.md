# Data Track — Week 2 Assignment (Template)

The HackYourFuture Data Track Week 2 assignment: **Refactoring to a Clean Pipeline**.

> 👩‍🎓 **Students:** you are in the wrong place. Do **not** fork or use this template.
> Go to your cohort's assignment repo under
> [`HackYourAssignment`](https://github.com/HackYourAssignment) (e.g. `c55-data-week2`,
> `c56-data-week2`, …). Your teacher posts the exact link in your cohort channel.
> Fork the cohort repo, branch, and open a PR back to it. Full instructions live in the
> [Week 2 Assignment on Notion](https://www.notion.so/hackyourfuture/Week-2-Assignment-Refactoring-to-a-Clean-Pipeline-f8c27aa88d144cb18f54c49d02f50b73).

## For instructors / track maintainers

This repo is the **upstream template** for the Week 2 assignment. At the start of each
cohort, generate a cohort-specific repo under the `HackYourAssignment` org from this
template (GitHub: **Use this template → Create a new repository**, owner =
`HackYourAssignment`, name = `c<NN>-data-week2`). Students then fork *that* cohort repo
and open PRs back to it; the auto-grader runs on every push.

Edits to the assignment, dataset, or grader belong here on the template, not on the
cohort copies.

## Tasks at a glance

| Task | Folder | Points | What you build |
|---|---|---|---|
| **Task 1** — Cleaner Pipeline | `task-1/` | 60 | A modular Python pipeline with `config.py` (env-var loading), `models.py` (`Transaction` dataclass with `__post_init__` validation), `transforms.py` (4+ pure composable functions, no mutation), `pipeline.py` (orchestrator), and `tests/test_transforms.py` (4+ pytest tests). Reads `data/messy_sales.csv`, writes `output/clean_sales.csv`. |
| **Task 2** — AI Debug Report | `task-2/` | 20 | Document one debugging session where you used an LLM to fix a bug. Fill in the four sections of `AI_DEBUG.md`. |
| **Task 3** — Azure Blob Upload | `task-3/` | 20 | Upload `task-1/output/clean_sales.csv` to a private Blob container in the HYF Azure storage account using the portal's Storage Browser. Save your screenshot as `task-3/assets/azure_blob_week2.png` (`.jpg`/`.jpeg` also accepted) and the blob URL in `task-3/assets/blob_url.txt`. |

Total: 100 · Passing: 60.

## Repository layout

```text
.
├── task-1/
│   ├── data/
│   │   └── messy_sales.csv      # the dataset (committed; do not edit)
│   ├── src/
│   │   ├── config.py            # env-var loader — fill in TODOs
│   │   ├── models.py            # Transaction dataclass — fill in TODOs
│   │   ├── transforms.py        # 4 pure transform functions — fill in TODOs
│   │   └── pipeline.py          # orchestrator — fill in TODOs
│   ├── tests/
│   │   └── test_transforms.py   # 4 pytest tests — fill in TODOs
│   ├── output/                  # your pipeline writes clean_sales.csv here (gitignored)
│   ├── .env.example             # copy to .env (gitignored) before running
│   └── requirements.txt         # python3 -m pip install -r requirements.txt
├── task-2/
│   └── AI_DEBUG.md              # fill in the four sections
├── task-3/
│   └── assets/
│       ├── azure_blob_week2.png # add your screenshot here (jpg/jpeg also accepted)
│       └── blob_url.txt         # paste your Azure Storage blob URL here
├── .hyf/
│   └── test.sh                  # auto-grader (read it to see exactly what it checks)
└── .github/workflows/
    └── grade-assignment.yml     # runs .hyf/test.sh on every PR
```

## Run the grader locally

Before opening a PR, run the same checks the auto-grader runs:

```bash
cd task-1
python3 -m pip install -r requirements.txt
cp .env.example .env
cd ..
bash .hyf/test.sh
cat .hyf/score.json
```

The grader prints a per-task breakdown so you can see exactly which check failed and
why. The PR-time grader does the same — your local run and the CI run are identical.

## Scoring ladder (Task 1)

The grader awards points incrementally so partial credit is meaningful:

- **10/60** — required files exist (`config.py`, `models.py`, `transforms.py`, `pipeline.py`, `tests/test_transforms.py`, `.env.example`).
- **20/60** — `python -m src.pipeline` runs from `task-1/` without crashing (the grader injects `INPUT_PATH` and `OUTPUT_PATH` inline; your local `.env` is not used during grading).
- **40/60** — `output/clean_sales.csv` passes structural checks: 12 rows (15 input − 3 invalid/zero-quantity), lowercased emails, title-cased product names, "Unknown" filled in for missing categories, `revenue` and `vat` columns present and correctly calculated.
- **60/60** — code looks engineered: `models.py` defines a `@dataclass` with `__post_init__`; `transforms.py` uses the `{**row, ...}` spread pattern (no mutation); `pytest tests/` reports all tests passing.

The 40-point cap exists to stop a 5-line script that hardcodes the expected JSON from getting full marks. Real engineering patterns (dataclass + spread + tests) are required for the top 20 points.
