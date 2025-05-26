#include <catch2/catch.hpp>

TEST_CASE("Test", "[classic]")
{
    SECTION("compile test")
    {
        const int var = 1;
        REQUIRE(var == 1);
    }
}
