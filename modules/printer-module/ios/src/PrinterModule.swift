import ExpoModulesCore
import StarIO10

public class PrinterModule: Module, StarDeviceDiscoveryManagerDelegate {

    private var manager: StarDeviceDiscoveryManager? = nil
    private var devices: String = "Initial value"

    public func definition() -> ModuleDefinition {
        Name("PrinterModule")

        Events("onDeviceFound")

        Function("getDevices") { () -> String in
            devices
        }

        Function("onScan") { () -> Void in
            sendDeviceFoundEvent(valueToAppend: "Scan starting...")
            do {
                try manager = StarDeviceDiscoveryManagerFactory.create(
                    interfaceTypes: [InterfaceType.bluetooth])
                manager?.discoveryTime = 1000
                manager?.delegate = self

                try manager?.startDiscovery()
            } catch let error {
                print("Error \(error)")
            }
        }
    }

    public func manager(
        _ manager: any StarIO10.StarDeviceDiscoveryManager,
        didFind printer: StarIO10.StarPrinter
    ) {
        let interfaceType = printer.connectionSettings.interfaceType
        let identifier = printer.connectionSettings.identifier

        sendDeviceFoundEvent(valueToAppend: "\(interfaceType): \(identifier)")
    }

    public func managerDidFinishDiscovery(
        _ manager: any StarIO10.StarDeviceDiscoveryManager
    ) {
        sendDeviceFoundEvent(valueToAppend: "Scan finished")
    }

    public func sendDeviceFoundEvent(valueToAppend: String) {
        devices.append("\n\(valueToAppend)")
        sendEvent("onDeviceFound", ["devices": devices])
    }
}
