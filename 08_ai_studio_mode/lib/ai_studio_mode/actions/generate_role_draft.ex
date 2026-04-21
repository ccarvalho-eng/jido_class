defmodule AIStudioMode.Actions.GenerateRoleDraft do
  @moduledoc """
  Executes the actual adapter call for a role draft.
  """

  use Jido.Action,
    name: "generate_role_draft",
    description: "Calls the configured AI adapter for one role draft",
    schema: [
      role: [type: :string, required: true],
      prompt: [type: :string, required: true]
    ]

  @impl true
  def run(%{role: role, prompt: prompt}, context) do
    adapter = Map.fetch!(context.state, :ai_adapter)

    opts = %{
      model: Map.get(context.state, :ollama_model, "llama3"),
      base_url: Map.get(context.state, :ollama_base_url, "http://localhost:11434/v1")
    }

    case adapter.generate_text(role, prompt, opts) do
      {:ok, text} -> {:ok, %{role: role, prompt: prompt, text: text}}
      {:error, reason} -> {:error, reason}
    end
  end
end
