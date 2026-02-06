
#include "CommonLibCompat.h"
#include "FWUtility.h"
//#include "../common/IFileStream.h"
#include <fstream>
#include <codecvt>
#include <sys/stat.h>
#include <iostream>
#include <iomanip>

#include <clocale>
#include <locale>
#include <vector>
#include <algorithm>
#include <cctype>
#include <cmath>
#include <cstring>
#include <string>
#include <sstream>

#include "stdint.h"
#include <cstdint>
#include <windows.h>
#include <tchar.h>

#include "inisetting.h"



namespace FWUtility {


	TESQuest* GetQuestObject(StaticFunctionTag*, BSFixedString modName, SInt32 index) {
		auto* dataHandler = DataHandler::GetSingleton();
		const ModInfo* modInfo = dataHandler->LookupModByName(modName.data());
		if (!modInfo) {
			std::string espName = modName.data();
			espName.append(".esp");
			modInfo = dataHandler->LookupModByName(espName.c_str());
		}
		if (!modInfo) {
			std::string esmName = modName.data();
			esmName.append(".esm");
			modInfo = dataHandler->LookupModByName(esmName.c_str());
		}
		if (!modInfo) {
			return nullptr;
		}

		auto& quests = dataHandler->GetFormArray<TESQuest>();
		SInt32 remaining = index;
		const auto modIndex = modInfo->GetCompileIndex();
		for (auto* quest : quests) {
			if (!quest)
				continue;
			if ((quest->formID >> 24) != modIndex)
				continue;
			if (remaining <= 0)
				return quest;
			--remaining;
		}
		return nullptr;
	}

	SInt32 GetQuestObjectCount(StaticFunctionTag*, BSFixedString modName) {
		auto* dataHandler = DataHandler::GetSingleton();
		const ModInfo* modInfo = dataHandler->LookupModByName(modName.data());
		if (!modInfo) {
			std::string espName = modName.data();
			espName.append(".esp");
			modInfo = dataHandler->LookupModByName(espName.c_str());
		}
		if (!modInfo) {
			std::string esmName = modName.data();
			esmName.append(".esm");
			modInfo = dataHandler->LookupModByName(esmName.c_str());
		}
		if (!modInfo) {
			return 0;
		}

		SInt32 count = 0;
		auto& quests = dataHandler->GetFormArray<TESQuest>();
		const auto modIndex = modInfo->GetCompileIndex();
		for (auto* quest : quests) {
			if (!quest)
				continue;
			if ((quest->formID >> 24) != modIndex)
				continue;
			++count;
		}
		return count;
	}



	//static std::string language;

	int exist(char* name) {
		struct stat   buffer;
		return (stat(name, &buffer) == 0);
	}


	SInt32 ScriptStringCount(StaticFunctionTag* base, BSFixedString src) {
		(void)base;
		std::ifstream fs;

		// Generating file name
		std::string FileName = "Data/Scripts/";
		FileName.append(src.data());
		FileName.append(".pex");

		try {
			// Try to open
			fs.open(FileName, std::ios::binary);
		}
		catch (std::exception*) {
			return -2;
		}
		if (fs.is_open()) {
			/*unsigned int fMagic;
			unsigned char fMajor;
			unsigned char fMinor;
			unsigned short fGameID;
			unsigned long fCompileTime;
			std::string fSourceFileName;
			std::string fUserName;
			std::string fMachineName;
			fs.read(reinterpret_cast<char*>(&fMagic), 4);
			fs.read(reinterpret_cast<char*>(&fMajor), 1);
			fs.read(reinterpret_cast<char*>(&fMinor), 1);
			fs.read(reinterpret_cast<char*>(&fGameID), 2);
			fs.read(reinterpret_cast<char*>(&fCompileTime), 8);
			fSourceFileName = ScriptHasString_GetString(fs);
			fUserName = ScriptHasString_GetString(fs);
			fMachineName = ScriptHasString_GetString(fs);*/

			unsigned int fMagic = ScriptFile_GetInt(fs);
			unsigned char fMajor = ScriptFile_GetByte(fs);
			unsigned char fMinor = ScriptFile_GetByte(fs);
			unsigned short fGameID = ScriptFile_GetShort(fs);
			(void)fMagic;
			(void)fMajor;
			(void)fMinor;
			(void)fGameID;
			//unsigned long fCompileTime = ScriptFile_GetLong(fs);
			fs.seekg(16, std::ios::beg);
			std::string fSourceFileName = ScriptFile_GetString(fs);
			std::string fUserName = ScriptFile_GetString(fs);
			std::string fMachineName = ScriptFile_GetString(fs);
			unsigned short StringTableCount = ScriptFile_GetShort(fs);

			fs.close();
			return StringTableCount;
		}
		return -1;
	}

	BSFixedString ScriptUser(StaticFunctionTag* base, BSFixedString src) {
		(void)base;
		std::ifstream fs;

		// Generating file name
		std::string FileName = "Data/Scripts/";
		FileName.append(src.data());
		FileName.append(".pex");

		try {
			// Try to open
			fs.open(FileName, std::ios::binary);
		}
		catch (std::exception*) {
			return BSFixedString("");
		}
		if (fs.is_open()) {
			unsigned int fMagic = ScriptFile_GetInt(fs);
			unsigned char fMajor = ScriptFile_GetByte(fs);
			unsigned char fMinor = ScriptFile_GetByte(fs);
			unsigned short fGameID = ScriptFile_GetShort(fs);
			(void)fMagic;
			(void)fMajor;
			(void)fMinor;
			(void)fGameID;
			//unsigned long fCompileTime = ScriptFile_GetLong(fs);
			fs.seekg(16, std::ios::beg);
			std::string fSourceFileName = ScriptFile_GetString(fs);
			std::string fUserName = ScriptFile_GetString(fs);
			std::string fMachineName = ScriptFile_GetString(fs);
			unsigned short StringTableCount = ScriptFile_GetShort(fs);
			(void)StringTableCount;
			fs.close();
			return BSFixedString(fUserName.c_str());
		}
		return BSFixedString("");
	}

	BSFixedString ScriptSource(StaticFunctionTag* base, BSFixedString src) {
		(void)base;
		std::ifstream fs;

		// Generating file name
		std::string FileName = "Data/Scripts/";
		FileName.append(src.data());
		FileName.append(".pex");

		try {
			// Try to open
			fs.open(FileName, std::ios::binary);
		}
		catch (std::exception*) {
			return BSFixedString("");
		}
		if (fs.is_open()) {
			unsigned int fMagic = ScriptFile_GetInt(fs);
			unsigned char fMajor = ScriptFile_GetByte(fs);
			unsigned char fMinor = ScriptFile_GetByte(fs);
			unsigned short fGameID = ScriptFile_GetShort(fs);
			(void)fMagic;
			(void)fMajor;
			(void)fMinor;
			(void)fGameID;
			//unsigned long fCompileTime = ScriptFile_GetLong(fs);
			fs.seekg(16, std::ios::beg);
			std::string fSourceFileName = ScriptFile_GetString(fs);
			std::string fUserName = ScriptFile_GetString(fs);
			std::string fMachineName = ScriptFile_GetString(fs);
			unsigned short StringTableCount = ScriptFile_GetShort(fs);
			(void)StringTableCount;
			fs.close();
			return BSFixedString(fSourceFileName.c_str());
		}
		return BSFixedString("");
	}

	BSFixedString ScriptMashine(StaticFunctionTag* base, BSFixedString src) {
		(void)base;
		std::ifstream fs;

		// Generating file name
		std::string FileName = "Data/Scripts/";
		FileName.append(src.data());
		FileName.append(".pex");

		try {
			// Try to open
			fs.open(FileName, std::ios::binary);
		}
		catch (std::exception*) {
			return BSFixedString("");
		}
		if (fs.is_open()) {
			unsigned int fMagic = ScriptFile_GetInt(fs);
			unsigned char fMajor = ScriptFile_GetByte(fs);
			unsigned char fMinor = ScriptFile_GetByte(fs);
			unsigned short fGameID = ScriptFile_GetShort(fs);
			(void)fMagic;
			(void)fMajor;
			(void)fMinor;
			(void)fGameID;
			//unsigned long fCompileTime = ScriptFile_GetLong(fs);
			fs.seekg(16, std::ios::beg);
			std::string fSourceFileName = ScriptFile_GetString(fs);
			std::string fUserName = ScriptFile_GetString(fs);
			std::string fMachineName = ScriptFile_GetString(fs);
			unsigned short StringTableCount = ScriptFile_GetShort(fs);
			(void)StringTableCount;
			fs.close();
			return BSFixedString(fMachineName.c_str());
		}
		return BSFixedString("");
	}

	BSFixedString ScriptStringGet(StaticFunctionTag* base, BSFixedString src, SInt32 Num) {
		(void)base;
		if (Num < 0) {
			return BSFixedString("");
		}
		std::ifstream fs;

		// Generating file name
		std::string FileName = "Data/Scripts/";
		FileName.append(src.data());
		FileName.append(".pex");

		try {
			// Try to open
			fs.open(FileName, std::ios::binary);
		}
		catch (std::exception*) {
			return BSFixedString("");
		}
		if (fs.is_open()) {
			unsigned int fMagic = ScriptFile_GetInt(fs);
			unsigned char fMajor = ScriptFile_GetByte(fs);
			unsigned char fMinor = ScriptFile_GetByte(fs);
			unsigned short fGameID = ScriptFile_GetShort(fs);
			(void)fMagic;
			(void)fMajor;
			(void)fMinor;
			(void)fGameID;
			//unsigned long fCompileTime = ScriptFile_GetLong(fs);
			fs.seekg(16, std::ios::beg);
			std::string fSourceFileName = ScriptFile_GetString(fs);
			std::string fUserName = ScriptFile_GetString(fs);
			std::string fMachineName = ScriptFile_GetString(fs);
			unsigned short StringTableCount = ScriptFile_GetShort(fs);

			for (unsigned short i = 0; i < StringTableCount; ++i) {
				std::string str1 = ScriptFile_GetString(fs);
				if (i == static_cast<unsigned short>(Num)) {
					fs.close();
					return BSFixedString(str1.c_str());
				}
			}
			fs.close();
			return BSFixedString("");
		}
		return BSFixedString("");
	}

