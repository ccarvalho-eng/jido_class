defmodule EngineeringOrg.CTOAgent do
  @moduledoc """
  CTO agent for lesson 6.

  The CTO now owns a real execution layer instead of only high-level planning.
  """

  use Jido.Agent,
    name: "cto",
    description: "Technical leader who delegates execution to an engineering manager",
    default_plugins: false,
    schema: [
      execution_team: [type: {:list, :string}, default: []],
      execution_boot_events: [type: {:list, :map}, default: []],
      milestone_snapshots: [type: {:list, :map}, default: []]
    ]

  def signal_routes(_ctx) do
    [
      {"studio.execution_layer_requested", EngineeringOrg.Actions.RequestExecutionLayer},
      {"jido.agent.child.started", EngineeringOrg.Actions.RecordExecutionChildStarted},
      {"engineering.milestone_delivery_snapshot",
       EngineeringOrg.Actions.RecordMilestoneDeliverySnapshot}
    ]
  end
end
