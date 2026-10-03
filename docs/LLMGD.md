# LLMGD verdict

Graded against [LLMGD v0.2](https://github.com/moWerk/llmgd-specs) on
2026-10-03, at commit `709e22e`, before the repository was made public.

**This is a self-grade.** The grader is the same model, in the same session,
that designed and wrote almost everything here. That is a conflict of interest
in both directions. Read it as a disclosure by an interested party, and rerun
the grading with another model before relying on it.

## What to expect

- **A machine designed and wrote this.** The human set the goals, described
  what he saw on the device, decided what the repository should look like, and
  judged every result with his own eyes and ears. He did not design the fixes.
- **Nobody has read the code.** Not one of the scripts, units or the C source
  was read by a human before this grading. Control was exercised by running
  things on a real tablet and looking at what happened.
- **Everything was tested on one tablet.** Each fix was installed there,
  removed, the stock fault recorded, and installed again from scratch. There is
  no second tablet. What happens on yours is not known.
- **Several first versions were wrong.** They are listed below. Each was
  caught, by a test or by the human using the device. That is the method
  working, and it is also the base rate: assume there are faults nobody has
  hit yet.
- **Three parts come from another session** that this grading could not see:
  the GPS library's source, the WiFi kick script, and the update path. They are
  marked `unassessed`, not vouched for.

## Summary

Retrieval found one transcript for this work on the grading machine and read
all 58 human turns in it; a second session on another machine, which produced
three imported parts, was not retrievable in this run. Origin is mostly
machine: the human named the repository's form, audience, licence and test
protocol, and the machine designed and wrote every fix. Assurance is A3 for
what this session produced: understood, shown by the human refuting two of the
machine's claims from his own observation and catching a defect its tests
missed, and tested, on the device with results in the transcript. The verdict
is provisional because of the unretrieved session. The main integrity concern
is the self-grading, followed by the fact that the human's sensory checks are
attested, not observable.

## Machine verdict

```json
{
  "llmgd_spec": "v0.2",
  "llmgd_number": 3,
  "assurance": "A3",
  "assurance_provisional": true,
  "flags": {"U": "yes", "T": "yes", "R": "no", "X": "no"},
  "flags_evidence": {
    "U": "Costly signals, all at the level of device behaviour, none at the level of code. Turn 11 (13:43:15Z): 'the minimum did barly go darker by deactivating als. so, do we have a deeper setting?' The human refuted the first brightness fix from his own observation and sent the work one layer down. Turn 12 (13:46:48Z): 'minimum was still the too bright min from before' contradicted the machine's belief that its below-floor register writes had taken effect; the missing latch bit was found because of it. Turn 27 (16:43:34Z): 'the display is bumping between different brightness states constantly when using it ... it bumps ~9 times back up' caught a defect that every machine-run test had missed, and the count matched the cause found afterwards (ten steps per burst). Turn 51 (18:19:43Z): 'you are diggin through togetehr jolla com? thats of no use' halted and redirected a running search. Turn 46 (18:07:47Z): 'it was never moved' corrected a wrong machine hypothesis.",
    "T": "observed: on the real tablet, with output in the transcript: every installer and uninstaller run; a full uninstall, stock-state recording and clean install with a check of each fix after reboot; PWM register read-back across brightness levels; a kernel function trace naming the process that caused the flicker; an HCI trace and kernel debug output for the pairing fault; a dummy saved network proving the WiFi mirror across a reboot; Bluetooth tethering with WiFi switched off. attested: the human's reports of what he saw and heard: turn 29 'seems to be stable now', turn 38 'i see no wake flash at all', turn 44 'they play ... also the tap paused and resumed', turn 49 'works great in various lighting', turn 53 'video plays fine'. Not tested in this session: the GPS fix after a standby, the update path, any second device.",
    "R": "Searched, not found. The standard R lexicon and the code-engagement lexicon have 0 hits in 58 human turns. No turn shows the human reading a script, a diff or the README. The repository was private and unpublished at grading time."
  },
  "origin": {"O0": 0.65, "O1": 0.35, "O2": 0.0, "O3": 0.0, "O4": 0.0},
  "origin_headline": "O0",
  "origin_evidence": [
    "O0, the human feeds a fact or a goal and the machine designs: turn 11 'do we have a deeper setting?' led to the machine's bind mount and PWM helper; turn 27 (the flicker) led to the machine finding and stopping the DPST daemon; turn 30 (16:58:17Z) 'the tablet claimed the headphnes did not answer' led to the machine's key-loading script; turn 55 (19:18:29Z) on Bluetooth tethering led to the machine's bt-tether command.",
    "O1, the human names the design: turn 17 (14:01:35Z) 'a jolla-tablet-2026 repo ... patches/scripts/install instructions as individual files ... and a readme'; turn 21 (14:10:27Z) 'no getting-started page needed ... dedicated to experienced users'; turn 25 (14:24:47Z) 'please use SPDX license headers'; turn 30 'gpl 2 oe later'; turn 38 (17:28:52Z) 'go ahead uninstalling all successively and do the clean install and pair test after wards'; turn 48 (18:14:32Z) 'we shold list all the threads'; turn 14 (13:51:47Z) 'the lowest step was kidof ideal as lowest' fixed the brightness floor.",
    "Sensitivity: the 0.65 / 0.35 split is a judgment. Counting the human's choices among options the machine presented (the floor value, which zram fix, which forum threads to pursue) as naming the design moves roughly 0.15 toward O1 and makes it near even. The stricter reading used here keeps the headline at O0.",
    "Unassessed: the GPS library source, wifi-boot-kick.sh with its unit, and docs/update-to-4.6.0.15.md were produced in a different session. Their origin is not graded. They are about an eighth of the repository by text (8.4 of 71 kB)."
  ],
  "preset_pair": "O0·A3",
  "scope": "The repository moWerk/jolla-tablet-2026 at commit 709e22e: fixes/ (wifi, brightness, gps, bluetooth, boot), lib/, docs/, README. Not graded: the rest of the session's work (a phone upgrade, a knowledge corpus).",
  "retrieval_log": {
    "searched": [
      "~/.claude/projects/<slug of the working directory>/ on the machine the session ran on",
      "the sibling directory <session-id>/subagents/ and <session-id>/tool-results/",
      "the other project directories under ~/.claude/projects/ on the same machine (three, belonging to unrelated sessions; listed, not opened)"
    ],
    "found": [
      {"id": "afced4d4-4500-4c4e-93ee-d8693735723a.jsonl", "size": "6.7 MB", "span": "2026-10-03T12:27:08Z .. 19:49:11Z", "records": 2667, "method": "stream-filter for human turns, then all 58 human turns read in full; standard lexicons run verbatim: U/correction 9 of 58 turns, R/review 0, code-engagement 0; 5 'Request interrupted' markers"},
      {"id": "subagents/agent-ab3fb00d3ef716b28.jsonl", "size": "1.1 MB", "span": "2026-10-03 evening", "records": 125, "method": "not read; a machine-only forum search with no human turns; its output was checked against the saved thread texts"}
    ],
    "skipped": [
      {"what": "An earlier session on another machine, 2026-10-01 to 2026-10-03, which produced the GPS library, the WiFi kick script and the update procedure", "why": "Its transcript is on another machine. This run had only its handover document, which is a model-written summary and not raw evidence."},
      {"what": "Assistant turns and tool output of the main transcript", "why": "Not read back as a whole. The grader is the session that produced them and cited them from its own record; a third party should stream them."}
    ]
  },
  "coverage": "unretrieved",
  "coverage_gaps": [
    "unretrieved: the transcript of the earlier session (exists, on another machine). It decides origin and assurance for three imported parts.",
    "unverifiable by construction: what the human saw and heard on the device. Those tests are attested.",
    "The human turns typed while the model was working are not stored as 'user' records. A first extraction that followed the grading prompt literally found 34 of the 58 turns. See the instrument notes."
  ],
  "integrity_flags": [
    "self-grading: same model, same session, graded minutes after the last change, with the whole session in its context. A structural conflict of interest. A third-party rerun is recommended.",
    "selective-retrieval risk: author-side run. The retrieval log above is the only check on it.",
    "inflation risk on U: the human's understanding is shown for how the device behaves and for the mechanisms discussed, not for the code. A stricter grader could read that as T feeding back, and score U lower.",
    "single device, single tester: every sensory test was done by one person on one tablet.",
    "voice: the README and the docs are written in the repository owner's voice by the machine. He had not read them at grading time."
  ],
  "retrieval": "author-side",
  "grader_model": "claude-fable-5-1 (the model that produced the work, in the producing session)",
  "run_declaration": "first run"
}
```

## What went wrong on the way

A process record, because a clean result hides how it was reached. Every item
was caught and corrected. The mechanism of each error is given.

1. **A unit that broke the boot.** The first brightness unit was ordered
   before `mce` and, by default, after `basic.target`. `mce` itself is ordered
   before `basic.target`. systemd broke the loop by not starting `mce`. The
   tablet sat on the logo. The check script that ran right after printed a full
   table of meaningless numbers, because it did not test whether `mce` was
   running.
2. **A flickering display, handed over as finished.** Every test of the
   brightness fix looked at a static screen. In use, a vendor daemon reset the
   backlight ten times on every change of the picture. The human found it by
   using the tablet.
3. **A WiFi fix that was believed proven and was not.** One part of the
   earlier fix, a udev rule, did not decide which address connman used. The
   other part copied saved networks into files that connman did not recognise,
   because their first line still named the other address. It was found when a
   boot with the rule in place came up with the other address anyway.
4. **An installer that disabled the fix it installed.** The GPS installer set
   owner and mode in one call. Changing the owner cleared the setuid bit, and
   the library was ignored. Found by comparing a file listing before and after.
5. **Deleted files that belonged to an installed package.** This one was on a
   phone in the same session, not on the tablet, and nothing in this
   repository comes from it. While tidying, a directory was removed without
   checking which package owned its files. It says something about the care
   taken, so it is listed.
6. **A wrong diagnosis: the cable.** The tablet's USB stopped working and the
   machine blamed the cable. A reboot cured it. The cause was most likely the
   machine's own restart of connman.
7. **Three unusable measurements.** The power measurement needed four
   attempts. The display blanked during the first three, and the first version
   of the script did not check for that.
8. **A register that read back a value it was not using.** A write to the PWM
   controller read back correctly and had no effect. The machine took the
   read-back as success. The human reported that nothing had changed.
9. **A quote that was not in the source.** The forum research returned a
   quote that the saved thread text does not contain. It was removed before
   publication.

## Instrument notes for the standard

Found while grading. They concern the grading prompt, not this repository.

- **Queued messages are not `user` records.** In Claude Code a message typed
  while the model is working is stored as an `attachment` record of type
  `queued_command` with `origin.kind = human`. The prompt's instruction to
  extract `type:"user"` turns dropped 24 of 58 human turns here, among them the
  flicker report, the strongest U evidence in the session.
- **The standard U lexicon missed the decisive turns.** Of the three turns
  that carry U here, the lexicon matched one, and that by the word "actually".
  The others say "sadly", "barely" and "still". Reading all human turns found
  them. For a larger transcript that is not an option.
- **U at the level of behaviour.** The rubric asks for demonstrated
  comprehension. Here the human demonstrated it for what the device does, and
  never for the code. The spec's own worked example awards U on the same kind
  of evidence. The verdict flags it, because a reader may expect more.
