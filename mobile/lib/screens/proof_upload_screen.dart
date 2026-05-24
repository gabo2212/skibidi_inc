import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../services/app_controller.dart';
import '../widgets/section_card.dart';

class ProofUploadScreen extends StatefulWidget {
  const ProofUploadScreen({
    super.key,
    required this.controller,
    required this.taskId,
  });

  final AppController controller;
  final String taskId;

  @override
  State<ProofUploadScreen> createState() => _ProofUploadScreenState();
}

class _ProofUploadScreenState extends State<ProofUploadScreen> {
  bool _uploading = false;
  String? _lastResult;

  Future<void> _pickAndUpload() async {
    setState(() {
      _uploading = true;
      _lastResult = null;
    });
    try {
      final result = await FilePicker.platform.pickFiles(withData: true);
      final file = result?.files.single;
      if (file == null || file.bytes == null) {
        setState(() => _lastResult = 'No file selected.');
        return;
      }
      final contentType = file.extension == 'pdf'
          ? 'application/pdf'
          : 'application/octet-stream';
      final session = await widget.controller.requestAttachmentUrl(
        taskId: widget.taskId,
        fileName: file.name,
        contentType: contentType,
        sizeBytes: file.size,
      );
      await widget.controller.uploadAttachment(
        uploadUrl: session.uploadUrl,
        bytes: file.bytes!,
        contentType: contentType,
      );
      setState(() {
        _lastResult =
            'Upload complete for ${file.name}. In preview mode this is a local no-op.';
      });
    } catch (error) {
      setState(() {
        _lastResult = 'Upload failed: $error';
      });
    } finally {
      if (mounted) {
        setState(() => _uploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Proof Upload')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: <Widget>[
          SectionCard(
            title: 'Upload work evidence',
            subtitle:
                'The backend returns a presigned S3 PUT URL, then the mobile client uploads bytes directly to the private bucket.',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                FilledButton.icon(
                  onPressed: _uploading ? null : _pickAndUpload,
                  icon: const Icon(Icons.upload_file),
                  label: Text(_uploading ? 'Uploading...' : 'Choose file'),
                ),
                if (_lastResult != null) ...<Widget>[
                  const SizedBox(height: 14),
                  Text(_lastResult!),
                ],
              ],
            ),
          ),
          SectionCard(
            title: 'Settings snapshot',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('AWS region: ${widget.controller.config.awsRegion}'),
                const SizedBox(height: 8),
                Text(
                  'API base URL: ${widget.controller.config.apiBaseUrl.isEmpty ? 'Not configured yet' : widget.controller.config.apiBaseUrl}',
                ),
                const SizedBox(height: 8),
                Text(
                  'Mode: ${widget.controller.isPreviewMode ? 'Preview' : 'Live AWS'}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
