import 'package:flutter/material.dart';
import 'package:spool/parts/responsive_helper.dart';

enum ErrorType {
  general,
  network,
  auth,
  data,
  permission,
}

class ErrorPage extends StatelessWidget {
  final String message;
  final ErrorType errorType;
  final VoidCallback? onRetry;

  const ErrorPage({
    Key? key,
    required this.message,
    this.errorType = ErrorType.general,
    this.onRetry,
  }) : super(key: key);

  String _getTitle() {
    switch (errorType) {
      case ErrorType.network:
        return 'Bağlantı Hatası';
      case ErrorType.auth:
        return 'Yetkilendirme Hatası';
      case ErrorType.data:
        return 'Veri Hatası';
      case ErrorType.permission:
        return 'Erişim Engellendi';
      case ErrorType.general:
      default:
        return 'Bir hata oluştu';
    }
  }

  IconData _getIcon() {
    switch (errorType) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.auth:
        return Icons.lock_outline;
      case ErrorType.data:
        return Icons.storage;
      case ErrorType.permission:
        return Icons.block;
      case ErrorType.general:
      default:
        return Icons.error;
    }
  }

  Color _getColor() {
    switch (errorType) {
      case ErrorType.network:
        return Colors.blueGrey;
      case ErrorType.auth:
        return Colors.orange;
      case ErrorType.data:
        return Colors.deepPurple;
      case ErrorType.permission:
        return Colors.amber;
      case ErrorType.general:
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    double padding = ResponsiveHelper.getResponsiveWidth(context, 24);
    double iconSize = ResponsiveHelper.getResponsiveWidth(context, 64);
    double titleFont = ResponsiveHelper.getResponsiveFontSize(context, 20);
    double messageFont = ResponsiveHelper.getResponsiveFontSize(context, 16);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(_getTitle()), backgroundColor: _getColor()),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(_getIcon(), color: _getColor(), size: iconSize),
              SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 20)),
              Text(
                _getTitle(),
                style: TextStyle(fontSize: titleFont, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 10)),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: messageFont, color: Colors.black54),
              ),
              SizedBox(height: ResponsiveHelper.getResponsiveHeight(context, 20)),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Geri Dön'),
                  ),
                  if (onRetry != null) ...[
                    SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tekrar Dene'),
                      style: ElevatedButton.styleFrom(backgroundColor: _getColor()),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
