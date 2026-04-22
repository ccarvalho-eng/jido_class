# Lesson 04: The CEO Spawns a Support Team

The studio is no longer a one-agent company.

By lesson 3, the founder had a runtime and a backoffice capability plugin. That was useful, but it still kept everything inside one agent process.

This chapter is the next architectural step: the founder is now acting as the CEO and starts spinning up a real support team.

The important shift is not just "more agents exist." The important shift is that **the CEO now manages a hierarchy**.

Interactive companion: [`../livebooks/04_spawn_backoffice_and_recruiter.livemd`](../livebooks/04_spawn_backoffice_and_recruiter.livemd)

## What You'll Learn

By the end of this lesson, you should understand:

- how to spawn child agents with `Directive.spawn_agent/3`
- how Jido tracks parent-child relationships in runtime state
- how spawned children receive a parent reference automatically
- how child agents can report back up to the parent with `Directive.emit_to_parent/3`
- how Jido emits lifecycle signals like `jido.agent.child.started`

## The Story

The founder has crossed an invisible line.

At the beginning of the series, there was one person with a backlog.

By lesson 3, that same person had become operationally capable, but still personally owned every function in the company.

That stops here.

In this chapter, the founder becomes the CEO in practice:

- the CEO keeps the top-level company priority
- the CEO spawns a `BackofficeAgent`
- the CEO spawns a `RecruiterAgent`
- each child owns one narrow responsibility
- each child reports its work back to the CEO

This is the first moment where the startup behaves like a small org chart instead of one increasingly overloaded process.

## The Jido Concept

Lesson 3 taught capability composition with plugins.

Lesson 4 teaches something different:

> when a responsibility deserves its own runtime lifecycle, it should become its own agent.

That is why backoffice is no longer just a plugin-mounted capability here. It becomes a live child agent because it now has:

- its own process
- its own signal routes
- its own state
- its own reporting path back to the CEO

The same is true for recruiting.

## What We're Building

We will create:

- `SpawnBackofficeAndRecruiter.StudioJido`
- `SpawnBackofficeAndRecruiter.CEOAgent`
- `SpawnBackofficeAndRecruiter.BackofficeAgent`
- `SpawnBackofficeAndRecruiter.RecruiterAgent`

The CEO will:

- receive `studio.support_team_requested`
- spawn backoffice and recruiting children
- record startup lifecycle events from those children
- record recruiting and backoffice updates as they report back

The recruiter will:

- receive `recruiter.role_opened`
- store the open role locally
- emit `studio.role_search_started` back to the CEO

The backoffice agent will:

- receive `backoffice.hiring_review_requested`
- store the requested review locally
- emit `studio.hiring_constraints_prepared` back to the CEO

## The Code

The lesson’s code lives in:

- [`lib/spawn_backoffice_and_recruiter/ceo_agent.ex`](./lib/spawn_backoffice_and_recruiter/ceo_agent.ex)
- [`lib/spawn_backoffice_and_recruiter/backoffice_agent.ex`](./lib/spawn_backoffice_and_recruiter/backoffice_agent.ex)
- [`lib/spawn_backoffice_and_recruiter/recruiter_agent.ex`](./lib/spawn_backoffice_and_recruiter/recruiter_agent.ex)
- [`lib/spawn_backoffice_and_recruiter/actions/request_support_team.ex`](./lib/spawn_backoffice_and_recruiter/actions/request_support_team.ex)
- [`lib/spawn_backoffice_and_recruiter/actions/record_child_started.ex`](./lib/spawn_backoffice_and_recruiter/actions/record_child_started.ex)
- [`lib/spawn_backoffice_and_recruiter/actions/record_role_search_started.ex`](./lib/spawn_backoffice_and_recruiter/actions/record_role_search_started.ex)
- [`lib/spawn_backoffice_and_recruiter/actions/record_hiring_constraints_prepared.ex`](./lib/spawn_backoffice_and_recruiter/actions/record_hiring_constraints_prepared.ex)
- [`lib/spawn_backoffice_and_recruiter/actions/start_role_search.ex`](./lib/spawn_backoffice_and_recruiter/actions/start_role_search.ex)
- [`lib/spawn_backoffice_and_recruiter/actions/prepare_hiring_constraints.ex`](./lib/spawn_backoffice_and_recruiter/actions/prepare_hiring_constraints.ex)

The CEO’s support-team action is the center of the chapter:

```elixir
defmodule SpawnBackofficeAndRecruiter.Actions.RequestSupportTeam do
  alias Jido.Agent.Directive
  alias SpawnBackofficeAndRecruiter.{BackofficeAgent, RecruiterAgent}

  use Jido.Action,
    name: "request_support_team",
    description: "Spawns backoffice and recruiter support agents",
    schema: []

  def run(_params, _context) do
    directives = [
      Directive.spawn_agent(BackofficeAgent, :backoffice),
      Directive.spawn_agent(RecruiterAgent, :recruiter)
    ]

    {:ok, %{support_team: ["backoffice", "recruiter"]}, directives}
  end
end
```

