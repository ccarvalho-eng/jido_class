defmodule EngineeringOrg.Actions.RecordEngineerChildStarted do
  @moduledoc """
  Records engineer startup events beneath the engineering manager.
  """

  use Jido.Action,
    name: "record_engineer_child_started",
    description: "Stores startup events for engineer children",
    schema: [
      child_id: [type: :string, required: true],
      tag: [type: :any, required: true]
    ]

  @impl true
  def run(%{child_id: child_id, tag: tag}, context) do
    events = Map.get(context.state, :engineer_boot_events, [])
    event = %{child_id: child_id, tag: normalize_tag(tag)}

    {:ok, %{engineer_boot_events: events ++ [event]}}
  end

  defp normalize_tag(tag) when is_atom(tag), do: Atom.to_string(tag)
  defp normalize_tag(tag), do: to_string(tag)
end
