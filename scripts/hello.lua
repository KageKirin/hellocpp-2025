--
-- Hello build configuration script
--
-------------------------------------------------------------------------------
--
-- Maintainer notes
--
-- - we're not using the regular _scaffolding_ for this project
--   mostly b/c it's too bloated
-- - scaffolds are still used though
--
-------------------------------------------------------------------------------
--
-- Use the --to=path option to control where the project files get generated. I use
-- this to create project files for each supported toolset, each in their own folder,
-- in preparation for deployment.
--
	newoption {
		trigger = "to",
		value   = "path",
		description = "Set the output location for the generated files"
	}
-------------------------------------------------------------------------------
--
-- Use the --tooolchain=identifier option to control which toolchain is used
--
	newoption {
		trigger = "toolchain",
		value   = "string",
		description = "Set the toolchain to use for compilation"
	}

-------------------------------------------------------------------------------
--
-- Use the --fuzzer=identifier option to control which fuzzer is used
--
	newoption {
		trigger = "fuzzer",
		value   = "string",
		description = "Set the fuzzer to use for compilation"
	}

-------------------------------------------------------------------------------
--
-- Use the --test option to enable unit tests
--
	newoption {
		trigger = "test",
		value   = "string",
		description = "Set the unit test mode compilation, optional arguments are for sanitizers"
	}

	-------------------------------------------------------------------------------
--
-- Use the --mold option to enable using mold as linker
--
	newoption {
		trigger = "mold",
		description = "Link using mold"
	}

-------------------------------------------------------------------------------
if not _ACTION then
	return true
end


-------------------------------------------------------------------------------
--
-- Pull in dependencies
--
	dofile("functions.lua") -- from scaffolding/system/functions.lua

-------------------------------------------------------------------------------
--
-- Solution wide settings
--

local thisscriptpath = path.getabsolute(path.getdirectory(_SCRIPT))
local rootpath       = path.getabsolute(path.join(thisscriptpath, '..'))
local locationpath = path.join(os.getcwd(), _OPTIONS["to"] or path.join('build/projects'))
local targetpath   = path.join(locationpath, '../bin')
local objectpath   = path.join(locationpath, '../obj')
local librarypath   = path.join(locationpath, '../lib')

	solution "Hello"
		configurations {
			"Debug",
			"Release"
		}
		location (locationpath)

		configuration { "Debug" }
			targetsuffix ""
			defines    { "DEBUG", "_DEBUG" }

		configuration { "Release" }
			targetsuffix ""
			defines    { "RELEASE", "NDEBUG" }

		configuration { "windows" }
			targetdir (path.join(targetpath, "windows"))
			objdir    (path.join(objectpath, "windows"))

		configuration { "linux*" }
			targetdir (path.join(targetpath, "linux"))
			objdir    (path.join(objectpath, "linux"))

		configuration { "macosx" }
			targetdir (path.join(targetpath, "darwin"))
			objdir    (path.join(objectpath, "darwin"))

		configuration { "asmjs" }
			targetdir (path.join(targetpath, "asmjs"))
			objdir    (path.join(objectpath, "asmjs"))

		configuration { "wasm*" }
			targetdir (path.join(targetpath, "wasm"))
			objdir    (path.join(objectpath, "wasm"))

		configuration { "Debug" }
			defines     { "_DEBUG", }
			flags       { "Symbols" }

		configuration { "Release" }
			defines     { "NDEBUG", }
			flags       { "OptimizeSize" }

		configuration { "Debug", "windows", "not zig" }
			linkoptions { "-Wl,/DEBUG:FULL" }

		configuration {}

		flags {
			"ExtraWarnings",
			"No64BitChecks",
			"StaticRuntime",
			"LinkSupportCircularDependencies",
		}

		buildoptions {
			--"-fdiagnostics-show-hotness",
			"-fdiagnostics-fixit-info",
			"-fdiagnostics-color",
			"-fdiagnostics-show-note-include-stack",
			"-Wextra-tokens",
			"-Wno-undef",
			"-Wno-ignored-qualifiers",
			"-Wno-unused-parameter",
			"-Wno-unknown-warning-option",
			"-Wno-switch",
			"-Wno-unknown-pragmas",
			"-Wno-nonnull",
			"-Wno-sign-compare",
			"-Wno-pessimizing-move",
			"-Wno-unused-lambda-capture",
			"-Wno-reorder-init-list",
			"-Wno-unused-variable",
			"-Wno-unused-const-variable",
			"-Wno-unused-value",
			"-Wno-unused-function",
			"-Wno-sign-compare",
			"-Wno-c99-designator",
			"-Wno-missing-field-initializers",
			"-Wno-reorder-ctor",
			"-Wno-undefined-var-template",
			"-Wno-sign-compare",
			--"-Rpass=inline",
		}

		if _OPTIONS['mold'] then
			linkoptions {
				'-fuse-ld=mold',
			}
		end

		configuration { "macosx", "not zig" }
			removeflags { "LinkSupportCircularDependencies" }

		configuration {}

	startproject "hello"

