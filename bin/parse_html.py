#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import division
import sys

reload(sys)  # Reload does the trick!
sys.setdefaultencoding('UTF8')

from os.path import dirname, basename
from bs4 import BeautifulSoup
from requests import get
from time import sleep
from random import randint
import codecs
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
import argparse as ap

accepted_property_names = [
    'Kilokalorien', 'Energie (kcal)', 'KiloJoule', 'Wasser',
    'Eiweiß, Proteine', 'Eiweiß, Proteingehalt', 'Fett', 'Kohlenhydrate',
    'Ballaststoffe', 'Broteinheiten', 'Mineralstoffe (Rohasche)',
    'organische Säuren', 'Alkohol (Ethanol)', 'Fett gesamt',
    'gesättigte Fettsäuren', 'Zucker', 'Salz', 'Vitamin A Retinoläquivalent',
    'Vitamin A Retinol', 'Vitamin A Beta-Carotin', 'Vitamin B1 Thiamin',
    'Vitamin B2 Riboflavin', 'Vitamin B3 Niacin, Nicotinsäure',
    'Vitamin B3 Niacinäquivalent', 'Vitamin B5 Pantothensäure',
    'Vitamin B6 Pyridoxin', 'Vitamin B7 Biotin (Vitamin H)',
    'Vitamin B9 gesamte Folsäure', 'Vitamin B12 Cobalamin',
    'Vitamin C Ascorbinsäure', 'Vitamin D Calciferole',
    'Vitamin E Tocopheroläquivalent', 'Vitamin E Tocopherol',
    'Vitamin K Phyllochinon', 'Natrium', 'Kalium', 'Calcium', 'Magnesium',
    'Phosphor', 'Schwefel', 'Chlorid', 'Eisen', 'Zink', 'Kupfer', 'Mangan',
    'Fluorid', 'Iodid', 'Carbohydrate units', 'Mannit', 'Sorbit', 'Xylit',
    'Summe Zuckeralkohole', 'Glucose (Traubenzucker)',
    'Fructose (Fruchtzucker)', 'Galactose (Schleimzucker)',
    'Monosaccharide (1 M)', 'Saccharose (Rübenzucker)', 'Maltose (Malzzucker)',
    'Lactose (Milchzucker)', 'Disaccharide (2 M)',
    'Oligosaccharide, resorbierbar (3 - 9 M)',
    'Oligosaccharide, resorbierbar (3-9 M)',
    'Oligosaccharide, nicht resorbierbar', 'Glykogen (tierische Stärke)',
    'Stärke', 'Polysaccharide (> 9 M)', 'Isoleucin', 'Leucin', 'Lysin',
    'Methionin', 'Cystein', 'Phenylalanin', 'Tyrosin', 'Threonin',
    'Tryptophan', 'Valin', 'Arginin', 'Histidin', 'Essentielle Aminosäuren',
    'Alanin', 'Asparaginsäure', 'Glutaminsäure', 'Glycin', 'Prolin', 'Serin',
    'Nichtessentielle Aminosäuren', 'Harnsäure', 'Purin', 'Poly-Pentosen',
    'Poly-Hexosen', 'Poly-Uronsäure', 'Cellulose', 'Lignin',
    'Wasserlösliche Ballaststoffe', 'Wasserunlösliche Ballaststoffe',
    'Butansäure/Buttersäure', 'Hexansäure/Capronsäure',
    'Octansäure/Caprylsäure', 'Decansäure/Caprinsäure',
    'Dodecansäure/Laurinsäure', 'Tetradecansäure/Myristinsäure',
    'Pentadecansäure', 'Hexadecansäure/Palmitinsäure', 'Heptadecansäure',
    'Octadecansäure/Stearinsäure', 'Eicosansäure/Arachinsäure',
    'Decosansäure/Behensäure', 'Tetracosansäure/Lignocerinsäure',
    'Gesättigte Fettsäuren', 'Tetradecensäure', 'Pentadecensäure',
    'Hexadecensäure/Palmitoleinsäure', 'Heptadecensäure',
    'Octadecensäure/Ölsäure', 'Eicosensäure', 'Decosensäure/Erucasäure',
    'Tetracosensäure/Nervonsäure', 'Einfach ungesättigte Fettsäuren',
    'Hexadecadiensäure', 'Hexadecatetraensäure',
    'Octadecadiensäure/Linolsäure', 'Octadecatriensäure/Linolensäure',
    'Octadecatetraensäure/Stearidonsäure', 'Nonadecatriensäure',
    'Eicosadiensäure', 'Eicosatriensäure', 'Eicosatetraensäure/Arachidonsäure',
    'Eicosapentaensäure', 'EPA - Eicosapentaensäure', 'Docosadiensäure',
    'Docosatriensäure', 'Docosatetraensäure', 'Docosapentaensäure',
    'Docosahexaensäure', 'DHA - Docosahexaensäure',
    'Mehrfach ungesättigte Fettsäuren', 'Kurzkettige Fettsäuren',
    'Mittelkettige Fettsäuren', 'Langkettige Fettsäuren',
    'Glycerin und Lipoide', 'Cholesterin'
]

