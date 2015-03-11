import csv
import urllib
from nyc_geoclient import Geoclient
from sys import argv
from sys import exit

script, infile, outfile = argv
g = Geoclient('9cd0a15f', '54dc84bcaca9ff4877da771750033275')

def parse_response(data):
  """
  parses a dictionary response returned by the nyc_geoclient 
  """
  bbl = None
  if type(data) == type({}):
    try:
      return data.get('bbl')
    except AttributeError:
      pass
      return None


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

  if attempt_one == None or 'error' in attempt_one:
    attempt_two = ping_geoclient(second[0], second[1], boro)

  elif attempt_one != None and 'error' not in attempt_one:
    return attempt_one
    
  if attempt_two == None or 'error' in attempt_two:
    attempt_three = ping_geoclient(third[0], third[1], boro)
  
  elif attempt_two != None and 'error' not in attempt_two:
    return attempt_two

  if attempt_three == None or 'error' in attempt_three:
    return 'null'

  elif attempt_three != None and 'error' not in attempt_three:
    return attempt_three

def read_csv(infile, outfile):
  """
  iterates over an input csv file containing fields for building number, 
  street name, street suffix, boro code, and zipcode
  """
  with open(infile, 'rb') as f:
    with open(outfile, 'wb') as w:
      reader = csv.reader(f)
      writer = csv.writer(w)
      header = next(reader, None) # skip CSV header
      writer.writerow(header) # write the header to the outfile      
      try:
        for row in reader:
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
          boro_code = row[-3]
          zipcode = row[-2]                        

          # url encode street name with suffix
          full_street1 = urllib.quote_plus(street + ' ' + suffix)
          full_street2 = urllib.quote_plus(street2 + ' ' + suffix2)          
          full_street3 = urllib.quote_plus(street3 + ' ' + suffix3)

          addresses = [
            [bldgno, full_street1],
            [bldgno2, full_street2],
            [bldgno3, full_street3]
          ]

          # print addresses[0][0], addresses[0][1]
          # print addresses[1][0], addresses[1][1]
          # print addresses[2][0], addresses[2][1]

          print 'bbl: ', try_addresses(addresses, boro_code)
          row[-1] = try_addresses(addresses, boro_code)
          writer.writerow(row)
      
      except csv.Error as e:
        sys.exit('file %s, line %d: %s' % (infile, reader.line_num, e))

if __name__ == '__main__':
  if len(argv) == 3:
    read_csv(infile, outfile)
  else:
    sys.stderr.write(u'''
      Should be called with a file name for CSV input and filename for CSV output data 
      ''')
    sys.exit(1)
