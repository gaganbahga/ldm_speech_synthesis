import re
import pprint

def main():
	with open('alignment/subs_aligned.final.tri.mlf','r') as align_file:
		counts_dict = dict()
		entry_pattern = r'[0-9]+,[0-9]+,([a-z_]+_[0-9]+),[a-z\-\+_]'
		state_pattern = r'([a-z_]+)_[0-9]+'
		previous_state = ''
		line = align_file.readline()
		while line:
			#print(line)
			match = re.search(entry_pattern, line)
			if match:
				current_state = match.group(1)
				current_phone = re.search(state_pattern, current_state).group(1)

				if current_phone+'_00' not in counts_dict:
					counts_dict[current_phone+'_00'] = dict()

				if previous_state:
					previous_phone = re.search(state_pattern, previous_state).group(1)

					if current_phone == previous_phone:
						if current_state in counts_dict[previous_state]:
							counts_dict[previous_state][current_state] += 1
						else:
							counts_dict[previous_state][current_state] = 1
					else:
						if current_state in counts_dict[current_phone+'_00']:
							counts_dict[current_phone+'_00'][current_state] += 1
						else:
							counts_dict[current_phone+'_00'][current_state] = 1

						if previous_phone+'_000' in counts_dict[previous_state]:
							counts_dict[previous_state][previous_phone+'_000'] += 1
						else:
							counts_dict[previous_state][previous_phone+'_000'] = 1


					if current_state not in counts_dict:
						counts_dict[current_state] = dict()
				else:
					counts_dict[current_state] = dict()

				previous_state = current_state
			line = align_file.readline()

	with open('alignment/phone_list_no_sp','r') as phone_file:
		with open('transition_prob','w') as trans_file:

			phones = phone_file.read().splitlines()
			for phone in phones:
				#print(phone)
				states = [state for state in counts_dict if re.match(phone+r'_[0-9]+',state)]
				states.sort()
				states.append(phone+'_000')
				trans_file.write('\t'.join(states)+'\n')
				for pstate in states:
					if pstate == phone+'_000':
						continue
					counts = [counts_dict[pstate][state] for state in counts_dict[pstate]]
					total = sum(counts)
					prob = list(map(int,[ count/total for count in counts ]))
					for nstate in states:
						if nstate in counts_dict[pstate]:
							trans_file.write(str(float(counts_dict[pstate][nstate] )))
						else:
							trans_file.write(str(0.0))
						trans_file.write('\t')
					trans_file.write('\n')
				trans_file.write('\n')	

			

	# pp = pprint.PrettyPrinter(indent=4)
	# pp.pprint(counts_dict)

if __name__ == '__main__':
	main()