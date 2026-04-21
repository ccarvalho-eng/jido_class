defmodule FounderRuntime.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      FounderRuntime.StudioJido
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: FounderRuntime.Supervisor)
  end
end
