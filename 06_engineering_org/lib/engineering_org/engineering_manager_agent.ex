defmodule EngineeringOrg.EngineeringManagerAgent do
  @moduledoc """
  Engineering manager for lesson 6.

  This agent fans work out to engineers and aggregates their results.
  """

  use Jido.Agent,
    name: "engineering_manager",
    description: "Runs day-to-day engineering execution beneath the CTO",
    default_plugins: false,
    schema: [
      active_milestone: [type: :string, default: nil],
      expected_disciplines: [type: {:list, :string}, default: []],
      engineer_boot_events: [type: {:list, :map}, default: []],
      completed_reports: [type: {:list, :map}, default: []]
    ]

  def signal_routes(_ctx) do
    [
      {"engineering.team_bootstrap_requested", EngineeringOrg.Actions.BootstrapEngineeringTeam},
      {"jido.agent.child.started", EngineeringOrg.Actions.RecordEngineerChildStarted},
      {"engineering.task_completed", EngineeringOrg.Actions.RecordEngineerTaskCompleted}
    ]
  end
end
