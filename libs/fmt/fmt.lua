-- package geniefile for fmt

fmt_script = path.getabsolute(path.getdirectory(_SCRIPT))
fmt_root = path.join(fmt_script, "fmt")

fmt_includedirs = {
	path.join(fmt_root, "include"),
}

fmt_libdirs = {}
fmt_links = {}

fmt_defines = {}

----

return {
	_load_package = function()
		if os.isdir(fmt_root) then
			os.executef('git -C %s pull', fmt_root)
		else
			os.executef('git clone https://github.com/fmtlib/fmt.git %s', fmt_root)
		end
	end,

	_add_includedirs = function()
		includedirs { fmt_includedirs }
	end,

	_add_defines = function()
		defines { fmt_defines }
	end,

	_add_libdirs = function()
		libdirs { fmt_libdirs }
	end,

	_add_external_links = function()
		links { fmt_links }
	end,

	_add_self_links = function()
		links { "fmt" }
	end,

	_create_projects = function()

group "thirdparty"
project "fmt"
	kind "StaticLib"
	language "C++"
	flags { "CppLatest"}

	defines {
		fmt_defines,
	}

	includedirs {
		fmt_includedirs,
	}

	files {
		path.join(fmt_root, "include/fmt/*.h"),
		path.join(fmt_root, "src/*.cc"),
	}

	removefiles {
		path.join(fmt_root, "src/fmt.cc"), -- No C++ module support
	}

	configuration {}

end, -- _create_projects()
}

---
