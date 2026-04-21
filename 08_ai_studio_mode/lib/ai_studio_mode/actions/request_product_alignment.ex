defmodule AIStudioMode.Actions.RequestProductAlignment do
  @moduledoc """
  Starts the AI-assisted product alignment round.
  """

  alias AIStudioMode.Prompts
  alias AIStudioMode.StudioJido
  alias Jido.Agent.Directive
  alias Jido.Instruction
  alias Jido.Signal

  use Jido.Action,
    name: "request_product_alignment",
    description: "Requests product, design, and QA AI drafts for one planning round",
    schema: [
      round: [type: :integer, required: true],
      milestone: [type: :string, required: true],
      player_promise: [type: :string, required: true]
    ]

  @impl true
  def run(%{round: round, milestone: milestone, player_promise: player_promise} = params, context) do
    registry = Map.get(context.state, :child_registry, %{})

    instruction =
      Instruction.new!(%{
        action: AIStudioMode.Actions.GenerateRoleDraft,
        params: %{
          role: "product_manager",
          prompt: Prompts.build("product_manager", params)
        }
      })

    directives =
      [
        Directive.run_instruction(instruction,
          result_action: AIStudioMode.Actions.RecordProductDraftResult,
          meta: %{round: round}
        ),
        emit_child_request(registry["designer"], "design.ai_direction_requested", %{
          round: round,
          milestone: milestone,
          player_promise: player_promise
        }),
        emit_child_request(registry["qa"], "qa.ai_summary_requested", %{
          round: round,
          milestone: milestone,
          player_promise: player_promise
        })
      ]
      |> Enum.reject(&is_nil/1)

    {:ok, %{}, directives}
  end

  defp emit_child_request(nil, _signal_type, _payload), do: nil

  defp emit_child_request(child_id, signal_type, payload) do
    case StudioJido.whereis(child_id) do
      pid when is_pid(pid) ->
        signal = Signal.new!(signal_type, payload, source: "/product_manager")
        Directive.emit_to_pid(signal, pid)

      _missing ->
        nil
    end
  end
end
