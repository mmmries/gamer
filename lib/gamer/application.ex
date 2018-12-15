defmodule Gamer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  @target Mix.Project.config()[:target]

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false
    main_viewport_config = Application.get_env(:gamer, :viewport)

    children = [
      supervisor(Scenic, viewports: [main_viewport_config])
    ]

    opts = [strategy: :one_for_one, name: Gamer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