	bool ScriptHasString(StaticFunctionTag* base, BSFixedString src, BSFixedString searchStr) {
		(void)base;
		std::string sStr = searchStr.data();
		const char* cStr = sStr.c_str();
		std::ifstream fs;

		// Generating file name
		std::string FileName = "Data/scripts/";
		FileName.append(src.data());
		FileName.append(".pex");

		try {
			// Try to open
			fs.open(FileName, std::ios::binary);
		}
		catch (std::exception*) {
			return false;
		}
		bool bFound = false;
		if (fs.is_open()) {
			//unsigned int fMagic;
			//unsigned char fMajor;
			//unsigned char fMinor;
			//unsigned short fGameID;
			//unsigned long fCompileTime;
			//std::string fSourceFileName;
			//std::string fUserName;
			//std::string fMachineName;
			//fs.read(reinterpret_cast<char*>(&fMagic), 4);
			//fs.read(reinterpret_cast<char*>(&fMajor), 1);
			//fs.read(reinterpret_cast<char*>(&fMinor), 1);
			//fs.read(reinterpret_cast<char*>(&fGameID), 2);
			//fs.read(reinterpret_cast<char*>(&fCompileTime), 8);
			//fSourceFileName = ScriptHasString_GetString(fs);
			//fUserName = ScriptHasString_GetString(fs);
			//fMachineName = ScriptHasString_GetString(fs);

			//unsigned short StringTableCount;
			//fs.read( reinterpret_cast<char*>(&StringTableCount) , sizeof(StringTableCount));
			//if(StringTableCount>0x4000)
			//	endswap(&StringTableCount);

			unsigned int fMagic = ScriptFile_GetInt(fs);
			unsigned char fMajor = ScriptFile_GetByte(fs);
			unsigned char fMinor = ScriptFile_GetByte(fs);
			unsigned short fGameID = ScriptFile_GetShort(fs);
			(void)fMagic;
			(void)fMajor;
			(void)fMinor;
			(void)fGameID;
			//unsigned long fCompileTime = ScriptFile_GetLong(fs);
			fs.seekg(16, std::ios::beg);
			std::string fSourceFileName = ScriptFile_GetString(fs);
			std::string fUserName = ScriptFile_GetString(fs);
			std::string fMachineName = ScriptFile_GetString(fs);
			unsigned short StringTableCount = ScriptFile_GetShort(fs);
			while (StringTableCount > 0 && !bFound) {
				StringTableCount -= 1;
				std::string str1 = ScriptFile_GetString(fs);
				if (strcmp(str1.c_str(), cStr) == 0)
					bFound = true;
			}
			fs.close();
		}
		return bFound;
	}

	unsigned char ScriptFile_GetByte(std::ifstream& fs) {
		unsigned char b1 = 0;
		fs.read(reinterpret_cast<char*>(&b1), 1);
		return b1;
	}

	unsigned short ScriptFile_GetShort(std::ifstream& fs) {
		unsigned char b1 = 0;
		unsigned char b2 = 0;
		fs.read(reinterpret_cast<char*>(&b1), 1);
		fs.read(reinterpret_cast<char*>(&b2), 1);
		unsigned short i1 = static_cast<unsigned short>(b1);
		unsigned short i2 = static_cast<unsigned short>(b2);
		return static_cast<unsigned short>((i1 << 8) | i2);

		//unsigned char b1;
		//unsigned char b2;
		//fs>>b1;
		//fs>>b2;
		//return (b1*256) + b2;
	}

	unsigned int ScriptFile_GetInt(std::ifstream& fs) {
		unsigned char b1 = 0;
		unsigned char b2 = 0;
		unsigned char b3 = 0;
		unsigned char b4 = 0;
		fs.read(reinterpret_cast<char*>(&b1), 1);
		fs.read(reinterpret_cast<char*>(&b2), 1);
		fs.read(reinterpret_cast<char*>(&b3), 1);
		fs.read(reinterpret_cast<char*>(&b4), 1);
		unsigned int i1 = static_cast<unsigned int>(b1);
		unsigned int i2 = static_cast<unsigned int>(b2);
		unsigned int i3 = static_cast<unsigned int>(b3);
		unsigned int i4 = static_cast<unsigned int>(b4);
		return (i1 << 24) | (i2 << 16) | (i3 << 8) | i4;
	}

	unsigned long ScriptFile_GetLong(std::ifstream& fs) {
		unsigned char b1;
		unsigned char b2;
		unsigned char b3;
		unsigned char b4;
		unsigned char b5;
		unsigned char b6;
		unsigned char b7;
		unsigned char b8;
		fs >> b1;
		fs >> b2;
		fs >> b3;
		fs >> b4;
		fs >> b5;
		fs >> b6;
		fs >> b7;
		fs >> b8;
		return 0; // Ignore - don't know how to read in a 64-bit integer
		//return (unsigned long)b8 | (unsigned long)b7<<8 | (unsigned long)b6<<16 | (unsigned long)b5<<24 | ((unsigned long)b4<<32) | ((unsigned long)b3<<40) | ((unsigned long)b2<<48) | ((unsigned long)b1<<56);
	}

	std::string ScriptFile_GetString(std::ifstream& fs) {
		unsigned short i_var = ScriptFile_GetShort(fs);

		/*char b1;
		char b2;
		fs.read(&b1, 1);
		fs.read(&b2, 1);
		unsigned short i1 = (int)b1;
		unsigned short i2 = (int)b2;
		unsigned short i_var = (i1<<8) + i2;*/

		std::string res;
		res.resize(i_var);
		fs.read(&res[0], i_var);
		return res;
		/*std::string res2;
		res2.append("(");
		res2.append(std::to_string(i1));
		res2.append("+");
		res2.append(std::to_string(i2));
		res2.append("=");
		res2.append(std::to_string(i_var));
		res2.append(")");
		res2.append(res);
		return res2;*/
	}


	TESForm* GetFormFromString(StaticFunctionTag* base, BSFixedString fstr) {
		(void)base;
		std::string objString = fstr.data();
		if (objString == "0")
			return nullptr;
		const size_t colonPos = objString.find(':');
		if (colonPos != std::string::npos) {
			const std::string modName = objString.substr(0, colonPos);
			std::string idStr = objString.substr(colonPos + 1);
			if (modName.empty() || idStr.empty()) {
				return nullptr;
			}
			if (idStr.size() > 1 && idStr[0] == '0' && (idStr[1] == 'x' || idStr[1] == 'X')) {
				idStr = idStr.substr(2);
			}
			char* endptr = nullptr;
			const UInt32 rawID = static_cast<UInt32>(std::strtoul(idStr.c_str(), &endptr, 16));
			if (endptr == idStr.c_str() || (endptr && *endptr != '\0')) {
				return nullptr;
			}

			const BSFixedString resolved = GetModFromString(nullptr, BSFixedString(modName.c_str()), true);
			const char* resolvedName = resolved.data();
			if (!resolvedName || resolvedName[0] == '\0') {
				return nullptr;
			}

			auto* dataHandler = DataHandler::GetSingleton();
			if (!dataHandler) {
				return nullptr;
			}
			const ModInfo* modInfo = dataHandler->LookupModByName(resolvedName);
			if (!modInfo) {
				return nullptr;
			}

			UInt32 formID = 0;
			if (modInfo->IsLight()) {
				const UInt32 lightIndex = modInfo->GetPartialIndex();
				formID = 0xFE000000 | (lightIndex << 12) | (rawID & 0xFFF);
			} else {
				const UInt32 index = modInfo->GetCompileIndex();
				formID = (index << 24) | (rawID & 0x00FFFFFF);
			}
			return TESForm::LookupByID(formID);
		}
		return nullptr;
	}

	BSFixedString GetModFromString(StaticFunctionTag* base, BSFixedString fstr, bool bExt) {
		(void)base;
		std::string objString = fstr.data();
		if (objString == "0")
			return BSFixedString("");

		auto* dataHandler = DataHandler::GetSingleton();
		if (!dataHandler) {
			return BSFixedString("");
		}

		auto stripExt = [](const std::string& name) {
			const size_t pos = name.find_last_of('.');
			if (pos == std::string::npos) {
				return name;
			}
			return name.substr(0, pos);
		};

		auto hasExt = [](const std::string& value, const char* ext) -> bool {
			const size_t extLen = std::strlen(ext);
			if (value.size() < extLen) {
				return false;
			}
			return value.compare(value.size() - extLen, extLen, ext) == 0;
		};

		auto resolveModName = [&](const std::string& name) -> BSFixedString {
			const ModInfo* modInfo = nullptr;
			if (hasExt(name, ".esm") || hasExt(name, ".esp") || hasExt(name, ".esl")) {
				modInfo = dataHandler->LookupModByName(name.c_str());
				if (modInfo) {
					auto filename = modInfo->GetFilename();
					std::string result(filename.data(), filename.size());
					if (!bExt) {
						result = stripExt(result);
					}
					return BSFixedString(result.c_str());
				}
			}

			modInfo = dataHandler->LookupModByName((name + ".esm").c_str());
			if (modInfo) {
				auto filename = modInfo->GetFilename();
				std::string result(filename.data(), filename.size());
				if (!bExt) {
					result = stripExt(result);
				}
				return BSFixedString(result.c_str());
			}

			modInfo = dataHandler->LookupModByName((name + ".esp").c_str());
			if (modInfo) {
				auto filename = modInfo->GetFilename();
				std::string result(filename.data(), filename.size());
				if (!bExt) {
					result = stripExt(result);
				}
				return BSFixedString(result.c_str());
			}

			modInfo = dataHandler->LookupModByName((name + ".esl").c_str());
			if (modInfo) {
				auto filename = modInfo->GetFilename();
				std::string result(filename.data(), filename.size());
				if (!bExt) {
					result = stripExt(result);
				}
				return BSFixedString(result.c_str());
			}

			modInfo = dataHandler->LookupModByName(name.c_str());
			if (modInfo) {
				auto filename = modInfo->GetFilename();
				std::string result(filename.data(), filename.size());
				if (!bExt) {
					result = stripExt(result);
				}
				return BSFixedString(result.c_str());
			}

			return BSFixedString("");
		};

		return resolveModName(objString);
	}

	UInt32 GetFormIDFromString(StaticFunctionTag* base, BSFixedString fstr) {
		(void)base;
		std::string objString = fstr.data();
		if (objString == "0")
			return 0;
		if (objString.find(':') == std::string::npos) {
			return 0;
		}
		TESForm* frm = GetFormFromString(nullptr, fstr);
		if (!frm) {
			return 0;
		}
		return frm->formID;
	}

	BSFixedString GetStringFromForm(StaticFunctionTag* base, TESForm* frm) {
		(void)base;
		if (frm == NULL) return BSFixedString("");
		const auto* file = frm->GetFile(0);
		if (!file) return BSFixedString("");
		std::string str = std::string(file->GetFilename());

		const size_t lastindex = str.find_last_of(".");
		if (lastindex != std::string::npos) {
			str = str.substr(0, lastindex);
		}

		str.append(":");
		str.append(Hex_str(frm->formID & 0xFFFFFF, 0));

		return BSFixedString(str.c_str());
	}

	BSFixedString GetModFromForm(StaticFunctionTag* base, TESForm* frm, bool bExt) {
		(void)base;
		if (frm == NULL) return BSFixedString("");
		const auto* file = frm->GetFile(0);
		if (!file) return BSFixedString("-3");
		std::string str = std::string(file->GetFilename());

		if (!bExt) {
			size_t lastindex = str.find_last_of(".");
			if (lastindex != std::string::npos)
				str = str.substr(0, lastindex);
		}

		return BSFixedString(str.c_str());
	}

	std::vector<RE::Actor*> ActorArrayResize(StaticFunctionTag* base, std::vector<RE::Actor*> oldArray, SInt32 newSize) {
		(void)base;
		if (newSize < 1) {
			newSize = 1;
		} else if (newSize > 128) {
			newSize = 128;
		}

		std::vector<RE::Actor*> result(static_cast<std::size_t>(newSize), nullptr);
		const std::size_t copyCount = (result.size() < oldArray.size()) ? result.size() : oldArray.size();
		for (std::size_t i = 0; i < copyCount; ++i) {
			result[i] = oldArray[i];
		}
		return result;
	}

