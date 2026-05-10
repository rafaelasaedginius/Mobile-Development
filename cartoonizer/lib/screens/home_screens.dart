import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gal/gal.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/stylizing_services.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StylizingService _service = StylizingService();
  final ImagePicker _picker = ImagePicker();

  File? _inputImage;
  Uint8List? _outputImage;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _service.loadModel();
  }

  @override
  void dispose() {
    _service.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        _showSnackbar('Izin kamera diperlukan');
        return;
      }
    }

    final XFile? picked = await _picker.pickImage(source: source);
    if (picked == null) return;

    setState(() {
      _inputImage = File(picked.path);
      _outputImage = null;
    });
  }

  Future<void> _processImage() async {
    if (_inputImage == null) return;

    setState(() => _isProcessing = true);

    try {
      final result = await _service.transferStyle(_inputImage!);
      setState(() => _outputImage = result);
    } catch (e) {
      _showSnackbar('Gagal memproses gambar: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _saveImage() async {
    if (_outputImage == null) return;
    await Gal.putImageBytes(_outputImage!);
    _showSnackbar('Gambar berhasil disimpan ke galeri!');
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cartoonizer'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: _PickButton(
                    icon: Icons.camera_alt,
                    label: 'Kamera',
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _PickButton(
                    icon: Icons.photo_library,
                    label: 'Galeri',
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),
            if (_inputImage != null) ...[
              const _SectionLabel(text: 'Foto Asli'),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  _inputImage!,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: _isProcessing ? null : _processImage,
                icon: _isProcessing
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.auto_fix_high),
                label: Text(_isProcessing ? 'Styling dalam proses...' : 'Ubah ke Cartoon'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],

            const SizedBox(height: 20),

            if (_outputImage != null) ...[
              const _SectionLabel(text: 'Hasil Cartoon'),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  _outputImage!,
                  height: 250,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),

              ElevatedButton.icon(
                onPressed: _saveImage,
                icon: const Icon(Icons.download),
                label: const Text('Simpan Gambar Ke Galeri'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],

            if (_inputImage == null)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 60),
                child: Column(
                  children: [
                    Icon(Icons.image_outlined, size: 80, color: Colors.grey),
                    SizedBox(height: 12),
                    Text(
                      'Pilih gambar atau gunakan kamera',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PickButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PickButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: Icon(icon),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }
}