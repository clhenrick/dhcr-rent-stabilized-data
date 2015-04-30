import csv
import urllib
import re
from nyc_geoclient import Geoclient
from sys import argv
from sys import exit

## TO DO: - fix issue with hyphenated building numbers, 
## - find out why SSL error occurs with GeoClient API

script, infile, outfile = argv
g = Geoclient('9cd0a15f', '54dc84bcaca9ff4877da771750033275')

def clean_bldg_no(num):
  """
  Removes a letter from the building number, eg 64A becomes 64
  """
  m = re.search('(?P<streetnumber>\S+)(\s+)?(?P<letter>(A-Z))?', num)
  if m:
    return m.group(0)
  else:
    return num

def parse_response(data):
  """
  parses a dictionary response returned by the nyc_geoclient 
  """
  keys = ['bbl', 'buildingIdentificationNumber',  
        'latitudeInternalLabel', 'longitudeInternalLabel', 
        'message']
  values = []
  if type(data) == type({}):
    for item in keys:
      try:
        values.append(data.get(item))
      except AttributeError:
        values.append(None)
  return values

def ping_geoclient(number, street, code):
  """
  ping the nyc geoclient api and then parse the response
  """
  response = g.address(number, street, code)
  return parse_response(response)

def try_addresses(addresses, boro):
  """
  try first address, if an error is returned try second, then third
  """
  first = addresses[0]
  second = addresses[1]
  third = addresses[2]  

  attempt_one = ping_geoclient(first[0], first[1], boro)

  if attempt_one[0] is None:
    print 'attempt one failed, trying second address...'
    attempt_two = ping_geoclient(second[0], second[1], boro)

  elif attempt_one[0] is not None:
    return attempt_one
    
  if attempt_two[0] is None:
    print 'attempt two failed, trying third address...'
    attempt_three = ping_geoclient(third[0], third[1], boro)

  elif attempt_two[0] is not None:
    return attempt_two

  if attempt_three[0] is None:
    print 'attempt three failed, removing letter from building number...'
    attempt_four = ping_geoclient(clean_bldg_no(first[0]), first[1], boro)

  elif attempt_three[0] is not None:
    return attempt_three

  if attempt_four[0] is None:
    print 'attempt four failed'
    return attempt_four

  elif attempt_four[0] is not None:
    return attempt_four

def read_csv(infile, outfile):
  """
  iterates over an input csv file containing fields for building number, 
  street name, street suffix, boro code, and zipcode
  writes input csv row with bbl and bin numbers from geoclient api to output csv
  """
  with open(infile, 'rb') as f:
    with open(outfile, 'wb') as w:
      reader = csv.reader(f)
      writer = csv.writer(w)
      header = next(reader, None) # skip CSV header      
      writer.writerow(header) # write the header to the outfile      
      for row in reader:      
        try:
          # reference values for each column
          bldgno = row[1]
          street = row[3]
          suffix = row[4]
          bldgno2 = row[6]
          street2 = row[8]
          suffix2 = row[9]
          bldgno3 = row[11]
          street3 = row[13]
          suffix3 = row[14]          
          boro_code = row[15]
          zipcode = row[16]

          # url encode street name with suffix
          full_street1 = urllib.quote_plus(street + ' ' + suffix)
          full_street2 = urllib.quote_plus(street2 + ' ' + suffix2)          
          full_street3 = urllib.quote_plus(street3 + ' ' + suffix3)

          addresses = [
            [bldgno, full_street1],
            [bldgno2, full_street2],
            [bldgno3, full_street3]
          ]

          parsed_gc_data = try_addresses(addresses, boro_code)

          if parsed_gc_data:
            row[17] = parsed_gc_data[0]
            row[18] = parsed_gc_data[1]
            row[19] = parsed_gc_data[2]
            row[20] = parsed_gc_data[3]
            print 'addresss: %s %s %s %s' % (bldgno, street, suffix, boro_code)
            print 'bbl: %s bin: %s lat: %s lon: %s msg: %s \n' % (parsed_gc_data[0], parsed_gc_data[1], parsed_gc_data[2], 
                                                                  parsed_gc_data[3], parsed_gc_data[4])            
            writer.writerow(row)

          elif parsed_gc_data is None:
            print 'geoclient error: %s \n' % parsed_gc_data[2]
      
        except csv.Error as e:
            # todo - append to a csv file; goal is to have a csv of entries that failed.
            print 'CSV Parse Error:'
            print 'file %s, line %d: %s' % (infile, reader.line_num, e)
            print '===\n\n\n'

        except Exception, e:
            # todo - append to a csv file; goal is to have a csv of entries that failed.
            print 'Exception: '
            print e
            print row
            print '====\n\n'      

if __name__ == '__main__':
  if len(argv) == 3:
    read_csv(infile, outfile)
  else:
    sys.stderr.write(u'''
      Should be called with a file name for CSV input and filename for CSV output data 
      ''')
    sys.exit(1)
