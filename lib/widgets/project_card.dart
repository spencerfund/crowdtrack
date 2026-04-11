import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/project.dart';

class ProjectCard extends StatelessWidget {
  final Project project;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onMarkBacked;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onEdit,
    required this.onDelete,
    required this.onMarkBacked,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Theme.of(context).colorScheme.surfaceContainer,
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildImageHeader(context),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  project.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                if (project.creatorName != null &&
                    project.creatorName!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 4, bottom: 16),
                    child: Text(
                      'by ${project.creatorName}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )
                else
                  const SizedBox(height: 16),

                const SizedBox(height: 16),
                _buildDetails(context),
              ],
            ),
          ),
          _buildFooter(context),
        ],
      ),
    );
  }

  Widget _buildImageHeader(BuildContext context) {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(24),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (project.imageUrl != null && project.imageUrl!.isNotEmpty)
            Image.network(
              project.imageUrl!,
              fit: BoxFit.cover,
              errorBuilder: (context, _, _) => Icon(
                Icons.inventory_2_rounded,
                size: 48,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            )
          else
            Icon(
              Icons.inventory_2_rounded,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),

          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                project.platform.displayName.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: _getPlatformColor(project.platform),
                ),
              ),
            ),
          ),
          Positioned(top: 12, right: 12, child: _buildStatusBadge()),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (project.status) {
      case ProjectStatus.upcoming:
        bgColor = Colors.amber.shade100.withValues(alpha: 0.8);
        textColor = Colors.amber.shade900;
        icon = Icons.calendar_month_rounded;
        break;
      case ProjectStatus.interested:
        bgColor = Colors.teal.shade100.withValues(alpha: 0.8);
        textColor = Colors.teal.shade900;
        icon = Icons.favorite_rounded;
        break;
      case ProjectStatus.funding:
        bgColor = Colors.blue.shade100.withValues(alpha: 0.8);
        textColor = Colors.blue.shade900;
        icon = Icons.trending_up_rounded;
        break;
      case ProjectStatus.funded:
        bgColor = Colors.green.shade100.withValues(alpha: 0.8);
        textColor = Colors.green.shade900;
        icon = Icons.check_circle_rounded;
        break;
      case ProjectStatus.pledged:
        bgColor = Colors.purple.shade100.withValues(alpha: 0.8);
        textColor = Colors.purple.shade900;
        icon = Icons.inventory_rounded;
        break;
      case ProjectStatus.shipped:
        bgColor = Colors.orange.shade100.withValues(alpha: 0.8);
        textColor = Colors.orange.shade900;
        icon = Icons.local_shipping_rounded;
        break;
      case ProjectStatus.delivered:
        bgColor = Colors.grey.shade200.withValues(alpha: 0.8);
        textColor = Colors.grey.shade800;
        icon = Icons.check_circle_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 6),
          Text(
            project.status.displayName,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getPlatformColor(ProjectPlatform platform) {
    switch (platform) {
      case ProjectPlatform.kickstarter:
        return Colors.green.shade700;
      case ProjectPlatform.backerkit:
        return Colors.blue.shade700;
      case ProjectPlatform.gamefound:
        return Colors.orange.shade700;
      case ProjectPlatform.other:
        return Colors.grey.shade700;
    }
  }

  Widget _buildDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (project.estimatedDelivery != null &&
            project.estimatedDelivery!.isNotEmpty)
          _buildInfoRow(
            context,
            Icons.calendar_month_rounded,
            'Est. Delivery',
            _formatMonthYear(project.estimatedDelivery!),
            Theme.of(context).colorScheme.surfaceContainerHighest,
          ),

        if (project.status == ProjectStatus.upcoming &&
            project.campaignBeginDate != null)
          _buildInfoRow(
            context,
            Icons.calendar_month_rounded,
            'Begins',
            _formatDate(project.campaignBeginDate!),
            Colors.amber.shade50,
            Colors.amber.shade500,
          ),

        if (project.status == ProjectStatus.funding &&
            project.campaignEndDate != null)
          _buildInfoRow(
            context,
            Icons.calendar_month_rounded,
            'Ends',
            _formatDate(project.campaignEndDate!),
            Colors.blue.shade50,
            Colors.blue.shade500,
          ),

        if (project.trackingLink != null &&
            project.trackingLink!.isNotEmpty &&
            (project.status == ProjectStatus.shipped ||
                project.status == ProjectStatus.delivered))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: ElevatedButton.icon(
              onPressed: () => _launchUrl(project.trackingLink!),
              icon: const Icon(Icons.local_shipping_rounded, size: 16),
              label: const Text('Track Package'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade50,
                foregroundColor: Colors.orange.shade700,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

        if (project.pledgeAmount != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Theme.of(context).colorScheme.surfaceContainer,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pledge Amount',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${project.currency ?? '\$'} ${project.pledgeAmount?.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    Color bgColor, [
    Color? iconColor,
  ]) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: iconColor ?? Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Text(
            '$label: $value',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        border: Border(
          top: BorderSide(
            color: Theme.of(context).colorScheme.surfaceContainer,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_rounded, size: 18),
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                hoverColor: Theme.of(context).colorScheme.primary,
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                color: Colors.white.withValues(alpha: 0.9),
                hoverColor: Colors.red,
              ),
            ],
          ),
          Row(
            children: [
              if (!project.backed)
                ElevatedButton.icon(
                  onPressed: onMarkBacked,
                  icon: const Icon(Icons.check_circle_rounded, size: 14),
                  label: const Text(
                    'Mark Backed',
                    style: TextStyle(fontSize: 12),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 0,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              if (project.url.isNotEmpty)
                IconButton(
                  onPressed: () => _launchUrl(project.url),
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatMonthYear(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length >= 2) {
        final date = DateTime(int.parse(parts[0]), int.parse(parts[1]));
        return DateFormat('MMM yyyy').format(date);
      }
    } catch (_) {}
    return dateStr;
  }

  String _formatDate(String dateStr) {
    try {
      final parts = dateStr.split('-');
      if (parts.length >= 3) {
        final date = DateTime(
          int.parse(parts[0]),
          int.parse(parts[1]),
          int.parse(parts[2]),
        );
        return DateFormat('MMM d, yyyy').format(date);
      }
    } catch (_) {}
    return dateStr;
  }

  Future<void> _launchUrl(String urlString) async {
    final url = Uri.parse(urlString);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}
