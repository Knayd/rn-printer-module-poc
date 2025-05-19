import { NativeModule, requireNativeModule } from "expo";

import { PrinterModuleEvents } from "./PrinterModule.types";

declare class PrinterModule extends NativeModule<PrinterModuleEvents> {
  onScan(): void;
  getDevices(): string;
  onPrint(): void;
}

// This call loads the native module object from the JSI.
export default requireNativeModule<PrinterModule>("PrinterModule");
