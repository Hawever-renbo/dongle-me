# Dongle.me

**A little check-in. A lot of peace of mind.** A two-role care prototype grounded in information bottleneck theory: a simple check-in for older adults, and recent trends for their families.

[**Try the browser demo →**](https://hawever-renbo.github.io/dongle-me-work-sample/) · [Six-screen gallery](https://hawever-renbo.github.io/dongle-me-work-sample/assets/index.html) · [Theory & evidence](docs/INFORMATION_BOTTLENECK.md)

![Dongle.me overview: older adult and family interfaces](assets/cover.png)

## Explore in one minute

1. Open the browser demo. No installation or account is needed.
2. Choose **English / 中文** to preview both roles.
3. Tap **I’m OK — preview check-in** to see the confirmation screen.
4. Switch **Stable trends / Changes to check** to compare family scenarios; scroll inside the screens.
5. Open the [Flutter UI excerpts](source/) and [implementation status](docs/STATUS.md) for technical context.

The browser demo is a screenshot-based interactive walkthrough built around the supplied Flutter screens. The check-in does not deliver a notification. It uses fixed synthetic fixtures and does not run a health prediction model. English localization and bilingual switching are concepts for a future Android release, not features claimed for the current APK.

## Why information bottleneck theory matters

Information bottleneck theory formalizes a trade-off: compress input **X** into a representation **Z** while retaining information relevant to a target **Y**. This project uses that framing to focus on task-relevant care signals and separate the information shown to each role. The supplied UI source explicitly references an **IB-v4** design and **five independent targets**; it does not collapse them into one overall score.

The family view shows separate estimates for falls, cognitive decline, depressive tendency, heart failure signs and social isolation, with seven-day trends and confidence handling. The older adult view emphasizes large type, steps and one-tap reassurance.

The public bundle demonstrates the interface and its design contracts. It does **not** include the full IB model, training pipeline, calibration dataset or predictive evaluation. See [the technical note](docs/INFORMATION_BOTTLENECK.md) for the distinction between source evidence and theory framing, and the [original paper](https://arxiv.org/abs/physics/0004057).

## People

Repository owner: [@Hawever-renbo](https://github.com/Hawever-renbo). Project collaborators: [@Mark751127](https://github.com/Mark751127) and [@marcmliu](https://github.com/marcmliu).

The collaborators are credited by GitHub account as requested by the project owner. Individual responsibilities are not specified in the supplied bundle; this page does not claim sole authorship or assign unverified roles. Credits do not imply that GitHub account invitations have been issued or accepted.

## Privacy and authorization

For this test project, the project owner confirms that **authorization was obtained from everyone involved**. This is an owner-provided statement, not a claim of independent consent verification or formal ethics approval.

All displayed steps, activity durations, histories and scores are synthetic. No personal test records or consent documents are published. The page has no analytics, login, forms, backend requests or external scripts/fonts; its assets are hosted with the site. The hosting provider may keep normal access logs. Information bottleneck compression alone is not a privacy guarantee. See [privacy and publication scope](docs/PRIVACY.md).

The five scores are research estimates, not diagnoses or calibrated disease probabilities. No clinical performance claim is made.

## Run locally

Open `index.html` directly, or serve this folder:

```sh
python3 -m http.server 8000
```

Then visit `http://localhost:8000`. No package installation, API keys, backend or build step is needed.

## What is included

| Path | Purpose |
| --- | --- |
| `index.html`, `style.css`, `demo.js` | Responsive public entry and synthetic-data walkthrough |
| `assets/cover.png` | Cover image supplied by the project owner |
| `assets/` | Original English/Chinese demo screens and presentation previews |
| `mock-data.json` | Synthetic fixture provenance and reference values |
| `source/` | Presentation-only Flutter UI excerpts, not a complete app |
| `render_demo_test.dart` | Screenshot-renderer excerpt; requires the original private Flutter project |
| `docs/` | Theory, implementation boundaries, privacy and provenance |

The original ZIP and slide deck are kept in the local application folder under `original/`, which is excluded from Git and the public site. The application’s other files are not part of this repository. No software license grant is inferred from public visibility.
