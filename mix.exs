defmodule ElloClick.Mixfile do
  use Mix.Project

  def project do
    [app: :ello_click,
     version: "0.0.1",
     elixir: "~> 1.6",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :httpoison, :cowboy, :plug],
     mod: {ElloClick, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      {:plug, "~> 1.5"},
      {:cowboy, "~> 1.0"},
      {:honeybadger, "~> 0.5"},
      {:httpoison, "~> 1.1"},
      {:exvcr, "~> 0.10", only: :test},
    ]
  end
end
