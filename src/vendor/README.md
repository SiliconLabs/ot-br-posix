# Vendor
Vendors wanting to add custom CLI commands to `otbr-agent` may implement a `ot-vendor-cli` library.

The source for this library may live anywhere and does not have to be in this repository.

## Usage
An example implementation has been provided in [cli](cli)

To include `ot-vendor-cli` in the `otbr-agent` build, the vendor simply has to define the `OTBR_POSIX_VENDOR_CLI` variable. This can be added to the `./script/setup` file or when running the setup script

For example:
```shell
$ OTBR_POSIX_VENDOR_CLI=/absolute/path/to/src/vendor/cli ./script/setup
```
