#!/usr/bin/env python3

import re
import argparse
import pandas as pd

from sys import exit

parser = argparse.ArgumentParser(description='Run the MAGMA pipeline samplesheet validation')
parser.add_argument('input_file', metavar='input_file', type=str, help='The input sample file')
args = vars(parser.parse_args())

name_re = re.compile('^[a-zA-Z0-9\-\_]*$')
ss = pd.read_csv(args['input_file'])

# Create another column by adding Sample and Attempt columns
ss['MagmaSampleName'] = ss['Study'].astype(str) + \
                                    "." + ss['Sample'].astype(str) + \
                                    ".L" + ss['Library'].astype(str) + \
                                    ".A" + ss['Attempt'].astype(str) + \
                                    "." + ss['Flowcell'].astype(str) + \
                                    "." + ss['Lane'].astype(str) + \
                                    "." + ss['Index Sequence'].astype(str)


fail = False
for idx, row in ss.iterrows():
    if not name_re.match(row['Study']):
        print('Row {}: {}  Illegal character in STUDY id'.format(idx, row['Study']))
        fail = True
    if not name_re.match(row['Sample']):
        print('Row {}: {} - Illegal character in SAMPLE id'.format(idx, row['Sample']))
        fail = True
    if row['R1'] == row['R2']:
        print('Row {}: {}, {} - REPEATED fastq file specified'.format(idx, row['R1'], row['R2']))
        fail = True


if not fail:
    ss.to_csv('samplesheet.format_valid.csv', index=False)
    print('Samplesheet format validation checks passed')
    exit(0)
else:
    print('Samplesheet format validation checks failed')
    exit(1)
