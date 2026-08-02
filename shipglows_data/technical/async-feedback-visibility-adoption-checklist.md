# Async Feedback Visibility Adoption Checklist

Use for one bounded flow at a time. This checklist does not imply a retrofit of every project or screen.

- [ ] Trigger and operation owner are named.
- [ ] Busy animation or measurable progress appears immediately.
- [ ] Current stage is understandable without technical jargon.
- [ ] Duplicate taps/actions are prevented or coalesced.
- [ ] Success, error, timeout, retry, and cancellation states are defined.
- [ ] A long wait has a bounded recovery path.
- [ ] Reduced-motion and screen-reader status semantics are covered.
- [ ] Status copy and logs contain no secrets, auth artifacts, or private payloads.
- [ ] Cheapest applicable proof ran first (widget/contract/browser), with native/provider/manual proof only where required.
- [ ] Remaining proof gap has an owner skill, scenario, and target/environment.
