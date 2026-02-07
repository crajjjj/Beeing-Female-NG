#pragma once

#include "CommonLibCompat.h"
#include <sstream>
#include <string>
#include <vector>

namespace FWUtility {

	template<typename T2, typename T1>
	inline T2 lexical_cast(const T1& in) {
		T2 out;
		std::stringstream ss;
		ss << in;
		ss >> out;
		return out;
	}
	template <class T>
	void endswap(T* objp) {
		unsigned char* memp = reinterpret_cast<unsigned char*>(objp);
		std::reverse(memp, memp + sizeof(T));
	}

	SInt32 GetQuestObjectCount(StaticFunctionTag*, BSFixedString modName);
	TESQuest* GetQuestObject(StaticFunctionTag*, BSFixedString modName, SInt32 index);

	TESForm* GetFormFromString(StaticFunctionTag* base, BSFixedString objString);
	BSFixedString GetModFromString(StaticFunctionTag* base, BSFixedString fstr, bool bExt);
	UInt32 GetFormIDFromString(StaticFunctionTag* base, BSFixedString fstr);
	BSFixedString GetStringFromForm(StaticFunctionTag* base, TESForm* frm);
	BSFixedString GetModFromForm(StaticFunctionTag* base, TESForm* frm, bool bExt);
	BSFixedString GetNames(StaticFunctionTag* base, std::vector<RE::Actor*> actors);
	BSFixedString GetActorListNames(StaticFunctionTag* base, std::vector<RE::Actor*> actors, bool preferDisplayName);
	BSFixedString GetPercentage(StaticFunctionTag* base, float percentage, SInt32 decimal, bool bDecimalBase);
	BSFixedString GetTimeString(StaticFunctionTag* base, float timeValue, bool shortFormat, BSFixedString negativeText);
	bool AreModsInstalled(StaticFunctionTag* base, std::vector<BSFixedString> modNames);
	BSFixedString ArrayReplace(StaticFunctionTag* base, BSFixedString text, std::vector<BSFixedString> replace);
	float FloatModulo(StaticFunctionTag* base, float value, float modValue);
	BSFixedString GetModFromID(StaticFunctionTag* base, RE::TESForm* form, bool fileExtension);
	RE::Actor* FindFemaleFromJsonFileName(StaticFunctionTag* base, BSFixedString fileName);
	BSFixedString GetVersionString(StaticFunctionTag* base, BSFixedString modDesc);

	bool ScriptHasString(StaticFunctionTag* base, BSFixedString src, BSFixedString searchStr);
	SInt32 ScriptStringCount(StaticFunctionTag* base, BSFixedString src);
	BSFixedString ScriptUser(StaticFunctionTag* base, BSFixedString src);
	BSFixedString ScriptSource(StaticFunctionTag* base, BSFixedString src);
	BSFixedString ScriptMashine(StaticFunctionTag* base, BSFixedString src);
	BSFixedString ScriptStringGet(StaticFunctionTag* base, BSFixedString src, SInt32 Num);

	unsigned long ScriptFile_GetLong(std::ifstream& fs);
	unsigned int ScriptFile_GetInt(std::ifstream& fs);
	unsigned short ScriptFile_GetShort(std::ifstream& fs);
	unsigned char ScriptFile_GetByte(std::ifstream& fs);
	std::string ScriptFile_GetString(std::ifstream& fs);


	std::string ws2s(std::wstring const& text);
	std::string ReplaceAll(std::string str, const std::string& from, const std::string& to);
	//BSFixedString IOReadTranslation(StaticFunctionTag* base, BSFixedString lng);
	//BSFixedString getLangText(StaticFunctionTag* base, BSFixedString content, BSFixedString VarName, BSFixedString DefaultValue);
	UInt32 GetFileCount(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString extantion);
	BSFixedString GetFileName(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString extantion, UInt32 ID);
	std::vector<BSFixedString> GetFileNames(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString extantion);

	BSFixedString GetDirectoryHash(StaticFunctionTag* Base, BSFixedString Directory);
	BSFixedString toLower(StaticFunctionTag* base, BSFixedString str);
	BSFixedString toUpper(StaticFunctionTag* base, BSFixedString str);
	BSFixedString StringReplace(StaticFunctionTag* Base, BSFixedString content, BSFixedString Find, BSFixedString Replace);
	BSFixedString MultiStringReplace(StaticFunctionTag* Base, BSFixedString content, BSFixedString Replace0, BSFixedString Replace1, BSFixedString Replace2, BSFixedString Replace3, BSFixedString Replace4, BSFixedString Replace5);
	BSFixedString Hex(StaticFunctionTag* Base, SInt32 value, SInt32 Digits);
	std::string Hex_str(long value, int Digits);
	std::string HexDigit(long value, long max, int shift);
	long logical_right_shift(long x, long n);

	BSFixedString getIniPath(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file);


	BSFixedString getIniString(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable, BSFixedString def);
	bool getIniBool(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable, bool def);
	SInt32 getIniInt(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable, SInt32 def);
	float getIniFloat(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable, float def);

	BSFixedString getIniCString(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString categorie, BSFixedString variable, BSFixedString def);
	bool getIniCBool(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString categorie, BSFixedString variable, bool def);
	SInt32 getIniCInt(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString categorie, BSFixedString variable, SInt32 def);
	float getIniCFloat(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString categorie, BSFixedString variable, float def);



	void setIniString(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable, BSFixedString value);
	void setIniBool(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable, bool value);
	void setIniInt(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable, SInt32 value);
	void setIniFloat(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable, float value);

	void setIniCString(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString categorie, BSFixedString variable, BSFixedString value);
	void setIniCBool(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString categorie, BSFixedString variable, bool value);
	void setIniCInt(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString categorie, BSFixedString variable, SInt32 value);
	void setIniCFloat(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString categorie, BSFixedString variable, float value);

	// Array

	/*VMResultArray<BSFixedString*> getIniStringA(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable);
	VMResultArray<bool> getIniBoolA(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable);
	VMResultArray<SInt32> getIniIntA(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable);
	VMResultArray<float> getIniFloatA(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable);*/

	BSFixedString getNextAutoFile(StaticFunctionTag* base, BSFixedString Directory, BSFixedString FileName, BSFixedString Extention);
	bool FileExists(StaticFunctionTag* base, BSFixedString FilePath);
	BSFixedString getTypeString(StaticFunctionTag* Base, UInt32 id);


	void split(const std::string& s, char delim, std::vector<std::string>& elems);
	std::vector<std::string> split(const std::string& s, char delim);

	bool RegisterFuncs(VMClassRegistry* registry);
}
