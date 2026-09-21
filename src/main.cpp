// Beeing Female NG - female reproductive cycle simulation for Skyrim SE/AE/VR.
// Copyright (C) 2025-2026 crajjjj
//
// This program is free software: you can redistribute it and/or modify it
// under the terms of the GNU General Public License as published by the Free
// Software Foundation, either version 3 of the License, or (at your option)
// any later version. It is built on CommonLibSSE-NG, which is GPL-3.0, and is
// distributed WITHOUT ANY WARRANTY. See the LICENSE file in the repository
// root, or <https://www.gnu.org/licenses/>.

#include "CommonLibCompat.h"

#include <REL/Module.h>
#include <spdlog/sinks/basic_file_sink.h>
#include <spdlog/sinks/msvc_sink.h>

#include "FWUtility.h"
#include "FWChildActor.h"
#include "FWSystem.h"
#include "FWChildEnchant.h"
#include "FWTextContents.h"

using namespace SKSE;
using namespace SKSE::log;
using namespace SKSE::stl;

namespace {
    void InitializeLogging() {
        auto path = log_directory();
        if (!path) {
            report_and_fail("Unable to lookup SKSE logs directory.");
        }
        *path /= PluginDeclaration::GetSingleton()->GetName();
        *path += L".log";

        std::shared_ptr<spdlog::logger> logger;
        if (IsDebuggerPresent()) {
            logger = std::make_shared<spdlog::logger>(
                "Global", std::make_shared<spdlog::sinks::msvc_sink_mt>());
        } else {
            logger = std::make_shared<spdlog::logger>(
                "Global", std::make_shared<spdlog::sinks::basic_file_sink_mt>(path->string(), true));
        }
        logger->set_level(spdlog::level::info);
        logger->flush_on(spdlog::level::info);

        spdlog::set_default_logger(std::move(logger));
        spdlog::set_pattern("[%Y-%m-%d %H:%M:%S.%e] [%n] [%l] [%t] [%s:%#] %v");
    }

    void InitializePapyrus() {
        log::trace("Initializing Papyrus binding...");
        auto* papyrus = GetPapyrusInterface();
        if (!papyrus) {
            report_and_fail("Failed to obtain Papyrus interface.");
        }

        bool ok = true;
        ok &= papyrus->Register(FWUtility::RegisterFuncs);
        ok &= papyrus->Register(FWChildActor::RegisterFuncs);
        ok &= papyrus->Register(FWChildEnchant::RegisterFuncs);
        ok &= papyrus->Register(FWTextContents::RegisterFuncs);
        ok &= papyrus->Register(FWSystem::RegisterFuncs);

        if (!ok) {
            report_and_fail("Failure to register Papyrus bindings.");
        }

        log::info("Papyrus functions bound.");
    }

    void InitializeSerialization() {
        log::trace("Initializing cosave serialization...");
        auto* serde = GetSerializationInterface();
        if (!serde) {
            log::info("Serialization interface not available.");
            return;
        }
        serde->SetUniqueID(_byteswap_ulong('BF10'));
        log::info("Cosave serialization initialized.");
    }
}

SKSEPluginLoad(const LoadInterface* skse) {
    InitializeLogging();

    const auto* plugin = PluginDeclaration::GetSingleton();
    log::info("{} v{} is loading...", plugin->GetName(), plugin->GetVersion());

    log::info("Runtime version: {}", REL::Module::get().version().string());

    Init(skse);
    InitializeSerialization();
    InitializePapyrus();

    log::info("{} loaded.", plugin->GetName());
    return true;
}
