import sys
import re


def main(argv):
	
	try:
		alignmentFile, no_states, out_file_name = argv
	except :
		print('usage: create_triphone_labels.py <aligmentfile> <no_states> <outputfile>')
		sys.exit(2)

	no_states = int(no_states)
	#out_file_name = 'monophone_labels_unilex'
	frame_shift = 50000;


	with open(alignmentFile, 'r') as align_file, open(out_file_name, 'w') as subs_file:
		begin_state_pat = r'([0-9]+) ([0-9]+) (s[2-4])?(?: -?[0-9\.]+ )?([a-z_\+\-\@\!]+) -?[0-9\.]+ ([a-z_\+\-\@\!]+)'
		other_state_pattern = r'([0-9]+) ([0-9]+) (s[2-4]) -?[0-9\.]+'
		last_begin = None;
		last_end = None
		line = align_file.readline()
		
		while line:
			match_begin = re.search(begin_state_pat, line)
			match_other = re.search(other_state_pattern, line)
			if match_begin:
				if last_begin is not None:
					write_label(subs_file, last_begin, last_end, frame_shift, no_states)
					# total_dur = int(last_end.group(2)) - int(last_begin.group(1))
					# rem = (total_dur/frame_shift)%no_states
					# time_begin = last_begin.group(1)
					# time_end = 0
					# for state in range(no_states):
					# 	if state < rem:
					# 		time_end = int(time_begin) + frame_shift*int(1 + (total_dur/frame_shift)/no_states)
					# 		subs_file.write(time_begin+','+str(time_end)+',' + last_begin.group(5)+','+str(state+1)+'\n')
					# 		time_begin = str(time_end)
					# 	else:
					# 		time_end = int(time_begin) + frame_shift*int((total_dur/frame_shift)/no_states)
					# 		subs_file.write(time_begin+','+str(time_end)+',' + last_begin.group(5)+','+str(state+1)+'\n')
					# 		time_begin = str(time_end)

				last_begin = match_begin
				last_end = match_begin
				#subs_file.write(match_begin.group(1)+','+match_begin.group(2)+',' + match_begin.group(group)+'\n')
			elif match_other:
				last_end = match_other
				#subs_file.write(match_other.group(1)+','+match_other.group(2)+','+states[last_begin.group(4)][match_other.group(3)]+\
				#	',' + last_begin.group(group)+'\n')
			else:
				if last_begin is not None:
					write_label(subs_file, last_begin, last_end, frame_shift, no_states)
					last_begin = None
				subs_file.write(line)

			line = align_file.readline()


def write_label(file, last_begin, last_end, frame_shift, no_states):
	total_dur = int(last_end.group(2)) - int(last_begin.group(1))
	rem = (total_dur/frame_shift)%no_states
	time_begin = last_begin.group(1)
	time_end = 0
	for state in range(no_states):
		if state < rem:
			time_end = int(time_begin) + frame_shift*int(1 + (total_dur/frame_shift)/no_states)
			file.write(time_begin+','+str(time_end)+',' + last_begin.group(5)+','+str(state+1)+'\n')
			time_begin = str(time_end)
		else:
			time_end = int(time_begin) + frame_shift*int((total_dur/frame_shift)/no_states)
			file.write(time_begin+','+str(time_end)+',' + last_begin.group(5)+','+str(state+1)+'\n')
			time_begin = str(time_end)

if __name__ == '__main__':
	main(sys.argv[1:])
