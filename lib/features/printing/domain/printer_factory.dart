import '../data/drivers/bluetooth_printer_driver.dart';
import '../data/drivers/network_printer_driver.dart';
import '../data/drivers/usb_printer_driver.dart';
import '../data/drivers/windows_system_printer_driver.dart';
import 'printer_service.dart';

class PrinterFactory {
  const PrinterFactory._();

  /// [driverType] matches [PrinterConfig.driverType]: network/usb/bluetooth/windowsSystem.
  static PrinterService create(String driverType, {int paperWidthMm = 58}) {
    final paperWidthChars = paperWidthMm >= 80 ? 48 : 32;
    return switch (driverType) {
      'network' => NetworkPrinterDriver(paperWidthChars: paperWidthChars),
      'usb' => UsbPrinterDriver(),
      'bluetooth' => BluetoothPrinterDriver(),
      'windowsSystem' => WindowsSystemPrinterDriver(paperWidthMm: paperWidthMm),
      _ => WindowsSystemPrinterDriver(paperWidthMm: paperWidthMm),
    };
  }
}
