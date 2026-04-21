defmodule BackofficePlugin.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BackofficePlugin.StudioJido
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: BackofficePlugin.Supervisor)
  end
end
