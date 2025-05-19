// Reexport the native module. On web, it will be resolved to PrinterModule.web.ts
// and on native platforms to PrinterModule.ts
export { default } from "./src/PrinterModule";
export * from "./src/PrinterModule.types";
