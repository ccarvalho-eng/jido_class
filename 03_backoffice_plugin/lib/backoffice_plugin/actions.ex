defmodule BackofficePlugin.Actions.AddIdea do
  @moduledoc false

  use Jido.Action,
    name: "add_idea",
    schema: [
      name: [type: :string, required: true],
      genre: [type: :string, required: true],
      hook: [type: :string, required: true]
    ]

  @impl true
  def run(params, context) do
    backlog = Map.get(context.state, :idea_backlog, [])

    idea = %{
      name: params.name,
      genre: params.genre,
      hook: params.hook
    }

    {:ok, %{idea_backlog: backlog ++ [idea]}}
  end
end

defmodule BackofficePlugin.Actions.AllocateBudget do
  @moduledoc false

  use Jido.Action,
    name: "allocate_budget",
    schema: [
      category: [type: :string, required: true],
      amount: [type: :integer, required: true]
    ]

  @impl true
  def run(%{category: category, amount: amount}, context) do
    allocations = get_in(context.state, [:backoffice, :allocations]) || []

    allocation = %{
      category: category,
      amount: amount
    }

    {:ok, %{backoffice: %{allocations: allocations ++ [allocation]}}}
  end
end

defmodule BackofficePlugin.Actions.ApproveHire do
  @moduledoc false

  use Jido.Action,
    name: "approve_hire",
    schema: [
      role: [type: :string, required: true]
    ]

  @impl true
  def run(%{role: role}, context) do
    approved_roles = get_in(context.state, [:backoffice, :approved_roles]) || []

    {:ok, %{backoffice: %{approved_roles: approved_roles ++ [role]}}}
  end
end

defmodule BackofficePlugin.Actions.MarkPayrollReady do
  @moduledoc false

  use Jido.Action,
    name: "mark_payroll_ready",
    schema: []

  @impl true
  def run(_params, _context) do
    {:ok, %{backoffice: %{payroll_ready: true}}}
  end
end
