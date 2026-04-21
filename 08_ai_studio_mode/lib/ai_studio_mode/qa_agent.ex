defmodule AIStudioMode.QAAgent do
  @moduledoc """
  QA agent for lesson 8.
  """

  alias AIStudioMode.AIAdapters.FakeAdapter

  use Jido.Agent,
    name: "qa",
    description: "Owns the AI-assisted QA summary draft",
    default_plugins: false,
    schema: [
      role_name: [type: :string, default: "qa"],
      drafts: [type: {:list, :map}, default: []],
      ai_adapter: [type: :atom, default: FakeAdapter],
      ollama_model: [type: :string, default: "llama3"],
      ollama_base_url: [type: :string, default: "http://localhost:11434/v1"]
    ]

  def signal_routes(_ctx) do
    [
      {"qa.ai_summary_requested", AIStudioMode.Actions.RequestRoleDraft},
      {"qa.ai_instruction_result", AIStudioMode.Actions.RecordRoleDraftResult}
    ]
  end
end
