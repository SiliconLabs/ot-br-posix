#include OPENTHREAD_POSIX_VENDOR_CLI_HEADER

#include <openthread/cli.h>

static void HandleMyCommand(void)
{
    // Intentionally empty
}

otCliCommand vendorCommands[] = {
    {"myCommand", HandleMyCommand},
};


/**
 * Set user commands to vendor commands
 *
 * @param[in]  aContext       @p The context passed to the handler.
 *
 */
void vendorCliInit(void)
{
    const uint8_t numCommands = sizeof(vendorCommands)) / (sizeof(otCliCommand);

    otCliSetUserCommands(&radioUrlCommand, numCommands, &config.mPlatformConfig);
}
