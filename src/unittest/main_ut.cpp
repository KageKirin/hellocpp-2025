#define CATCH_CONFIG_RUNNER
#define CATCH_CONFIG_CPP11_TO_STRING

#define CATCH_CONFIG_CPP17_UNCAUGHT_EXCEPTIONS
#define CATCH_CONFIG_CPP17_STRING_VIEW
#define CATCH_CONFIG_CPP17_VARIANT
#define CATCH_CONFIG_CPP17_OPTIONAL
#define CATCH_CONFIG_CPP17_BYTE

#ifdef _WIN32
#define CATCH_CONFIG_COLOUR_WINDOWS  // forces the Win32 console API to be used
#else
#define CATCH_CONFIG_COLOUR_ANSI  // forces ANSI colour codes to be used
#endif                            // _WIN32


#include <catch2/catch.hpp>

int main(int argc, char* argv[])
{
    return Catch::Session().run(argc, argv);
}
