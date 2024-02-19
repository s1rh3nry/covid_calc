#!/bin/bash

DATE1=`date +%Y_%m_%d`

echo "Get MA mortality and wastewater data updates."
echo "Mortality updates are posted on Thursdays at 5 pm."
echo
echo "Requires python and packages: pandas, openpyxl"
echo

cd data

#URL=https://www.mass.gov/info-details/covid-19-response-reporting
#FNAME="MA/covid-19-response-reporting.html"
#wget -q $URL -O $FNAME
#[ -s $FNAME ] || echo "$FNAME is empty. ABORT."
#[ -s $FNAME ] || exit 1

##extract data file URL
#URL2=`awk -e '$0 ~ /raw-data/ {print $0}' $FNAME | awk -F'"' '{print $2}'`

URL=https://www.mass.gov/media/2642851/download

echo "Get mortality data from $URL"
echo

FNAME="MA/raw_data.xlsx"
wget -q $URL -O $FNAME

MOD=`date -r $FNAME`
echo $FNAME $(stat --format=%s "$FNAME") bytes, modified $MOD

FNAME2="MA/mortality.csv"
python3 ../util/extractSheet.py -i $FNAME -o $FNAME2 -n "Weekly Cases and Deaths" -c 4
echo $FNAME2 $(stat --format=%s "$FNAME2") bytes, modified $MOD

# get wastewater data

cd MWRA
URL0=https://www.mwra.com/biobot/
FNAME=biobotdata.htm
wget -q $URL0$FNAME -O $FNAME
[ -s $FNAME ] || echo "$FNAME is empty. ABORT."
[ -s $FNAME ] || exit 1

#extract PDF data file URL
URL2=`awk -e '$0 ~ /view the data/ {print $0}' $FNAME | awk -F'"' '{print $4}'`
URL=$URL0$URL2

echo "Get wastewater data from $URL"
echo

FNAME=$URL2
wget -q $URL -O $FNAME

MOD=`date -r $FNAME`
echo $FNAME $(stat --format=%s "$FNAME") bytes, modified $MOD

# CONVERT TO TEXT
PDF=$FNAME
echo $FNAME
TXT=$PDF.txt

pdftotext -layout -f 3 $PDF $TXT

# strip FF char
sed -i 's/\f//g' $TXT

# remove leading spaces
sed -i "s/^[ \t]*//" $TXT

cp $TXT wastewater.txt

exit

# OLD CODE TO GET WASTEWATER DATA
URL=https://raw.githubusercontent.com/biobotanalytics/covid19-wastewater-data/master/wastewater_by_county.csv
FNAME="biobot/wastewater_by_county.csv"
wget -q $URL -O $FNAME

MOD=`date -r $FNAME`
echo $FNAME $(stat --format=%s "$FNAME") bytes, modified $MOD

FNAME2="biobot/wastewater.csv"
COUNTY="Suffolk County, MA"
echo "Filter wastewater data for $COUNTY"
# copy header line
head -n 1 $FNAME > $FNAME2
#filter
grep "$COUNTY" $FNAME >> $FNAME2
echo $FNAME $(stat --format=%s "$FNAME2") bytes, modified $MOD
