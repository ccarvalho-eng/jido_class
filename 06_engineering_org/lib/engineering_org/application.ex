defmodule EngineeringOrg.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      EngineeringOrg.StudioJido
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: EngineeringOrg.Supervisor)
  end
end
