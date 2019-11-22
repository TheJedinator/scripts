import requests
import datetime
from bs4 import BeautifulSoup
from pprint import pprint
import json


def main():
    req = requests.get('https://www.anbl.com/growlers')
    data = req.content
    soup = BeautifulSoup(data, 'lxml')
    york_fred = soup.find(
        'div', attrs={'class': 'widget', 'data-type': 'view', 'data-index': '3'})
    # print(york_fred.prettify())
    test_list = []

    for bt in york_fred.find_all('strong'):
        x = bt.get_text().strip()
        if x != "":
            # print(x)
            test_list.append(x)
    polly_str = ""
    date = datetime.date.today().strftime('%B %d, %Y')
    if len(test_list) <= 0:
        polly_str = "Either the ANBL Devs forgot how to use p-tags again OR there is a special event, I'm not that smart, you'll have to manage on your own today....... https://www.anbl.com/growlers"
    else:
        polly_str = '/polly "On Tap - {}"'.format(date)

    # For each beer, make a request to the untapped API for some info
    # If the request succeeds we add info & beer to the poll, otherwise we just add the beer to the poll
    for beer in test_list:
        print(beer)
        api_str = """ https://api.untappd.com/v4/search/beer?q={}&client_id=FAC6C2CDD00FD0787888C1A4383832B52D20463F&client_secret=091BCEE693FF092F66CF5A6381077940E541CC82""".format(beer)
        res = requests.get(api_str)
        res = json.loads(res.content)
        beer_str = None
        if res.get('status_code') == 200 or res.get('meta').get('code') == 200:
            search_results = res.get('response').get('beers').get('items')
            if search_results: 
                sr = search_results[0]
                sr = sr['beer']
                beer_str = """
                Style: {}
                IBU: {}
                ABV: {}
                Description: {}
                """.format(
                    sr['beer_style'].strip(),
                    sr['beer_ibu'],
                    sr['beer_abv'],
                    sr['beer_description'].strip()
                )
            if beer_str: 
                polly_str += ' "{}{}"'.format(beer, beer_str)
            else: polly_str += '"{}"'.format(beer)
    print(polly_str)
    return polly_str 


if __name__ == "__main__":
    main()
