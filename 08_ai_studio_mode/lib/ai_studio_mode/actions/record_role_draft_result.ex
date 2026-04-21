defmodule AIStudioMode.Actions.RecordRoleDraftResult do
  @moduledoc """
  Stores one role-local AI draft and emits it upward using the right domain signal.
  """

  alias Jido.Agent.Directive
  alias Jido.Signal

  use Jido.Action,
    name: "record_role_draft_result",
    description: "Stores one role AI draft and reports it upward",
    schema: [
      status: [type: :atom, required: true],
      result: [type: :map],
      reason: [type: :any],
      instruction: [type: :any],
      meta: [type: :map, default: %{}]
    ]

  @impl true
  def run(%{status: :ok, result: %{text: text}, meta: %{round: round}}, context) do
    drafts = Map.get(context.state, :drafts, [])
    updates = %{drafts: drafts ++ [%{round: round, text: text}]}
    role = Map.get(context.state, :role_name)

    signal =
      case role do
        "cto" ->
          Signal.new!(
            "studio.technical_alignment_received",
            %{round: round, technical_strategy: text, status: "technical_alignment_ready"},
            source: "/cto"
          )

        "designer" ->
          Signal.new!(
            "product.design_ai_received",
            %{round: round, design_direction: text},
            source: "/designer"
          )

        "qa" ->
          Signal.new!(
            "product.qa_ai_received",
            %{round: round, qa_summary: text},
            source: "/qa"
          )
      end

    {:ok, updates, List.wrap(Directive.emit_to_parent(context.agent, signal))}
  end

  def run(%{status: :error, reason: reason, meta: %{round: round}}, _context) do
    {:error,
     Jido.Error.execution_error("Role AI draft failed", round: round, reason: inspect(reason))}
  end
end
