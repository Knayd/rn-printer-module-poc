import { Button, SafeAreaView, StyleSheet, Text, View } from "react-native";

import PrinterModule from "@/modules/printer-module/src/PrinterModule";
import { useEventListener } from "expo";
import { useState } from "react";

export default function HomeScreen() {
  const [devices, setDevices] = useState<string>(PrinterModule.getDevices());

  useEventListener(PrinterModule, "onDeviceFound", ({ devices }) => {
    setDevices(devices);
  });

  return (
    <SafeAreaView style={{ flex: 1 }}>
      <View style={styles.container}>
        <Text style={styles.text}>Printers:</Text>
        <Text style={styles.text}>{devices}</Text>
        <Button title="Scan" onPress={() => PrinterModule.onScan()} />
        <Button title="Print" onPress={() => PrinterModule.onPrint()} />
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
  },
  text: {
    color: "gray",
  },
});
