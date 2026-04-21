defmodule AIStudioMode.Actions.RecordLeadershipChildStarted do
  @moduledoc """
  Records leadership startup and asks the product manager to bring design and QA online.
  """

  alias AIStudioMode.Alignment

  use Jido.Action,
    name: "record_leadership_child_started",
    description: "Stores leadership startup events and triggers the PM subteam",
    schema: [
      child_id: [type: :string, required: true],
      tag: [type: :any, required: true]
    ]

  @impl true
  def run(%{child_id: child_id, tag: tag}, context) do
    {updates, directives} = Alignment.leadership_child_started(context.state, child_id, tag)
    {:ok, updates, directives}
  end
end
