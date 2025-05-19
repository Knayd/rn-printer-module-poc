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
        let commands = LabelSample01_TamperProofLabel.createTamperProofLabel()

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

class LabelSample01_TamperProofLabel {
    static func createTamperProofLabel() -> String {
        guard
            let checkedImage = UIImage(
                named: "label_sample01_tamper_proof_label_checked.png")
        else {
            print(
                "Failed to load \"label_sample01_tamper_proof_label_checked.png\"."
            )
            return ""
        }

        let builder = StarXpandCommand.StarXpandCommandBuilder()

        _ = builder.addDocument(
            StarXpandCommand.DocumentBuilder()
                .addPrinter(
                    StarXpandCommand.PrinterBuilder()
                        .styleAlignment(.center)
                        .styleBold(true)
                        .styleMagnification(
                            StarXpandCommand.MagnificationParameter(
                                width: 4, height: 4)
                        )
                        .actionPrintText(
                            "SEALED\n"
                        )
                        .actionPrintText(
                            "FRESH\n"
                        )
                        .styleBold(false)
                        .styleMagnification(
                            StarXpandCommand.MagnificationParameter(
                                width: 3, height: 3)
                        )
                        .actionPrintText(
                            "for Safety\n"
                        )
                        .actionPrintImage(
                            StarXpandCommand.Printer.ImageParameter(
                                image: checkedImage, width: 100)
                        )
                        .styleBold(true)
                        .actionPrintText(
                            "................\n"
                        )
                        .styleBold(false)
                        .actionPrintText(
                            "Scan to leave\n"
                        )
                        .actionPrintText(
                            "a review\n"
                        )
                        .actionPrintQRCode(
                            StarXpandCommand.Printer.QRCodeParameter(
                                content: "http://starmicronics.com/"
                            )
                            .setCellSize(8)
                            .setLevel(.q)
                            .setModel(.model2)
                        )
                        .actionCut(.partial)
                )
        )

        return builder.getCommands()
    }
}
