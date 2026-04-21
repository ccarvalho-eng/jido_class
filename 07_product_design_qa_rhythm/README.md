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

This chapter brings in:

- a `ProductManagerAgent`
- a `DesignerAgent`
- a `QAAgent` or `PlaytestAgent`
- scheduling and recurring workflows
- workflow-level regression tests
- observability and debugging hooks for repeated runtime behavior

The focus is confidence under repetition: knowing what happened, proving the loops still behave as intended, and making the ongoing system inspectable.

The product manager belongs here because this is the point where the CEO can finally stop acting as the default product owner. The designer arrives for the same reason. Once engineering has a real execution layer, the studio also needs someone shaping the player-facing experience without turning the CTO or the engineers into accidental designers.

At this stage the studio needs roles that can:

- translate company goals into milestone scope
- turn scope into player-facing interaction, UX, and presentation decisions
- negotiate tradeoffs with technical leadership
- keep recurring planning loops healthy

By this point the story can finally play all of its layers at once:

- CEO-level outcomes
- product-level milestone framing
- design-level experience and presentation decisions
- CTO-level technical decisions
- engineering-manager aggregation
- engineer execution traces

Instead of treating the whole studio as one opaque runtime, this chapter follows the motion between those layers and makes the rhythm visible.
