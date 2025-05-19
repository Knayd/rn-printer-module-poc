const { withAppBuildGradle, withInfoPlist } = require("@expo/config-plugins");

function withMySDK(config, options = {}) {
  return withInfoPlist(config, (config) => {
    console.log("✅ withMySDK plugin applied (iOS Info.plist)");

    config.modResults.NSLocalNetworkUsageDescription =
      "Use Local Network for communication with the printer or discovery the printers";

    config.modResults.NSBluetoothAlwaysUsageDescription =
      "Use Bluetooth for communication with the printer";

    config.modResults.UISupportedExternalAccessoryProtocols = [
      "jp.star-m.starpro",
    ];

    return config;
  });
}

module.exports = withMySDK;
