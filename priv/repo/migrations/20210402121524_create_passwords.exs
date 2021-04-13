defmodule Crisp.Repo.Migrations.CreatePasswords do
  use Ecto.Migration

  def change do
    create table(:passwords) do
      add :hash, :string, null: false
      add :email_id, references(:emails, on_delete: :delete_all), null: false

      timestamps()
    end

    execute """
            CREATE OR REPLACE FUNCTION get_salt(acct_id BIGINT) RETURNS text AS $$
              DECLARE salt text;
              BEGIN
              SELECT
                CASE
                WHEN hash ~ '^\\$argon2id'
                THEN substring(hash from '\\$argon2id\\$v=\\d+\\$m=\\d+,t=\\d+,p=\\d+\\$.+\\$')
                ELSE substr(hash, 0, 30)
                END INTO salt
              FROM passwords
              WHERE acct_id = id;
              RETURN salt;
              END;
              $$ LANGUAGE plpgsql
              SECURITY DEFINER
              SET search_path = public, pg_temp;
            """,
            "DROP FUNCTION IF EXISTS get_salt"

    execute """
              CREATE OR REPLACE FUNCTION valid_hash(acct_id BIGINT, input_hash text) RETURNS boolean AS $$
              DECLARE valid boolean;
              BEGIN
              SELECT hash = input_hash INTO valid
              FROM passwords
              WHERE acct_id = id;
              RETURN valid;
              END;
              $$ LANGUAGE plpgsql
              SECURITY DEFINER
              SET search_path = public, pg_temp;
            """,
            "DROP FUNCTION IF EXISTS valid_hash"

    create unique_index(:passwords, [:email_id])
  end
end
