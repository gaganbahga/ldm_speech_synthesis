import sys, re, numpy

def main(args):
	try:
		score_file = args[1]

	except:
		print('Usage: mean_pesq.py score_file')

	with open(score_file,'r') as sf:
		
		pat = r'[^\s\t]+[\s\t]+[^\s\t]+[\s\t]+([\-0-9\.]+)[\s\t]+([\-0-9\.]+)'
		sf.readline()
		line = sf.readline().strip()

		scores = [];
		while line:
			match = re.match(pat, line)
			if match:
				scores.append(float(match.group(1)))
			else:
				raise Except

			line = sf.readline().strip()
		print('The pesq score is ' + str(numpy.mean(scores)))


if __name__ == '__main__':
	main(sys.argv)