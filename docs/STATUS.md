# Implementation status and scope

| Component | Public work sample status |
| --- | --- |
| Browser entry page | Runs without a build step or backend |
| English / Chinese demo switch | Switches pre-rendered images and demo controls in this webpage |
| “I’m OK” | Shows the supplied synthetic confirmation screenshot; no notification delivery |
| Stable / changed family scenario | Switches fixed synthetic screens; does not infer new risks |
| Five independent targets, trends, confidence handling | Visible in supplied Flutter excerpts and rendered screens |
| Flutter UI excerpts | Presentation copies; imports from the private `dongle_me` application are unresolved in this repo |
| Screenshot renderer | Requires private app types, theme, dependencies and local fonts; not reproducible from this repo alone |
| Native English localization / language switching | Future-release concept according to original package documentation |
| Full Android APK / production backend | Not included |
| Full IB implementation / training / evaluation | Not included |
| Clinical calibration or predictive performance | Not established by this bundle |

The original package reported successful Flutter screenshot tests and bilingual browser checks. These are historical package statements, not tests rerun during this publication. Publication validation focuses on the public browser experience and selected release files.

## Renderer path changes

`render_demo_test.dart` is retained for technical review. Machine-specific paths were removed. Font files default to a local `fonts/` directory and can be overridden through `DEMO_LATIN_FONT`, `DEMO_CHINESE_FONT`, `DEMO_EMOJI_FONT` and `DEMO_ICONS_FONT`. `DEMO_OUTPUT_DIR` defaults to `demo-output/` and is created before rendering.

The original `flutter test` command in that file assumes the private app and original directory arrangement. It is historical context, not a standalone command for this repository. To reproduce native screenshots, restore the private app dependencies and adapt the test location and fonts first. The public browser demo needs none of these dependencies.
