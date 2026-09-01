set_xmakever("3.0.0") -- CommonLibSSE-NG v7 (alandtse) requires xmake 3.x

-- Globals
PROJECT_NAME = "BeeingFemale"

-- Project
set_project(PROJECT_NAME)
set_version("3.0.0")
set_languages("cxx23")
set_license("gplv3")
set_warnings("allextra")

-- Options
option("copy_to_mod")
    set_default(false)
    set_description("Copy dist/* to a mod folder (XSE_TES5_MODS_PATH)")
option_end()

-- Dependencies & Includes
-- https://github.com/xmake-io/xmake-repo/tree/dev
includes("lib/commonlibsse-ng")

-- policies
set_policy("package.requires_lock", true)

-- rules
add_rules("mode.debug", "mode.release")

if is_mode("debug") then
    add_defines("DEBUG")
    set_optimize("none")
    set_runtimes("MTd")
elseif is_mode("release") then
    add_defines("NDEBUG")
    set_optimize("fastest")
    set_symbols("debug")
    set_runtimes("MT")
end

add_defines("_SILENCE_CXX17_CODECVT_HEADER_DEPRECATION_WARNING")

-- set_config("skyrim_se", true)
-- set_config("skyrim_ae", true)
-- set_config("skyrim_vr", true)

-- Target
target(PROJECT_NAME)
    set_kind("shared")

    -- CommonLibSSE-NG
    add_deps("commonlibsse-ng")
    add_rules("commonlibsse-ng.plugin", {
        name = PROJECT_NAME,
        author = "crajjjj",
        description = "Beeing Female NG SKSE plugin."
    })

    -- The v7 commonlib.plugin rule auto-runs `install` after every build and,
    -- with XSE_TES5_MODS_PATH set, drops a stray "<target>" mod folder into the
    -- live MO2 instance (the rule's on_config overrides a plain set_installdir).
    -- This project stages into dist/ (see after_build) and deploys via the
    -- opt-in copy_to_mod option instead, so sink the rule's install inside the
    -- build directory from our own on_config.
    on_config(function (target)
        target:set("installdir", path.join(target:autogendir(), "install"))
    end)

    -- Source files
    add_files("src/**.cpp")
    add_headerfiles("src/**.h")
    add_includedirs("src", "include")

    -- Exports
    add_ldflags("/DEF:exports.def", { force = true })

    -- flags
    add_cxxflags(
        "cl::/diagnostics:caret",
        "cl::/wd4200",
        "cl::/wd4201",
        "cl::/Zc:preprocessor",
        "cl::/utf-8"
    )

    if is_mode("debug") then
        add_cxxflags("cl::/bigobj")
    end

    -- Post Build
    after_build(function (target)
        local plugin_folder = path.join(os.projectdir(), "dist", "Core", "skse", "plugins")
        if not os.isdir(plugin_folder) then
            os.mkdir(plugin_folder)
        end
        os.cp(target:targetfile(), plugin_folder)
        if is_mode("debug") then
            local pdb = target:symbolfile()
            if pdb then
                os.cp(pdb, plugin_folder)
            end
        end

        local mod_folder = os.getenv("XSE_TES5_MODS_PATH")
        if mod_folder and has_config("copy_to_mod") then
            os.cp("dist/*", path.join(mod_folder, "Beeing Female NG"))
        end
    end)
target_end()
