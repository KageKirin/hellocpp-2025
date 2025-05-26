--
-- Script to format code using clang-tidy (modernization) and clang-format (properly format)
--

local script_path = path.getdirectory(_SCRIPT)
local source_path = path.join(script_path, "..", "src")

function doformat(_inputs)
	local tidycheckers = {
		'modernize-concat-nested-namespaces',
		'llvm-namespace-comment',

		'readability-const-return-type',
		--'llvm-header-guard', -- nopes, changes headerguards to include full source path

		'misc-misplaced-const',
		'misc-unused-parameters',
		'misc-unused-using-decls',
		'misc-definitions-in-headers',

		'readability-braces-around-statements',
		'readability-redundant-declaration',
		'readability-redundant-smartptr-get',
		'readability-redundant-string-cstr',
		'readability-redundant-string-init',

		'readability-qualified-auto',
		'readability-avoid-const-params-in-decls',
		'readability-container-data-pointer',
		'readability-container-size-empty',
		'readability-convert-member-functions-to-static',
		'readability-static-accessed-through-instance',
		'readability-delete-null-pointer',
		'readability-else-after-return',
		'readability-function-cognitive-complexity',
		--'readability-identifier-naming', -- potentially breaking
		'readability-implicit-bool-conversion',
		'readability-inconsistent-declaration-parameter-name',
		'readability-isolate-declaration',
		'readability-make-member-function-const',
		'readability-misplaced-array-index',
		'readability-named-parameter',
		'readability-non-const-parameter',
		'readability-redundant-access-specifiers',
		'readability-redundant-control-flow',
		'readability-redundant-function-ptr-dereference',
		'readability-redundant-member-init',
		'readability-simplify-boolean-expr',
		'readability-simplify-subscript-expr',
		'readability-static-definition-in-anonymous-namespace',
		'readability-string-compare',
		'readability-suspicious-call-argument',
		'readability-uniqueptr-delete-release',
		'readability-uppercase-literal-suffix',


		'misc-redundant-expression',
		'misc-throw-by-value-catch-by-reference',
		'misc-uniqueptr-reset-release',
		'misc-unused-alias-decls',

		'performance-faster-string-find',
		'performance-for-range-copy',
		'performance-implicit-conversion-in-loop',
		'performance-inefficient-algorithm',
		'performance-inefficient-string-concatenation',
		'performance-inefficient-vector-operation',
		'performance-move-const-arg',
		'performance-no-automatic-move',
		'performance-no-int-to-ptr',
		'performance-trivially-destructible',
		'performance-type-promotion-in-math-fn',
		'performance-unnecessary-copy-initialization',
		'performance-unnecessary-value-param',

		'modernize-avoid-bind',
		'modernize-use-using',
		'modernize-avoid-c-arrays',
		'modernize-deprecated-ios-base-aliases',
		'modernize-loop-convert',
		'modernize-make-shared',
		'modernize-make-unique',
		'modernize-pass-by-value',
		'modernize-raw-string-literal',
		'modernize-redundant-void-arg',
		'modernize-replace-auto-ptr',
		'modernize-shrink-to-fit',
		'modernize-unary-static-assert',
		'modernize-use-bool-literals',
		'modernize-use-default-member-init',
		'modernize-use-emplace',
		'modernize-use-nullptr',


		--- potentially hazardous
		'modernize-deprecated-headers',
		'modernize-replace-disallow-copy-and-assign-macro',
		'modernize-return-braced-init-list',
		'modernize-use-auto',
		'modernize-use-equals-default',
		'modernize-use-equals-delete',
		'modernize-use-override',
		'modernize-use-transparent-functors',
		'modernize-use-uncaught-exceptions',

		--- breaking ?!
		'modernize-use-trailing-return-type',

		--'clang-analyzer-*',
		--'clang-analyzer-cplusplus*',
		--'concurrency-*',
		--'performance-*',
		--'portability-*',
		--'readability-*',
	}

	local do_not_tidy_filter = table.flatten {
		os.matchfiles(path.join(source_path, "schemas", "**.h")),
		os.matchfiles(path.join(source_path, "schemas", "**.cxx")),
	}
	do_not_tidy_filter = table.translate(do_not_tidy_filter, function(item)
		return path.getrelative(path.getabsolute(path.join(script_path, "..")), path.getabsolute(item))
	end)

	local _inputs_for_tidy = table.translate(_inputs, function(item)
		if table.contains(do_not_tidy_filter, item) then
			printf("filtering item %q", item)
		else
			return item
		end
	end)

	local cmd_builddb = "make -B build-db"
	os.execute(cmd_builddb)

	local cmd_tidy   = "clang-tidy --fix --fix-errors " .. table.concat(_inputs_for_tidy, " ")
	os.execute(cmd_tidy)

	local cmd_format = "clang-format -i " .. table.concat(_inputs_for_tidy, " ")
	os.execute(cmd_format)
end
-------------------------------------------------------------------------------
