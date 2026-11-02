# Information bottleneck theory in Dongle.me

## Foundation

The information bottleneck (IB) method asks how to compress input X into a representation Z while preserving information about a relevant target Y. A standard objective is:

`min I(X; Z) − β I(Z; Y)`

Here I denotes mutual information and β controls the trade-off between compression and relevance. This is the theoretical objective, not a loss function implemented by the public JavaScript demo. Reference: Tishby, Pereira and Bialek, [The information bottleneck method](https://arxiv.org/abs/physics/0004057).

## Project framing

The project owner identifies IB theory as an important foundation of this work. For a care application, the framing is to retain signals that help recognize relevant changes while avoiding unnecessary detail. The public explanation maps this to everyday activity signals (X), a compact representation (Z), and distinct care targets (Y). This mapping is an explanatory model of the project’s intent; it is not a recovered specification of the private model architecture.

Five targets are displayed separately rather than merged into one overall health score. This matters because a change relevant to one target need not imply the same change in the other four. The older adult sees a simple reassurance interaction; family members can inspect trends and confidence.

## Evidence in the supplied source

| Evidence | Location | What it supports |
| --- | --- | --- |
| “5 independent Y risk cards (IB-v4 §14.5 Pareto, no overall risk)” | `source/risk_score_cards_en.dart`, opening comment | Explicit reference to an IB design and separate targets |
| `_yOrder` with five target IDs | Same file | Independent target display |
| `history` and `_extractSparkline` | Same file | Seven-day trend display |
| `confidenceLow` handling | Same file | Confidence-aware presentation; hiding bands when confidence is low |
| `elderStatusFromSteps` | `source/elder_status_en.dart` | Friendly older-adult status derived from steps rather than a risk score |
| `synthetic: true`, `personal_test_data_used: false` | `mock-data.json` | Fixed presentation fixtures, with no personal test data in this bundle |

The excerpt mentions an internal IB-v4 document and literature-based scoring, but neither that document nor the scoring implementation is in this bundle. Those comments are not evidence of an executed IB optimization, achieved compression, clinical validity or privacy guarantees.

## What this work sample does and does not establish

It demonstrates role-specific interfaces, independent target cards, synthetic scenario visualization, confidence-handling code and bilingual presentation concepts. The browser walkthrough switches between pre-rendered screens; it does not calculate new target scores.

The bundle does not establish the exact input features, representation size, β, training objective, mutual-information estimator, training data, evaluation results or calibration. No values should be invented to fill those gaps. A model-level review would require the corresponding implementation and evaluation artifacts.

The information bottleneck principle is not equivalent to anonymization, differential privacy or a guarantee against recovering sensitive information. Public-release privacy here comes from excluding personal records and using synthetic fixtures.
