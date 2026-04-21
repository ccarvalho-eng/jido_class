defmodule AIStudioMode.Actions.RequestProductAITeam do
  @moduledoc """
  Brings the designer and QA online under product.
  """

  alias AIStudioMode.{DesignerAgent, QAAgent}
  alias Jido.Agent.Directive

  use Jido.Action,
    name: "request_product_ai_team",
    description: "Spawns design and QA beneath the product manager",
    schema: []

  @impl true
  def run(_params, context) do
    child_state = inherited_ai_state(context.state)

    directives = [
      Directive.spawn_agent(DesignerAgent, :designer,
        opts: %{initial_state: Map.put(child_state, :role_name, "designer")}
      ),
      Directive.spawn_agent(QAAgent, :qa,
        opts: %{initial_state: Map.put(child_state, :role_name, "qa")}
      )
    ]

    {:ok, %{}, directives}
  end

  defp inherited_ai_state(state) do
    %{
      ai_adapter: Map.get(state, :ai_adapter),
      ollama_model: Map.get(state, :ollama_model),
      ollama_base_url: Map.get(state, :ollama_base_url)
    }
  end
end
