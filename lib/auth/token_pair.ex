defmodule Fast.Auth.TokenPair do
  defstruct [:access_token, :refresh_token, :expires_in]
end
