# cargo culted from https://github.com/thestonefox/elixir_poolboy_example/blob/master/mix.exs
defmodule ParallelTreeWalk.Mixfile do
  use Mix.Project

  def project do
    [
      app: :parallel_tree_walk,
      version: "0.0.1",
      elixir: "~> 1.0",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      escript: escript(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [
      mod: {ParallelTreeWalk, []},
      applications: [:logger, :poolboy]
    ]
  end

  def escript do
    [
      main_module: ParallelTreeWalk,
      emu_args: "+A32"
    ]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [
      {:poolboy, "~> 1.5"}
    ]
  end
end
