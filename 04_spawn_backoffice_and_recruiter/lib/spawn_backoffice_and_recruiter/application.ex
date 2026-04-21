defmodule SpawnBackofficeAndRecruiter.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      SpawnBackofficeAndRecruiter.StudioJido
    ]

    Supervisor.start_link(children,
      strategy: :one_for_one,
      name: SpawnBackofficeAndRecruiter.Supervisor
    )
  end
end
