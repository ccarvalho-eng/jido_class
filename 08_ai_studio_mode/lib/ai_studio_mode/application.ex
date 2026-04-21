defmodule AIStudioMode.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      AIStudioMode.StudioJido
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: AIStudioMode.Supervisor)
  end
end
