defmodule Fast.Auth do
  # -- Imports

  # -- Contexts
  # alias Fast.Auth.Token

  @doc """
  Available features:
    - `:passwords`
    - `:confirmable`
    - `:invitable`
    - `:magic_links`
    - `:saml_sso`
    - `:login_attempt_locking`
    - `?`

  Opts:
    - `:schema` - The user account schema
    - `:features` - A subset of features.
  """

  @type login_method :: :password | :magic_link | :saml_sso

  @callback handle_login_success(user :: any(), method :: login_method(), context :: map()) ::
              any()
  @callback handle_login_failure(user :: any(), method :: login_method(), context :: map()) ::
              any()
  @callback verify_login_allowed(user :: any(), method :: login_method(), context :: map()) ::
              :ok | {:error, any()}

  @optional_callbacks [
    verify_login_allowed: 3,
    handle_login_success: 3,
    handle_login_failure: 3
  ]

  @valid_features [
    :passwords,
    :confirmations,
    :invitations,
    :magic_links,
    :saml_sso,
    :login_attempt_locking
  ]

  @password_fields [
    :hashed_password,
    :password_updated_at
  ]

  @confirmable_fields [
    :confirmation_token_created_at,
    :confirmation_token_hash,
    :confirmed_at
  ]

  @invitable_fields [
    :invitation_token_created_at,
    :invitation_token_hash
  ]

  @magic_link_fields [
    :magic_link_token,
    :magic_link_token_created_at
  ]

  @saml_sso_fields [
    :saml_idp_id,
    :saml_idp_subject_id,
    :saml_idp_username,
    :sso_authenticated_nonce_created_at,
    :sso_authenticated_nonce_hash
  ]

  @login_attempt_locking_fields [
    :locked_from_failed_login_attempts,
    :locked_from_failed_login_attempts_at
  ]

  defmodule MissingFieldsError do
    defexception [:message]
  end

  defmodule InvalidFeaturesError do
    defexception [:message]
  end

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @behaviour Fast.Auth
      @auth_schema Keyword.fetch!(opts, :schema)
      @auth_features Keyword.fetch!(opts, :features)
      @otp_app Keyword.fetch!(opts, :otp_app)
      @repo Keyword.fetch!(opts, :repo)
      @hashed_password_field Keyword.fetch!(opts, :hashed_password_field)
      @guardian_module Keyword.fetch!(opts, :guardian_module)

      Fast.Auth.ensure_valid_features!(__MODULE__, @auth_features)

      def auth_features, do: @auth_features
      def auth_schema, do: @auth_schema
      def auth_otp_app, do: @otp_app
      def auth_repo, do: @repo

      if :passwords in @auth_features do
        Fast.Auth.ensure_fields_present!(:passwords, @auth_schema)

        def login_with_password(user, password, context) do
          method = :password

          with :ok <- verify_login_allowed(user, method, context),
               {:ok, user} <- Bcrypt.check_pass(user, password, hash_key: @hashed_password_field) do
            {:ok, jwt, _} = @guardian_module.encode_and_sign(user, %{}, ttl: {200_000, :seconds})

            handle_login_success(user, method, context)

            {:ok, %{jwt: jwt, user: @repo.reload(user)}}
          else
            error ->
              if !is_nil(user) do
                handle_login_failure(user, method, context)
              end

              case error do
                {:error, "invalid password"} ->
                  {:error, :invalid_credentials}

                error ->
                  Bcrypt.no_user_verify()
                  error
              end
          end
        end
      end

      if :confirmations in @auth_features do
        Fast.Auth.ensure_fields_present!(:confirmations, @auth_schema)

        # feature functions here...
      end

      if :invitations in @auth_features do
        Fast.Auth.ensure_fields_present!(:invitations, @auth_schema)

        # feature functions here...
      end

      if :magic_links in @auth_features do
        Fast.Auth.ensure_fields_present!(:magic_link, @auth_schema)

        # feature functions here...
      end

      if :saml_sso in @auth_features do
        Fast.Auth.ensure_fields_present!(:saml_sso, @auth_schema)

        # feature functions here...
      end

      if :login_attempt_locking in @auth_features do
        Fast.Auth.ensure_fields_present!(:login_attempt_locking, @auth_schema)

        # feature functions here...
      end

      def revoke(jwt) do
        @guardian_module.revoke(jwt)
      end

      def user_for_token(token) do
        with {:ok, claims} <- @guardian_module.decode_and_verify(token) do
          @guardian_module.resource_from_claims(claims)
        end
      end

      # NB: Replacing these with `verify_login_allowed/3`
      # def allow_login?(nil, _method, _context), do: {:error, :nil_user}
      # def allow_login?(_user), do: :ok
    end
  end

  for {feature, required_fieldset} <- [
        passwords: @password_fields,
        confirmations: @confirmable_fields,
        invitations: @invitable_fields,
        magic_links: @magic_link_fields,
        saml_sso: @saml_sso_fields,
        login_attempt_locking: @login_attempt_locking_fields
      ] do
    def ensure_fields_present!(unquote(feature), schema) do
      missing = unquote(required_fieldset) -- schema.__schema__(:fields)

      case missing do
        [] -> :ok
        _ -> raise_missing_fields!(unquote(feature), schema, missing)
      end
    end
  end

  def ensure_valid_features!(module, features) do
    invalid = features -- @valid_features
    unused_features = @valid_features -- features

    case invalid do
      [] -> :ok
      _ -> raise_invalid_features!(module, invalid, unused_features)
    end
  end

  def raise_missing_fields!(feature, schema, missing_fields) do
    raise Fast.Auth.MissingFieldsError,
      message: """


      ** You're trying to use a Fast.Auth feature for a schema that is missing the required fields:
        - schema: #{inspect(schema)}
        - feature: #{inspect(feature)}
        - missing fields: #{inspect(missing_fields)}\n\n

      """
  end

  def raise_invalid_features!(module, invalid_features, unused_features) do
    raise Fast.Auth.InvalidFeaturesError,
      message: """


      ** You're trying to use invalid Fast.Auth features.
        - module: #{inspect(module)}
        - your invalid features: #{inspect(invalid_features)}
        - maybe you meant one of: #{inspect(unused_features)}

      """
  end
end
