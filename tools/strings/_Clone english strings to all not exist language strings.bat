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

set ext[0]=DLSTRINGS
set ext[1]=ILSTRINGS
set ext[2]=STRINGS

set name[0]=BeeingFemale
set name[1]=BeeingFemaleBasicAddOn

if exist _BakClonedFromEnglish.bat del _BakClonedFromEnglish.bat
echo ::need to fast backup all cloned strings to bakforcloned folder when need to reclone updated english strings >> _BakClonedFromEnglish.bat
echo if not exist bakforcloned md bakforcloned >> _BakClonedFromEnglish.bat


FOR /L %%a IN (0,1,1) DO (
FOR /L %%i IN (0,1,2) DO (
FOR /L %%p IN (1,1,18) DO (

if not exist !name[%%a]!_!lang[%%p]!.!ext[%%i]! (

copy !name[%%a]!_!lang[0]!.!ext[%%i]! !name[%%a]!_!lang[%%p]!.!ext[%%i]!
echo move !name[%%a]!_!lang[%%p]!.!ext[%%i]! bakforcloned\ >> _BakClonedFromEnglish.bat

)
)
)
)

echo del _BakClonedFromEnglish.bat >> _BakClonedFromEnglish.bat

cls
echo Cloning finished!
pause