That is the lesson 4 leap.

The CEO updates its own state, but also emits external runtime effects that create real child agents.

## Child Startup Signals

When Jido spawns a child agent, the child reports its startup back to the parent with a lifecycle signal:

- `jido.agent.child.started`

This chapter takes advantage of that instead of ignoring it.

The CEO routes that signal into a small action that records support-team boot events:

```elixir
{"jido.agent.child.started", SpawnBackofficeAndRecruiter.Actions.RecordChildStarted}
```

That matters because it teaches a useful runtime fact:

> Jido hierarchies are observable at the signal level, not only through hidden process metadata.

## Child-To-Parent Reporting

The recruiter and backoffice agents both use the same pattern:

- handle a role-specific signal locally
- update their own state
- emit a domain result back to the CEO

The recruiter example:

```elixir
signal =
  Signal.new!(
    "studio.role_search_started",
    %{role: role, status: "search_started"},
    source: "/recruiter"
  )

directive = Directive.emit_to_parent(context.agent, signal)

{:ok, %{open_roles: open_roles ++ [role]}, List.wrap(directive)}
```

That is different from lesson 2, where the founder only reacted to external studio events.

Here, a child is using the runtime parent reference that Jido injected automatically during spawn.

## Trying It Out

Run the lesson:

```bash
cd 04_spawn_backoffice_and_recruiter
mix deps.get
mix test
```

If your shell is not already resolving asdf shims first:

```bash
PATH="$HOME/.asdf/shims:$HOME/.asdf/bin:$PATH" mix test
```

You can also inspect the full flow in `iex`:

```bash
PATH="$HOME/.asdf/shims:$HOME/.asdf/bin:$PATH" iex -S mix
```

Then:

```elixir
alias Jido.{AgentServer, Signal}
alias SpawnBackofficeAndRecruiter.{CEOAgent, StudioJido}

{:ok, pid} = StudioJido.start_agent(CEOAgent, id: "ceo-1")

{:ok, _ceo} =
  AgentServer.call(
    pid,
    Signal.new!("studio.support_team_requested", %{}, source: "/ceo")
  )

{:ok, runtime_state} = AgentServer.state(pid)

recruiter_pid = runtime_state.children.recruiter.pid
backoffice_pid = runtime_state.children.backoffice.pid

AgentServer.call(
  recruiter_pid,
  Signal.new!("recruiter.role_opened", %{role: "gameplay engineer"}, source: "/ceo")
)

AgentServer.call(
  backoffice_pid,
  Signal.new!("backoffice.hiring_review_requested", %{role: "gameplay engineer"}, source: "/ceo")
)

{:ok, updated_state} = AgentServer.state(pid)
updated_state.agent.state
```

You should see:

- a CEO with two tracked child agents
- startup lifecycle events recorded under `support_team_boot_events`
- a recruiting update from the recruiter child
- a hiring-constraints update from the backoffice child

## What the Tests Prove

The lesson 4 tests in [`test/spawn_backoffice_and_recruiter_test.exs`](./test/spawn_backoffice_and_recruiter_test.exs) prove two things:

- the CEO can spawn child agents and Jido tracks them under `state.children`
- those child agents can report role-specific results back to the CEO

That second assertion is the important one.

Without that reporting path, "spawning children" would just be process management.

With it, the company starts behaving like an actual hierarchy.

## Why This Matters

This chapter answers a design question that starts appearing in any growing Jido system:

When should a capability stay inside one agent, and when should it become a child agent?

The answer here is:

- if it is just reusable behavior, use a plugin
- if it deserves an independent lifecycle, use a child agent

That is why lesson 3 used a plugin and lesson 4 uses spawned agents.

The distinction is not cosmetic. It is architectural.

## Jido Takeaway

`Directive.spawn_agent/3` is not just a convenience API.

It is the point where one agent can stop being a solitary worker and start becoming the manager of a real runtime hierarchy.

That hierarchy becomes especially useful when:

- children own narrow domains
- children send structured results upward
- the parent aggregates outcomes without absorbing all the work

## What the Studio Can Do Now

The studio can now:

- run a CEO agent
- spawn a support team at runtime
- observe child startup events
- let recruiting own role-search work
- let backoffice own hiring-review preparation
- aggregate support-team updates back at the CEO layer

The company finally feels like more than one person with more features.

## What Still Hurts

The CEO now has support, but the technical side of the company is still missing.

There is no technical leader yet.

The CEO can hire and organize support work, but still does not have a dedicated agent that owns engineering direction.

That is the next problem.

## Next Lesson

[`05_hire_a_cto`](../05_hire_a_cto/README.md) introduces the `CTOAgent`.

That chapter moves the company from support structure into technical leadership. The important shift is not another child process. It is the arrival of a real technical boundary, where the CEO stops carrying detailed engineering decisions and the CTO starts owning them.
