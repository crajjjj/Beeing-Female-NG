@echo off
setlocal EnableDelayedExpansion
SET lang[0]=ENGLISH
SET lang[1]=CHINESE
SET lang[2]=CZECH
SET lang[3]=DANISH
SET lang[4]=FINNISH
SET lang[5]=FRENCH
SET lang[6]=GERMAN
SET lang[7]=ITALIAN
SET lang[8]=JAPANESE
SET lang[9]=POLISH
SET lang[10]=RUSSIAN
SET lang[11]=SPANISH
SET lang[12]=SWEDISH
SET lang[13]=TURKISH
SET lang[14]=ARABIC
SET lang[15]=GREEK
SET lang[16]=HUNGARIAN
SET lang[17]=NORWEGIAN
SET lang[18]=PORTUGUESE

if exist _BakClonedFromEnglish.bat del _BakClonedFromEnglish.bat
echo ::need to fast backup all cloned strings to bakforcloned folder when need to reclone updated english strings >> _BakClonedFromEnglish.bat
echo if not exist bakforcloned md bakforcloned >> _BakClonedFromEnglish.bat

FOR /L %%p IN (1,1,18) DO (

if not exist BeeingFemale_!lang[%%p]!.txt (
copy BeeingFemale_!lang[0]!.txt BeeingFemale_!lang[%%p]!.txt
echo move BeeingFemale_!lang[%%p]!.txt bakforcloned\ >> _BakClonedFromEnglish.bat
)
)

echo del _BakClonedFromEnglish.bat >> _BakClonedFromEnglish.bat

cls
echo Cloning finished!

pause

