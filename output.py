import os
import sys

def loadFile(file,tp='r'):
	try:
		f=open(file,tp,encoding='utf-8')
		fs=f.read()
		f.close()
		return fs
	except:
		return None

def writeFile(file,data,tp='w'):
	try:
		f=open(file,tp,encoding='utf-8')
		f.write(data)
		f.close()
		return True
	except:
		return False

def main():
	modelContent=loadFile('README.model.md')
	modelSp=modelContent.split('******')
	modelRs=[]
	for m in modelSp:
		if '.lsl' in m and os.path.exists(m):
			lsl=loadFile(m)
			lslSp=lsl.split('***更新记录***\n')
			if len(lslSp)>1:
				lslUp=lslSp[1]
				modelRs.append(lslUp)
				print(lslUp)
		else:
			modelRs.append(m)
			print(m)
	writeFile('README.md',''.join(modelRs))
	print('README.md处理完成！')
	os.system('pause')

if __name__=='__main__':
	main()