	std::vector<RE::Actor*> ActorArrayUnique(StaticFunctionTag* base, std::vector<RE::Actor*> actors) {
		(void)base;
		if (actors.size() < 2) {
			return actors;
		}
		const std::size_t c = actors.size();
		SInt32 newLen = static_cast<SInt32>(c);
		for (std::size_t i = 0; i + 1 < c; ++i) {
			if (!actors[i]) {
				continue;
			}
			bool found = false;
			for (std::size_t j = i + 1; j < c; ++j) {
				if (actors[i] == actors[j]) {
					found = true;
					break;
				}
			}
			if (found) {
				actors[i] = nullptr;
				newLen -= 1;
			}
		}
		if (newLen < 1) {
			newLen = 1;
		} else if (newLen > 128) {
			newLen = 128;
		}
		std::vector<RE::Actor*> result(static_cast<std::size_t>(newLen), nullptr);
		std::size_t ni = 0;
		for (std::size_t i = 0; i < c && ni < result.size(); ++i) {
			if (actors[i]) {
				result[ni] = actors[i];
				ni += 1;
			}
		}
		return result;
	}

	std::vector<RE::Actor*> ActorArrayAppend(StaticFunctionTag* base, std::vector<RE::Actor*> oldArray, RE::Actor* append, SInt32 count) {
		(void)base;
		if (count <= 0) {
			return oldArray;
		}
		if (oldArray.size() > 127) {
			return oldArray;
		}
		const std::size_t maxSize = 128;
		const std::size_t available = maxSize - oldArray.size();
		std::size_t toAdd = static_cast<std::size_t>(count);
		if (toAdd > available) {
			toAdd = available;
		}
		if (toAdd == 0) {
			return oldArray;
		}
		oldArray.reserve(oldArray.size() + toAdd);
		for (std::size_t i = 0; i < toAdd; ++i) {
			oldArray.push_back(append);
		}
		return oldArray;
	}

	std::vector<RE::Actor*> RemoveDuplicatedActors(StaticFunctionTag* base, std::vector<RE::Actor*> list) {
		(void)base;
		const std::size_t c = list.size();
		for (std::size_t i = 0; i + 1 < c; ++i) {
			if (!list[i]) {
				continue;
			}
			for (std::size_t j = i + 1; j < c; ++j) {
				if (list[i] == list[j]) {
					list[j] = nullptr;
				}
			}
		}
		SInt32 newLen = 0;
		for (std::size_t i = 0; i < c; ++i) {
			if (list[i]) {
				newLen += 1;
			}
		}
		if (newLen < 1) {
			newLen = 1;
		} else if (newLen > 128) {
			newLen = 128;
		}
		std::vector<RE::Actor*> result(static_cast<std::size_t>(newLen), nullptr);
		std::size_t idx = 0;
		for (std::size_t i = 0; i < c && idx < result.size(); ++i) {
			if (list[i]) {
				result[idx] = list[i];
				idx += 1;
			}
		}
		return result;
	}

	std::vector<float> FloatArrayAppend(StaticFunctionTag* base, std::vector<float> oldArray, float append) {
		(void)base;
		if (oldArray.size() > 127) {
			return oldArray;
		}
		oldArray.push_back(append);
		return oldArray;
	}

	std::vector<float> FloatArrayResize(StaticFunctionTag* base, std::vector<float> oldArray, SInt32 newSize) {
		(void)base;
		if (newSize < 1) {
			newSize = 1;
		} else if (newSize > 128) {
			newSize = 128;
		}
		std::vector<float> result(static_cast<std::size_t>(newSize), 0.0f);
		const std::size_t copyCount = (result.size() < oldArray.size()) ? result.size() : oldArray.size();
		for (std::size_t i = 0; i < copyCount; ++i) {
			result[i] = oldArray[i];
		}
		return result;
	}

	std::vector<SInt32> IntArrayAppend(StaticFunctionTag* base, std::vector<SInt32> oldArray, SInt32 append) {
		(void)base;
		if (oldArray.size() > 127) {
			return oldArray;
		}
		oldArray.push_back(append);
		return oldArray;
	}

	std::vector<RE::Actor*> ActorArray(StaticFunctionTag* base, SInt32 size) {
		(void)base;
		if (size < 1) {
			size = 1;
		} else if (size > 128) {
			size = 128;
		}
		return std::vector<RE::Actor*>(static_cast<std::size_t>(size), nullptr);
	}

	std::vector<RE::TESNPC*> ActorBaseArray(StaticFunctionTag* base, SInt32 size) {
		(void)base;
		if (size < 1) {
			size = 1;
		} else if (size > 128) {
			size = 128;
		}
		return std::vector<RE::TESNPC*>(static_cast<std::size_t>(size), nullptr);
	}

	std::vector<RE::TESForm*> FormArray(StaticFunctionTag* base, SInt32 size) {
		(void)base;
		if (size < 1) {
			size = 1;
		} else if (size > 128) {
			size = 128;
		}
		return std::vector<RE::TESForm*>(static_cast<std::size_t>(size), nullptr);
	}

	std::vector<bool> BoolArray(StaticFunctionTag* base, SInt32 size) {
		(void)base;
		if (size < 1) {
			size = 1;
		} else if (size > 128) {
			size = 128;
		}
		return std::vector<bool>(static_cast<std::size_t>(size), false);
	}

	std::vector<float> FloatArray(StaticFunctionTag* base, SInt32 size) {
		(void)base;
		if (size < 1) {
			size = 1;
		} else if (size > 128) {
			size = 128;
		}
		return std::vector<float>(static_cast<std::size_t>(size), 0.0f);
	}

	std::vector<SInt32> IntArray(StaticFunctionTag* base, SInt32 size) {
		(void)base;
		if (size < 1) {
			size = 1;
		} else if (size > 128) {
			size = 128;
		}
		return std::vector<SInt32>(static_cast<std::size_t>(size), 0);
	}

	std::vector<BSFixedString> StringArray(StaticFunctionTag* base, SInt32 size) {
		(void)base;
		if (size < 1) {
			size = 1;
		} else if (size > 128) {
			size = 128;
		}
		return std::vector<BSFixedString>(static_cast<std::size_t>(size), BSFixedString(""));
	}

	std::vector<RE::TESForm*> FormArrayConcat(StaticFunctionTag* base, std::vector<RE::TESForm*> f1, std::vector<RE::TESForm*> f2) {
		(void)base;
		if (f1.empty()) {
			return f2;
		}
		if (f2.empty()) {
			return f1;
		}
		std::size_t f1l = f1.size();
		std::size_t f2l = f2.size();
		std::size_t n = f1l + f2l;
		if (n > 128) {
			if (f1l >= 128) {
				f2l = 0;
			} else {
				f2l = 128 - f1l;
			}
			n = f1l + f2l;
		}
		if (n < 1) {
			n = 1;
		}
		std::vector<RE::TESForm*> result(n, nullptr);
		for (std::size_t i = 0; i < f1l && i < result.size(); ++i) {
			result[i] = f1[i];
		}
		for (std::size_t i = 0; i < f2l && (i + f1l) < result.size(); ++i) {
			result[i + f1l] = f2[i];
		}
		return result;
	}

	BSFixedString GetNames(StaticFunctionTag* base, std::vector<RE::Actor*> actors) {
		(void)base;
		std::string tmp;
		bool first = true;
		for (auto* actor : actors) {
			if (!actor) {
				continue;
			}
			auto* baseForm = actor->GetActorBase();
			if (!baseForm) {
				continue;
			}
			const char* name = baseForm->GetName();
			if (!name || name[0] == '\0') {
				continue;
			}
			if (!first) {
				tmp.append(", ");
			}
			tmp.append(name);
			first = false;
		}
		return BSFixedString(tmp.c_str());
	}

	BSFixedString GetActorListNames(StaticFunctionTag* base, std::vector<RE::Actor*> actors, bool preferDisplayName) {
		(void)base;
		std::string result;
		for (std::size_t i = 0; i < actors.size(); ++i) {
			auto* actor = actors[i];
			if (!actor) {
				continue;
			}

			const char* name = nullptr;
			const char* displayName = actor->GetDisplayFullName();
			auto* baseForm = actor->GetActorBase();
			const char* baseName = baseForm ? baseForm->GetName() : nullptr;

			if (preferDisplayName) {
				if (displayName && displayName[0] != '\0') {
					name = displayName;
				} else if (baseName && baseName[0] != '\0') {
					name = baseName;
				} else {
					name = actor->GetName();
				}
			} else {
				if (baseName && baseName[0] != '\0') {
					name = baseName;
				} else if (displayName && displayName[0] != '\0') {
					name = displayName;
				} else {
					name = actor->GetName();
				}
			}

			if (!name || name[0] == '\0') {
				continue;
			}

			if (!result.empty()) {
				result.append(", ");
			}
			result.append(name);
		}
		return BSFixedString(result.c_str());
	}

	BSFixedString GetPercentage(StaticFunctionTag* base, float percentage, SInt32 decimal, bool bDecimalBase) {
		(void)base;
		if (percentage < 0.0001f) {
			return BSFixedString("< 1");
		}

		auto floorInt = [](float value) -> SInt32 {
			return static_cast<SInt32>(std::floor(value));
		};

		if (bDecimalBase) {
			if (decimal >= 0 && decimal < 4) {
				if (decimal == 0) {
					return BSFixedString(std::to_string(floorInt(percentage * 100.0f)).c_str());
				} else if (decimal == 1) {
					const auto whole = floorInt(percentage * 100.0f);
					const auto frac = floorInt(percentage * 1000.0f) % 10;
					return BSFixedString((std::to_string(whole) + "." + std::to_string(frac)).c_str());
				} else if (decimal == 2) {
					const auto whole = floorInt(percentage * 100.0f);
					const auto frac = floorInt(percentage * 10000.0f) % 100;
					return BSFixedString((std::to_string(whole) + "." + std::to_string(frac)).c_str());
				} else if (decimal == 3) {
					const auto whole = floorInt(percentage * 100.0f);
					const auto frac = floorInt(percentage * 100000.0f) % 1000;
					return BSFixedString((std::to_string(whole) + "." + std::to_string(frac)).c_str());
				}
			}
		} else {
			if (decimal >= 0 && decimal < 6) {
				if (decimal == 0) {
					return BSFixedString(std::to_string(floorInt(percentage)).c_str());
				} else if (decimal == 1) {
					const auto whole = floorInt(percentage);
					const auto frac = floorInt(percentage * 10.0f) % 10;
					return BSFixedString((std::to_string(whole) + "." + std::to_string(frac)).c_str());
				} else if (decimal == 2) {
					const auto whole = floorInt(percentage);
					const auto frac = floorInt(percentage * 100.0f) % 100;
					return BSFixedString((std::to_string(whole) + "." + std::to_string(frac)).c_str());
				} else if (decimal == 3) {
					const auto whole = floorInt(percentage);
					const auto frac = floorInt(percentage * 1000.0f) % 1000;
					return BSFixedString((std::to_string(whole) + "." + std::to_string(frac)).c_str());
				} else if (decimal == 4) {
					const auto whole = floorInt(percentage);
					const auto frac = floorInt(percentage * 10000.0f) % 10000;
					return BSFixedString((std::to_string(whole) + "." + std::to_string(frac)).c_str());
				} else if (decimal == 5) {
					const auto whole = floorInt(percentage);
					const auto frac = floorInt(percentage * 100000.0f) % 100000;
					return BSFixedString((std::to_string(whole) + "." + std::to_string(frac)).c_str());
				}
			}
		}

		return BSFixedString("");
	}

