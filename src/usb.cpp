#include <iostream>
#include <print>
#include <usb.hpp>

auto main(int /*argc*/, char* /*argv*/[]) -> int {
    auto context = usb::Context::createDefault();

    if (!context) {
        std::println(std::cerr, "Failed to create LIBUSB context");
        return 1;
    }

    std::println("Created context");

    return 0;
}
