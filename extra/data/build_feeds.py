#!/usr/bin/env python3
from datetime import datetime, date, time, timezone
import json
import glob
import os

locales = ['en_CA', 'en_HK', 'en_GB', 'en_SG', 'en_US', 'ko_KR', 'ja_JP', "pt_BR"]
# locales = ['en_CA']
feeds = []
input_dir  = './feeds'
output_dir = './feeds'
default_language_dir = input_dir + '/en'

def load_feeds(dirname, fname):
    print('\nload feed:{}'.format(fname))
    with open(dirname + '/' + fname, 'r') as f:
        content = json.load(f)
        return content['data']

def merge_dict(olddict, newdict):
    # TODO
    for key in newdict:
        if key not in olddict:
            olddict[key] = newdict[key]

def merge_feeds(oldfeed, newfeeds):
    for newfeed in newfeeds:
        print('newfeed.title:{}'.format(newfeed['title']))
        skip = False
        for feed in oldfeed:
            print('  feed.title:{}'.format(feed['title']))
            if(feed['title'] == newfeed['title']):
                print('{} is going to be merged'.format(feed['title']))
                merge_dict(feed['channels'], newfeed['channels'])
                skip = True
                break
        if skip == False:
            oldfeed.append(newfeed)
            
    return

if __name__ == '__main__':

    for locale in locales:
        # clear feed data
        feeds.clear()

        # decode locale into language and country
        [language, country] = locale.split('_')

        # country code
        dir_name = input_dir + '/' + country

        if os.path.isdir(dir_name):
            for file in os.listdir(dir_name):
                merge_feeds(feeds, load_feeds(dir_name, file))
        else:
            # no country data found
            print('no country data for {}'.format(country))
            break

        # language code
        dir_name = input_dir +  '/' + language

        if os.path.isdir(dir_name):
            for file in os.listdir(dir_name):
                merge_feeds(feeds, load_feeds(dir_name, file))
        else:
            # default to en
            for file in os.listdir(default_language_dir):
                merge_feeds(feeds, load_feeds(default_language_dir, file))

        
        # build output format
        output = {
            "created":datetime.utcnow().isoformat(),
            "data":feeds
        }
        # save it to the file
        with open(output_dir + '/feeds_' + language + '_' + country + '.json', 'w') as f:
            json.dump(output, f, indent=2)