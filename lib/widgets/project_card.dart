import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200.withOpacity(0.5),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildImageHeader(),
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
                      color: const Color(0xFF1c1917),
                    ),
                  ),
                  if (project.creatorName != null && project.creatorName!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4, bottom: 16),
                      child: Text(
                        'by ${project.creatorName}',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  else
                    const SizedBox(height: 16),
                  
                  const SizedBox(height: 16),
                  _buildDetails(),
                ],
              ),
            ),
            _buildFooter(),
          ],
        ),
    );
  }

  Widget _buildImageHeader() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
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
              errorBuilder: (context, _, __) => const Icon(LucideIcons.box, size: 48, color: Colors.grey),
            )
          else
            const Icon(LucideIcons.box, size: 48, color: Colors.grey),
          
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                project.platform.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  color: _getPlatformColor(project.platform),
                ),
              ),
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: _buildStatusBadge(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (project.status) {
      case 'Upcoming':
        bgColor = Colors.amber.shade100.withOpacity(0.8);
        textColor = Colors.amber.shade900;
        icon = LucideIcons.calendar;
        break;
      case 'Funding':
        bgColor = Colors.blue.shade100.withOpacity(0.8);
        textColor = Colors.blue.shade900;
        icon = LucideIcons.trendingUp;
        break;
      case 'Funded':
        bgColor = Colors.green.shade100.withOpacity(0.8);
        textColor = Colors.green.shade900;
        icon = LucideIcons.checkCircle2;
        break;
      case 'Pledged':
        bgColor = Colors.purple.shade100.withOpacity(0.8);
        textColor = Colors.purple.shade900;
        icon = LucideIcons.package;
        break;
      case 'Shipped':
        bgColor = Colors.orange.shade100.withOpacity(0.8);
        textColor = Colors.orange.shade900;
        icon = LucideIcons.truck;
        break;
      case 'Delivered':
      default:
        bgColor = Colors.grey.shade200.withOpacity(0.8);
        textColor = Colors.grey.shade800;
        icon = LucideIcons.checkCircle2;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: textColor),
          const SizedBox(width: 6),
          Text(
            project.status,
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

  Color _getPlatformColor(String platform) {
    switch (platform) {
      case 'Kickstarter': return Colors.green.shade700;
      case 'Backerkit': return Colors.blue.shade700;
      case 'Gamefound': return Colors.orange.shade700;
      default: return Colors.grey.shade700;
    }
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (project.estimatedDelivery != null && project.estimatedDelivery!.isNotEmpty)
          _buildInfoRow(LucideIcons.calendar, 'Est. Delivery', _formatMonthYear(project.estimatedDelivery!), Colors.grey.shade50),
        
        if (project.status == 'Upcoming' && project.campaignBeginDate != null)
          _buildInfoRow(LucideIcons.calendar, 'Begins', _formatDate(project.campaignBeginDate!), Colors.amber.shade50, Colors.amber.shade500),
          
        if (project.status == 'Funding' && project.campaignEndDate != null)
          _buildInfoRow(LucideIcons.calendar, 'Ends', _formatDate(project.campaignEndDate!), Colors.blue.shade50, Colors.blue.shade500),

        if (project.trackingLink != null && project.trackingLink!.isNotEmpty && (project.status == 'Shipped' || project.status == 'Delivered'))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: ElevatedButton.icon(
              onPressed: () => _launchUrl(project.trackingLink!),
              icon: const Icon(LucideIcons.truck, size: 16),
              label: const Text('Track Package'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade50,
                foregroundColor: Colors.orange.shade700,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),

        if (project.pledgeAmount != null)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade100))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Pledge Amount', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
                  Text(
                    '${project.currency ?? '\$'} ${project.pledgeAmount?.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color bgColor, [Color? iconColor]) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: iconColor ?? Colors.grey.shade400),
          const SizedBox(width: 8),
          Text('$label: $value', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.grey.shade700)),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        border: Border(top: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onEdit,
                icon: const Icon(LucideIcons.edit2, size: 18),
                color: Colors.grey.shade400,
                hoverColor: const Color(0xFF1c1917),
              ),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(LucideIcons.trash2, size: 18),
                color: Colors.grey.shade400,
                hoverColor: Colors.red,
              ),
            ],
          ),
          Row(
            children: [
              if (!project.backed)
                ElevatedButton.icon(
                  onPressed: onMarkBacked,
                  icon: const Icon(LucideIcons.checkCircle2, size: 14),
                  label: const Text('Mark Backed', style: TextStyle(fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1c1917),
                    foregroundColor: Colors.white,
                    elevation: 2,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
              if (project.url.isNotEmpty)
                IconButton(
                  onPressed: () => _launchUrl(project.url),
                  icon: const Icon(LucideIcons.arrowUpRight, size: 18),
                  color: Colors.grey.shade600,
                ),
            ],
          )
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
        final date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
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
