defmodule AIStudioMode.Prompts do
  @moduledoc """
  Prompt builder for the role-specific drafts in lesson 8.
  """

  def build("cto", %{milestone: milestone, player_promise: player_promise}) do
    """
    Role: CTO
    Goal: produce a concise technical strategy draft for the next planning round.
    Milestone: #{milestone}
    Player promise: #{player_promise}
    Focus on architecture, delivery risk, and the first technical priority.
    """
  end

  def build("product_manager", %{milestone: milestone, player_promise: player_promise}) do
    """
    Role: Product Manager
    Goal: produce a short scope brief for the planning round.
    Milestone: #{milestone}
    Player promise: #{player_promise}
    Focus on player value, scope discipline, and what must feel true in the next build.
    """
  end

  def build("designer", %{milestone: milestone, player_promise: player_promise}) do
    """
    Role: Designer
    Goal: propose a player-facing direction for the next planning round.
    Milestone: #{milestone}
    Player promise: #{player_promise}
    Focus on readability, interaction feel, and what the player should immediately understand.
    """
  end

  def build("qa", %{milestone: milestone, player_promise: player_promise}) do
    """
    Role: QA
    Goal: summarize the main playtest risk for the next planning round.
    Milestone: #{milestone}
    Player promise: #{player_promise}
    Focus on what could break trust for a first-time player.
    """
  end
end
