import os
from os.path import exists
import json
import yaml

dir = './paths/'
for file_name in os.listdir (dir):
   if file_name.endswith('yaml'):
      file_origin = dir + file_name
      file_dest = file_origin.replace('yaml', 'json')

      if not exists(file_dest):
         print('DOES NOT exists' + file_dest)
         with open(file_origin, 'r') as yaml_origin:
            yaml_source = yaml.safe_load(yaml_origin)

            with open(file_dest, 'w+') as json_dest:
               json.dump(yaml_source, json_dest)
      else:
         print('exists' + file_dest)
