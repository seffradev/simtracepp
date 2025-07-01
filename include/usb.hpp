#ifndef USB_HPP
#define USB_HPP

#include <libusb-1.0/libusb.h>

#include <expected>
#include <print>

namespace usb {

struct Error {
    int resultCode;
};

class Context {
public:
    static constexpr auto createDefault() noexcept
        -> std::expected<Context, Error> {
        auto options = std::array<libusb_init_option, 1>{
            libusb_init_option{.option = LIBUSB_OPTION_LOG_LEVEL,
                               .value = {LIBUSB_LOG_LEVEL_ERROR}}};
        if (auto result = libusb_init_context(
                nullptr, options.data(), options.size());
            result != 0) {
            return std::unexpected{Error{result}};
        }

        return Context{};
    }

    constexpr Context(const Context&)                    = delete;
    constexpr auto operator=(const Context&) -> Context& = delete;

    constexpr Context(Context&&)                    = default;
    constexpr auto operator=(Context&&) -> Context& = default;

    constexpr ~Context() noexcept {
        if (context != nullptr || isDefaultContext) {
            libusb_exit(context);
        }
    }

private:
    static constexpr auto
    log(auto context, auto level, auto message) noexcept -> void {
        std::println("{}", message);
    }

    constexpr Context(libusb_context* context = nullptr) noexcept
        : context(context), isDefaultContext(context == nullptr) {
        libusb_set_log_cb(context, &log, LIBUSB_LOG_CB_CONTEXT);
    }

    /// `std::unique_ptr` didn't work here
    /// due to linkage (or sizing) issues,
    /// therefore a raw pointer is used.
    /// TODO: Explore if it must be raw or if
    /// linkage (or sizing) can be resolved.
    libusb_context* context;
    bool            isDefaultContext;
};

}

#endif
