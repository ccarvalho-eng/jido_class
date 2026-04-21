defmodule HireEngineerAndBuild.CEOAgent do
  @moduledoc """
  CEO agent for lesson 5.

  The CEO no longer owns technical strategy directly once the CTO is in place.
  """

  use Jido.Agent,
    name: "ceo",
    description: "CEO who delegates technical planning outcomes to a CTO",
    default_plugins: false,
    schema: [
      studio_name: [type: :string, default: "Starboard Studio"],
      technical_brief: [type: :string, default: "wait for the cto"],
      leadership_team: [type: {:list, :string}, default: []],
      leadership_boot_events: [type: {:list, :map}, default: []],
      executive_updates: [type: {:list, :map}, default: []]
    ]

  def signal_routes(_ctx) do
    [
      {"studio.technical_leadership_requested",
       HireEngineerAndBuild.Actions.RequestTechnicalLeadership},
      {"jido.agent.child.started", HireEngineerAndBuild.Actions.RecordChildStarted},
      {"studio.technical_strategy_proposed",
       HireEngineerAndBuild.Actions.RecordTechnicalStrategyProposed}
    ]
  end
end
