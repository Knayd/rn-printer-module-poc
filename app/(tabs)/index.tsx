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
      <View
        style={{
          flex: 1,
          alignItems: "center",
          justifyContent: "center",
        }}
      >
        <Text>Printers:</Text>
        <Text>{devices}</Text>
        <Button title="Scan" onPress={() => PrinterModule.onScan()} />
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  titleContainer: {
    flexDirection: "row",
    alignItems: "center",
    gap: 8,
  },
  stepContainer: {
    gap: 8,
    marginBottom: 8,
  },
  reactLogo: {
    height: 178,
    width: 290,
    bottom: 0,
    left: 0,
    position: "absolute",
  },
});
