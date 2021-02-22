# Vendor CLI

Vendors wanting to add custom CLI commands to `otbr-agent` may implement a `ot-vendor-cli` library.

## Quick Start Guide

This folder provides an example implementation of a `ot-vendor-cli` CMake library.

```
cli
├── CMakeLists.txt
├── include
│   └── vendor_cli_example.h
├── README.md
└── src
    └── vendor_cli_example.c
```

The quickest way to start a new implementation would be to copy this project and
use it as a template. The source files for the new implementation may live
anywhere and do not have to be in this repository.

### Required definitions

The first file to look at is [CMakeLists.txt](CMakeLists.txt), which defines
the `ot-vendor-cli` library. In here, two variable definitions are required:

- `VENDOR_CLI_SOURCES` - This defines the list of source files in the library
- `VENDOR_CLI_HEADER` - This is the header file which will be included by
`otbr-agent`

The second requirement for `ot-vendor-cli` is the definition of the hook
function.

```c
void otVendorCliInit(void)
```

In the example implementation, this function is defined in
[src/vendor_cli_example.c](src/vendor_cli_example.c).


## Usage

To include `ot-vendor-cli` in the `otbr-agent` build, the vendor simply has to
define the location of the library as `OTBR_POSIX_VENDOR_SRCDIR` prior to running
`./script/setup`.

The path assigned to `OTBR_POSIX_VENDOR_SRCDIR` must be an **absolute** path

**Example**
```shell
$ OTBR_POSIX_VENDOR_SRCDIR=/home/user/ot-br-posix/examples/vendor/ ./script/setup
```

Once the setup has completed successfully, restart the `otbr-agent` service and
the vendor commands should appear at the tail of the commands listed with `help`

**Example**
```shell
$ sudo systemctl restart otbr-agent.service
$ sudo ot-ctl
> help
...
version
myCommand
Done
> myCommand
Hello world!
>
```

