# Lesson 07: Product, Design, and QA Give the Studio a Rhythm

By this point the studio has company direction, technical direction, and an execution layer.

What it still lacks is rhythm.

Real startups do not run as one-off commands forever. They repeat:

- standups
- milestone reviews
- playtests
- bug triage
- release checks

That recurring pressure is exactly where observability and testability start to matter.

This chapter will introduce:

- a `ProductManagerAgent`
- a `DesignerAgent`
- a `QAAgent` or `PlaytestAgent`
- scheduling and recurring workflows
- workflow-level regression tests
- observability and debugging hooks for repeated runtime behavior

The focus is confidence under repetition: understanding what happened, proving the loops still behave as intended, and making the ongoing system inspectable.

The product manager belongs here, not earlier, because this is the point where the CEO should stop being the default product owner. The designer belongs here for the same reason: once engineering has a real execution layer, the studio also needs a role that can shape player-facing decisions without forcing the CTO or engineers to absorb that work.

At this stage the studio needs roles that can:

- translate company goals into milestone scope
- turn scope into player-facing interaction, UX, and presentation decisions
- negotiate tradeoffs with technical leadership
- keep recurring planning loops healthy

By this stage, the story should also pay off the previous org layers:

- CEO-level outcomes
- product-level milestone framing
- design-level experience and presentation decisions
- CTO-level technical decisions
- engineering-manager aggregation
- engineer execution traces

The lesson should show how to inspect those layers distinctly instead of treating the whole studio as one opaque runtime.
