import os
import sys
import glob
import shutil

buildPath='./build'
buildConfigTag='//SRC_PATH'
buildConfigTail='_config'
buildSrcSplit='/*CONFIG END*/'

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

def buildLsl(lsl):
	lslContent=loadFile(lsl)
	if lslContent:
		lslLines=lslContent.replace('\r\n','\n').split('\n')
		if buildConfigTag in lslLines[0]:
			srcPath=lslLines[0].split('=')[1]
			srcName=lsl.replace(buildConfigTail, '')
			lslConfig='\n'.join(lslLines[1:]).strip()

			srcLslContent=loadFile(srcPath)
			if srcLslContent:
				if lslConfig.strip()=='':
					writeFile(f'{buildPath}/{srcName}', srcLslContent.replace(buildSrcSplit, '').strip())
					return True
				else:
					srcLslLines=srcLslContent.split(buildSrcSplit)
					srcLslLines[0]=lslConfig
					lslBuild=''.join(srcLslLines)
					writeFile(f'{buildPath}/{srcName}', lslBuild)
					return True
			else:
				return False
		else:
			writeFile(f'{buildPath}/{lsl}', lslContent)
			return True
	else:
		return False

def main():
	if os.path.exists(buildPath):
		print("Removing build path...")
		shutil.rmtree(buildPath)
	os.makedirs(buildPath)

	lslList=glob.glob('*.lsl')
	buildRs=True
	for lsl in lslList:
		print(f'Building {lsl}...', end='')
		curRs=buildLsl(lsl)
		if curRs==True:
			print('Done!')
		else:
			buildRs=False
			print('Error!')
	if buildRs==True:
		print('Build success!')
	else:
		print('Build Error!')
	os.system('pause')


if __name__=='__main__':
	main()