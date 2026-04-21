defmodule AIStudioMode.DesignerAgent do
  @moduledoc """
  Designer for lesson 8.
  """

  alias AIStudioMode.AIAdapters.FakeAdapter

  use Jido.Agent,
    name: "designer",
    description: "Owns the AI-assisted design direction draft",
    default_plugins: false,
    schema: [
      role_name: [type: :string, default: "designer"],
      drafts: [type: {:list, :map}, default: []],
      ai_adapter: [type: :atom, default: FakeAdapter],
      ollama_model: [type: :string, default: "llama3"],
      ollama_base_url: [type: :string, default: "http://localhost:11434/v1"]
    ]

  def signal_routes(_ctx) do
    [
      {"design.ai_direction_requested", AIStudioMode.Actions.RequestRoleDraft},
      {"design.ai_instruction_result", AIStudioMode.Actions.RecordRoleDraftResult}
    ]
  end
end
