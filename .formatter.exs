# Used by "mix format"
[
  import_deps: [:ecto],
  inputs: ["{mix,.formatter}.exs", "{config,lib,test,bench}/**/*.{ex,exs}"],
  subdirectories: ["priv/*/migrations"]
]
