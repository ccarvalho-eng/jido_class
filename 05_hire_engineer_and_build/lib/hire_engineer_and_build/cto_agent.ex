defmodule HireEngineerAndBuild.CTOAgent do
  @moduledoc """
  CTO agent for lesson 5.

  The CTO owns technical direction, roadmap shape, and hiring intent.
  """

  use Jido.Agent,
    name: "cto",
    description: "Technical leader who owns engineering strategy for the studio",
    default_plugins: false,
    schema: [
      technical_roadmap: [type: {:list, :map}, default: []],
      hiring_intent: [type: {:list, :string}, default: []],
      architecture_decisions: [type: {:list, :string}, default: []]
    ]

  def signal_routes(_ctx) do
    [
      {"cto.technical_strategy_requested", HireEngineerAndBuild.Actions.ProposeTechnicalStrategy}
    ]
  end
end
