includes("@builtin/xpack")

set_languages("cxxlatest")

add_requires("libusb", { system = false })
add_requires("libudev", { system = true })

add_rules("mode.debug", "mode.release")

if is_mode("debug") then
    set_symbols("debug")
    set_optimize("none")
    set_policy("build.sanitizer.address", true)
    set_policy("build.sanitizer.undefined", true)
    set_policy("build.sanitizer.leak", true)
else
    set_symbols("hidden")
    set_optimize("fastest")
    set_strip("all")
    set_warnings("all", "error")
end

target("simtracepp")
    -- TODO: Set version with `git describe`
    set_version("0.1.0")
    set_license("LGPL-2.1")
    set_kind("static")
    add_includedirs("include", { public = true })
    add_files("src/**.cpp")
    remove_files("src/usb.cpp")
    add_packages("libusb", "libudev")
    add_syslinks("usb-1.0", "udev")
target_end()

target("usb-test")
    set_kind("binary")
    add_files("src/usb.cpp")
    add_deps("simtracepp")
    set_default(true)
target_end()

xpack("simtracepp")
    -- TODO: Check if the OS names are proper
    -- if linuxos.name() == "debian" then
    --     set_formats("deb", "targz")
    -- elseif linuxos.name() == "rocky" then
    --     set_formats("rpm", "targz")
    -- else
    --     set_formats("targz")
    -- end
    -- TODO: Update to adapt target to platform
    set_formats("targz")
    set_prefixdir("simtracepp")
    add_targets("simtracepp")
    set_author("Hampus Avekvist <hampus.avekvist@hey.com>")
    set_maintainer("Hampus Avekvist <hampus.avekvist@hey.com>")
    set_license("MIT")
    set_licensefile("LICENSE")
    set_title("SIMtrace2 host software in C++")
    set_description("SIMtrace2 cardem-supporting host software written in pure, modern C++")
target_end()

add_requires("gtest", {
    system = false,
    ---@diagnostic disable-next-line: missing-fields
    configs = {
        main = true,
        gmock = true,
    },
})

---@diagnostic disable-next-line: undefined-field
for _, file in ipairs(os.files("tests/**.cpp")) do
    ---@diagnostic disable-next-line: undefined-global
    local name = path.basename(file)
    target(name)
        set_kind("binary")
        add_packages("gtest")
        add_links("gtest_main")
        set_default(false)
        add_files(file)
        add_deps("simtracepp")
        add_tests("default")
    target_end()
end
