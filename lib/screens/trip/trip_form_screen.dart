import 'package:flutter/material.dart';
import '../../core/constants.dart';
import '../../models/trip_model.dart';
import '../../models/car_model.dart';
import '../../models/user_model.dart';
import '../../models/advance_model.dart';
import '../../services/trip_service.dart';
import '../../services/car_service.dart';
import '../../services/user_service.dart';
import '../../widgets/input_field.dart';
import '../../widgets/dropdown_field.dart';

/// Create or edit a trip/booking.
class TripFormScreen extends StatefulWidget {
  const TripFormScreen({super.key});

  @override
  State<TripFormScreen> createState() => _TripFormScreenState();
}

class _TripFormScreenState extends State<TripFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tripService = TripService();
  final _carService = CarService();
  final _userService = UserService();

  final _pickupDateCtrl = TextEditingController();
  final _pickupTimeCtrl = TextEditingController();
  final _pickupLocationCtrl = TextEditingController();
  final _daysCtrl = TextEditingController();
  final _placesCtrl = TextEditingController();

  // Charges
  final _tollCtrl = TextEditingController(text: '0');
  final _permitCtrl = TextEditingController(text: '0');
  final _parkingCtrl = TextEditingController(text: '0');
  final _otherChargesCtrl = TextEditingController(text: '0');

  // Advance
  final _advanceAmountCtrl = TextEditingController();
  String _advanceType = AppConstants.advanceBooking;

  List<CarModel> _cars = [];
  List<UserModel> _drivers = [];
  String? _selectedCarId;
  String? _selectedDriverId;
  TripModel? _existing;
  bool _isEdit = false;
  List<AdvanceModel> _advances = [];

  @override
  void initState() {
    super.initState();
    _loadDropdownData();
  }

  Future<void> _loadDropdownData() async {
    _cars = await _carService.getAllCars();
    _drivers = await _userService.getUsersByRole(AppConstants.roleDriver);
    setState(() {});
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arg = ModalRoute.of(context)?.settings.arguments;
    if (arg is TripModel && !_isEdit) {
      _existing = arg;
      _isEdit = true;
      _pickupDateCtrl.text = arg.pickupDate;
      _pickupTimeCtrl.text = arg.pickupTime;
      _pickupLocationCtrl.text = arg.pickupLocation;
      _daysCtrl.text = arg.numberOfDays.toString();
      _placesCtrl.text = arg.placesToVisit;
      _selectedCarId = arg.carId;
      _selectedDriverId = arg.driverId;
      _tollCtrl.text = arg.toll.toStringAsFixed(0);
      _permitCtrl.text = arg.permit.toStringAsFixed(0);
      _parkingCtrl.text = arg.parking.toStringAsFixed(0);
      _otherChargesCtrl.text = arg.otherCharges.toStringAsFixed(0);
      _loadAdvances(arg.id!);
    }
  }

  Future<void> _loadAdvances(String tripId) async {
    _advances = await _tripService.getAdvancesForTrip(tripId);
    setState(() {});
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (picked != null) {
      _pickupDateCtrl.text = picked.toIso8601String().split('T').first;
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && mounted) {
      _pickupTimeCtrl.text = picked.format(context);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final trip = TripModel(
      id: _existing?.id,
      pickupDate: _pickupDateCtrl.text.trim(),
      pickupTime: _pickupTimeCtrl.text.trim(),
      pickupLocation: _pickupLocationCtrl.text.trim(),
      numberOfDays: int.tryParse(_daysCtrl.text) ?? 1,
      placesToVisit: _placesCtrl.text.trim(),
      carId: _selectedCarId,
      driverId: _selectedDriverId,
      status: _existing?.status ?? AppConstants.tripCreated,
      startTime: _existing?.startTime,
      startingKm: _existing?.startingKm,
      endTime: _existing?.endTime,
      endingKm: _existing?.endingKm,
      toll: double.tryParse(_tollCtrl.text) ?? 0,
      permit: double.tryParse(_permitCtrl.text) ?? 0,
      parking: double.tryParse(_parkingCtrl.text) ?? 0,
      otherCharges: double.tryParse(_otherChargesCtrl.text) ?? 0,
    );

    if (_existing != null) {
      await _tripService.updateTrip(trip);
    } else {
      await _tripService.createTrip(trip);
    }
    if (mounted) Navigator.pop(context);
  }

  Future<void> _addAdvance() async {
    if (_existing == null) return;
    final amount = double.tryParse(_advanceAmountCtrl.text);
    if (amount == null || amount <= 0) return;

    await _tripService.addAdvance(AdvanceModel(
      tripId: _existing!.id!,
      amount: amount,
      advanceType: _advanceType,
      enteredBy: 'user', // simplified
      date: DateTime.now().toIso8601String(),
    ));
    _advanceAmountCtrl.clear();
    _loadAdvances(_existing!.id!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_existing != null ? 'Edit Trip' : 'New Booking'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InputField(
                label: 'Pickup Date',
                controller: _pickupDateCtrl,
                readOnly: true,
                onTap: _pickDate,
                suffixIcon: const Icon(Icons.calendar_today),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              InputField(
                label: 'Pickup Time',
                controller: _pickupTimeCtrl,
                readOnly: true,
                onTap: _pickTime,
                suffixIcon: const Icon(Icons.access_time),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              InputField(
                label: 'Pickup Location',
                controller: _pickupLocationCtrl,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              InputField(
                label: 'Number of Days',
                controller: _daysCtrl,
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              InputField(
                label: 'Places to Visit',
                controller: _placesCtrl,
                maxLines: 2,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),

              // Car picker
              if (_cars.isNotEmpty)
                DropdownField<String>(
                  label: 'Assign Car',
                  value: _selectedCarId,
                  items: _cars
                      .map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text('${c.vehicleNumber} (${c.vehicleType})'),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedCarId = v),
                ),

              // Driver picker
              if (_drivers.isNotEmpty)
                DropdownField<String>(
                  label: 'Assign Driver',
                  value: _selectedDriverId,
                  items: _drivers
                      .map((d) => DropdownMenuItem(
                            value: d.id,
                            child: Text(d.name),
                          ))
                      .toList(),
                  onChanged: (v) => setState(() => _selectedDriverId = v),
                ),

              const Divider(height: 32),
              const Text('Charges',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              InputField(
                label: 'Toll',
                controller: _tollCtrl,
                keyboardType: TextInputType.number,
              ),
              InputField(
                label: 'Permit',
                controller: _permitCtrl,
                keyboardType: TextInputType.number,
              ),
              InputField(
                label: 'Parking',
                controller: _parkingCtrl,
                keyboardType: TextInputType.number,
              ),
              InputField(
                label: 'Other Charges',
                controller: _otherChargesCtrl,
                keyboardType: TextInputType.number,
              ),

              // Advance section (only in edit mode)
              if (_existing != null) ...[
                const Divider(height: 32),
                const Text('Advances',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ..._advances.map((a) => ListTile(
                      dense: true,
                      title: Text('₹${a.amount.toStringAsFixed(0)} (${a.advanceType})'),
                      subtitle: Text(a.date),
                    )),
                Row(
                  children: [
                    Expanded(
                      child: InputField(
                        label: 'Amount',
                        controller: _advanceAmountCtrl,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: _advanceType,
                      items: const [
                        DropdownMenuItem(value: 'booking', child: Text('Booking')),
                        DropdownMenuItem(value: 'fuel', child: Text('Fuel')),
                      ],
                      onChanged: (v) => setState(() => _advanceType = v!),
                    ),
                    IconButton(
                      icon: const Icon(Icons.add_circle),
                      onPressed: _addAdvance,
                    ),
                  ],
                ),
              ],

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(_existing != null ? 'Update' : 'Create Booking'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
