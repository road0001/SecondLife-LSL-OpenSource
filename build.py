import os
import sys
import glob
import shutil

buildPath='./build'
cfgPath='./Config'
lanPath='./Language'
buildConfigTag='//SRC_PATH'
buildConfigTail='_config'
buildSrcSplit='/*CONFIG END*/'
bulidLanHeader='lan_'

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
				writeFile(f'{buildPath}/{srcName}', lslConfig.strip())
				return True
		else:
			writeFile(f'{buildPath}/{lsl}', lslContent)
			return True
	else:
		return False

def buildCfg(cfg):
	cfgContent=loadFile(f'{cfgPath}/{cfg}')
	if cfgContent:
		cfgLines=cfgContent.replace('\r\n','\n').strip().split('\n')
		if buildConfigTag in cfgLines[0]:
			srcPath=cfgLines[0].split('=')[1]
			cfgConfig='\n'.join(cfgLines[1:]).strip()

			srcCfgContent=loadFile(f'{srcPath}/{cfg}')
			if srcCfgContent:
				if cfgConfig.strip()=='':
					writeFile(f'{buildPath}/{cfg}', srcCfgContent.strip())
					return True
				else:
					writeFile(f'{buildPath}/{cfg}', srcCfgContent.strip()+'\n'+cfgConfig.strip())
					return True
			else:
				writeFile(f'{buildPath}/{cfg}', cfgConfig.strip())
				return True
		else:
			writeFile(f'{buildPath}/{cfg}', cfgContent)
			return True
	else:
		return False

def buildLan(lan):
	lanContent=loadFile(f'{lanPath}/{lan}')
	if lanContent:
		lanLines=lanContent.replace('\r\n','\n').strip().split('\n')
		if buildConfigTag in lanLines[0]:
			srcPath=lanLines[0].split('=')[1]
			lanConfig='\n'.join(lanLines[1:]).strip()

			srcLanContent=loadFile(f'{srcPath}/{lan}')
			if srcLanContent:
				if lanConfig.strip()=='':
					writeFile(f'{buildPath}/{bulidLanHeader}{lan}', srcLanContent.strip())
					return True
				else:
					writeFile(f'{buildPath}/{bulidLanHeader}{lan}', srcLanContent.strip()+'\n'+lanConfig.strip())
					return True
			else:
				writeFile(f'{buildPath}/{bulidLanHeader}{lan}', lanConfig.strip())
				return True
		else:
			writeFile(f'{buildPath}/{bulidLanHeader}{lan}', lanContent)
			return True
	else:
		return False

def main():
	if os.path.exists(buildPath):
		print("Removing build path...")
		shutil.rmtree(buildPath)
	os.makedirs(buildPath)
	buildRs=True
	
	lslList=glob.glob('*.lsl')
	for lsl in lslList:
		print(f'Building {lsl}...', end='')
		curRs=buildLsl(lsl)
		if curRs==True:
			print('Done!')
		else:
			buildRs=False
			print('Error!')
	
	cfgList=glob.glob(f'{cfgPath}/*.txt')
	for cfg in cfgList:
		print(f'Building config {cfg}...', end='')
		curRs=buildCfg(cfg.split('\\')[1])
		if curRs==True:
			print('Done!')
		else:
			buildRs=False
			print('Error!')

	lanList=glob.glob(f'{lanPath}/*.txt')
	for lan in lanList:
		print(f'Building language {lan}...', end='')
		curRs=buildLan(lan.split('\\')[1])
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