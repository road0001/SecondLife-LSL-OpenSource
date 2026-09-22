import os
import sys
import re

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

def syncVersion(file, fileContent, version, hasBuild=True):
	versionSp=version.split('\n')
	curVersion=versionSp[0].replace('-', '').strip()
	if not hasBuild:
		curVersion=curVersion.split(' ')[0]

	pattern = re.compile(r'^([ \t]*string\s+VERSION\s*=\s*")([^"]*)(")', re.MULTILINE)
	m = pattern.search(fileContent)
	if m:
		start, end = m.span(2)
		fileContent = fileContent[:start] + curVersion + fileContent[end:]
		writeFile(file, fileContent)
		print(f'{file} 版本：{curVersion} 已同步')
	else:
		print(f'{file} 版本：{curVersion}')
	return curVersion

def main():
	modelContent=loadFile('README.model.md')
	modelSp=modelContent.split('******')
	modelRs=[]
	modelUp=[]
	for m in modelSp:
		if '.lsl' in m and os.path.exists(m):
			lsl=loadFile(m)
			lslSp=lsl.split('***更新记录***\n')
			if len(lslSp)>1:
				lslUp=lslSp[1]
				modelRs.append(syncVersion(m, lsl, lslUp))
				modelUp.append(lslUp)
				
				# print(lslUp)
		else:
			modelRs.append(m)
			modelUp.append(m)
			print(m)
	writeFile('README.md',''.join(modelRs))
	writeFile('README.VERSION.md',''.join(modelUp))
	print('README.md处理完成！')
	os.system('pause')

if __name__=='__main__':
	main()