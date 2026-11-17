import duckdb
import pendulum
from pathlib import Path
from airflow.decorators import dag, task

BASE_DIR = Path(__file__).resolve().parent.parent
DATA_DIR = BASE_DIR / "datos"
SQL_DIR = BASE_DIR / "consultas"
DB_PATH = BASE_DIR / "pipeline.duckdb"

def read_sql(filename: str) -> str:
    return (SQL_DIR / filename).read_text(encoding="utf-8")

def count(con, table: str) -> int:
    return con.execute(f"SELECT COUNT(*) FROM {table}").fetchone()[0]

@task
def extraer():
    con = duckdb.connect(str(DB_PATH))
    con.execute(read_sql("extract.sql"), [str(DATA_DIR / "rrhh.sqlite")])
    print("Registros extraídos:", count(con, "raw_rrhh"))
    con.close()

@task
def validar():
    con = duckdb.connect(str(DB_PATH))
    con.execute(read_sql("validar.sql"))
    print("Registros válidos:", count(con, "validos"))
    print("Registros rechazados:", count(con, "rechazados"))
    con.close()

@task
def limpiar():
    con = duckdb.connect(str(DB_PATH))
    con.execute(read_sql("limpiar.sql"))
    print("Registros recuperados limpios:", count(con, "rechazados_limpios"))
    con.close()

@task
def unir():
    con = duckdb.connect(str(DB_PATH))
    con.execute(read_sql("unir.sql"))
    print("Total registros en tabla_final:", count(con, "tabla_final"))
    con.close()

@task
def preguntas():
    con = duckdb.connect(str(DB_PATH))
    for numero, consulta in enumerate(read_sql("consultas.sql").split(";"), start=1):
        if consulta.strip():
            print(f"Pregunta {numero}:")
            print(con.execute(consulta).df().to_string(index=False))
    con.close()

@dag(
    dag_id="dag_pipeline",
    start_date=pendulum.datetime(2026, 1, 1, tz="America/Argentina/Buenos_Aires"),
    schedule="0 2 * * *",
    max_active_runs=1,
    catchup=False
)
def pipeline():
    extraer() >> validar() >> limpiar() >> unir() >> preguntas()

pipeline()
