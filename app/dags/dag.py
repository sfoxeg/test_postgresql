from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.providers.postgres.operators.postgres import PostgresOperator
from airflow.utils.dates import days_ago
import random
from datetime import datetime
from mimesis import Finance
from mimesis import Hardware


def generate_data():
    insert = "INSERT INTO dds_stg.invoices (type, num, deal_date, counterparty_name, product_name, amt, unit_price) VALUES\n"
    x = 730  # Данные за Х дней
    dt = datetime.now().replace(hour=9, minute=0, second=0, microsecond=0)
    dt = datetime.timestamp(dt)
    dt = dt - x * 86400
    num = 0
    data = []
    data.append(['type', 'num', 'date', 'company', 'product', 'amt', 'price'])
    facke_f = Finance('ru')
    facke_h = Hardware()
    for d in range(x):  # Данные за Х дней
        for t in range(random.randint(1, 3)):  # Количество сделок в день
            num += 1
            this_day_dt = dt + 9800 + random.randint(0,
                                                     1000)  # Для простоты предположим, что сделки происходят каждые три часа. Или не происходят
            type = random.choice(['buy', 'sale'])
            date = datetime.fromtimestamp(this_day_dt)
            date = datetime.date(date)  # Но в реальных документах ставится дата без времени. Оставим как опцию
            company = facke_f.company()
            for i in range(random.randint(1, 5)):  # Сколько позиций в накладной

                product = facke_h.phone_model()
                amt = random.randint(1, 5)
                price = facke_f.price(10000, 100000)

                insert += f"('{type}', '{num}', '{date}', '{company}', '{product}', '{amt}', '{price}'),\n"
        dt += 86400
    return insert[0:-2] + ';'


dag = DAG(
    'test_dag',
    schedule_interval='@once',
    start_date=days_ago(1)
)

create_dds_stg = PostgresOperator(
    dag=dag,
    task_id="create_dds_stg",
    postgres_conn_id="postgres_default",
    sql="sql/dds_stg.sql"
)

generate_test_data = PostgresOperator(
    dag=dag,
    task_id="generate_test_data",
    postgres_conn_id="postgres_default",
    sql=generate_data()
)

create_dds = PostgresOperator(
    dag=dag,
    task_id="create_dds",
    postgres_conn_id="postgres_default",
    sql="sql/dds.sql"
)

create_ddm = PostgresOperator(
    dag=dag,
    task_id="create_ddm",
    postgres_conn_id="postgres_default",
    sql="sql/ddm.sql"
)

create_dds_stg >> generate_test_data >> create_dds >> create_ddm
