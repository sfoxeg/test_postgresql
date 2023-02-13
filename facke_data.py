import random
from datetime import datetime
import csv
from mimesis import Finance
from mimesis import Hardware


def facke_data():
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

                data.append([type, num, date, company, product, amt, price])
        dt += 86400

    with open('data.csv', 'w', newline='') as f:
        writer = csv.writer(f, delimiter=';')
        for row in data:
            writer.writerow(row)


facke_data()