-------------------------------------------------------------------------------
--
-- External 'scaffold' projects
--

local external_projects = {
	--keep
	--this
	--line
	--['argus'] = dofile(path.join(rootpath, "libs", "argus", "argus.lua")),
	--keep
	--this
	--line
	['catch2'] = dofile(path.join(rootpath, "libs", "catch2", "catch2.lua")),
	--keep
	--this
	--line
	['fmt'] = dofile(path.join(rootpath, "libs", "fmt", "fmt.lua")),
	--keep
	--this
	--line
}

create_packages_projects(external_projects)

-------------------------------------------------------------------------------
--
-- Main project
--

core_projects = {
	["hello.gitrev"] = {
		_add_includedirs = function() end,
		_add_defines = function() end,
		_add_libdirs = function() end,
		_add_external_links = function() end,
		_add_self_links = function()
			links { "hello.gitrev" }
		end,
		_create_projects = function()
			project "hello.gitrev"
				language "C"
				kind "StaticLib"
				flags {
					"ExtraWarnings",
					--"FatalWarnings",
					"No64BitChecks",
					"StaticRuntime",
					"ObjcARC",
					"CppLatest",
				}

				files {
					path.join("../src/",  "gitrev.c"),
				}

				buildoptions {
					"-fblocks",
					"-Wno-undef",
					--"-Rpass=inline",
				}

				configuration { "Debug" }
					defines     { "_DEBUG", "WITH_DEBUG_PRINT", }
					flags       { "Symbols" }

				configuration { "Release" }
					defines     { "NDEBUG", }
					flags       { "OptimizeSize" }

				configuration { "windows" }
					defines     { "PLATFORM_WINDOWS" }
				configuration { "windows", "not zig" }
					linkoptions { "-Wl,/subsystem:console" }

				configuration { "macosx" }
					defines      { "PLATFORM_MACOS" }

				configuration { "linux*" }
					defines      { "PLATFORM_LINUX" }
					links        { "dl", "m" }
					linkoptions  { "-rdynamic", "-pthreads" }

				configuration {}

				debugargs {
				}

		end, -- _create_projects()
	}, -- hello.gitrev
}

tool_projects = {
	["hello"] = {
		_add_includedirs = function() end,
		_add_defines = function() end,
		_add_libdirs = function() end,
		_add_external_links = function() end,
		_add_self_links = function() end,
		_create_projects = function()
			project "hello"
				language "C++"
				kind "ConsoleApp"
				flags {
					"ExtraWarnings",
					--"FatalWarnings",
					"No64BitChecks",
					"StaticRuntime",
					"ObjcARC",
					"CppLatest",
				}

				defines {}

				add_packages {
					external_projects['fmt'],
					core_projects['hello.gitrev'],
				}

				links {}

				includedirs {
					"../src",
				}

				files {
					path.join("../src/Hello", "hello.h"),
					path.join("../src/Hello", "hello.cpp"),
				}

				buildoptions {
					"-fblocks",
					"-Wno-undef",
					--"-Rpass=inline",
				}

				configuration { "Debug" }
					defines     { "_DEBUG", "WITH_DEBUG_PRINT", }
					flags       { "Symbols" }

				configuration { "Release" }
					defines     { "NDEBUG", }
					flags       { "OptimizeSize" }

				configuration { "windows" }
					defines     { "PLATFORM_WINDOWS" }
				configuration { "windows", "not zig" }
					linkoptions { "-Wl,/subsystem:console" }

				configuration { "macosx" }
					defines      { "PLATFORM_MACOS" }

				configuration { "linux*" }
					defines      { "PLATFORM_LINUX" }
					links        { "dl", "m" }
					linkoptions  { "-rdynamic", "-pthreads" }

				configuration {}

				debugargs {
				}

		end, -- _create_projects()
	}, -- hello
}

