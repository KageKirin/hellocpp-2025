-- package geniefile for catch2

catch2_script = path.getabsolute(path.getdirectory(_SCRIPT))
catch2_root = path.join(catch2_script, "catch2")

catch2_includedirs = {
	path.join(catch2_root, "single_include"),
}

catch2_libdirs = {}
catch2_links = {}

catch2_defines = {
	"CATCH_CONFIG_ENABLE_BENCHMARKING",
}

----

return {
	_load_package = function()
		if os.isdir(catch2_root) then
			os.executef('git -C %s pull', catch2_root)
		else
			os.executef('git clone --branch=v2.x https://github.com/catchorg/Catch2.git %s', catch2_root)
		end
	end,

	_add_includedirs = function()
		includedirs {
			catch2_includedirs,
		}
	end,

	_add_defines = function()
		defines { catch2_defines }
	end,

	_add_libdirs = function()
		libdirs { catch2_libdirs }
	end,

	_add_external_links = function()
		links { catch2_links }
	end,

	_add_self_links = function()
	end,

	_create_projects = function()

group "thirdparty"
project "catch2"
	kind "StaticLib"
	language "C++"
	flags { "CppLatest"}

	defines {
		catch2_defines,
	}

	includedirs {
		catch2_includedirs,
		path.join(catch2_root, "include"),
		path.join(catch2_root, "include", "internal"),
		path.join(catch2_root, "src"),
	}

	files {
		path.join(catch2_root, "single_include", "**.hpp"),
		-- path.join(catch2_script, "catch2.cpp"),

		-- path.join(catch2_root, "include/**.hpp"),
		-- path.join(catch2_root, "src/**.hpp"),
		-- path.join(catch2_root, "src/**.cpp"),
		-- path.join(catch2_root, "third_party/*.hpp"),

		path.join(catch2_script, "dummy.cpp")
	}

	configuration {}

end, -- _create_projects()
}

---
