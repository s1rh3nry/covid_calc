#!/bin/bash

DATE1=`date +%Y_%m_%d`

echo "Get MA mortality and wastewater data updates."
echo "Mortality updates are posted on Thursdays at 5 pm."
echo
echo "Requires python and packages: pandas, openpyxl"
echo

cd data

URL=https://www.mass.gov/info-details/covid-19-response-reporting
FNAME="MA/covid-19-response-reporting.html"
wget -q $URL -O $FNAME
[ -s $FNAME ] || echo "$FNAME is empty. ABORT."
[ -s $FNAME ] || exit 1

#extract data file URL
URL2=`awk -e '$0 ~ /raw-data/ {print $0}' $FNAME | awk -F'"' '{print $2}'`
URL=https://www.mass.gov$URL2

echo "Get mortality data from $URL"
echo

FNAME="MA/raw_data.xlsx"
wget -q $URL -O $FNAME

MOD=`date -r $FNAME`
echo $FNAME $(stat --format=%s "$FNAME") bytes, modified $MOD

FNAME2="MA/mortality.csv"
python3 ../util/extractSheet.py -i $FNAME -o $FNAME2 -n DateofDeath -c 2
echo $FNAME2 $(stat --format=%s "$FNAME2") bytes, modified $MOD


URL=https://raw.githubusercontent.com/biobotanalytics/covid19-wastewater-data/master/wastewater_by_county.csv
FNAME="biobot/wastewater_by_county.csv"
wget -q $URL -O $FNAME

MOD=`date -r $FNAME`
echo $FNAME $(stat --format=%s "$FNAME") bytes, modified $MOD

FNAME2="biobot/wastewater.csv"
COUNTY="Suffolk County, MA"
echo "Filter wastewater data for $COUNTY"
grep "$COUNTY" $FNAME > $FNAME2
echo $FNAME $(stat --format=%s "$FNAME2") bytes, modified $MOD