	BSFixedString GetTimeString(StaticFunctionTag* base, float timeValue, bool shortFormat, BSFixedString negativeText) {
		(void)base;
		std::string sign;
		if (timeValue < 0.0f) {
			if (negativeText.data() && negativeText.data()[0] != '\0') {
				return negativeText;
			}
			sign = "-";
			timeValue = -timeValue;
		}

		std::string timeString;

		SInt32 val = static_cast<SInt32>(timeValue);
		if (val != 0) {
			timeString += std::to_string(val);
			if (shortFormat) {
				timeString += "d ";
			} else if (val == 1) {
				timeString += "day ";
			} else {
				timeString += "days ";
			}
		}
		timeValue = (timeValue - static_cast<float>(val)) * 24.0f;

		val = static_cast<SInt32>(timeValue);
		if (val != 0) {
			timeString += std::to_string(val);
			if (shortFormat) {
				timeString += "h ";
			} else if (val == 1) {
				timeString += "hour ";
			} else {
				timeString += "hours ";
			}
		}
		timeValue = (timeValue - static_cast<float>(val)) * 60.0f;

		val = static_cast<SInt32>(timeValue);
		if (val != 0) {
			timeString += std::to_string(val);
			if (shortFormat) {
				timeString += "m";
			} else if (val == 1) {
				timeString += "minute";
			} else {
				timeString += "minutes";
			}
		}

		return BSFixedString((sign + timeString).c_str());
	}

	BSFixedString GetVersionString(StaticFunctionTag* base, BSFixedString modDesc) {
		(void)base;
		const char* descCstr = modDesc.data();
		if (!descCstr || descCstr[0] == '\0') {
			return BSFixedString("Undefined");
		}

		const std::string desc(descCstr);
		const size_t descLen = desc.size();
		size_t vpos = 0;

		auto isDigit = [](unsigned char ch) -> bool {
			return std::isdigit(ch) != 0;
		};

		while (true) {
			const size_t found = desc.find("ersion", vpos);
			if (found == std::string::npos) {
				break;
			}
			if (found > 0 && (desc[found - 1] == 'V' || desc[found - 1] == 'v')) {
				size_t pos = found + 6;
				while (pos < descLen && desc[pos] != ':' && desc[pos] != ' ') {
					++pos;
				}
				const size_t startpos = pos;
				while (pos < descLen && (isDigit(static_cast<unsigned char>(desc[pos])) || desc[pos] == '.')) {
					++pos;
				}
				if (pos <= startpos) {
					vpos = found + 1;
					continue;
				}
				const size_t endpos = pos - 1;
				const size_t length = endpos - startpos;
				if (endpos + 1 < descLen && desc[endpos + 1] == 'b') {
					return BSFixedString((std::string("Beta ") + desc.substr(startpos, length)).c_str());
				}
				return BSFixedString(desc.substr(startpos, length).c_str());
			}
			vpos = found + 1;
		}

		return BSFixedString("Undefined");
	}

	bool AreModsInstalled(StaticFunctionTag* base, std::vector<BSFixedString> modNames) {
		(void)base;
		auto* dataHandler = DataHandler::GetSingleton();
		if (!dataHandler) {
			return false;
		}

		auto hasExt = [](const std::string& value, const char* ext) -> bool {
			const size_t extLen = std::strlen(ext);
			if (value.size() < extLen) {
				return false;
			}
			return value.compare(value.size() - extLen, extLen, ext) == 0;
		};

		auto isInstalled = [&](const std::string& name) -> bool {
			if (name.empty()) {
				return false;
			}
			if (hasExt(name, ".esm") || hasExt(name, ".esp") || hasExt(name, ".esl")) {
				if (dataHandler->LookupModByName(name.c_str())) {
					return true;
				}
			}
			if (dataHandler->LookupModByName((name + ".esm").c_str())) {
				return true;
			}
			if (dataHandler->LookupModByName((name + ".esp").c_str())) {
				return true;
			}
			if (dataHandler->LookupModByName((name + ".esl").c_str())) {
				return true;
			}
			if (dataHandler->LookupModByName(name.c_str())) {
				return true;
			}
			return false;
		};

		for (const auto& modName : modNames) {
			const char* cstr = modName.data();
			if (!cstr || cstr[0] == '\0') {
				continue;
			}
			if (!isInstalled(cstr)) {
				return false;
			}
		}
		return true;
	}

	BSFixedString ArrayReplace(StaticFunctionTag* base, BSFixedString text, std::vector<BSFixedString> replace) {
		(void)base;
		std::string result = text.data() ? text.data() : "";
		for (std::size_t i = replace.size(); i > 0; --i) {
			const auto idx = i - 1;
			std::string key = "{" + std::to_string(idx) + "}";
			const char* rep = replace[idx].data();
			std::string value = rep ? rep : "";
			result = ReplaceAll(result, key, value);
		}
		return BSFixedString(result.c_str());
	}

	float FloatModulo(StaticFunctionTag* base, float value, float modValue) {
		(void)base;
		if (modValue <= 0.0f) {
			return value;
		}
		return std::fmod(value, modValue);
	}

	BSFixedString GetModFromID(StaticFunctionTag* base, RE::TESForm* form, bool fileExtension) {
		(void)base;
		if (!form) {
			return BSFixedString("unknown");
		}

		const RE::TESFile* file = form->GetFile(0);
		if (!file) {
			if (auto* actor = form->As<RE::Actor>()) {
				if (auto* baseForm = actor->GetActorBase()) {
					file = baseForm->GetFile(0);
				}
			}
		}

		if (!file) {
			return BSFixedString("unknown");
		}

		std::string name(file->GetFilename());
		if (!fileExtension) {
			const size_t lastindex = name.find_last_of('.');
			if (lastindex != std::string::npos) {
				name = name.substr(0, lastindex);
			}
		}
		return BSFixedString(name.c_str());
	}

	RE::Actor* FindFemaleFromJsonFileName(StaticFunctionTag* base, BSFixedString fileName) {
		(void)base;
		const char* raw = fileName.data();
		if (!raw || raw[0] == '\0') {
			return nullptr;
		}

		std::string name(raw);
		if (name.size() >= 5 && name.substr(name.size() - 5) == ".json") {
			name = name.substr(0, name.size() - 5);
		}

		const std::size_t idx = name.find_last_of('_');
		if (idx == std::string::npos || idx == 0) {
			return nullptr;
		}

		const std::string mod = name.substr(0, idx);
		const std::string formHex = name.substr(idx + 1);
		if (mod.empty() || formHex.empty()) {
			return nullptr;
		}

		std::string spec = mod;
		spec.push_back(':');
		spec.append(formHex);
		RE::TESForm* form = GetFormFromString(nullptr, BSFixedString(spec.c_str()));
		if (!form) {
			return nullptr;
		}
		return form->As<RE::Actor>();
	}


	std::string ws2s(std::wstring const& text) {
		std::locale const loc("");
		wchar_t const* from = text.c_str();
		std::size_t const len = text.size();
		std::vector<char> buffer(len + 1);
		std::use_facet<std::ctype<wchar_t> >(loc).narrow(from, from + len, '_', &buffer[0]);
		return std::string(&buffer[0], &buffer[len]);
	}

	std::string ReplaceAll(std::string str, const std::string& from, const std::string& to) {
		size_t start_pos = 0;
		int maxCount = 20;
		while ((start_pos = str.find(from, start_pos)) != std::string::npos) {
			str.replace(start_pos, from.length(), to);
			start_pos += to.length();
			if (maxCount <= 0)
				break;
			maxCount--;
		}
		return str;
	}

	bool FileExists(StaticFunctionTag* base, BSFixedString FilePath) {
		std::fstream fi;
		std::string f = "Data/BeeingFemale/";
		f.append(FilePath.data());
		fi.open(f);
		if (fi.is_open() == true) {
			fi.close();
			return true;
		}
		else
			return false;
	}

	BSFixedString getNextAutoFile(StaticFunctionTag* base, BSFixedString Directory, BSFixedString FileName, BSFixedString Extention) {
		for (int i = 0; i < 128; i++) {
			std::string f = "Data/BeeingFemale/";
			f.append(Directory.data());
			f.append("/");
			f.append(FileName.data());
			if (i < 10)
				f.append("00");
			else if (i < 100)
				f.append("0");
			std::stringstream ss;
			ss << i;
			f.append(ss.str());
			f.append(".");
			f.append(Extention.data());

			std::fstream fi;
			fi.open(f);
			if (fi.is_open() == true) {
				fi.close();
			}
			else {
				std::string res = "";
				res.append(FileName.data());
				if (i < 10)
					res.append("00");
				else if (i < 100)
					res.append("0");
				res.append(ss.str());
				res.append(".");
				res.append(Extention.data());
				return BSFixedString(res.c_str());
			}
		}
		return "";
	}

	BSFixedString toLower(StaticFunctionTag* base, BSFixedString str) {
		std::string s = str.data();
		std::transform(s.begin(), s.end(), s.begin(), [](unsigned char c) { return static_cast<char>(std::tolower(c)); });
		return BSFixedString(s.c_str());
	}
	BSFixedString toUpper(StaticFunctionTag* base, BSFixedString str) {
		std::string s = str.data();
		std::transform(s.begin(), s.end(), s.begin(), [](unsigned char c) { return static_cast<char>(std::toupper(c)); });
		return BSFixedString(s.c_str());
	}

	/*BSFixedString IOReadTranslation(StaticFunctionTag* base, BSFixedString lng){
		std::wifstream fs;

		// Generating file name
		std::string FileName="Data/Interface/Translations/BeeingFemale_";
		FileName.append(lng.data());
		FileName.append(".txt");

		try {
			// Try to open
			fs.open(FileName, std::ios::binary);
		} catch (std::exception*){
			language = "";
			return NULL;
		}
		if (fs.is_open()) {
			// imbue the file stream
			//fs.imbue(std::locale(fs.getloc(), new std::codecvt_utf16<wchar_t, 0x10ffff, std::little_endian>));
			fs.imbue(std::locale(fs.getloc(), new std::codecvt_utf16<wchar_t, 0xFEFF, std::little_endian>));

			// Creating the converter
			std::wstring_convert<std::codecvt_utf8<wchar_t>, wchar_t> converter;

			// read file into file_content
			std::wstring file_content;
			fs.seekg(0, std::ios::end);
			file_content.resize(fs.tellg());
			fs.seekg(0, std::ios::beg); // Reset pos to 2
			fs.read(&file_content[0], file_content.size());
			fs.close();

			delete fs;

			// Convert and return the contents
			std::string res = converter.to_bytes(file_content.c_str());
			//std::string res = ws2s(file_content);
			language=res;
			//return BSFixedString(res.c_str());
			return NULL;
		} else {
			return NULL;
		}
	}



	BSFixedString getLangText(StaticFunctionTag* Base, BSFixedString content, BSFixedString VarName) {
		/*GFxLoader * tmpLoader = GFxLoader::GetSingleton();
		BSScaleformTranslator * trans = tmpLoader->stateBag->GetTranslator();

		TranslationTableItem * tti = trans->translations.Find(content.c_str());
		return BSFixedString(tti->translation.c_str());*/

