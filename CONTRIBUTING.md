# Contributing

Additions, corrections, and staleness reports are all welcome.

## Entry format

One line per entry, in this order:

```markdown
- [name](url) — What it is and why it's worth your time. `LICENSE` · ★stars · Language
```

- Use an em dash (`—`) after the link.
- License in backticks, using the SPDX identifier where one applies.
- Stars rounded: `★1.8k`, `★276`, `★0`.
- Put the language last. Omit it for entries where it isn't meaningful.

## What gets in

- Open source, or clearly labeled if not (see Remotion for how non-standard terms are noted).
- Actually relevant to editing, encoding, analyzing, or playing video.
- A real project. Not a repo containing only a README and screenshots for a closed-source app.

## What doesn't

- Closed-source apps whose repository is documentation only.
- Affiliate or referral links.
- Projects with no commits and no releases, ever.
- Duplicate entries under a different name.

## Annotations

- **⚠️** — flag staleness (roughly no pushes in 12+ months), platform restrictions, or
  non-standard/copyleft-surprising licensing. Say what the problem is.
- **🔬** — only if you have read the source and can point to specific files, types, or
  decisions. A teardown belongs in `NOTES.md`. Do not use this for entries you have
  merely used or skimmed.

## Verifying metadata

Stars, license, and push dates must come from live data, not memory:

```bash
gh api /repos/OWNER/REPO \
  --jq '[.full_name, .stargazers_count, (.license.spdx_id // "NONE"), (.pushed_at|split("T")[0]), .language] | @tsv'
```

A `NOASSERTION` license means GitHub could not classify it — open the `LICENSE` file and
report what it actually says rather than leaving it ambiguous.

## Before opening a PR

```bash
./scripts/check-links.sh    # verifies every GitHub link resolves
```

Update the `Contents` section if you add a category, and keep the
`License Compatibility` table in sync with any new entry's license tier.

## Tone

Descriptions should tell a reader whether to spend time on something. "Video editor for
macOS" is not useful. "The smallest complete AVFoundation timeline you will find" is.

Being direct about weaknesses is the point of the list — unmaintained, platform-locked, or
awkward-to-use projects can stay, as long as the entry says so.
