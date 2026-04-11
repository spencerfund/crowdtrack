import 'package:flutter/material.dart';
import '../models/project.dart';
import '../services/firebase_service.dart';

class ProjectFormSheet extends StatefulWidget {
  final Project? project; // If null, it's adding a new project
  final bool initialBacked;

  const ProjectFormSheet({super.key, this.project, this.initialBacked = true});

  @override
  State<ProjectFormSheet> createState() => _ProjectFormSheetState();
}

class _ProjectFormSheetState extends State<ProjectFormSheet> {
  final FirebaseService _firebaseService = FirebaseService();
  final _formKey = GlobalKey<FormState>();

  late String _title;
  late String _creatorName;
  late ProjectPlatform _platform;
  late ProjectStatus _status;
  late String _url;
  late String _imageUrl;
  late bool _backed;
  late String _pledgeAmount;
  late String _currency;
  late String _estimatedDelivery;
  late String _campaignBeginDate;
  late String _campaignEndDate;
  late String _trackingLink;
  late String _notes;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final p = widget.project;
    _title = p?.title ?? '';
    _creatorName = p?.creatorName ?? '';
    _platform = p?.platform ?? ProjectPlatform.kickstarter;
    _status = p?.status ?? ProjectStatus.funding;
    _url = p?.url ?? '';
    _imageUrl = p?.imageUrl ?? '';
    _backed = p?.backed ?? widget.initialBacked;
    _pledgeAmount = p?.pledgeAmount?.toString() ?? '';
    _currency = p?.currency ?? 'USD';
    _estimatedDelivery = p?.estimatedDelivery ?? '';
    _campaignBeginDate = p?.campaignBeginDate ?? '';
    _campaignEndDate = p?.campaignEndDate ?? '';
    _trackingLink = p?.trackingLink ?? '';
    _notes = p?.notes ?? '';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    try {
      final user = _firebaseService.currentUser!;
      final newProject = Project(
        id: widget.project?.id ?? '', // empty for new
        userId: user.uid,
        title: _title,
        platform: _platform,
        url: _url,
        imageUrl: _imageUrl,
        creatorName: _creatorName,
        status: _status,
        backed: _backed,
        pledgeAmount: double.tryParse(_pledgeAmount),
        currency: _currency,
        estimatedDelivery: _estimatedDelivery,
        trackingLink: _trackingLink,
        campaignBeginDate: _campaignBeginDate,
        campaignEndDate: _campaignEndDate,
        notes: _notes,
        createdAt: widget.project?.createdAt,
      );

      if (widget.project == null) {
        await _firebaseService.addProject(newProject);
      } else {
        await _firebaseService.updateProject(newProject);
      }
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving project: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      // Max height to allow scrolling for keyboard
      height: MediaQuery.of(context).size.height * 0.9,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildTextField(
                        context,
                        'Project Title',
                        (v) => _title = v,
                        initial: _title,
                        required: true,
                      ),
                      _buildTextField(
                        context,
                        'Creator Name',
                        (v) => _creatorName = v,
                        initial: _creatorName,
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown<ProjectPlatform>(
                        context,
                        'Platform',
                        ProjectPlatform.values,
                        _platform,
                        (v) => setState(() => _platform = v!),
                        (v) => v.displayName,
                      ),
                      const SizedBox(height: 16),
                      _buildDropdown<ProjectStatus>(
                        context,
                        'Status',
                        ProjectStatus.values,
                        _status,
                        (v) => setState(() => _status = v!),
                        (v) => v.displayName,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        context,
                        'URL',
                        (v) => _url = v,
                        initial: _url,
                      ),
                      _buildTextField(
                        context,
                        'Image URL',
                        (v) => _imageUrl = v,
                        initial: _imageUrl,
                      ),
                      if (_backed) ...[
                        _buildTextField(
                          context,
                          'Pledge Amount',
                          (v) => _pledgeAmount = v,
                          initial: _pledgeAmount,
                          keyboardType: TextInputType.number,
                        ),
                        _buildTextField(
                          context,
                          'Currency',
                          (v) => _currency = v,
                          initial: _currency,
                        ),
                      ],
                      _buildTextField(
                        context,
                        'Estimated Delivery (YYYY-MM)',
                        (v) => _estimatedDelivery = v,
                        initial: _estimatedDelivery,
                      ),
                      if (_status == ProjectStatus.shipped ||
                          _status == ProjectStatus.delivered)
                        _buildTextField(
                          context,
                          'Tracking Link',
                          (v) => _trackingLink = v,
                          initial: _trackingLink,
                        ),
                      if (_status == ProjectStatus.upcoming ||
                          _status == ProjectStatus.funding) ...[
                        _buildTextField(
                          context,
                          'Campaign Begin Date (YYYY-MM-DD)',
                          (v) => _campaignBeginDate = v,
                          initial: _campaignBeginDate,
                        ),
                        _buildTextField(
                          context,
                          'Campaign End Date (YYYY-MM-DD)',
                          (v) => _campaignEndDate = v,
                          initial: _campaignEndDate,
                        ),
                      ],
                      _buildTextField(
                        context,
                        'Notes',
                        (v) => _notes = v,
                        initial: _notes,
                        maxLines: 3,
                      ),

                      const SizedBox(height: 24),
                      SizedBox(
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _submit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Theme.of(
                              context,
                            ).colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                )
                              : Text(
                                  widget.project == null
                                      ? 'Save Project'
                                      : 'Update Project',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
                      ),
                      // Add extra padding at the bottom for keyboard
                      SizedBox(
                        height: MediaQuery.of(context).viewInsets.bottom,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.surfaceContainer,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            widget.project == null ? 'New Project' : 'Edit Project',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context,
    String label,
    ValueChanged<String> onSaved, {
    String initial = '',
    bool required = false,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: initial,
            decoration: InputDecoration(
              filled: true,
              fillColor: Theme.of(
                context,
              ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
            keyboardType: keyboardType,
            maxLines: maxLines,
            validator: required ? (v) => v!.isEmpty ? 'Required' : null : null,
            onSaved: (v) => onSaved(v ?? ''),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>(
    BuildContext context,
    String label,
    List<T> items,
    T value,
    ValueChanged<T?> onChanged,
    String Function(T) itemLabel,
  ) {
    // If somehow the existing value isn't in the list, fallback to first item
    T effectiveValue = items.contains(value) ? value : items.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          initialValue: effectiveValue,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(
              context,
            ).colorScheme.surfaceContainerHighest.withOpacity(0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          items: items
              .map((i) => DropdownMenuItem(value: i, child: Text(itemLabel(i))))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