		//std::string c = content.data();
		/*std::string c = language;
		std::string find;
		find.append("$");
		find.append(VarName.data());
		find.append("\t");
		if(c.length()==0)
			return "";

		int pos=c.find (find);
		if( pos!=-1) {

			int posStart = pos + find.length();
			int posEnd1 = c.find("\r",posStart);
			int posEnd2 = c.find("\n",posStart);
			int posEnd = -1;
			if(posEnd1>-1 && posEnd1<posEnd2)
				posEnd=posEnd1;
			else if(posEnd2>-1 && posEnd2<posEnd1)
				posEnd=posEnd2;
			if(posEnd==-1)
				posEnd = c.length();
			int len=posEnd - posStart;
			return BSFixedString(c.substr(posStart,len).c_str());
		}
		//Console_Print("Variable not found: ",VarName.data());
		return "";
	}*/

	BSFixedString StringReplace(StaticFunctionTag* Base, BSFixedString content, BSFixedString Find, BSFixedString Replace) {
		std::string str1 = content.data();
		std::string res = ReplaceAll(str1, Find.data(), Replace.data());
		return BSFixedString(res.c_str());
	}

	BSFixedString MultiStringReplace(StaticFunctionTag* Base, BSFixedString content, BSFixedString Replace0, BSFixedString Replace1, BSFixedString Replace2, BSFixedString Replace3, BSFixedString Replace4, BSFixedString Replace5) {
		std::string str1 = content.data();
		std::string res1 = ReplaceAll(str1, "{0}", Replace0.data());
		std::string res2 = ReplaceAll(res1, "{1}", Replace1.data());
		std::string res3 = ReplaceAll(res2, "{2}", Replace2.data());
		std::string res4 = ReplaceAll(res3, "{3}", Replace3.data());
		std::string res5 = ReplaceAll(res4, "{4}", Replace4.data());
		std::string res6 = ReplaceAll(res5, "{5}", Replace5.data());
		return BSFixedString(res6.c_str());
	}


	BSFixedString GetDirectoryHash(StaticFunctionTag* Base, BSFixedString Directory) {
		WIN32_FIND_DATA FindData;
		std::string dir = "Data/BeeingFemale/";
		dir.append(Directory.data());
		if (dir.substr(dir.length() - 1, 1) != "/" && dir.substr(dir.length() - 1, 1) != "\\")
			dir.append("/");
		std::string dir2 = dir;
		dir2.append("*.*");
		HANDLE hFind = FindFirstFile(dir2.c_str(), &FindData);
		UInt32 count = 0;
		size_t FNameLen = 0;
		long long FSize = 0;
		if (&FindData) {
			do {
				std::string x = FindData.cFileName;

				if (x != "." && x != "..") {
					// Get FileName Length
					FNameLen += x.length();

					// Get FileSize
					std::wifstream fs;
					std::string FileName = dir;
					FileName.append(x);
					try {
						fs.open(FileName, std::ifstream::binary);
						fs.seekg(0, std::ifstream::end);
						FSize += static_cast<long long>(fs.tellg());
						fs.close();
					}
					catch (std::exception*) {
						return BSFixedString("");
					}

					// Add Counter*/
					count++;
				}
			} while (FindNextFile(hFind, &FindData));
		}

		FindClose(hFind);

		// Example Result: 0079-7d7-08b-6c57-000862
		std::string res = Hex_str(count, 3);
		res.append(Hex_str((count % 13) + 2, 1));
		res.append("-");
		res.append(Hex_str(static_cast<long>(FNameLen % 11), 1));
		res.append(Hex_str(static_cast<long>(FNameLen % 14), 1));
		res.append(Hex_str(static_cast<long>((FNameLen % 9) + 3), 1));
		res.append("-");
		res.append(Hex_str(static_cast<long>(FNameLen % 2100), 3));
		res.append("-");
		res.append(Hex_str(static_cast<long>((FSize % 11) + 5), 1));
		res.append(Hex_str(static_cast<long>((FSize % 10) + 6), 1));
		res.append(Hex_str(static_cast<long>((FSize % 230) + 11), 2));
		res.append("-");
		res.append(Hex_str(static_cast<long>(FSize % 8388500), 6));
		return BSFixedString(res.c_str());
	}

	BSFixedString Hex(StaticFunctionTag* Base, SInt32 value, SInt32 Digits) {
		return BSFixedString(Hex_str(value, Digits).c_str());
	}
	std::string Hex_str(long value, int Digits) {
		std::stringstream ss;
		if (Digits > 8)
			Digits = 8;
		else if (Digits < 0)
			Digits = 1;
		if (Digits == 0) {
			ss << std::setfill('0') << std::setw(1)
				<< std::hex << value;
		}
		else {
			ss << std::setfill('0') << std::setw(Digits)
				<< std::hex << value;
		}
		std::string s = ss.str();
		if (s.size() > Digits && Digits > 0)
			s = s.substr(s.size() - Digits);
		return s;

		// This code is overdue
		/*std::string sHex="";
		switch(Digits) {
		case 0: return "";
		case 1: // signed Byte
			return HexDigit(value,0xf,0);
		case 2: // Byte
			sHex = HexDigit(value,0xf0,4);
			sHex.append(HexDigit(value,0xf,0));
		case 3: // unsigned short
			sHex = HexDigit(value,0xf00,8);
			sHex.append(HexDigit(value,0xf0,4));
			sHex.append(HexDigit(value,0xf,0));
		case 4: // short
			sHex = HexDigit(value,0xf000,12);
			sHex.append(HexDigit(value,0xf00,8));
			sHex.append(HexDigit(value,0xf0,4));
			sHex.append(HexDigit(value,0xf,0));
		case 5:
			sHex = HexDigit(value,0xf0000,16);
			sHex.append(HexDigit(value,0xf000,12));
			sHex.append(HexDigit(value,0xf00,8));
			sHex.append(HexDigit(value,0xf0,4));
			sHex.append(HexDigit(value,0xf,0));
		case 6: // unsigned int
			sHex = HexDigit(value,0xf00000,20);
			sHex.append(HexDigit(value,0xf0000,16));
			sHex.append(HexDigit(value,0xf000,12));
			sHex.append(HexDigit(value,0xf00,8));
			sHex.append(HexDigit(value,0xf0,4));
			sHex.append(HexDigit(value,0xf,0));
		case 7:
			sHex = HexDigit(value,0xf000000,24);
			sHex.append(HexDigit(value,0xf00000,20));
			sHex.append(HexDigit(value,0xf0000,16));
			sHex.append(HexDigit(value,0xf000,12));
			sHex.append(HexDigit(value,0xf00,8));
			sHex.append(HexDigit(value,0xf0,4));
			sHex.append(HexDigit(value,0xf,0));
		case 8: // int
			sHex = HexDigit(value,0xf0000000,28);
			sHex.append(HexDigit(value,0xf000000,24));
			sHex.append(HexDigit(value,0xf00000,20));
			sHex.append(HexDigit(value,0xf0000,16));
			sHex.append(HexDigit(value,0xf000,12));
			sHex.append(HexDigit(value,0xf00,8));
			sHex.append(HexDigit(value,0xf0,4));
			sHex.append(HexDigit(value,0xf,0));
		*/
		/*case 9:
			sHex = HexDigit(value,0xf00000000,32);
			sHex.append(HexDigit(value,0xf0000000,28));
			sHex.append(HexDigit(value,0xf000000,24));
			sHex.append(HexDigit(value,0xf00000,20));
			sHex.append(HexDigit(value,0xf0000,16));
			sHex.append(HexDigit(value,0xf000,12));
			sHex.append(HexDigit(value,0xf00,8));
			sHex.append(HexDigit(value,0xf0,4));
			sHex.append(HexDigit(value,0xf,0));
		case 10:
			sHex = HexDigit(value,0xf000000000,36);
			sHex.append(HexDigit(value,0xf00000000,32));
			sHex.append(HexDigit(value,0xf0000000,28));
			sHex.append(HexDigit(value,0xf000000,24));
			sHex.append(HexDigit(value,0xf00000,20));
			sHex.append(HexDigit(value,0xf0000,16));
			sHex.append(HexDigit(value,0xf000,12));
			sHex.append(HexDigit(value,0xf00,8));
			sHex.append(HexDigit(value,0xf0,4));
			sHex.append(HexDigit(value,0xf,0));
		case 11:
			sHex = HexDigit(value,0xf0000000000,40);
			sHex.append(HexDigit(value,0xf000000000,36));
			sHex.append(HexDigit(value,0xf00000000,32));
			sHex.append(HexDigit(value,0xf0000000,28));
			sHex.append(HexDigit(value,0xf000000,24));
			sHex.append(HexDigit(value,0xf00000,20));
			sHex.append(HexDigit(value,0xf0000,16));
			sHex.append(HexDigit(value,0xf000,12));
			sHex.append(HexDigit(value,0xf00,8));
			sHex.append(HexDigit(value,0xf0,4));
			sHex.append(HexDigit(value,0xf,0));
		case 12:
			sHex = HexDigit(value,0xf00000000000,44);
			sHex.append(HexDigit(value,0xf0000000000,40));
			sHex.append(HexDigit(value,0xf000000000,36));
			sHex.append(HexDigit(value,0xf00000000,32));
			sHex.append(HexDigit(value,0xf0000000,28));
			sHex.append(HexDigit(value,0xf000000,24));
			sHex.append(HexDigit(value,0xf00000,20));
			sHex.append(HexDigit(value,0xf0000,16));
			sHex.append(HexDigit(value,0xf000,12));
			sHex.append(HexDigit(value,0xf00,8));
			sHex.append(HexDigit(value,0xf0,4));
			sHex.append(HexDigit(value,0xf,0));
		case 13: //
			sHex = HexDigit(value,0xf000000000000,48);
			sHex.append(HexDigit(value,0xf00000000000,44));
			sHex.append(HexDigit(value,0xf0000000000,40));
			sHex.append(HexDigit(value,0xf000000000,36));
			sHex.append(HexDigit(value,0xf00000000,32));
			sHex.append(HexDigit(value,0xf0000000,28));
			sHex.append(HexDigit(value,0xf000000,24));
			sHex.append(HexDigit(value,0xf00000,20));
			sHex.append(HexDigit(value,0xf0000,16));
			sHex.append(HexDigit(value,0xf000,12));
			sHex.append(HexDigit(value,0xf00,8));
			sHex.append(HexDigit(value,0xf0,4));
			sHex.append(HexDigit(value,0xf,0));
		case 14: // unsigned long
			sHex = HexDigit(value,0xf0000000000000,52);
			sHex.append(HexDigit(value,0xf000000000000,48));
			sHex.append(HexDigit(value,0xf00000000000,44));
			sHex.append(HexDigit(value,0xf0000000000,40));
			sHex.append(HexDigit(value,0xf000000000,36));
			sHex.append(HexDigit(value,0xf00000000,32));
			sHex.append(HexDigit(value,0xf0000000,28));
			sHex.append(HexDigit(value,0xf000000,24));
			sHex.append(HexDigit(value,0xf00000,20));
			sHex.append(HexDigit(value,0xf0000,16));
			sHex.append(HexDigit(value,0xf000,12));
			sHex.append(HexDigit(value,0xf00,8));
			sHex.append(HexDigit(value,0xf0,4));
			sHex.append(HexDigit(value,0xf,0));*/
			//}
			//return sHex;
	}
	std::string HexDigit(long value, long max, int shift) {
		long x = 0;
		if (shift < 1) {
			x = value & max;
		} else {
			x = logical_right_shift(value & max, shift);
		}
		switch (x) {
		case 0: return "0";
		case 1: return "1";
		case 2: return "2";
		case 3: return "3";
		case 4: return "4";
		case 5: return "5";
		case 6: return "6";
		case 7: return "7";
		case 8: return "8";
		case 9: return "9";
		case 10: return "A";
		case 11: return "B";
		case 12: return "C";
		case 13: return "D";
		case 14: return "E";
		case 15: return "F";
		}
		return "";
	}
	long logical_right_shift(long x, long n) {
		return (unsigned)x >> n;
	}


