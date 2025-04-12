import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gearcare/localStorage/firebase_auth_service.dart';
import 'package:gearcare/models/rental_history_model.dart';
import 'package:gearcare/theme.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:signature/signature.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

class RentalBillScreen extends StatefulWidget {
  final RentalRecord rental;

  const RentalBillScreen({Key? key, required this.rental}) : super(key: key);

  @override
  State<RentalBillScreen> createState() => _RentalBillScreenState();
}

class _RentalBillScreenState extends State<RentalBillScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController companyNameController;
  late TextEditingController customerNameController;
  bool hasSignature = false;
  Uint8List? signatureImage;
  DateTime selectedDate = DateTime.now();
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );
  final FirebaseAuthService _authService = FirebaseAuthService();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    companyNameController = TextEditingController(text: 'GearCare');
    customerNameController = TextEditingController(text: 'Valued Customer');
    selectedDate = widget.rental.rentalDate;
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userName = prefs.getString('name');

      if (userName != null && userName.isNotEmpty) {
        setState(() {
          customerNameController.text = userName;
        });
      } else {
        // If name not in SharedPreferences, try to get from Firestore
        try {
          final userData = await _authService.getUserData();
          if (userData.containsKey('name') && userData['name'] != null) {
            setState(() {
              customerNameController.text = userData['name'];
            });
          }
        } catch (e) {
          // If Firestore fetch fails, keep the default value
          print('Error fetching user data from Firestore: $e');
        }
      }
    } catch (e) {
      print('Error loading user profile: $e');
    }
  }

  Future<void> pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> handleSignature() async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Add Signature'),
            content: SizedBox(
              height: 200,
              child: Signature(
                controller: _signatureController,
                backgroundColor: Colors.grey[200]!,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  _signatureController.clear();
                  Navigator.of(context).pop();
                },
                child: const Text('Clear'),
              ),
              TextButton(
                onPressed: () async {
                  if (_signatureController.isNotEmpty) {
                    final exportedImage =
                        await _signatureController.toPngBytes();
                    setState(() {
                      signatureImage = exportedImage;
                      hasSignature = true;
                    });
                  }
                  Navigator.of(context).pop();
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  double get total => widget.rental.totalCost;

  Future<void> createPDF() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final pdf = pw.Document();
      final font = pw.Font.helvetica();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            final DateTime endDate = widget.rental.rentalDate.add(
              Duration(days: widget.rental.duration),
            );
            final dateFormat = DateFormat('yyyy-MM-dd');

            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  ' ${companyNameController.text}',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Customer: ${customerNameController.text}',
                      style: pw.TextStyle(fontSize: 18),
                    ),
                    pw.Text(
                      'Date: ${dateFormat.format(selectedDate)}',
                      style: pw.TextStyle(fontSize: 18),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Text(
                  'Rental Invoice',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 20),
                pw.Table(
                  border: pw.TableBorder.all(),
                  children: [
                    pw.TableRow(
                      decoration: pw.BoxDecoration(color: PdfColors.grey300),
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Item',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Rental Period',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Price/Day',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(
                            'Total Price',
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(widget.rental.productName),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(
                            '${dateFormat.format(widget.rental.rentalDate)} to ${dateFormat.format(endDate)}',
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(
                            '${widget.rental.price.toStringAsFixed(2)}',
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Text(
                            '${widget.rental.totalCost.toStringAsFixed(2)}',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  children: [
                    pw.Expanded(child: pw.Container()),
                    pw.Container(
                      padding: pw.EdgeInsets.all(10),
                      decoration: pw.BoxDecoration(border: pw.Border.all()),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                'Duration:',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.SizedBox(width: 20),
                              pw.Text('${widget.rental.duration} days'),
                            ],
                          ),
                          pw.SizedBox(height: 5),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                'Total:',
                                style: pw.TextStyle(
                                  fontWeight: pw.FontWeight.bold,
                                ),
                              ),
                              pw.SizedBox(width: 20),
                              pw.Text(
                                '${widget.rental.totalCost.toStringAsFixed(2)}',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 50),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      children: [
                        hasSignature && signatureImage != null
                            ? pw.Container(
                              width: 150,
                              height: 70,
                              child: pw.Image(pw.MemoryImage(signatureImage!)),
                            )
                            : pw.Container(
                              width: 150,
                              height: 50,
                              decoration: pw.BoxDecoration(
                                border: pw.Border(bottom: pw.BorderSide()),
                              ),
                            ),
                        pw.SizedBox(height: 5),
                        pw.Text('Authorized Signature'),
                        pw.SizedBox(height: 5),
                        pw.Text(
                          'Verified by GearCare ✓',
                          style: pw.TextStyle(
                            fontStyle: pw.FontStyle.italic,
                            color: PdfColors.green800,
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 30),
                pw.Divider(),
                pw.SizedBox(height: 10),
                pw.Text(
                  'Payment Information:',
                  style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 5),
                pw.Text('Transaction ID: ${widget.rental.id}'),
                pw.Text('Payment Status: Paid'),
                pw.SizedBox(height: 20),
                pw.Center(
                  child: pw.Text(
                    'Thank you for choosing GearCare!',
                    style: pw.TextStyle(
                      fontStyle: pw.FontStyle.italic,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Save to a more accessible location (the Downloads directory)
      Directory? directory;

      try {
        // First try to get the downloads directory
        if (Platform.isAndroid) {
          directory = Directory('/storage/emulated/0/Download');
          // Check if the directory exists, if not create it
          if (!await directory.exists()) {
            await directory.create(recursive: true);
          }
        } else {
          // For iOS or other platforms, use the temp directory
          directory = await getTemporaryDirectory();
        }
      } catch (e) {
        // Fallback to the app's temporary directory
        directory = await getTemporaryDirectory();
      }

      // Create a unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'gearcare_invoice_${timestamp}.pdf';
      final filePath = path.join(directory.path, fileName);
      final file = File(filePath);

      await file.writeAsBytes(await pdf.save());

      if (mounted) {
        // First show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF generated successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );

        // Then try to open the file
        try {
          final result = await OpenFile.open(filePath);
          if (result.type != ResultType.done) {
            _showFileLocationDialog(filePath);
          }
        } catch (e) {
          _showFileLocationDialog(filePath);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      print('Error generating PDF: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showFileLocationDialog(String filePath) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 10),
                Expanded(child: Text('PDF Saved')),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your invoice has been saved to:',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          filePath,
                          style: TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.copy, size: 20),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: filePath));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Path copied to clipboard'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  'Go to your file manager and navigate to this location to open the PDF file.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                if (Platform.isAndroid)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'You can find it in the Downloads folder.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Generate Bill'),
        backgroundColor: AppTheme.backgroundColor,
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder:
              (context, constraints) => SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: companyNameController,
                        decoration: const InputDecoration(
                          labelText: 'Company Name',
                          border: OutlineInputBorder(),
                          enabled: false,
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Enter company name'
                                    : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: customerNameController,
                        decoration: const InputDecoration(
                          labelText: 'Customer Name',
                          border: OutlineInputBorder(),
                          enabled: false,
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? 'Enter customer name'
                                    : null,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Invoice Date: ${DateFormat('yyyy-MM-dd').format(selectedDate)}',
                            ),
                          ),
                          ElevatedButton(
                            onPressed: pickDate,
                            child: const Text('Choose Date'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Signature: ${hasSignature ? 'Added' : 'Not Added'}',
                            ),
                          ),
                          ElevatedButton(
                            onPressed: handleSignature,
                            child: const Text('Add Signature'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Rental Details:',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Product: ${widget.rental.productName}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Duration: ${widget.rental.duration} days',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Price per day: ${widget.rental.price.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Total Cost: ${widget.rental.totalCost.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton.icon(
                        onPressed: _isLoading ? null : createPDF,
                        icon:
                            _isLoading
                                ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Icon(Icons.picture_as_pdf),
                        label: Text(
                          _isLoading ? 'Generating...' : 'Generate PDF Invoice',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    companyNameController.dispose();
    customerNameController.dispose();
    _signatureController.dispose();
    super.dispose();
  }
}
