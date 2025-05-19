import ExpoModulesCore
import StarIO10

public class PrinterModule: Module, StarDeviceDiscoveryManagerDelegate {

    private var manager: StarDeviceDiscoveryManager? = nil
    private var devices: String = "Initial value"
    private var printer: StarPrinter? = nil

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
                    interfaceTypes: [
                        InterfaceType.bluetooth, InterfaceType.bluetoothLE,
                    ])
                manager?.discoveryTime = 15000
                manager?.delegate = self

                try manager?.startDiscovery()
            } catch let error {
                print("Error \(error)")
            }
        }

        Function("onPrint") { () -> Void in
            printData()
        }
    }

    public func manager(
        _ manager: any StarIO10.StarDeviceDiscoveryManager,
        didFind printer: StarIO10.StarPrinter
    ) {
        let interfaceType = printer.connectionSettings.interfaceType
        let identifier = printer.connectionSettings.identifier

        sendDeviceFoundEvent(valueToAppend: "\(interfaceType): \(identifier)")
        self.printer = printer
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

    public func printData() {
        let commands = LabelSample02_DrinkLabel.createDrinkLabel()

        Task {
            do {
                try await printer?.open()
            } catch let error {
                print(error)
                return
            }

            do {
                defer {
                    Task {
                        await printer?.close()
                    }
                }

                try await printer?.print(command: commands)
            } catch StarIO10Error.unprintable(
                message: let message, errorCode: let errorCode,
                status: let status)
            {
                // If an error occurs and the print process fails, the StarIO10Error.unprintable is thrown.
                // More detailed error information may be obtained with the errorCode property.
                switch errorCode {
                case .deviceHasError:
                    // An error (e.g. paper empty or cover open) has occurred in the printer.
                    // Please retry after resolving the printer error.
                    print(
                        "An error (e.g. paper empty or cover open) has occurred in the printer."
                    )
                case .printerHoldingPaper:
                    // The printer is holding paper.
                    // Remove the pre-printed paper and printing will begin.
                    print("The printer is holding paper.")
                default:
                    // Other errors occurred.
                    print("Other errors occurred.")
                }
            } catch let error {
                // Catch other exceptions.
            }
        }
    }
}

class LabelSample02_DrinkLabel {
    static func createDrinkLabel() -> String {
        let builder = StarXpandCommand.StarXpandCommandBuilder()
        
        _ = builder.addDocument(StarXpandCommand.DocumentBuilder()
            .addPrinter(
                StarXpandCommand.PrinterBuilder()
                    .styleBold(true)
                    .actionPrintText(
                        "Item:   1 of 3\n"
                    )
                    .add(
                        StarXpandCommand.PrinterBuilder()
                            .styleMagnification(StarXpandCommand.MagnificationParameter(width: 1, height: 2))
                            .actionPrintText(
                                "* Jane Smith *\n" +
                                "Gr Icd Coffee\n"
                            )
                    )
                    .actionPrintText(
                        "No Classic\n" +
                        "With Whole Milk\n" +
                        "\n" +
                        "Time:   4:14:29 PM\n" +
                        "Reg:    9\n" +
                        "\n" +
                        "--------------------------------\n"
                    )
                    .add(
                        StarXpandCommand.PrinterBuilder()
                            .styleBold(true)
                            .actionPrintText(
                                ">MOBILE<\n"
                            )
                    )
                    .actionPrintText(
                        "--------------------------------\n"
                    )
                    .actionCut(.partial)
            )
        )
        
        return builder.getCommands()
    }
}