accepted_category_names = [
    'Alkoholfreie Getränke',
    'Alkoholische Getränke',
    'Brot- und Kleingebäck',
    'Cerealien, Getreide und Getreideprodukte, Reis',
    'Reis, Cerealien, Getreide und Getreideprodukte',
    'Diätetische Lebensmittel',
    'Kuchen, Feinbackwaren, Dauerbackwaren',
    'Fische, Krusten-, Schalen-, Weichtiere',
    'Fleisch (Rind, Kalb, Schwein, Hammel, Lamm)',
    'Fleisch (Wild, Geflügel, Federwild, Innereien)',
    'Fleisch- und Wurstwaren',
    'Wurst, Fleischwaren',
    'Früchte, Obst und Obsterzeugnisse',
    'Gemüse und Gemüseerzeugnisse',
    'Hülsenfrüchte (reif), Schalenobst, Öl- und andere Samen',
    'Eier und Eierprodukte, Teigwaren',
    'Milch, Milcherzeugnisse, Käse',
    'Fette, Öle, Butter, Schmalz',
    'Öle, Fette, Butter, Schmalz, Talg',
    'Kartoffeln und Kartoffelerzeugnisse, stärkereiche Pflanzenteile, Pilze',
    'Pilze, Kartoffeln und Kartoffelerzeugnisse, stärkereiche Pflanzenteile',
    'Süßwaren, Zucker, Bonbons, Schokolade, Brotaufstrich süß, Eis'
    'Menükomponenten',
    'Gewürze, Würzmittel, Hilfsstoffe',
]


def read_params():
    parser = ap.ArgumentParser(prog='Parses HTML of NWR')

    parser.add_argument('--input-file',
                        required=True,
                        metavar='PATH',
                        type=str,
                        help='NWR HTML input file.')
    parser.add_argument('--output-file',
                        required=True,
                        metavar='PATH',
                        type=str,
                        help='Output file.')

    return vars(parser.parse_args())


def parse_html(file):
    with open(file, 'r') as f:
        contents = f.read()

    page_content = BeautifulSoup(contents, 'lxml')
    page_items = page_content.find_all('tbody')

    item_properties = {
        'item_id':
        basename(file),
        'item_descr':
        page_content.find_all('h2')[0].text,
        'item_cat':
        page_content.find('ol', {
            'class': 'breadcrumb'
        }).findAll('li')[2].find('span').text
    }

    for page_item in page_items:
        for properties in page_item.find_all('tr'):
            data = [p.text.strip() for p in properties.find_all('td')]
            property_name = data[0]
            property_value = data[1]

            if property_name is not None and property_value is not None:
                if property_name.startswith('Tagesbedarf'):
                    continue

                if property_name not in accepted_property_names:
                    print("Skipping: %s" % (properties))
                    continue

                if property_name == 'Broteinheiten' or property_name == 'Carbohydrate units':
                    country_src = properties.find('img').get('src')
                    country_code = country_src.replace('.png', '')[-2:].upper()
                    gram = property_value.endswith('mg')
                    suffix = '_'
                    if country_code is not None:
                        suffix += country_code
                    if gram:
                        suffix += '_MG'
                    else:
                        suffix += '_UNIT'
                    property_name += suffix
                    accepted_property_names.append(property_name)

            item_properties[property_name] = property_value
    return item_properties


if __name__ == "__main__":
    args = read_params()
    data = parse_html(args['input_file'])

    txt = '\n'.join(['Property\tValue'] +
                    ['%s\t%s' % (key, value) for (key, value) in data.items()])

    with open(args['output_file'], 'w') as f:
        f.write(txt + '\n')
