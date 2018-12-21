defmodule Gamer.Scene.Home do
  use Scenic.Scene

  alias Scenic.Graph

  import Scenic.Primitives
  # import Scenic.Components

  require Logger

  @note """
    This is a very simple starter application.

    If you want a more full-on example, please start from:

    mix scenic.new.example
  """

  @graph Graph.build(font: :roboto, font_size: 24)
  |> text(@note, translate: {20, 60})

  # ============================================================================
  # setup
  # --------------------------------------------------------
  def init(first_scene, opts) do
    IO.inspect(first_scene)
    IO.inspect(opts)
    push_graph( @graph )
    {:ok, @graph}
  end

  def handle_info(msg) do
    Logger.info("#{inspect(msg)}", label: "handle_info")
  end

  def handle_input(event, _context, state) do
    Logger.info("#{inspect(event)}", label: "handle_input")
    {:noreply, state}
  end

 def status_message(msg) do
    @graph
    |> text(msg, translate: {20, 204})
    |> push_graph()
  end
end
