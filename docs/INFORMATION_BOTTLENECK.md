# Information bottleneck: theory and care application

**Theoretical highlight:** information bottleneck representations, from **X → T → Y** toward multiple T stages. **Social responsibility:** applying that research direction to care for older adults who live alone.

## 1. The theory: X → T → Y

This project uses **T** for the intermediate representation. The standard information bottleneck question is how to represent input X compactly while preserving information about a relevant target Y. Its usual trade-off is:

`min I(X; T) − β I(T; Y)`

I denotes mutual information; β balances compression and target relevance. This equation explains the theory, rather than documenting a loss function executed by the public demo. See Tishby, Pereira and Bialek, [The information bottleneck method](https://arxiv.org/abs/physics/0004057).

T is a representation in the research model. It should not be equated with a screen, a shorter interface, or a label on a target card. Role-specific presentation is an application design choice; it does not establish that IB optimization has taken place.

## 2. Research trajectory: one T, then additional T stages

The project owner clarified the trajectory on **2026-11-03**:

| Stage | Chain | Meaning and evidence |
| --- | --- | --- |
| Earlier work | **X → T → Y** | The owner reports using a single T for an extended period |
| Recent exploration | **X → T₁ → T₂ → Y** | Exploring at least one additional intermediate T |
| Additional depth | **X → T₁ → T₂ → T₃ → Y**, or more | Exploring 1–2 additional T stages relative to the earlier single-T approach; longer chains remain possible |

This is an owner-reported research direction. The public package does not specify the definitions of T₁, T₂ or T₃, the exact connections, training objectives or measured results. It is therefore premature to assign those layers specific roles such as feature extraction, behavioral state or decision-making.

The useful research question is what information each intermediate representation should retain for the next stage and for Y. Adding stages should be investigated for both useful abstraction and loss of relevant information. A longer chain alone is not evidence of improved performance or an optimized IB model. Layered representations can be studied through the IB framework; see Tishby and Zaslavsky, [Deep Learning and the Information Bottleneck Principle](https://arxiv.org/abs/1503.02406). That paper provides theoretical context, not evidence about this project’s implementation or results.

## 3. Interpretation in the care application

The following is an application-level reading, rather than a recovered specification of the private model:

| Element | Interpretation for care | Public evidence boundary |
| --- | --- | --- |
| X | Inputs relevant to recognizing changes in everyday activity | Screens show steps, activity and histories; the model’s complete input feature set is not included |
| T / T₁…Tₖ | Intermediate representations intended to preserve task-relevant information | The owner confirms the single-T history and recent multi-T exploration; the model definitions are outside this bundle |
| Y | Care-relevant target variables | The UI names five separate research targets; the underlying scoring implementation is not included |
| Product interaction | Check-ins and family views that present information to people | Demonstrated by supplied screens and Flutter UI excerpts |

**Five targets do not mean five T layers.** Falls, cognitive decline, depressive tendency, heart failure signs and social isolation are separate Y targets in the supplied interface. A single representation may be discussed with multiple targets; target count does not establish representation depth. Likewise, the older-adult and family interfaces do not establish T₁ and T₂.

## 4. Social responsibility: older adults living alone

The purpose is to help older adults who live alone and their families stay connected. A large-type, one-tap check-in offers a manageable way to share reassurance. The family view provides recent changes, separate target estimates and confidence context that can prompt a conversation.

This gives the theoretical work a concrete social application. Simplicity, dignity and privacy matter to the care experience. They are design aims, not proof of IB performance. The public work sample does not establish reductions in isolation, falls or other care outcomes.

## 5. What the supplied source supports

| Evidence | Location | What it supports |
| --- | --- | --- |
| “5 independent Y risk cards (IB-v4 §14.5 Pareto, no overall risk)” | `source/risk_score_cards_en.dart`, opening comment | Explicit reference to an IB design and separate targets |
| `_yOrder` with five target IDs | Same file | Independent target display, not five representation stages |
| `history` and `_extractSparkline` | Same file | Seven-day trend display |
| `confidenceLow` handling | Same file | Confidence-aware presentation |
| `elderStatusFromSteps` | `source/elder_status_en.dart` | Friendly older-adult status derived from steps rather than a risk score |
| `synthetic: true`, `personal_test_data_used: false` | `mock-data.json` | Fixed presentation fixtures without personal test data |

The referenced IB-v4 document, full scoring implementation and recent multi-T experiment artifacts are absent from the supplied package. The source comments support design intent; they do not prove an executed optimization, information retention or clinical validity.

## 6. What the online demo shows

The [online demo](https://hawever-renbo.github.io/dongle-me-work-sample/) demonstrates the care interaction with synthetic screenshots: two roles, a check-in confirmation, stable and changed-trend scenarios, and an English/Chinese presentation concept. It does not execute the single-T or multi-T model, learn representations, or compare architectures.

To interpret the specific T stages further would require their definitions, encoder/decoder connections, objectives and corresponding experiment artifacts. Those details should come from the project materials rather than be inferred from the UI. Predictive performance and clinical calibration remain outside this public bundle. Information compression alone is not a privacy guarantee.
