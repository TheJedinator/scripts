import requests
import datetime
from bs4 import BeautifulSoup

req = requests.get('https://www.anbl.com/growlers')
data = req.content
soup = BeautifulSoup(data, 'lxml')
york_fred = soup.find('div', attrs={'class': 'widget', 'data-type': 'view', 'data-index': '3'})
print(york_fred.prettify())
test_list = []

for beer in york_fred.find_all('p'):
  for bt in beer.find_all('strong'):
    print(bt.get_text())
    x = bt.get_text().strip()
    test_list.append(x)
polly_str = ""
date = datetime.date.today().strftime('%B %d, %Y')
if len(test_list) <= 0:
  polly_str = "Either the ANBL Devs forgot how to use p-tags again OR there is a special event, I'm not that smart, you'll have to manage on your own today......."
else:
  polly_str = '/polly "On Tap - {}"'.format(date)

for beer in test_list:
    polly_str += ' "{}"'.format(beer)

print(polly_str)