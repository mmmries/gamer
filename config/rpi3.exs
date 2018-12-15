use Mix.Config

config :gamer, :viewport, %{
  name: :main_viewport,
  size: {800, 480},
  default_scene: {Gamer.Scene.Home, nil},
  drivers: [
    %{
      module: Scenic.Driver.Nerves.Rpi
    },
    %{
      module: Scenic.Driver.Nerves.Touch,
      opts: [
        device: "FT5406 memory based driver",
        calibartion: {{1, 0, 0}, {1, 0, 0}}
      ]
    }
  ]
}
