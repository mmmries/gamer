use Mix.Config

config :gamer, :viewport, %{
  name: :main_viewport,
  size: {800, 480},
  default_scene: {Gamer.Scene.Home, nil},
  drivers: [
    %{
      module: Scenic.Driver.Glfw,
      name: :glfw,
      opts: [resizeable: false, title: "snake"]
    }
  ]
}
