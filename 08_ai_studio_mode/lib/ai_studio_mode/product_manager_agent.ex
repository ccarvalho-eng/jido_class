defmodule AIStudioMode.ProductManagerAgent do
  @moduledoc """
  Product manager for lesson 8.
  """

  alias AIStudioMode.AIAdapters.FakeAdapter

  use Jido.Agent,
    name: "product_manager",
    description: "Aggregates the AI-assisted product alignment packet",
    default_plugins: false,
    schema: [
      role_name: [type: :string, default: "product_manager"],
      child_boot_events: [type: {:list, :map}, default: []],
      child_registry: [type: :map, default: %{}],
      product_briefs: [type: {:list, :map}, default: []],
      design_directions: [type: {:list, :map}, default: []],
      qa_summaries: [type: {:list, :map}, default: []],
      product_alignments: [type: {:list, :map}, default: []],
      ai_adapter: [type: :atom, default: FakeAdapter],
      ollama_model: [type: :string, default: "llama3"],
      ollama_base_url: [type: :string, default: "http://localhost:11434/v1"]
    ]

  def signal_routes(_ctx) do
    [
      {"product.ai_team_requested", AIStudioMode.Actions.RequestProductAITeam},
      {"jido.agent.child.started", AIStudioMode.Actions.RecordProductChildStarted},
      {"product.ai_brief_requested", AIStudioMode.Actions.RequestProductAlignment},
      {"product.ai_instruction_result", AIStudioMode.Actions.RecordProductDraftResult},
      {"product.design_ai_received", AIStudioMode.Actions.RecordDesignDraftReceived},
      {"product.qa_ai_received", AIStudioMode.Actions.RecordQADraftReceived}
    ]
  end
end
