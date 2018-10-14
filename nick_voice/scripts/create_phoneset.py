#! /usr/bin/env python
# create phonesets using the utts.mlf
import sys
import re


def main(argv):
	
	try:
		utt_file_path, phone_file_path = argv
	except :
		print('usage: create_phoneset.py <utterance file (utts.mlf)> <phonelist_output_file>')
		sys.exit(2)

	phones = set();
	with open(utt_file_path, 'r') as utt_file:
		
		line = utt_file.readline()
		while line:
			print(line)
			if '#!MLF!#' in line:
				line = utt_file.readline()
			elif '.lab' in line:
				line = utt_file.readline()
			elif '.' in line:
				line = utt_file.readline()
			else:
				phones.add(line)
				line = utt_file.readline()


	with open(phone_file_path,'w') as phone_file:
		for phone in phones:
			phone_file.write(phone)

if __name__ == '__main__':
	main(sys.argv[1:])