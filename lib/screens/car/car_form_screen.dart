import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/car_model.dart';
import '../../services/car_service.dart';
import '../../widgets/input_field.dart';
import '../../widgets/dropdown_field.dart';

/// Add or edit a car.
class CarFormScreen extends StatefulWidget {
  const CarFormScreen({super.key});

  @override
  State<CarFormScreen> createState() => _CarFormScreenState();
}

class _CarFormScreenState extends State<CarFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _carService = CarService();

  final _vehicleNumberCtrl = TextEditingController();
  final _currentKmCtrl = TextEditingController();
  final _nextServiceKmCtrl = TextEditingController();
  final _fcExpiryCtrl = TextEditingController();
  final _insuranceExpiryCtrl = TextEditingController();
  final _pucExpiryCtrl = TextEditingController();
  String _vehicleType = AppConstants.vehicleTypes.first;

  CarModel? _existing;
  bool _isEdit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is CarModel && !_isEdit) {
      _existing = arg;
      _isEdit = true;
      _vehicleNumberCtrl.text = arg.vehicleNumber;
      _vehicleType = arg.vehicleType;
      _currentKmCtrl.text = arg.currentKm.toStringAsFixed(0);
      _nextServiceKmCtrl.text = arg.nextServiceKm.toStringAsFixed(0);
      _fcExpiryCtrl.text = arg.fcExpiryDate;
      _insuranceExpiryCtrl.text = arg.insuranceExpiryDate;
      _pucExpiryCtrl.text = arg.pucExpiryDate;
    }
  }

  Future<void> _pickDate(TextEditingController ctrl) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      ctrl.text = picked.toIso8601String().split('T').first;
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final car = CarModel(
      id: _existing?.id,
      vehicleNumber: _vehicleNumberCtrl.text.trim(),
      vehicleType: _vehicleType,
      currentKm: double.tryParse(_currentKmCtrl.text) ?? 0,
      nextServiceKm: double.tryParse(_nextServiceKmCtrl.text) ?? 0,
      fcExpiryDate: _fcExpiryCtrl.text.trim(),
      insuranceExpiryDate: _insuranceExpiryCtrl.text.trim(),
      pucExpiryDate: _pucExpiryCtrl.text.trim(),
    );

    if (_existing != null) {
      await _carService.updateCar(car);
    } else {
      await _carService.addCar(car);
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _delete() async {
    if (_existing == null) return;
    await _carService.deleteCar(_existing!.id!);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_existing != null ? 'Edit Car' : 'Add Car'),
        actions: [
          if (_existing != null)
            IconButton(icon: const Icon(Icons.delete), onPressed: _delete),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              InputField(
                label: 'Vehicle Number',
                controller: _vehicleNumberCtrl,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              DropdownField<String>(
                label: 'Vehicle Type',
                value: _vehicleType,
                items: AppConstants.vehicleTypes
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) => setState(() => _vehicleType = v!),
              ),
              InputField(
                label: 'Current KM',
                controller: _currentKmCtrl,
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              InputField(
                label: 'Next Service KM',
                controller: _nextServiceKmCtrl,
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              InputField(
                label: 'FC Expiry Date',
                controller: _fcExpiryCtrl,
                readOnly: true,
                onTap: () => _pickDate(_fcExpiryCtrl),
                suffixIcon: const Icon(Icons.calendar_today),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              InputField(
                label: 'Insurance Expiry Date',
                controller: _insuranceExpiryCtrl,
                readOnly: true,
                onTap: () => _pickDate(_insuranceExpiryCtrl),
                suffixIcon: const Icon(Icons.calendar_today),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              InputField(
                label: 'PUC Expiry Date',
                controller: _pucExpiryCtrl,
                readOnly: true,
                onTap: () => _pickDate(_pucExpiryCtrl),
                suffixIcon: const Icon(Icons.calendar_today),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(_existing != null ? 'Update' : 'Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
