import pandas as pd
import openpyxl
import argparse

desc = "Extract named sheet of .xlsx file and save to .csv ."
parser = argparse.ArgumentParser(description=desc)

parser.add_argument("-i", "--input", type=str, help="input file name", required=True)
parser.add_argument("-o", "--output", type=str, help="output file name", required=True)
parser.add_argument("-n", "--name", type=str, help="sheet name", required=True)
parser.add_argument("-c", "--columns", type=int, help="number of columns", required=True)
parser.add_argument("-v", help="verbose", action='store_true')

args = parser.parse_args()

book = openpyxl.load_workbook(args.input, read_only=True, data_only=True)
sheet = book[args.name]
data = sheet.values

# Get the first line in file as a header line
columns = next(data)[0:]
# Create a DataFrame based on the second and subsequent lines of data
df = pd.DataFrame(data, columns=columns)

df.to_csv(args.output, columns=columns[0:args.columns], index=False)
