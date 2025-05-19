export type PrinterModuleEvents = {
  onDeviceFound: (params: OnDeviceFoundPayload) => void;
};

export type OnDeviceFoundPayload = {
  devices: string;
};
