import csv
import os
import sys

languageCSV='./Languages.csv'

languageKeysList={
	'index':[],
	'text':[],
	'count':0,
}
languageValsList={}

def checkKeyValDuplicate():
	languageTempList=[]
	for i,key in enumerate(languageKeysList['text']):
		if key in languageTempList:
			dupIndex=languageKeysList['text'].index(key)
			print(f"!!! Warning: Key duplicate: {languageKeysList['index'][i]} -> {key}  ^  {languageKeysList['index'][dupIndex]} -> {languageKeysList['text'][dupIndex]}")
		else:
			languageTempList.append(key)
	for lan in languageValsList:
		languageTempList=[]
		for i,val in enumerate(languageValsList[lan]['text']):
			if val in languageTempList:
				dupIndex=languageValsList[lan]['text'].index(val)
				print(f"!!! Warning: Val duplicate: {lan} / {languageValsList[lan]['index'][i]} -> {languageKeysList['text'][i]}={val}  ^  {languageValsList[lan]['index'][dupIndex]} -> {languageKeysList['text'][dupIndex]}={languageValsList[lan]['text'][dupIndex]}")
			else:
				languageTempList.append(val)


def outputLanguage(data):
	header=data[0]
	contents=data[1:]
	for i,lan in enumerate(header): # 每列一种语言，第0列为key，第1列以后为语言
		if i==0:
			continue
		curLan=[]
		languageKeysList['count']+=1
		languageValsList[lan]={'index':[], 'text':[]}
		for j,cur in enumerate(contents): # 每行一条语句，第0行为语言名
			key=cur[0]
			val=cur[i]
			if key and not key.startswith('//') and val:
				curLan.append(f'{key}={val}')
				if languageKeysList['count']<=1:
					languageKeysList['index'].append(j+2)
					languageKeysList['text'].append(key)
				languageValsList[lan]['index'].append(j+2)
				languageValsList[lan]['text'].append(val)
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
	checkKeyValDuplicate()
	os.system('pause')


if __name__ == '__main__':
	main()