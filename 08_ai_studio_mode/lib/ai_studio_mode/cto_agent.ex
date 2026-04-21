defmodule AIStudioMode.CTOAgent do
  @moduledoc """
  CTO for lesson 8.
  """

  alias AIStudioMode.AIAdapters.FakeAdapter

  use Jido.Agent,
    name: "cto",
    description: "Owns the AI-assisted technical strategy draft",
    default_plugins: false,
    schema: [
      role_name: [type: :string, default: "cto"],
      drafts: [type: {:list, :map}, default: []],
      ai_adapter: [type: :atom, default: FakeAdapter],
      ollama_model: [type: :string, default: "llama3"],
      ollama_base_url: [type: :string, default: "http://localhost:11434/v1"]
    ]

  def signal_routes(_ctx) do
    [
      {"cto.ai_strategy_requested", AIStudioMode.Actions.RequestRoleDraft},
      {"cto.ai_instruction_result", AIStudioMode.Actions.RecordRoleDraftResult}
    ]
  end
end
