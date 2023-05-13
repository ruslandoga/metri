# Used by "mix format"
[
  import_deps: [:ecto, :phoenix],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test,bench,dev}/**/*.{ex,exs}"],
  subdirectories: ["priv/*/migrations"]
]
