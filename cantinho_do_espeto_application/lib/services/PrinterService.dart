import 'package:flutter/material.dart';
import 'package:flutter_pos_printer_platform_image_3/flutter_pos_printer_platform_image_3.dart';
import 'dart:convert' show latin1;

class PrinterService {
  static final PrinterService _instance = PrinterService._internal();
  factory PrinterService() => _instance;
  PrinterService._internal();

  PrinterManager? _printerManager;
  PrinterDevice? _selectedPrinter;
  bool _isConnected = false;
  bool _isInitialized = false;
  

  static const String printerModel = 'Epson-TM-T20X';
  static const int vendorId = 0x04b8;
  static const int productId = 0x0e28; 

  Future<bool> initializePrinter() async {
    if (_isInitialized) return _isConnected;
    
    try {
      debugPrint('Iniciando serviço de impressão para $printerModel...');
      _printerManager = PrinterManager.instance;
      
      if (_printerManager == null) {
        debugPrint('Erro: PrinterManager.instance retornou null');
        return false;
      }
      
      _isInitialized = true;
      debugPrint('Serviço de impressão inicializado com sucesso');
      return true;
    } catch (e, stackTrace) {
      debugPrint('Erro ao inicializar serviço de impressão: $e');
      debugPrint('Stack trace: $stackTrace');
      _isInitialized = false;
      return false;
    }
  }

  
  

  Future<bool> connectToPrinter(BuildContext context) async {
    if (!_isInitialized) {
      debugPrint('Tentando inicializar o serviço antes de conectar...');
      final initialized = await initializePrinter();
      if (!initialized) {
        _showMessage(context, 'Falha ao inicializar serviço de impressão', isError: true);
        return false;
      }
    }

    try {
      debugPrint('Procurando impressora $printerModel...');
      bool printerFound = false;
      
      if (_printerManager == null) {
        _showMessage(context, 'Serviço de impressão não inicializado', isError: true);
        return false;
      }

      await for (var device in _printerManager!.discovery(type: PrinterType.usb)) {
        debugPrint('Impressora encontrada: ${device.name} (VID: ${device.vendorId}, PID: ${device.productId})');
        

        if (device.name.contains(printerModel) ?? false) {
          _selectedPrinter = device;
          printerFound = true;
          break;
        }

      }

      if (!printerFound) {
        debugPrint('Impressora $printerModel não encontrada');
        _showMessage(context, 'Impressora $printerModel não encontrada', isError: true);
        return false;
      }

      debugPrint('Conectando à impressora $printerModel: ${_selectedPrinter?.name}');
      var result = await _printerManager?.connect(
        type: PrinterType.usb,
        model: UsbPrinterInput(
          name: _selectedPrinter!.name ?? printerModel,
            productId: productId.toRadixString(16), // Converte para String hexadecimal
            vendorId: vendorId.toRadixString(16),   // Converte para String hexadecimal
        ),
      );

      _isConnected = result ?? false;
      debugPrint('Status da conexão: ${_isConnected ? 'Conectado' : 'Falha na conexão'}');
      
      _showMessage(
        context,
        _isConnected ? 'Impressora $printerModel conectada' : 'Falha ao conectar impressora $printerModel',
        isError: !_isConnected,
      );
      return _isConnected;
    } catch (e, stackTrace) {
      debugPrint('Erro ao conectar impressora: $e');
      debugPrint('Stack trace: $stackTrace');
      _showMessage(context, 'Erro ao conectar impressora: $e', isError: true);
      return false;
    }
  }

  Future<List<int>> printContent(String content, {bool largeFontMode = true}) async {
    if (!_isConnected || _printerManager == null) {
      throw Exception('Impressora não está conectada');
    }

    try {
      List<int> bytes = [];

      // Comandos específicos para TM-T20X
      bytes.addAll([0x1B, 0x40]); // ESC @ - Initialize printer
      bytes.addAll([0x1B, 0x74, 0x02]); // ESC t - Select character code table (PC852)

      // Configure text size
      if (largeFontMode) {
        bytes.addAll([0x1B, 0x21, 0x20]); // ESC ! - Select print mode (double-height and double-width)
      } else {
        bytes.addAll([0x1B, 0x21, 0x00]); // ESC ! - Select print mode (normal)
      }

      // Add the content
      bytes.addAll(latin1.encode(content));

      // Feed paper and cut
      bytes.addAll([0x0A, 0x0A, 0x0A]); // Line feeds
      bytes.addAll([0x1D, 0x56, 0x41, 0x00]); // GS V A - Full cut

      debugPrint('Enviando dados para impressora $printerModel...');
      await _printerManager?.send(type: PrinterType.usb, bytes: bytes);
      debugPrint('Dados enviados com sucesso');

      return bytes;
    } catch (e, stackTrace) {
      debugPrint('Erro ao imprimir: $e');
      debugPrint('Stack trace: $stackTrace');
      throw Exception('Falha ao imprimir: $e');
    }
  }
    void _showMessage(BuildContext context, String message, {bool isError = false}) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: isError ? Colors.red : Colors.green,
          ),
        );
      }
  }

  Future<void> disconnect() async {
    if (_isConnected && _printerManager != null) {
      try {
        await _printerManager?.disconnect(type: PrinterType.usb);
        _isConnected = false;
        debugPrint('Impressora $printerModel desconectada com sucesso');
      } catch (e) {
        debugPrint('Erro ao desconectar impressora: $e');
      }
    }
  }

  bool get isConnected => _isConnected;
}