import glob, os
import re
import pathlib

#Instructions: Create old_files directory you are running this from. Copy common, events, and history into old_files, then run the program.
#Years to add will be the number of years added to every date. After running manually update gfx/portraits/portrait_modifiers/01_headgear_base.txt.
#For reasons unknown to me this file has two instances of the date 1300.1.1 and is the only gfx file to have any dates at all


years_to_add = 10000

for file in glob.glob("old_files/**/*.txt", recursive=True):
	cur_file = open(file, 'r', encoding='utf-8')
	if re.search(r"([0-9]+\.[0-9]+\.[0-9]+)",cur_file.read()): #regex for date selection
		cur_file.seek(0)
		pathlib.Path(file.replace("old_files","new_files").rsplit("\\",1)[0]).mkdir(parents=True, exist_ok=True) #get the path to the file and make the directory if needed
		new_cur_file = open(file.replace("old_files","new_files"), 'w', encoding='utf-8')
		for line in cur_file:
			while True:
				date_regex =  re.search(r"([0-9]+\.[0-9]+\.[0-9]+)",line)
				if date_regex is None: break
				date_span = date_regex.span()
				new_cur_file.write(line[0:date_span[0]])
				date = line[date_span[0]:date_span[1]].split(".",1)
				new_cur_file.write(str(int(date[0])+years_to_add) + "." + date[1])
				line = line[date_span[1]:]
			new_cur_file.write(line)