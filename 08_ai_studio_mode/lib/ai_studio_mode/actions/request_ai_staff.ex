defmodule AIStudioMode.Actions.RequestAIStaff do
  @moduledoc """
  Brings the AI-capable leadership team online.
  """

  alias AIStudioMode.{CTOAgent, ProductManagerAgent}
  alias Jido.Agent.Directive

  use Jido.Action,
    name: "request_ai_staff",
    description: "Spawns the CTO and product manager for the AI planning round",
    schema: []

  @impl true
  def run(_params, context) do
    child_state = inherited_ai_state(context.state)

    directives = [
      Directive.spawn_agent(CTOAgent, :cto,
        opts: %{initial_state: Map.put(child_state, :role_name, "cto")}
      ),
      Directive.spawn_agent(ProductManagerAgent, :product_manager,
        opts: %{initial_state: Map.put(child_state, :role_name, "product_manager")}
      )
    ]

    {:ok, %{leadership_team: ["cto", "product_manager"]}, directives}
  end

  defp inherited_ai_state(state) do
    %{
      ai_adapter: Map.get(state, :ai_adapter),
      ollama_model: Map.get(state, :ollama_model),
      ollama_base_url: Map.get(state, :ollama_base_url)
    }
  end
end
