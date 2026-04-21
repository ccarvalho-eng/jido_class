defmodule AIStudioMode.CEOAgent do
  @moduledoc """
  CEO for lesson 8.

  This agent keeps the company structure intact and aggregates the final
  AI-assisted planning packet.
  """

  alias AIStudioMode.AIAdapters.FakeAdapter

  use Jido.Agent,
    name: "ceo",
    description: "Coordinates the final AI-assisted planning round",
    default_plugins: false,
    schema: [
      leadership_team: [type: {:list, :string}, default: []],
      child_boot_events: [type: {:list, :map}, default: []],
      child_registry: [type: :map, default: %{}],
      technical_updates: [type: {:list, :map}, default: []],
      product_updates: [type: {:list, :map}, default: []],
      alignment_packets: [type: {:list, :map}, default: []],
      ai_adapter: [type: :atom, default: FakeAdapter],
      ollama_model: [type: :string, default: "llama3"],
      ollama_base_url: [type: :string, default: "http://localhost:11434/v1"]
    ]

  def signal_routes(_ctx) do
    [
      {"studio.ai_staff_requested", AIStudioMode.Actions.RequestAIStaff},
      {"jido.agent.child.started", AIStudioMode.Actions.RecordLeadershipChildStarted},
      {"studio.ai_planning_round_requested", AIStudioMode.Actions.RequestAIPlanningRound},
      {"studio.technical_alignment_received",
       AIStudioMode.Actions.RecordTechnicalAlignmentReceived},
      {"studio.product_alignment_received", AIStudioMode.Actions.RecordProductAlignmentReceived}
    ]
  end
end
