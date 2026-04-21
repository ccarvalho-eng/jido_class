defmodule BackofficePlugin.BackofficeCapability do
  @moduledoc """
  Plugin that adds budget, hiring approval, and payroll readiness state.
  """

  use Jido.Plugin,
    name: "backoffice",
    state_key: :backoffice,
    actions: [
      BackofficePlugin.Actions.AllocateBudget,
      BackofficePlugin.Actions.ApproveHire,
      BackofficePlugin.Actions.MarkPayrollReady
    ],
    description: "Reusable operations capability for finance and hiring",
    schema:
      Zoi.object(%{
        monthly_budget: Zoi.integer() |> Zoi.default(12_000),
        hiring_budget: Zoi.integer() |> Zoi.default(4_000),
        allocations: Zoi.list(Zoi.map()) |> Zoi.default([]),
        approved_roles: Zoi.list(Zoi.string()) |> Zoi.default([]),
        payroll_ready: Zoi.boolean() |> Zoi.default(false)
      }),
    signal_patterns: ["*"],
    signal_routes: [
      {"budget_allocated", BackofficePlugin.Actions.AllocateBudget},
      {"hiring_approved", BackofficePlugin.Actions.ApproveHire},
      {"payroll_marked_ready", BackofficePlugin.Actions.MarkPayrollReady}
    ]

  @impl Jido.Plugin
  def mount(_agent, config) do
    {:ok,
     %{
       monthly_budget: Map.get(config, :monthly_budget, 12_000),
       hiring_budget: Map.get(config, :hiring_budget, 4_000)
     }}
  end
end

defmodule BackofficePlugin.FounderAgent do
  @moduledoc """
  Founder agent with operational capability mounted as a plugin.
  """

  use Jido.Agent,
    name: "backoffice_founder",
    description: "Live founder agent extended with backoffice capability",
    default_plugins: false,
    schema: [
      studio_name: [type: :string, default: "Starboard Studio"],
      active_idea: [type: :string, default: nil],
      idea_backlog: [type: {:list, :map}, default: []],
      next_milestone: [type: :string, default: nil]
    ],
    plugins: [
      {BackofficePlugin.BackofficeCapability, %{monthly_budget: 12_000, hiring_budget: 4_000}}
    ]

  def signal_routes(_ctx) do
    [
      {"studio.idea_submitted", BackofficePlugin.Actions.AddIdea}
    ]
  end
end
