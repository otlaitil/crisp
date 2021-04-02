defmodule Crisp.Repo.Migrations.CreateEmails do
  use Ecto.Migration

  def change do
    create table(:emails) do
      add :address, :string, null: false
      add :verification_token, :binary, null: false
      add :verified_at, :naive_datetime
      add :employee_id, references(:employees, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:emails, [:address])
    create index(:emails, [:employee_id])
  end
end
