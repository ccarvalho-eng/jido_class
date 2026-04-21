defmodule FounderBootstrapTest do
  use ExUnit.Case
  alias Jido.Agent.Directive
  alias JidoClass.Actions.AddIdea
  alias JidoClass.Actions.GreenlightIdea
  alias JidoClass.Actions.PlanMilestone
  alias JidoClass.FounderAgent

  test "founder organizes ideas into a first milestone" do
    founder = FounderAgent.new()

    {founder, []} =
      FounderAgent.cmd(
        founder,
        {AddIdea,
         %{
           name: "Dungeon Postal",
           genre: "management sim",
           hook: "Deliver mail in a cursed dungeon"
         }}
      )

    {founder, []} =
      FounderAgent.cmd(
        founder,
        {AddIdea,
         %{
           name: "Orbit Cafe",
           genre: "cozy sim",
           hook: "Run a coffee shop on a drifting station"
         }}
      )

    {founder, []} = FounderAgent.cmd(founder, {GreenlightIdea, %{name: "Orbit Cafe"}})

    {founder, []} =
      FounderAgent.cmd(founder, {PlanMilestone, %{milestone: "build a playable prototype"}})

    assert founder.state.active_idea == "Orbit Cafe"
    assert founder.state.next_milestone == "build a playable prototype"

    assert founder.state.idea_backlog == [
             %{
               name: "Dungeon Postal",
               genre: "management sim",
               hook: "Deliver mail in a cursed dungeon"
             },
             %{
               name: "Orbit Cafe",
               genre: "cozy sim",
               hook: "Run a coffee shop on a drifting station"
             }
           ]
  end

  test "greenlighting an unknown idea emits an error directive and keeps state unchanged" do
    founder = FounderAgent.new()

    {updated_founder, directives} =
      FounderAgent.cmd(founder, {GreenlightIdea, %{name: "Missing Project"}})

    assert updated_founder.state.active_idea == nil
    assert [%Directive.Error{error: error, context: :instruction}] = directives
    assert error.message == "Instruction failed"
  end
end
