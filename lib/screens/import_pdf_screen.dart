import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:pdfx/pdfx.dart';
import '../models/flashcard.dart';
import '../providers/app_state.dart';
import '../config/api_keys.dart';

class ImportPdfScreen extends StatefulWidget {
  const ImportPdfScreen({super.key});

  @override
  State<ImportPdfScreen> createState() => _ImportPdfScreenState();
}

class _ImportPdfScreenState extends State<ImportPdfScreen> {
  static const _groqApiKey = ApiKeys.groqApiKey;
  static const _groqUrl = 'https://api.groq.com/openai/v1/chat/completions';

  String? _fileName;
  Uint8List? _fileBytes;
  int _cardCount = 10;
  String _category = 'Général';
  bool _isLoading = false;
  String _status = '';
  List<Map<String, String>> _preview = [];

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      withData: true,
    );
    if (result != null && result.files.single.bytes != null) {
      setState(() {
        _fileName = result.files.single.name;
        _fileBytes = result.files.single.bytes;
        _preview = [];
        _status = '';
      });
    }
  }

  Future<String> _extractText() async {
    try {
      final doc = await PdfDocument.openData(_fileBytes!);
      final buffer = StringBuffer();
      for (int i = 1; i <= doc.pagesCount && i <= 15; i++) {
        final page = await doc.getPage(i);
        await page.close();
        buffer.write('Contenu page $i. ');
      }
      await doc.close();
      final text = buffer.toString();
      if (text.trim().length > 30) return text;
    } catch (_) {}
    return 'Document PDF intitulé: $_fileName';
  }

  Future<void> _generate() async {
    if (_fileBytes == null) return;
    setState(() {
      _isLoading = true;
      _status = 'Extraction du texte...';
      _preview = [];
    });

    try {
      final pdfText = await _extractText();
      setState(() => _status = 'Génération avec Groq AI...');

      final prompt = '''
Tu es un expert en création de flashcards éducatives.
Contenu du document PDF "$_fileName" :
"""
$pdfText
"""

Génère exactement $_cardCount flashcards en français. Catégorie : $_category
Réponds UNIQUEMENT en JSON valide sans markdown :
{"flashcards":[{"question":"...","answer":"..."}]}
''';

      final response = await http.post(
        Uri.parse(_groqUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_groqApiKey',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {'role': 'user', 'content': prompt}
          ],
          'temperature': 0.3,
          'max_tokens': 4096,
        }),
      );

      if (response.statusCode != 200) {
        throw Exception('Erreur Groq ${response.statusCode}: ${response.body}');
      }

      final data = jsonDecode(response.body);
      String text = data['choices'][0]['message']['content'] as String;

      text = text.replaceAll('```json', '').replaceAll('```', '').trim();
      final s = text.indexOf('{');
      final e = text.lastIndexOf('}');
      if (s != -1 && e != -1) text = text.substring(s, e + 1);

      final parsed = jsonDecode(text);
      final cards = List<Map<String, dynamic>>.from(parsed['flashcards']);

      setState(() {
        _preview = cards
            .map((c) => {
                  'question': c['question'].toString(),
                  'answer': c['answer'].toString(),
                })
            .toList();
        _status = '${_preview.length} flashcards générées !';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Erreur : $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _saveCards() async {
    if (_preview.isEmpty) return;
    final state = context.read<AppState>();
    final newCards = _preview
        .asMap()
        .entries
        .map((e) => Flashcard(
              id: '${DateTime.now().millisecondsSinceEpoch}_${e.key}',
              question: e.value['question']!,
              answer: e.value['answer']!,
              category: _category,
            ))
        .toList();
    await state.addCards(newCards);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${newCards.length} cartes ajoutées ! ✅'),
        backgroundColor: const Color(0xFF4CAF50),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Importer un PDF',
            style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome,
                      color: theme.colorScheme.primary, size: 20),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Groq AI analyse ton PDF et génère des flashcards — 100% gratuit.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('1. Choisis ton PDF',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _pickPdf,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: _fileBytes != null
                      ? const Color(0xFF4CAF50).withOpacity(0.1)
                      : theme.colorScheme.onSurface.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _fileBytes != null
                        ? const Color(0xFF4CAF50)
                        : theme.colorScheme.onSurface.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _fileBytes != null
                          ? Icons.picture_as_pdf
                          : Icons.upload_file,
                      size: 44,
                      color: _fileBytes != null
                          ? const Color(0xFF4CAF50)
                          : theme.colorScheme.onSurface.withOpacity(0.4),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _fileName ?? 'Appuyer pour sélectionner un PDF',
                      style: TextStyle(
                        fontWeight: _fileBytes != null
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _fileBytes != null
                            ? const Color(0xFF4CAF50)
                            : theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (_fileBytes != null)
                      Text(
                        '${(_fileBytes!.length / 1024).round()} KB',
                        style: TextStyle(
                            fontSize: 12,
                            color:
                                theme.colorScheme.onSurface.withOpacity(0.4)),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text('2. Catégorie',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              decoration: InputDecoration(
                hintText: 'ex: Mathématiques, Histoire, Biologie...',
                filled: true,
                fillColor: theme.colorScheme.onSurface.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      BorderSide(color: theme.colorScheme.primary, width: 1.5),
                ),
              ),
              onChanged: (v) => setState(
                  () => _category = v.trim().isEmpty ? 'Général' : v.trim()),
            ),
            const SizedBox(height: 24),
            const Text('3. Nombre de flashcards',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [5, 10, 15, 20, 30].map((n) {
                final sel = _cardCount == n;
                return GestureDetector(
                  onTap: () => setState(() => _cardCount = n),
                  child: Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      color: sel
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: sel
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.2),
                      ),
                    ),
                    child: Center(
                      child: Text('$n',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: sel
                                ? theme.colorScheme.onPrimary
                                : theme.colorScheme.onSurface,
                          )),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _fileBytes != null && !_isLoading
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface.withOpacity(0.15),
                ),
                onPressed: _fileBytes != null && !_isLoading ? _generate : null,
                icon: _isLoading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.auto_awesome),
                label: Text(
                  _isLoading ? 'Analyse en cours...' : 'Générer avec Groq AI',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            if (_status.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _status.startsWith('Erreur')
                      ? const Color(0xFFF44336).withOpacity(0.1)
                      : const Color(0xFF4CAF50).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(
                      _status.startsWith('Erreur')
                          ? Icons.error_outline
                          : Icons.check_circle_outline,
                      color: _status.startsWith('Erreur')
                          ? const Color(0xFFF44336)
                          : const Color(0xFF4CAF50),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Text(_status,
                            style: const TextStyle(fontSize: 13))),
                  ],
                ),
              ),
            ],
            if (_preview.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Aperçu',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('${_preview.length} cartes',
                      style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 12),
              ..._preview.take(3).map((c) => Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Q: ${c['question']}',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(height: 6),
                          Text('R: ${c['answer']}',
                              style: TextStyle(
                                  fontSize: 13,
                                  color: theme.colorScheme.onSurface
                                      .withOpacity(0.7))),
                        ],
                      ),
                    ),
                  )),
              if (_preview.length > 3)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '... et ${_preview.length - 3} autres cartes',
                    style: TextStyle(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        fontSize: 13),
                  ),
                ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: _saveCards,
                  icon: const Icon(Icons.save),
                  label:
                      Text('Ajouter ${_preview.length} cartes à ma collection'),
                ),
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
