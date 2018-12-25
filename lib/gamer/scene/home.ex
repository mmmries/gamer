defmodule Gamer.Scene.Home do
  use Scenic.Scene
  alias Scenic.Graph
  import Scenic.Primitives, only: [rect: 3, rrect: 3]
  require Logger

  @frame_interval 200

  @width 40      #tiles
  @height 24     #tiles
  @tile_size 20  #pixels per side
  @tile_radius 8 #pixels

  defstruct snake:     List.duplicate({20, 12}, 4),
            direction: :right,
            food:      nil,
            length:    4,
            score:     0,
            dead:      false

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
  def handle_input({:cursor_button, {:left, :press, _, coords}}, _context, %__MODULE__{snake: [head | _]}=state) do
    direction = relative_click_direction(head, coords)
    try_move(state, direction)
  end
  def handle_input(event, _context, state) do
    Logger.info("#{inspect(event)}", label: "handle_input")
    {:noreply, state}
  end

  def eat_or_generate_food(%__MODULE__{food: nil, snake: snake}=state) do
    all_tiles = for x <- 0..(@width - 1),
                    y <- 0..(@height - 1),
                    do: {x, y}
    tile = all_tiles
          |> Enum.reject(fn(tile) -> Enum.member?(snake, tile) end)
          |> Enum.shuffle()
          |> hd
    %{ state | food: tile }
  end
  def eat_or_generate_food(%__MODULE__{food: tile, snake: [tile | _rest]}=state) do
    %{ state | score: state.score + 1,length: state.length + 1, food: nil }
  end
  def eat_or_generate_food(state), do: state

  def move_snake(%__MODULE__{dead: true}=state), do: state
  def move_snake(%__MODULE__{snake: [head | tail], direction: direction, length: length}=state) do
    next = pick_next(head, direction)
    new_tail = [head | Enum.take(tail, length - 2)]
    case Enum.member?(new_tail, next) do
      false -> %{state | snake: [next | new_tail]}
      true ->  %{state | dead: true}
    end
  end

  def paint(state) do
    Graph.build(font: :roboto, font_size: 24)
    |> rect({@width * @tile_size, @height * @tile_size}, []) # a clear background rect so we can receive positional input like clicks
    |> paint_snake(state.snake)
    |> paint_food(state.food)
    |> push_graph()
  end

  def paint_food(graph, nil), do: graph
  def paint_food(graph, {x, y}) do
    tile_opts = [fill: :yellow, translate: {x * @tile_size, y * @tile_size}]

    graph
    |> rrect({@tile_size, @tile_size, @tile_radius}, tile_opts)
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
    |> eat_or_generate_food()
  end

  defp relative_click_direction({tile_x, tile_y}, {x, y}) do
    head_x = tile_x * @tile_size + div(@tile_size, 2)
    head_y = tile_y * @tile_size + div(@tile_size, 2)
    vec_x = x - head_x
    vec_y = y - head_y
    cond do
      abs(vec_y) > abs(vec_x) && vec_y < 0 -> :up
      abs(vec_y) > abs(vec_x) && vec_y >= 0 -> :down
      vec_x < 0 -> :left
      true -> :right
    end
  end
end
