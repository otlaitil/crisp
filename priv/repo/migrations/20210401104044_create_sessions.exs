defmodule Crisp.Repo.Migrations.CreateSessions do
  use Ecto.Migration

  def change do
    create table(:sessions) do
      add :token, :binary, null: false
      add :security, :string, null: false
      add :employee_id, references(:employees, on_delete: :delete_all), null: false

      timestamps(updated_at: false)
    end

    create unique_index(:sessions, [:token])
    create index(:sessions, [:employee_id])
  end
end