	UInt32 GetFileCount(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString extantion) {
		WIN32_FIND_DATA FindData;
		std::string dir = "Data/BeeingFemale/";
		dir.append(Directory.data());
		if (dir.substr(dir.length() - 1, 1) != "/" && dir.substr(dir.length() - 1, 1) != "\\")
			dir.append("/");
		dir.append("*.").append(extantion.data());
		HANDLE hFind = FindFirstFile(dir.c_str(), &FindData);
		if (hFind == INVALID_HANDLE_VALUE) {
			return 0;
		}
		UInt32 count = 0;
		do {
			count++;
		} while (FindNextFile(hFind, &FindData));
		FindClose(hFind);
		return count;
	}

	BSFixedString GetFileName(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString extantion, UInt32 ID) {
		WIN32_FIND_DATA FindData;
		std::string dir = "Data/BeeingFemale/";
		dir.append(Directory.data());
		if (dir.substr(dir.length() - 1, 1) != "/" && dir.substr(dir.length() - 1, 1) != "\\")
			dir.append("/");
		dir.append("*.").append(extantion.data());
		HANDLE hFind = FindFirstFile(dir.c_str(), &FindData);
		if (hFind == INVALID_HANDLE_VALUE) {
			return "";
		}
		UInt32 count = 0;
		do {
			if (ID == count) {
				//std::string x = FindData.cFileName;
				//return BSFixedString(x.c_str());
				FindClose(hFind);
				return BSFixedString(FindData.cFileName);
			}
			count++;
		} while (FindNextFile(hFind, &FindData));
		FindClose(hFind);
		return "";
	}

	std::vector<BSFixedString> GetFileNames(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString extantion) {
		WIN32_FIND_DATA FindData;
		std::vector<BSFixedString> result;
		std::string dir = "Data/BeeingFemale/";
		dir.append(Directory.data());
		if (dir.substr(dir.length() - 1, 1) != "/" && dir.substr(dir.length() - 1, 1) != "\\")
			dir.append("/");
		dir.append("*.").append(extantion.data());
		HANDLE hFind = FindFirstFile(dir.c_str(), &FindData);
		if (hFind == INVALID_HANDLE_VALUE) {
			return result;
		}
		do {
			result.emplace_back(FindData.cFileName);
		} while (FindNextFile(hFind, &FindData));
		FindClose(hFind);
		return result;
	}

	/*BSFixedString GetFileName(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString extantion, UInt32 ID) {
		std::string dir = Directory.data();
		if(dir.substr(dir.length() - 1,1) != "/" && dir.substr(dir.length() - 1,1) != "\\")
			dir.append("/");
		dir.append("*.").append(extantion.data());

		WIN32_FIND_DATA FindData;
		HANDLE hFind = FindFirstFile(dir.c_str(), &FindData);
		int count=0;
		std::string name1="";
		PTSTR name2;
		char* name3;
		char* name4;
		//_MESSAGE("BeeingFemale::GetFileName()");
		if(&FindData) {
			//_MESSAGE(FindData.cFileName);
			do {
				if(count==ID) {
					name1=std::string(FindData.cFileName).c_str();
					name2=FindData.cFileName;
					name3=FindData.cFileName;
					name4=_T("%s",FindData.cFileName.c_str());
					break;
				}
				count++;
			} while(FindNextFile(hFind, &FindData));
		}
		FindClose(hFind);
		//return BSFixedString(name1.c_str());
		//return BSFixedString(name2);
		return BSFixedString(name3);
		return BSFixedString(name4);
	}*/


	BSFixedString getIniPath(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file) {
		std::string dir = "Data\\BeeingFemale\\";
		dir.append(Directory.data());
		if (dir.substr(dir.length() - 1, 1) != "/" && dir.substr(dir.length() - 1, 1) != "\\")
			dir.append("\\");
		dir.append(file.data());
		return BSFixedString(dir.c_str());
	}


	BSFixedString getIniString(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable, BSFixedString def) {
		std::string dir = "Data\\BeeingFemale\\";
		dir.append(Directory.data());
		if (dir.substr(dir.length() - 1, 1) != "/" && dir.substr(dir.length() - 1, 1) != "\\")
			dir.append("\\");
		dir.append(file.data());
		const char* tmpType = Directory.data();
		const char* tmpVariable = variable.data();
		const char* tmpDef = def.data();
		const char* tmpDir = dir.c_str();
		std::string x = GetPrivateProfile<std::string>(tmpType, tmpVariable, tmpDef, tmpDir);
		return BSFixedString(x.c_str());
	}
	bool getIniBool(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable, bool def) {
		std::string dir = "Data/BeeingFemale/";
		dir.append(Directory.data());
		if (dir.substr(dir.length() - 1, 1) != "/" && dir.substr(dir.length() - 1, 1) != "\\")
			dir.append("/");
		dir.append(file.data());
		const char* tmpType = Directory.data();
		const char* tmpVariable = variable.data();
		const char* tmpDef = def ? "True" : "False";
		const char* tmpDir = dir.c_str();
		std::string x = GetPrivateProfile<std::string>(tmpType, tmpVariable, tmpDef, tmpDir);
		return x == "y" || x == "Y" || x == "1" || x == "true" || x == "TRUE" || x == "True" || x == "Yes" || x == "yes" || x == "YES";
	}
	SInt32 getIniInt(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable, SInt32 def) {
		std::string dir = "Data\\BeeingFemale\\";
		dir.append(Directory.data());
		if (dir.substr(dir.length() - 1, 1) != "/" && dir.substr(dir.length() - 1, 1) != "\\")
			dir.append("\\");
		dir.append(file.data());
		const char* tmpType = Directory.data();
		const char* tmpVariable = variable.data();
		const char* tmpDir = dir.c_str();

		std::string tmpString = GetPrivateProfile<std::string>(tmpType, tmpVariable, "", tmpDir);
		if (tmpString != "")
			if (tmpString.substr(0, 2) == "0x" && tmpString.length() <= 10) {
				if (tmpString.length() == 2) return 0;
				//signed int conv = std::stoul(tmpString, nullptr, 32);
				int conv;
				std::stringstream ss;
				ss << std::hex << tmpString.substr(2);
				ss >> conv;
				return conv;
			}

		SInt32 x = GetPrivateProfile<int>(tmpType, tmpVariable, def, tmpDir);
		return x;
	}
	float getIniFloat(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable, float def) {
		std::string dir = "Data/BeeingFemale/";
		dir.append(Directory.data());
		if (dir.substr(dir.length() - 1, 1) != "/" && dir.substr(dir.length() - 1, 1) != "\\")
			dir.append("/");
		dir.append(file.data());
		const char* tmpType = Directory.data();
		const char* tmpVariable = variable.data();
		const char* tmpDir = dir.c_str();

		float x = GetPrivateProfile<float>(tmpType, tmpVariable, def, tmpDir);
		return x;
	}

	BSFixedString getIniCString(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString categorie, BSFixedString variable, BSFixedString def) {
		std::string dir = "Data\\BeeingFemale\\";
		dir.append(Directory.data());
		if (dir.substr(dir.length() - 1, 1) != "/" && dir.substr(dir.length() - 1, 1) != "\\")
			dir.append("\\");
		dir.append(file.data());
		const char* tmpType = categorie.data();
		const char* tmpVariable = variable.data();
		const char* tmpDef = def.data();
		const char* tmpDir = dir.c_str();
		std::string x = GetPrivateProfile<std::string>(tmpType, tmpVariable, tmpDef, tmpDir);
		return BSFixedString(x.c_str());
	}
	bool getIniCBool(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString categorie, BSFixedString variable, bool def) {
		std::string dir = "Data/BeeingFemale/";
		dir.append(Directory.data());
		if (dir.substr(dir.length() - 1, 1) != "/" && dir.substr(dir.length() - 1, 1) != "\\")
			dir.append("/");
		dir.append(file.data());
		const char* tmpType = categorie.data();
		const char* tmpVariable = variable.data();
		const char* tmpDef = def ? "True" : "False";
		const char* tmpDir = dir.c_str();
		std::string x = GetPrivateProfile<std::string>(tmpType, tmpVariable, tmpDef, tmpDir);
		return x == "y" || x == "Y" || x == "1" || x == "true" || x == "TRUE" || x == "True" || x == "Yes" || x == "yes" || x == "YES";
	}
	SInt32 getIniCInt(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString categorie, BSFixedString variable, SInt32 def) {
		std::string dir = "Data\\BeeingFemale\\";
		dir.append(Directory.data());
		if (dir.substr(dir.length() - 1, 1) != "/" && dir.substr(dir.length() - 1, 1) != "\\")
			dir.append("\\");
		dir.append(file.data());
		const char* tmpType = categorie.data();
		const char* tmpVariable = variable.data();
		const char* tmpDir = dir.c_str();

		std::string tmpString = GetPrivateProfile<std::string>(tmpType, tmpVariable, "", tmpDir);
		if (tmpString != "")
			if (tmpString.substr(0, 2) == "0x" && tmpString.length() <= 10) {
				if (tmpString.length() == 2) return 0;
				//signed int conv = std::stoul(tmpString, nullptr, 32);
				int conv;
				std::stringstream ss;
				ss << std::hex << tmpString.substr(2);
				ss >> conv;
				return conv;
			}

		SInt32 x = GetPrivateProfile<int>(tmpType, tmpVariable, def, tmpDir);
		return x;
	}
	float getIniCFloat(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString categorie, BSFixedString variable, float def) {
		std::string dir = "Data/BeeingFemale/";
		dir.append(Directory.data());
		if (dir.substr(dir.length() - 1, 1) != "/" && dir.substr(dir.length() - 1, 1) != "\\")
			dir.append("/");
		dir.append(file.data());
		const char* tmpType = categorie.data();
		const char* tmpVariable = variable.data();
		const char* tmpDir = dir.c_str();

		float x = GetPrivateProfile<float>(tmpType, tmpVariable, def, tmpDir);
		return x;
	}

