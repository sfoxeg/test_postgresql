from db import *
from facke_data import facke_data
import csv
import psycopg2
from psycopg2 import Error


if __name__ == '__main__':

    facke_data()

    insert = "INSERT INTO dds_stg.invoices (type, num, deal_date, counterparty_name, product_name, amt, unit_price) VALUES\n"

    with open('data.csv') as f:
        reader = csv.DictReader(f, delimiter=';')
        for row in reader:
            insert += f"('{row['type']}', '{row['num']}', '{row['date']}', '{row['company']}', '{row['product']}', '{row['amt']}', '{row['price']}'),\n"

    insert = insert[0:-2] + ';'

    try:
        connection = psycopg2.connect(database=DATABASE, user=USER, password=PASSWORD, host=HOST, port=PORT)
        cursor = connection.cursor()
        cursor.execute("TRUNCATE dds_stg.invoices;")
        cursor.execute(insert)
        connection.commit()


    except (Exception, Error) as error:
        print("PostgreSQL: ", error)

    finally:
        if connection:
            cursor.close()
            connection.close()


