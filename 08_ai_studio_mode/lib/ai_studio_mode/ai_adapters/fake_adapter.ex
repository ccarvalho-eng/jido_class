defmodule AIStudioMode.AIAdapters.FakeAdapter do
  @moduledoc """
  Deterministic AI adapter used by the lesson tests.
  """

  @behaviour AIStudioMode.AIAdapter

  @impl true
  def generate_text(role, prompt, _opts) do
    {:ok, render(role, prompt)}
  end

  defp render("cto", prompt),
    do: "CTO draft: technical plan aligned to #{extract_phrase(prompt, "player promise")}"

  defp render("product_manager", prompt),
    do: "Product draft: scope brief anchored in #{extract_phrase(prompt, "player promise")}"

  defp render("designer", prompt),
    do:
      "Design draft: interaction direction that reinforces #{extract_phrase(prompt, "player promise")}"

  defp render("qa", prompt),
    do:
      "QA draft: playtest summary focused on protecting #{extract_phrase(prompt, "player promise")}"

  defp render(role, _prompt), do: "AI draft for #{role}"

  defp extract_phrase(prompt, marker) do
    prompt
    |> String.downcase()
    |> String.split("#{marker}: ", parts: 2)
    |> case do
      [_prefix, rest] -> rest |> String.split("\n") |> hd()
      _ -> "the milestone"
    end
  end
end
