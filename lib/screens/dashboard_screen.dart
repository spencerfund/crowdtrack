import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/project.dart';
import '../services/firebase_service.dart';
import '../widgets/project_card.dart';
import '../widgets/project_form_sheet.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  String _activeTab = 'backed'; // 'backed' or 'interested'
  String _searchQuery = '';
  String _filterPlatform = 'All';

  void _showProjectForm({Project? project}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ProjectFormSheet(
        project: project,
        initialBacked: _activeTab == 'backed',
      ),
    );
  }

  void _markBacked(Project project) async {
    final updated = Project(
      id: project.id,
      userId: project.userId,
      title: project.title,
      platform: project.platform,
      url: project.url,
      imageUrl: project.imageUrl,
      creatorName: project.creatorName,
      status: project.status,
      backed: true,
      pledgeAmount: project.pledgeAmount,
      currency: project.currency,
      estimatedDelivery: project.estimatedDelivery,
      trackingLink: project.trackingLink,
      campaignBeginDate: project.campaignBeginDate,
      campaignEndDate: project.campaignEndDate,
      notes: project.notes,
      createdAt: project.createdAt,
    );
    await _firebaseService.updateProject(updated);
  }

  Future<void> _deleteProject(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _firebaseService.deleteProject(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _firebaseService.currentUser;
    if (user == null) return const Scaffold();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F0),
      appBar: _buildAppBar(),
      body: StreamBuilder<List<Project>>(
        stream: _firebaseService.streamProjects(user.uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final projects = snapshot.data ?? [];
          return _buildBody(projects);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white.withValues(alpha: 0.8),
      elevation: 0,
      scrolledUnderElevation: 0,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1c1917),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              LucideIcons.layers,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'CrowdTrack',
            style: TextStyle(
              color: Color(0xFF1c1917),
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(LucideIcons.logOut, color: Colors.grey),
          onPressed: () => _firebaseService.signOut(),
        ),
      ],
    );
  }

  Widget _buildBody(List<Project> allProjects) {
    final isBacked = _activeTab == 'backed';

    // Filter projects
    var filtered = allProjects.where((p) {
      final matchesTab = isBacked ? p.backed : !p.backed;
      final matchesSearch = p.title.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      final matchesPlatform =
          _filterPlatform == 'All' || p.platform == _filterPlatform;
      return matchesTab && matchesSearch && matchesPlatform;
    }).toList();

    return Column(
      children: [
        // Tabs
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton(
                    'Backed Projects',
                    isBacked,
                    () => setState(() => _activeTab = 'backed'),
                  ),
                ),
                Expanded(
                  child: _buildTabButton(
                    'Interested',
                    !isBacked,
                    () => setState(() => _activeTab = 'interested'),
                  ),
                ),
              ],
            ),
          ),
        ),

        Expanded(
          child: CustomScrollView(
            slivers: [
              if (isBacked)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _buildStats(
                      allProjects.where((p) => p.backed).toList(),
                    ),
                  ),
                ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 8.0,
                  ),
                  child: _buildControls(),
                ),
              ),

              if (filtered.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 64.0),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            LucideIcons.alertCircle,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No projects found',
                            style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Try adjusting your search or add a new project.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else
                ..._buildCategorizedLists(filtered),

              const SliverPadding(padding: EdgeInsets.only(bottom: 100)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(String title, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1c1917) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isActive ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }

  Widget _buildStats(List<Project> backedProjects) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Backed',
            backedProjects.length.toString(),
            LucideIcons.box,
            Colors.grey.shade100,
            Colors.grey.shade700,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            'In Transit',
            backedProjects
                .where((p) => p.status == 'Shipped')
                .length
                .toString(),
            LucideIcons.truck,
            Colors.orange.shade50,
            Colors.orange.shade600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            'Delivered',
            backedProjects
                .where((p) => p.status == 'Delivered')
                .length
                .toString(),
            LucideIcons.checkCircle2,
            Colors.green.shade50,
            Colors.green.shade600,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            'Active',
            backedProjects
                .where((p) => p.status == 'Funding')
                .length
                .toString(),
            LucideIcons.trendingUp,
            Colors.blue.shade50,
            Colors.blue.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color bgColor,
    Color fgColor,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200.withValues(alpha: 0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: fgColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 1,
            ),
            maxLines: 1,
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: fgColor,
              fontFamily: Theme.of(context).textTheme.displayLarge?.fontFamily,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton.icon(
            onPressed: () => _showProjectForm(),
            icon: const Icon(LucideIcons.plus, size: 20),
            label: const Text(
              'New Project',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1c1917),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCategorizedLists(List<Project> filtered) {
    final order = [
      'Shipped',
      'Pledged',
      'Funded',
      'Funding',
      'Upcoming',
      'Delivered',
    ];

    return order.map((status) {
      final statusProjects = filtered.where((p) => p.status == status).toList();
      if (statusProjects.isEmpty) {
        return const SliverToBoxAdapter(child: SizedBox.shrink());
      }
      return SliverMainAxisGroup(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
              child: Row(
                children: [
                  Text(
                    status,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusProjects.length.toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: ProjectCard(
                    project: statusProjects[index],
                    onEdit: () =>
                        _showProjectForm(project: statusProjects[index]),
                    onDelete: () => _deleteProject(statusProjects[index].id),
                    onMarkBacked: () => _markBacked(statusProjects[index]),
                  ),
                );
              }, childCount: statusProjects.length),
            ),
          ),
        ],
      );
    }).toList();
  }
}
