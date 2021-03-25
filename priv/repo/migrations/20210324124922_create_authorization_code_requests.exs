defmodule Crisp.Repo.Migrations.CreateAuthorizationCodeRequests do
  use Ecto.Migration

  def change do
    create table(:authorization_code_requests) do
      add :identity_provider_id, :string, null: false
      add :state, :binary, null: false
      add :nonce, :binary, null: false
      add :expired_at, :naive_datetime, null: false
      add :context, :string, null: false

      timestamps(updated_at: false)
    end

    create unique_index(:authorization_code_requests, [:state])
    create unique_index(:authorization_code_requests, [:nonce])
  end
end
