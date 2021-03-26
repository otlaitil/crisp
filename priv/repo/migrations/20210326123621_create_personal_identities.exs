defmodule Crisp.Repo.Migrations.CreatePersonalIdentities do
  use Ecto.Migration

  def change do
    create table(:personal_identities) do
      add :code, :string
      add :employee_id, references(:employees, on_delete: :nothing)

      timestamps()
    end

    create index(:personal_identities, [:employee_id])
  end
end
