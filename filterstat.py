#!/usr/bin/env python
# encoding: utf-8
"""
filterstat.py

# CDDL HEADER START
#
# The contents of this file are subject to the terms of the
# Common Development and Distribution License, Version 1.0 only
# (the "License").  You may not use this file except in compliance
# with the License.
#
# You can obtain a copy of the license at
# http://forgerock.org/license/CDDLv1.0.html.
# See the License for the specific language governing permissions
# and limitations under the License.
#
# When distributing Covered Code, include this CDDL HEADER in each
# file and include the License file at
# trunk/opends/resource/legal-notices/OpenDS.LICENSE.  If applicable,
# add the following below this CDDL HEADER, with the fields enclosed
# by brackets "[]" replaced with your own identifying information:
#      Portions Copyright [yyyy] [name of copyright owner]
#
# CDDL HEADER END
#
#
#      Copyright 2013 ForgeRock Inc.

Created by Ludovic Poitou on 2013-10-11.

This program reads OpenDJ access logs and output filter statistics.
"""
import sys
import getopt
import re
import string

help_message = '''
Usage: filterstat.py [options] file [file ...]
options:
\t -f : keep full original filters
\t -o output : specifies the output file, otherwise stdout is used
\t -v : verbose mode

file must be an OpenDJ textual access log file
'''

class Usage(Exception):
	def __init__(self, msg):
		self.msg = msg


def reduce(string):
	pattern = "\(([\w-]+)=([^)\*]+)\)"
	f = re.sub(pattern, "(\\1=VALUE)",string, 0)
	f = re.sub("\(([\w-]+)=\*([^)\*]+)(\**)\)", "(\\1=*SUBSTRING\\3)",f, 0)
	f = re.sub("\(([\w-]+)=([^)\*]+)(\*+)\)", "(\\1=SUBSTRING\\3)",f, 0)
	return f

def main(argv=None):
	output = ""
	verbose = False
	fullFilter = False
	baseFilters = dict()
	filters = dict()
	IDs = {}
	if argv is None:
		argv = sys.argv
	try:
		try:
			opts, args = getopt.getopt(argv[1:], "fho:v", ["help", "output="])
		except getopt.error, msg:
			raise Usage(msg)

		# option processing
		for option, value in opts:
			if option == "-f":
				fullFilter = True
			if option == "-v":
				verbose = True
			if option in ("-h", "--help"):
				raise Usage(help_message)
			if option in ("-o", "--output"):
				output = value
				
	except Usage, err:
		print >> sys.stderr, sys.argv[0].split("/")[-1] + ": " + str(err.msg)
		print >> sys.stderr, "\t for help use --help"
		return 2

	if output != "":
		try:
			outfile = open(output, "w")
		except Usage, err:
			print >> sys.stderr, "Can't open output file: " + str(err.msg)
	else:
		outfile = sys.stdout

	for logfile in args:
		try:
			infile = open(logfile, "r")
		except err:
			print >> sys.stderr, "Can't open file: " + str(err.msg)


		outfile.write("processing file: "+ logfile + "\n")
		for i in infile:
			m = re.match(".* SEARCH .* scope=(.+) filter=\"(.+)\" attrs.*", i)
			if m:
				scope = m.group(1)
				filter = m.group(2)
				
				if fullFilter == False :
					filter = reduce(filter)
				
				if scope == "baseObject":
					# just count the filters
					if filter in baseFilters:
						baseFilters[filter] += 1
					else:
						baseFilters[filter] = 1
				else:
					if filter in filters:
						filters[filter] += 1
					else:
						filters[filter] = 1
		
		infile.close()

	ranking = sorted(((v, k) for k, v in filters.iteritems()), reverse=True)
	for k, v in ranking:
		outfile.write(str(k) +"\t" + v + "\n")
	outfile.write("\nBase search filters only:\n")
	baseRanking = sorted(((v, k) for k, v in baseFilters.iteritems()), reverse=True)
	for k, v in baseRanking:
		outfile.write(str(k) +"\t" + v + "\n")
		
	outfile.write("Done\n")
	outfile.close()
if __name__ == "__main__":
	sys.exit(main())
