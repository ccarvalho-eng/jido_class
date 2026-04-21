defmodule AIStudioMode.Actions.RequestRoleDraft do
  @moduledoc """
  Requests one AI draft for the receiving role through a runtime instruction.
  """

  alias AIStudioMode.Prompts
  alias Jido.Agent.Directive
  alias Jido.Instruction

  use Jido.Action,
    name: "request_role_draft",
    description: "Starts one AI draft through RunInstruction",
    schema: [
      round: [type: :integer, required: true],
      milestone: [type: :string, required: true],
      player_promise: [type: :string, required: true]
    ]

  @impl true
  def run(%{round: round} = params, context) do
    role = Map.get(context.state, :role_name)

    instruction =
      Instruction.new!(%{
        action: AIStudioMode.Actions.GenerateRoleDraft,
        params: %{
          role: role,
          prompt: Prompts.build(role, params)
        }
      })

    result_action =
      case role do
        "cto" -> AIStudioMode.Actions.RecordRoleDraftResult
        "designer" -> AIStudioMode.Actions.RecordRoleDraftResult
        "qa" -> AIStudioMode.Actions.RecordRoleDraftResult
      end

    directive =
      Directive.run_instruction(instruction,
        result_action: result_action,
        meta: %{round: round}
      )

    {:ok, %{}, [directive]}
  end
end