	void setIniString(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable, BSFixedString value) {
		std::string dir = "Data\\BeeingFemale\\";
		dir.append(Directory.data());
		if (dir.substr(dir.length() - 1, 1) != "/" && dir.substr(dir.length() - 1, 1) != "\\")
			dir.append("\\");
		dir.append(file.data());
		const char* tmpType = Directory.data();
		const char* tmpVariable = variable.data();
		const char* tmpVal = value.data();
		const char* tmpDir = dir.c_str();
		WritePrivateProfile<std::string>(tmpType, tmpVariable, tmpVal, tmpDir);
		return;
	}
	void setIniBool(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable, bool value) {
		std::string dir = "Data/BeeingFemale/";
		dir.append(Directory.data());
		if (dir.substr(dir.length() - 1, 1) != "/" && dir.substr(dir.length() - 1, 1) != "\\")
			dir.append("/");
		dir.append(file.data());
		const char* tmpType = Directory.data();
		const char* tmpVariable = variable.data();
		const char* tmpVal = value ? "True" : "False";
		const char* tmpDir = dir.c_str();
		WritePrivateProfile<std::string>(tmpType, tmpVariable, tmpVal, tmpDir);
		return;
	}
	void setIniInt(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable, SInt32 value) {
		std::string dir = "Data\\BeeingFemale\\";
		dir.append(Directory.data());
		if (dir.substr(dir.length() - 1, 1) != "/" && dir.substr(dir.length() - 1, 1) != "\\")
			dir.append("\\");
		dir.append(file.data());
		const char* tmpType = Directory.data();
		const char* tmpVariable = variable.data();
		const char* tmpDir = dir.c_str();
		WritePrivateProfile<SInt32>(tmpType, tmpVariable, value, tmpDir);
		return;
	}
	void setIniFloat(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable, float value) {
		std::string dir = "Data/BeeingFemale/";
		dir.append(Directory.data());
		if (dir.substr(dir.length() - 1, 1) != "/" && dir.substr(dir.length() - 1, 1) != "\\")
			dir.append("/");
		dir.append(file.data());
		const char* tmpType = Directory.data();
		const char* tmpVariable = variable.data();
		const char* tmpDir = dir.c_str();

		WritePrivateProfile<float>(tmpType, tmpVariable, value, tmpDir);
		return;
	}

	void setIniCString(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString categorie, BSFixedString variable, BSFixedString value) {
		std::string dir = "Data\\BeeingFemale\\";
		dir.append(Directory.data());
		if (dir.substr(dir.length() - 1, 1) != "/" && dir.substr(dir.length() - 1, 1) != "\\")
			dir.append("\\");
		dir.append(file.data());
		const char* tmpType = categorie.data();
		const char* tmpVariable = variable.data();
		const char* tmpVal = value.data();
		const char* tmpDir = dir.c_str();
		WritePrivateProfile<std::string>(tmpType, tmpVariable, tmpVal, tmpDir);
		return;
	}
	void setIniCBool(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString categorie, BSFixedString variable, bool value) {
		std::string dir = "Data/BeeingFemale/";
		dir.append(Directory.data());
		if (dir.substr(dir.length() - 1, 1) != "/" && dir.substr(dir.length() - 1, 1) != "\\")
			dir.append("/");
		dir.append(file.data());
		const char* tmpType = categorie.data();
		const char* tmpVariable = variable.data();
		const char* tmpVal = value ? "True" : "False";
		const char* tmpDir = dir.c_str();
		WritePrivateProfile<std::string>(tmpType, tmpVariable, tmpVal, tmpDir);
		return;
	}
	void setIniCInt(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString categorie, BSFixedString variable, SInt32 value) {
		std::string dir = "Data\\BeeingFemale\\";
		dir.append(Directory.data());
		if (dir.substr(dir.length() - 1, 1) != "/" && dir.substr(dir.length() - 1, 1) != "\\")
			dir.append("\\");
		dir.append(file.data());
		const char* tmpType = categorie.data();
		const char* tmpVariable = variable.data();
		const char* tmpDir = dir.c_str();

		WritePrivateProfile<SInt32>(tmpType, tmpVariable, value, tmpDir);
		return;
	}
	void setIniCFloat(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString categorie, BSFixedString variable, float value) {
		std::string dir = "Data/BeeingFemale/";
		dir.append(Directory.data());
		if (dir.substr(dir.length() - 1, 1) != "/" && dir.substr(dir.length() - 1, 1) != "\\")
			dir.append("/");
		dir.append(file.data());
		const char* tmpType = categorie.data();
		const char* tmpVariable = variable.data();
		const char* tmpDir = dir.c_str();

		WritePrivateProfile<float>(tmpType, tmpVariable, value, tmpDir);
		return;
	}




	/*VMResultArray<BSFixedString*> getIniStringA(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable) {
		std::string dir = "Data\\BeeingFemale\\";
		dir.append(Directory.data());
		if(dir.substr(dir.length() - 1,1) != "/" && dir.substr(dir.length() - 1,1) != "\\")
			dir.append("\\");
		dir.append(file.data());
		const char* tmpType = Directory.data();
		const char* tmpVariable = variable.data();
		const char* tmpDir = dir.c_str();
		std::string x = GetPrivateProfile<std::string>(tmpType, tmpVariable, "", tmpDir);
		std::vector<std::string> a = split('|',x);
		VMResultArray<BSFixedString> ab;
		ab.resize(a.size(), 0);
		int i=0;
		while(i<ab.size()) {
			ab[i]=BSFixedString(a[i].c_str());
			i++;
		}
		return ab;
	}
	VMResultArray<bool> getIniBoolA(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable) {
		std::string dir = "Data/BeeingFemale/";
		dir.append(Directory.data());
		if(dir.substr(dir.length() - 1,1) != "/" && dir.substr(dir.length() - 1,1) != "\\")
			dir.append("/");
		dir.append(file.data());
		const char* tmpType = Directory.data();
		const char* tmpVariable = variable.data();
		const char* tmpDir = dir.c_str();
		std::string x = GetPrivateProfile<std::string>(tmpType, tmpVariable, "", tmpDir);
		std::vector<std::string> a = split('|',x);
		VMResultArray<bool> ab;
		ab.resize(a.size(), 0);
		int i=0;
		while(i<ab.size()) {
			ab[i]=(x=="y"||x=="Y"||x=="1"||x=="true"||x=="TRUE"||x=="True"||x=="Yes"||x=="yes"||x=="YES");
			i++;
		}
		return ab;
	}
	VMResultArray<SInt32> getIniIntA(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable) {
		std::string dir = "Data\\BeeingFemale\\";
		dir.append(Directory.data());
		if(dir.substr(dir.length() - 1,1) != "/" && dir.substr(dir.length() - 1,1) != "\\")
			dir.append("\\");
		dir.append(file.data());
		const char* tmpType = Directory.data();
		const char* tmpVariable = variable.data();
		const char* tmpDir = dir.c_str();
		std::string x = GetPrivateProfile<std::string>(tmpType, tmpVariable, "", tmpDir);
		std::vector<std::string> a = split('|',x);
		VMResultArray<SInt32> ab;
		ab.resize(a.size(), 0);
		int i=0;
		while(i<ab.size()) {
			if(a[i]=="") {
				ab[i]=0;
			} else if(a[i].size()>=2 && a[i].substr(0,2)=="0x") {
				if(a[i].size()==2)
					ab[i]=0;
				else
					ab[i]=(int)strtol(a[i].substr(2), NULL, 16);
			} else if(a[i].size()<11) {
				bool bIsNumeric=true;
				int j=0;
				while(j<a[i].size() && bIsNumeric) {
					switch(a[i].substr(j,1))
					case "0":
					case "1":
					case "2":
					case "3":
					case "4":
					case "5":
					case "6":
					case "7":
					case "8":
					case "9":
						break;
					case"-":
						if(j>0)
							bIsNumeric=false;
						break;
					default:
						bIsNumeric=false;
						break;
					j++;
				}
				if(bIsNumeric) {
					ab[i]=(int)strtol(a[i], NULL, 16);
				} else
					ab[i]=0;
			} else
				ab[i]=0;
			i++;
		}
		return ab;
	}
	VMResultArray<float> getIniFloatA(StaticFunctionTag* Base, BSFixedString Directory, BSFixedString file, BSFixedString variable) {
		std::string dir = "Data/BeeingFemale/";
		dir.append(Directory.data());
		if(dir.substr(dir.length() - 1,1) != "/" && dir.substr(dir.length() - 1,1) != "\\")
			dir.append("/");
		dir.append(file.data());
		const char* tmpType = Directory.data();
		const char* tmpVariable = variable.data();
		const char* tmpDir = dir.c_str();

		float x = GetPrivateProfile<float>(tmpType, tmpVariable, 0, tmpDir);
		std::vector<std::string> a = split('|',x);
		VMResultArray<float> ab;
		ab.resize(a.size(), 0);
		int i=0;
		while(i<ab.size()) {
			if(a[i]=="") {
				ab[i]=0;
			} else if(a[i].size()<16) {
				bool bIsNumeric=true;
				int j=0;
				while(j<a[i].size() && bIsNumeric) {
					switch(a[i].substr(j,1))
					case "0":
					case "1":
					case "2":
					case "3":
					case "4":
					case "5":
					case "6":
					case "7":
					case "8":
					case "9":
					case ".":
						break;
					case"-":
						if(j>0)
							bIsNumeric=false;
						break;
					default:
						bIsNumeric=false;
						break;
					j++;
				}
				if(bIsNumeric) {
					ab[i]=(float)atof(a[i].c_str());
				} else
					ab[i]=0.0;
			} else
				ab[i]=0.0;
			i++;
		}
		return ab;
	}*/





