# Lesson 06: The Studio Learns a Rhythm

With a CTO in place, the studio can finally add the next layer down: someone who manages the day-to-day engineering loop and keeps delivery moving.

This chapter will introduce:

- an `EngineeringManagerAgent`
- one or more `EngineerAgent`s
- scheduling
- recurring workflows
- QA or playtest feedback loops
- recurring engineering and operations cadences

At this point, the CTO sets direction, the engineering manager coordinates execution, engineers deliver scoped work, and the system starts repeating on a cadence.

This chapter should teach something different from the CTO chapter:

- the `EngineeringManagerAgent` teaches fan-out and result aggregation across multiple children
- the `EngineerAgent` teaches specialized worker state and narrow task execution
- the recurring cadence teaches how Jido handles ongoing delivery loops without collapsing everything back into the founder
