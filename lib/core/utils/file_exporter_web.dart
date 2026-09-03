import 'dart:js_interop';
import 'dart:typed_data';
import 'package:web/web.dart' as web;

Future<bool> saveAndDownloadFile({
  required Uint8List bytes,
  required String fileName,
  required String mimeType,
}) async {
  try {
    final blobParts = [bytes.toJS].toJS;
    final blobOptions = web.BlobPropertyBag(type: mimeType);
    final blob = web.Blob(blobParts, blobOptions);
    final url = web.URL.createObjectURL(blob);

    final anchor = web.HTMLAnchorElement()
      ..href = url
      ..download = fileName
      ..style.display = 'none';

    web.document.body?.appendChild(anchor);
    anchor.click();
    web.document.body?.removeChild(anchor);
    web.URL.revokeObjectURL(url);
    return true;
  } catch (e) {
    return false;
  }
}
