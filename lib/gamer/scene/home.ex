defmodule Gamer.Scene.Home do
  use Scenic.Scene
  alias Scenic.Graph
  import Scenic.Primitives, only: [rrect: 3]
  require Logger

  @frame_interval 200

  @width 40      #tiles
  @height 24     #tiles
  @tile_size 20  #pixels per side
  @tile_radius 8 #pixels

  defstruct snake:     [{20, 12},{20, 12},{20, 12},{20, 12}],
            direction: :right,
            scope:     0

  def init(_first_scene, _opts) do
    schedule_tick()
    {:ok, %__MODULE__{}}
  end

  def handle_info(:tick, state) do
    state = state |> update_state()

    paint(state)
    schedule_tick()

    {:noreply, state}
  end
  def handle_info(msg, _state) do
    Logger.info("#{inspect(msg)}", label: "handle_info")
  end

  def handle_input({:key, {"up",    :press, _}}, _context, state), do: try_move(state, :up)
  def handle_input({:key, {"down",  :press, _}}, _context, state), do: try_move(state, :down)
  def handle_input({:key, {"left",  :press, _}}, _context, state), do: try_move(state, :left)
  def handle_input({:key, {"right", :press, _}}, _context, state), do: try_move(state, :right)
  def handle_input(event, _context, state) do
    Logger.info("#{inspect(event)}", label: "handle_input")
    {:noreply, state}
  end

  def move_snake(%__MODULE__{snake: [head | tail], direction: direction}=state) do
    next = pick_next(head, direction)
    new_snake = [next, head | Enum.slice(tail, 0..-2)]
    %{state | snake: new_snake}
  end

  def paint(state) do
    Graph.build(font: :roboto, font_size: 24)
    |> paint_snake(state.snake)
    |> push_graph()
  end

  def paint_snake(graph, []), do: graph
  def paint_snake(graph, [{x, y} | tail]) do
    tile_opts = [fill: :lime, translate: {x * @tile_size, y * @tile_size}]
    graph
    |> rrect({@tile_size, @tile_size, @tile_radius}, tile_opts)
    |> paint_snake(tail)
  end

  def pick_next({x, y}, :right), do: {rem(x + 1 + @width, @width), y}
  def pick_next({x, y}, :left),  do: {rem(x - 1 + @width, @width), y}
  def pick_next({x, y}, :up),    do: {x, rem(y - 1 + @height, @height)}
  def pick_next({x, y}, :down), do:  {x, rem(y + 1 + @height, @height)}

  def schedule_tick, do: Process.send_after(self(), :tick, @frame_interval)

  def try_move(%__MODULE__{direction: :up}=state,    :down),  do: {:noreply, state}
  def try_move(%__MODULE__{direction: :down}=state,  :up),    do: {:noreply, state}
  def try_move(%__MODULE__{direction: :left}=state,  :right), do: {:noreply, state}
  def try_move(%__MODULE__{direction: :right}=state, :left),  do: {:noreply, state}
  def try_move(%__MODULE__{}=state, direction) do
    {:noreply, %{state | direction: direction}}
  end

  def update_state(state) do
    state
    |> move_snake()
  end
end
