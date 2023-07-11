defmodule Fast.Auth.Passwords do
  def login_with_password(nil = _user, _password, _context) do
    Bcrypt.no_user_verify()
    {:error, :invalid_credentials}
  end

  def login_with_password(%{locked_from_failed_login_attempts: true} = _user, _password, _context) do
    Bcrypt.no_user_verify()
    {:error, :account_locked}
  end

  def verify_password(user_struct, password) do
    Bcrypt.check_pass(user_struct, password)
  end

  def create_session(user, password) when is_binary(password) do
    case user do
      nil ->
        # Waste time pretending to has to make enumeration attacks harder and to
        # not reveal whether an account exists for an email via timing.
        Bcrypt.no_user_verify()
        {:error, :nil_user}

      %{locked_from_failed_login_attempts: true} ->
        Bcrypt.no_user_verify()
        {:error, :account_locked}

      %{active: false} ->
        Bcrypt.no_user_verify()
        {:error, :account_inactive}
    end
  end
end
