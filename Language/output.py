import csv
import os
import sys

languageCSV='./Languages.csv'

def outputLanguage(data):
	header=data[0]
	contents=data[1:]
	for i,lan in enumerate(header):
		if i==0:
			continue
		curLan=[]
		for cur in contents:
			key=cur[0]
			val=cur[i]
			if key and not key.startswith('//') and val:
				curLan.append(f'{key}={val}')
		f=open(f'{lan}.txt','w',encoding='utf-8')
		f.write('\n'.join(curLan))
		f.close()

def main():
	languageData=None
	print('Loading Language CSV...')
	with open(languageCSV, 'r', encoding='utf-8-sig') as f:
		reader = csv.reader(f)
		languageData = list(reader)
	print('Outputing Language data...')
	outputLanguage(languageData)
	print('Output Language Success!')
	os.system('pause')


if __name__ == '__main__':
	main()