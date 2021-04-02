defmodule Crisp.Repo.Migrations.CreatePasswords do
  use Ecto.Migration

  def change do
    create table(:passwords) do
      add :hash, :string, null: false
      add :email_id, references(:emails, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:passwords, [:email_id])
  end
end
