defmodule ElloClick do
  use Application

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      # Define workers and child supervisors to be supervised
      # worker(ElloClick.Worker, [arg1, arg2, arg3]),
      Plug.Adapters.Cowboy.child_spec(:http, ElloClick.Plug, [], [port: port()])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElloClick.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp port do
    case System.get_env("PORT") do
      nil  -> 4000
      port -> String.to_integer(port)
    end
  end
end