unittest_projects = {
	["unittest"] = {
		_add_includedirs = function() end,
		_add_defines = function() end,
		_add_libdirs = function() end,
		_add_external_links = function() end,
		_add_self_links = function() end,
		_create_projects = function()
			project "unittest"
				language "C++"
				kind "ConsoleApp"
				flags {
					"ExtraWarnings",
					--"FatalWarnings",
					"No64BitChecks",
					"StaticRuntime",
					"ObjcARC",
					"CppLatest",
				}

				defines {}

				add_packages {
					external_projects['catch2'],
					---
					core_projects['hello.gitrev'],
				}

				links {}

				includedirs {}

				files {
					path.join("../src", "unittest", "*.cpp"),
				}

				buildoptions {
					"-fblocks",
					"-Wno-undef",
					--"-Rpass=inline",
				}

				configuration { "Debug" }
					defines     { "_DEBUG", "WITH_DEBUG_PRINT", }
					flags       { "Symbols" }

				configuration { "Release" }
					defines     { "NDEBUG", }
					flags       { "OptimizeSize" }

				configuration { "windows" }
					defines     { "PLATFORM_WINDOWS" }
				configuration { "windows", "not zig" }
					linkoptions { "-Wl,/subsystem:console" }

				configuration { "macosx" }
					defines      { "PLATFORM_MACOS" }

				configuration { "linux*" }
					defines      { "PLATFORM_LINUX" }
					links        { "dl", "m" }
					linkoptions  { "-rdynamic", "-pthreads" }

				configuration {}

				debugargs {
				}

		end, -- _create_projects()
	}, -- unittest
}

create_packages_projects(core_projects)
create_packages_projects(tool_projects)
create_packages_projects(unittest_projects)

-------------------------------------------------------------------------------
--
-- Patch _some_ of the scaffolded projects with different properties
--

local projectkinds = {
	"consoleapp",
	"windowedapp",
	"sharedlib",
}

for _,p in ipairs(solution().projects) do
	project (p.name)
	for __,blk in ipairs(p.blocks) do
		if blk.kind and table.icontains(projectkinds, blk.kind:lower()) then
			printf("configuring targetdir for project %s %s", colorize(ansicolors.cyan, p.name), colorize(ansicolors.green, blk.kind))
			configuration {}
			configuration { blk.keywords , "windows" }
				targetdir    (path.join(rootpath, "bin/windows"))
			configuration { blk.keywords , "linux*" }
				targetdir    (path.join(rootpath, "bin/linux"))
			configuration { blk.keywords , "macosx" }
				targetdir    (path.join(rootpath, "bin/darwin"))
			configuration { blk.keywords , "asmjs" }
				targetdir    (path.join(rootpath, "bin/asmjs"))
			configuration { blk.keywords , "wasm*" }
				targetdir    (path.join(rootpath, "bin/wasm"))
			configuration {}
		end
	end
end


-------------------------------------------------------------------------------
--
-- A more thorough cleanup.
--

	if _ACTION == "clean" then
		os.rmdir("bin")
		os.rmdir("build")
	end
-------------------------------------------------------------------------------
--
-- Use the release action to prepare source and binary packages for a new release.
-- This action isn't complete yet; a release still requires some manual work.
--
	dofile("release.lua")

	newaction {
		trigger     = "release",
		description = "Prepare a new release (incomplete)",
		execute     = dorelease
	}

-------------------------------------------------------------------------------
--
-- Use the embed action to refresh embed source.
--
	dofile("embed.lua")

	newaction {
		trigger     = "embed",
		description = "Refresh 'embed' sources",
		execute     = doembed
	}
-------------------------------------------------------------------------------
--
-- Use the format action to format source files
--
	dofile("format.lua")

	newaction {
		trigger     = "format",
		description = "Format sources",
		execute     = function() doformat(_ARGS) end
	}
-------------------------------------------------------------------------------
--
-- Use the generate action to generate sources that are generated from templates.
--
dofile("generate.lua")

newaction {
	trigger     = "generate",
	description = "Refresh generated sources",
	execute     = dogenerate
}

-------------------------------------------------------------------------------
--
-- Use the load-packages to load 3rd party packages
--
	function doloadpackages()
		load_packages(external_projects)
	end

	newaction {
		trigger     = "loadpackages",
		description = "Load 3rd party packages",
		execute     = doloadpackages
	}
-------------------------------------------------------------------------------
