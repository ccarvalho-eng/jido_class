defmodule SpawnBackofficeAndRecruiter.Actions.RecordChildStarted do
  @moduledoc """
  Records runtime lifecycle signals when a spawned child comes online.
  """

  use Jido.Action,
    name: "record_child_started",
    description: "Stores support-team startup events emitted by spawned children",
    schema: [
      child_id: [type: :string, required: true],
      tag: [type: :any, required: true]
    ]

  @impl true
  def run(%{child_id: child_id, tag: tag}, context) do
    events = Map.get(context.state, :support_team_boot_events, [])
    event = %{child_id: child_id, tag: normalize_tag(tag)}

    {:ok, %{support_team_boot_events: events ++ [event]}}
  end

  defp normalize_tag(tag) when is_atom(tag), do: Atom.to_string(tag)
  defp normalize_tag(tag), do: to_string(tag)
end
