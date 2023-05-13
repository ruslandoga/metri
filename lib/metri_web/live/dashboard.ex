defmodule MetriWeb.DashboardLive do
  use MetriWeb, :live_view

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-screen max-w-2xl mx-auto">
      dashboard
    </div>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
