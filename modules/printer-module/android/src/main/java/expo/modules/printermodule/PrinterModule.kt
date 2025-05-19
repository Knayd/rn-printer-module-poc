package expo.modules.printermodule

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import com.starmicronics.stario10.InterfaceType
import com.starmicronics.stario10.StarDeviceDiscoveryManager
import com.starmicronics.stario10.StarDeviceDiscoveryManagerFactory
import com.starmicronics.stario10.StarPrinter
import expo.modules.kotlin.modules.Module
import expo.modules.kotlin.modules.ModuleDefinition

class PrinterModule : Module() {

    private var manager: StarDeviceDiscoveryManager? = null
    private var devices: String = "Initial value"

    companion object {
        private const val TAG = "PrinterModule"
    }

    override fun definition() = ModuleDefinition {
        Name("PrinterModule")

        Events("onDeviceFound")

        Function("getDevices") {
            devices
        }

        Function("onScan") {
            sendOnDeviceFoundEvent("Scan starting...")
            if (hasBluetoothPermission()) {
                try {
                    manager?.stopDiscovery()

                    appContext.reactContext?.let { context ->
                        manager = StarDeviceDiscoveryManagerFactory.create(listOf(InterfaceType.Bluetooth), context).apply {
                            discoveryTime = 1000
                            callback = object : StarDeviceDiscoveryManager.Callback {

                                override fun onPrinterFound(printer: StarPrinter) {
                                    sendOnDeviceFoundEvent("${printer.connectionSettings.interfaceType}:${printer.connectionSettings.identifier}")
                                }

                                override fun onDiscoveryFinished() {
                                    sendOnDeviceFoundEvent("Discovery finished.")
                                }
                            }
                            startDiscovery()
                        }
                    }
                } catch (e: Exception) {
                    Log.d(TAG, "Error: $e")
                }
            } else {
                requestBluetoothPermission()
            }
        }
    }

    private fun requestBluetoothPermission() {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            return
        }

        appContext.currentActivity?.apply {
            if (checkSelfPermission(Manifest.permission.BLUETOOTH_CONNECT) != PackageManager.PERMISSION_GRANTED) {
                requestPermissions(
                    arrayOf(Manifest.permission.BLUETOOTH_CONNECT), 10000
                )
            }
        }
    }

    private fun hasBluetoothPermission(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.S) {
            return true
        }

        return appContext.currentActivity?.checkSelfPermission(Manifest.permission.BLUETOOTH_CONNECT) == PackageManager.PERMISSION_GRANTED
    }

    fun sendOnDeviceFoundEvent(valueToAppend: String) {
        devices += "\n$valueToAppend"
        sendEvent("onDeviceFound", mapOf("devices" to devices))
    }
}
