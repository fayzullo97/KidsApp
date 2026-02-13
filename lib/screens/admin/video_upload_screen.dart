import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';

class VideoUploadScreen extends ConsumerStatefulWidget {
  const VideoUploadScreen({super.key});

  @override
  ConsumerState<VideoUploadScreen> createState() => _VideoUploadScreenState();
}

class _VideoUploadScreenState extends ConsumerState<VideoUploadScreen> {
  PlatformFile? _selectedFile;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result != null) {
        setState(() {
          _selectedFile = result.files.first;
        });
      }
    } catch (e) {
      print('Error picking file: $e');
    }
  }

  Future<void> _uploadVideo() async {
    if (_selectedFile == null) return;

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    // SIMULATED UPLOAD for MVP
    // In production, this would use Supabase Edge Function to get presigned URL
    // and upload directly to R2.
    for (int i = 0; i <= 10; i++) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (mounted) {
        setState(() {
          _uploadProgress = i / 10;
        });
      }
    }

    if (mounted) {
      setState(() {
        _isUploading = false;
        _selectedFile = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video uploaded successfully (Simulated)')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload Video',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
             const SizedBox(height: 8),
            const Text(
              'Select a video mp4 file to upload to Cloudflare R2.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            
            // Topic/Unit Selectors would go here
            
            Center(
              child: Container(
                width: 400,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.grey.shade50,
                ),
                child: Column(
                  children: [
                    if (_selectedFile != null) ...[
                      const Icon(Icons.movie, size: 64, color: Colors.blue),
                      const SizedBox(height: 16),
                      Text(
                        _selectedFile!.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      Text('${(_selectedFile!.size / 1024 / 1024).toStringAsFixed(2)} MB'),
                      const SizedBox(height: 24),
                      if (_isUploading)
                        Column(
                          children: [
                            LinearProgressIndicator(value: _uploadProgress),
                            const SizedBox(height: 8),
                            Text('${(_uploadProgress * 100).toInt()}%'),
                          ],
                        )
                      else
                        ElevatedButton.icon(
                          onPressed: _uploadVideo,
                          icon: const Icon(Icons.cloud_upload),
                          label: const Text('Start Upload'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          ),
                        ),
                      
                      if (!_isUploading)
                        TextButton(
                          onPressed: () => setState(() => _selectedFile = null),
                          child: const Text('Cancel'),
                        ),
                    ] else ...[
                      const Icon(Icons.cloud_upload_outlined, size: 64, color: Colors.grey),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _pickFile,
                        child: const Text('Select Video File'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