	BSFixedString getTypeString(StaticFunctionTag* Base, UInt32 id) {
		switch (id) {
		case 83: return "kANIO"; break;
		case 102: return "kARMA"; break;
		case 16: return "kAcousticSpace"; break;
		case 6: return "kAction"; break;
		case 24: return "kActivator"; break;
		case 95: return "kActorValueInfo"; break;
		case 94: return "kAddonNode"; break;
		case 42: return "kAmmo"; break;
		case 33: return "kApparatus"; break;
		case 26: return "kArmor"; break;
		case 64: return "kArrowProjectile"; break;
		case 125: return "kArt"; break;
		case 123: return "kAssociationType"; break;
		case 69: return "kBarrierProjectile"; break;
		case 66: return "kBeamProjectile"; break;
		case 93: return "kBodyPartData"; break;
		case 27: return "kBook"; break;
		case 97: return "kCameraPath"; break;
		case 96: return "kCameraShot"; break;
		case 60: return "kCell"; break;
		case 62: return "kCharacter"; break;
		case 10: return "kClass"; break;
		case 55: return "kClimate"; break;
		case 132: return "kCollisionLayer"; break;
		case 133: return "kColorForm"; break;
		case 80: return "kCombatStyle"; break;
		case 68: return "kConeProjectile"; break;
		case 49: return "kConstructibleObject"; break;
		case 28: return "kContainer"; break;
		case 117: return "kDLVW"; break;
		case 88: return "kDebris"; break;
		case 107: return "kDefaultObject"; break;
		case 115: return "kDialogueBranch"; break;
		case 29: return "kDoor"; break;
		case 129: return "kDualCastData"; break;
		case 18: return "kEffectSetting"; break;
		case 85: return "kEffectShader"; break;
		case 21: return "kEnchantment"; break;
		case 103: return "kEncounterZone"; break;
		case 120: return "kEquipSlot"; break;
		case 87: return "kExplosion"; break;
		case 13: return "kEyes"; break;
		case 11: return "kFaction"; break;
		case 67: return "kFlameProjectile"; break;
		case 39: return "kFlora"; break;
		case 110: return "kFootstep"; break;
		case 111: return "kFootstepSet"; break;
		case 40: return "kFurniture"; break;
		case 3: return "kGMST"; break;
		case 9: return "kGlobal"; break;
		case 37: return "kGrass"; break;
		case 65: return "kGrenadeProjectile"; break;
		case 2: return "kGroup"; break;
		case 51: return "kHazard"; break;
		case 12: return "kHeadPart"; break;
		case 78: return "kIdle"; break;
		case 47: return "kIdleMarker"; break;
		case 89: return "kImageSpace"; break;
		case 90: return "kImageSpaceModifier"; break;
		case 100: return "kImpactData"; break;
		case 101: return "kImpactDataSet"; break;
		case 30: return "kIngredient"; break;
		case 45: return "kKey"; break;
		case 4: return "kKeyword"; break;
		case 72: return "kLand"; break;
		case 20: return "kLandTexture"; break;
		case 44: return "kLeveledCharacter"; break;
		case 53: return "kLeveledItem"; break;
		case 82: return "kLeveledSpell"; break;
		case 31: return "kLight"; break;
		case 108: return "kLightingTemplate"; break;
		case 91: return "kList"; break;
		case 81: return "kLoadScreen"; break;
		case 104: return "kLocation"; break;
		case 5: return "kLocationRef"; break;
		case 126: return "kMaterial"; break;
		case 99: return "kMaterialType"; break;
		case 8: return "kMenuIcon"; break;
		case 105: return "kMessage"; break;
		case 32: return "kMisc"; break;
		case 63: return "kMissileProjectile"; break;
		case 36: return "kMovableStatic"; break;
		case 127: return "kMovementType"; break;
		case 116: return "kMusicTrack"; break;
		case 109: return "kMusicType"; break;
		case 59: return "kNAVI"; break;
		case 43: return "kNPC"; break;
		case 73: return "kNavMesh"; break;
		case 0: return "kNone"; break;
		case 48: return "kNote"; break;
		case 124: return "kOutfit"; break;
		case 70: return "kPHZD"; break;
		case 79: return "kPackage"; break;
		case 92: return "kPerk"; break;
		case 46: return "kPotion"; break;
		case 50: return "kProjectile"; break;
		case 77: return "kQuest"; break;
		case 14: return "kRace"; break;
		case 106: return "kRagdoll"; break;
		case 61: return "kReference"; break;
		case 57: return "kReferenceEffect"; break;
		case 58: return "kRegion"; break;
		case 121: return "kRelationship"; break;
		case 134: return "kReverbParam"; break;
		case 122: return "kScene"; break;
		case 19: return "kScript"; break;
		case 23: return "kScrollItem"; break;
		case 56: return "kShaderParticleGeometryData"; break;
		case 119: return "kShout"; break;
		case 17: return "kSkill"; break;
		case 52: return "kSoulGem"; break;
		case 15: return "kSound"; break;
		case 130: return "kSoundCategory"; break;
		case 128: return "kSoundDescriptor"; break;
		case 131: return "kSoundOutput"; break;
		case 22: return "kSpell"; break;
		case 34: return "kStatic"; break;
		case 35: return "kStaticCollection"; break;
		case 112: return "kStoryBranchNode"; break;
		case 114: return "kStoryEventNode"; break;
		case 113: return "kStoryQuestNode"; break;
		case 1: return "kTES4"; break;
		case 74: return "kTLOD"; break;
		case 86: return "kTOFT"; break;
		case 25: return "kTalkingActivator"; break;
		case 7: return "kTextureSet"; break;
		case 75: return "kTopic"; break;
		case 76: return "kTopicInfo"; break;
		case 38: return "kTree"; break;
		case 98: return "kVoiceType"; break;
		case 84: return "kWater"; break;
		case 41: return "kWeapon"; break;
		case 54: return "kWeather"; break;
		case 118: return "kWordOfPower"; break;
		case 71: return "kWorldSpace"; break;
		default: return "UNKNOWN";
		}
	}

	void split(const std::string& s, char delim, std::vector<std::string>& elems) {
		std::stringstream ss;
		ss.str(s);
		std::string item;
		while (std::getline(ss, item, delim)) {
			elems.push_back(item);
		}
	}
	std::vector<std::string> split(const std::string& s, char delim) {
		std::vector<std::string> elems;
		split(s, delim, elems);
		return elems;
	}

	bool RegisterFuncs(VMClassRegistry* registry) {
		//_MESSAGE("registering functions");

		//registry->RegisterFunction("IOReadTranslation", "FWUtility", FWUtility::IOReadTranslation);

		//registry->RegisterFunction("getLangText", "FWUtility", FWUtility::getLangText);


		registry->RegisterFunction("toLower", "FWUtility", &FWUtility::toLower);

		registry->RegisterFunction("toUpper", "FWUtility", &FWUtility::toUpper);


		registry->RegisterFunction("StringReplace", "FWUtility", &FWUtility::StringReplace);

		registry->RegisterFunction("MultiStringReplace", "FWUtility", &FWUtility::MultiStringReplace);



		registry->RegisterFunction("GetQuestObject", "FWUtility", &FWUtility::GetQuestObject);

		registry->RegisterFunction("GetQuestObjectCount", "FWUtility", &FWUtility::GetQuestObjectCount);




		registry->RegisterFunction("GetFileCount", "FWUtility", &FWUtility::GetFileCount);

		registry->RegisterFunction("GetFileName", "FWUtility", &FWUtility::GetFileName);
		registry->RegisterFunction("GetFileNames", "FWUtility", &FWUtility::GetFileNames);

		registry->RegisterFunction("getTypeString", "FWUtility", &FWUtility::getTypeString);

		registry->RegisterFunction("getIniPath", "FWUtility", &FWUtility::getIniPath);



		// Script Functions
		registry->RegisterFunction("ScriptHasString", "FWUtility", &FWUtility::ScriptHasString);

		registry->RegisterFunction("ScriptStringCount", "FWUtility", &FWUtility::ScriptStringCount);

		registry->RegisterFunction("ScriptUser", "FWUtility", &FWUtility::ScriptUser);

		registry->RegisterFunction("ScriptSource", "FWUtility", &FWUtility::ScriptSource);

		registry->RegisterFunction("ScriptMashine", "FWUtility", &FWUtility::ScriptMashine);

		registry->RegisterFunction("ScriptStringGet", "FWUtility", &FWUtility::ScriptStringGet);


		//SInt32 ScriptStringCount(StaticFunctionTag* base, BSFixedString src)
		//BSFixedString ScriptUser(StaticFunctionTag* base, BSFixedString src)
		//BSFixedString ScriptSource(StaticFunctionTag* base, BSFixedString src)
		//BSFixedString ScriptMashine(StaticFunctionTag* base, BSFixedString src)
		//BSFixedString ScriptStringGet(StaticFunctionTag* base, BSFixedString src, SInt32 Num)


		// Ini get
		registry->RegisterFunction("getIniString", "FWUtility", &FWUtility::getIniString);

		registry->RegisterFunction("getIniBool", "FWUtility", &FWUtility::getIniBool);

		registry->RegisterFunction("getIniInt", "FWUtility", &FWUtility::getIniInt);

		registry->RegisterFunction("getIniFloat", "FWUtility", &FWUtility::getIniFloat);

		// Ini get via Categorie
		registry->RegisterFunction("getIniCString", "FWUtility", &FWUtility::getIniCString);

		registry->RegisterFunction("getIniCBool", "FWUtility", &FWUtility::getIniCBool);

		registry->RegisterFunction("getIniCInt", "FWUtility", &FWUtility::getIniCInt);

		registry->RegisterFunction("getIniCFloat", "FWUtility", &FWUtility::getIniCFloat);




		// Ini set
		registry->RegisterFunction("setIniString", "FWUtility", &FWUtility::setIniString);

		registry->RegisterFunction("setIniBool", "FWUtility", &FWUtility::setIniBool);

		registry->RegisterFunction("setIniInt", "FWUtility", &FWUtility::setIniInt);

		registry->RegisterFunction("setIniFloat", "FWUtility", &FWUtility::setIniFloat);

		// Ini set via Categorie
		registry->RegisterFunction("setIniCString", "FWUtility", &FWUtility::setIniCString);

		registry->RegisterFunction("setIniCBool", "FWUtility", &FWUtility::setIniCBool);

		registry->RegisterFunction("setIniCInt", "FWUtility", &FWUtility::setIniCInt);

		registry->RegisterFunction("setIniCFloat", "FWUtility", &FWUtility::setIniCFloat);



		registry->RegisterFunction("getNextAutoFile", "FWUtility", &FWUtility::getNextAutoFile);

		registry->RegisterFunction("FileExists", "FWUtility", &FWUtility::FileExists);


		registry->RegisterFunction("Hex", "FWUtility", &FWUtility::Hex);

		registry->RegisterFunction("GetDirectoryHash", "FWUtility", &FWUtility::GetDirectoryHash);




		registry->RegisterFunction("GetFormFromString", "FWUtility", &FWUtility::GetFormFromString);

		registry->RegisterFunction("GetModFromString", "FWUtility", &FWUtility::GetModFromString);

		registry->RegisterFunction("GetFormIDFromString", "FWUtility", &FWUtility::GetFormIDFromString);

		registry->RegisterFunction("GetStringFromForm", "FWUtility", &FWUtility::GetStringFromForm);

		registry->RegisterFunction("GetModFromForm", "FWUtility", &FWUtility::GetModFromForm);

		registry->RegisterFunction("ActorArrayResize", "FWUtility", &FWUtility::ActorArrayResize);
		registry->RegisterFunction("ActorArrayUnique", "FWUtility", &FWUtility::ActorArrayUnique);
		registry->RegisterFunction("ActorArrayAppend", "FWUtility", &FWUtility::ActorArrayAppend);
		registry->RegisterFunction("removeDuplicatedActors", "FWUtility", &FWUtility::RemoveDuplicatedActors);
		registry->RegisterFunction("FloatArrayAppend", "FWUtility", &FWUtility::FloatArrayAppend);
		registry->RegisterFunction("FloatArrayResize", "FWUtility", &FWUtility::FloatArrayResize);
		registry->RegisterFunction("IntArrayAppend", "FWUtility", &FWUtility::IntArrayAppend);
		registry->RegisterFunction("ActorArray", "FWUtility", &FWUtility::ActorArray);
		registry->RegisterFunction("ActorBaseArray", "FWUtility", &FWUtility::ActorBaseArray);
		registry->RegisterFunction("FormArray", "FWUtility", &FWUtility::FormArray);
		registry->RegisterFunction("BoolArray", "FWUtility", &FWUtility::BoolArray);
		registry->RegisterFunction("FloatArray", "FWUtility", &FWUtility::FloatArray);
		registry->RegisterFunction("IntArray", "FWUtility", &FWUtility::IntArray);
		registry->RegisterFunction("StringArray", "FWUtility", &FWUtility::StringArray);
		registry->RegisterFunction("FormArrayConcat", "FWUtility", &FWUtility::FormArrayConcat);
		registry->RegisterFunction("GetNames", "FWUtility", &FWUtility::GetNames);
		registry->RegisterFunction("getActorListNames", "FWUtility", &FWUtility::GetActorListNames);
		registry->RegisterFunction("GetPercentage", "FWUtility", &FWUtility::GetPercentage);
		registry->RegisterFunction("GetTimeString", "FWUtility", &FWUtility::GetTimeString);
		registry->RegisterFunction("GetVersionString", "FWUtility", &FWUtility::GetVersionString);
		registry->RegisterFunction("AreModsInstalled", "FWUtility", &FWUtility::AreModsInstalled);
		registry->RegisterFunction("ArrayReplace", "FWUtility", &FWUtility::ArrayReplace);
		registry->RegisterFunction("floatModulo", "FWUtility", &FWUtility::FloatModulo);
		registry->RegisterFunction("GetModFromID", "FWUtility", &FWUtility::GetModFromID);
		registry->RegisterFunction("FindFemaleFromJsonFileName", "FWUtility", &FWUtility::FindFemaleFromJsonFileName);

		return true;
	}

}


