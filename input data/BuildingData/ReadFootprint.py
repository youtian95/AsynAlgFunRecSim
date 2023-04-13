# Read footprint data from 'California.geojson' (source: https://github.com/Microsoft/USBuildingFootprints)
#   and write the footprints into 'SanFrancisco_buildings_full.csv', which contains the basic
#   information of buildings. Since 'California.geojson' is a huge file, we need to use ijson library.
# 
# Note:  'California.geojson' file can be a huge file, but 'SanFrancisco_buildings_full.csv' must be
#   a small file that can be loaded into Memory.
# 
# 3-rd party dependency:
# - ijson, pandas, shapely, simplejson

from urllib.request import urlopen
import ijson 
import simplejson as json
import pandas as pd
from shapely.geometry import Point
from shapely.geometry.polygon import Polygon

footprint_file = 'California.geojson'
Blds_file = 'SanFrancisco_buildings_full.csv'

Blds_allinfo = pd.read_csv(Blds_file,index_col=0)

long_max = Blds_allinfo['Longitude'].max()
long_min = Blds_allinfo['Longitude'].min()
lat_max = Blds_allinfo['Latitude'].max()
lat_min = Blds_allinfo['Latitude'].min()

with open(footprint_file, 'r', encoding='utf-8') as f:
    allblds = ijson.items(f, 'features.item')
    blds = (o for o in allblds if 
        o['geometry']['coordinates'][0][0][0] < (long_max+0.02) 
        and o['geometry']['coordinates'][0][0][0] > (long_min-0.02)
        and o['geometry']['coordinates'][0][0][1] < (lat_max+0.02)
        and o['geometry']['coordinates'][0][0][1] > (lat_min-0.02))

    for b in blds:
        polygon = Polygon(b['geometry']['coordinates'][0])
        for ind, row in Blds_allinfo.iterrows():
            point = Point(row['Longitude'],row['Latitude'])
            if polygon.contains(point):
                Blds_allinfo.loc[ind,'Footprint']= json.dumps(b)

Blds_allinfo.to_csv('new_'+Blds_file)





