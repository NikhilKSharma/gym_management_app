import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gymanager/src/config/app_colors.dart';
import 'package:gymanager/src/models/member_model.dart';
import 'package:gymanager/src/services/api_service.dart';
import 'package:gymanager/src/widgets/member_details_sheet.dart';
import 'package:intl/intl.dart';

class MembersView extends StatefulWidget {
  const MembersView({super.key});

  @override
  State<MembersView> createState() => _MembersViewState();
}

class _MembersViewState extends State<MembersView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // We will manage the futures for each tab's data
  late Future<List<Member>> _activeMembersFuture;
  late Future<List<Member>> _expiredMembersFuture;

  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _fetchInitialData();
    _searchController.addListener(_onSearchChanged);
  }

  void _fetchInitialData() {
    _activeMembersFuture = ApiService.getActiveMembers();
    _expiredMembersFuture = ApiService.getExpiredMembers();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // Note: Search will now apply to all members, not filtered list.
      // We can adjust this later if needed.
      setState(() {
        _activeMembersFuture =
            ApiService.getMembers(query: _searchController.text);
        _expiredMembersFuture =
            ApiService.getMembers(query: _searchController.text);
      });
    });
  }

  void _refreshData() {
    setState(() {
      _fetchInitialData();
      _searchController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Using a nested Scaffold to place the TabBar in the AppBar
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryText,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.accent,
          tabs: const [
            Tab(text: 'Active'),
            Tab(text: 'Expired'),
          ],
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search All Members',
                prefixIcon: const Icon(Icons.search),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
              style: const TextStyle(color: AppColors.primaryText),
              cursorColor: AppColors.primaryText,
            ),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMemberList(_activeMembersFuture),
                _buildMemberList(_expiredMembersFuture),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper widget to avoid duplicating the FutureBuilder logic
  Widget _buildMemberList(Future<List<Member>> future) {
    return FutureBuilder<List<Member>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.accent));
        }
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No members found.'));
        }

        final members = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            final bool isMembershipActive =
                member.membershipEndDate.isAfter(DateTime.now());

            return InkWell(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (ctx) => MemberDetailsSheet(
                    member: member,
                    onActionCompleted: _refreshData,
                  ),
                );
              },
              child: Card(
                color: AppColors.surface,
                margin:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.background,
                        child: Text(
                          member.name[0],
                          style: const TextStyle(
                              color: AppColors.primaryText,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              member.name,
                              style: const TextStyle(
                                  color: AppColors.secondaryText,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Expires: ${DateFormat.yMMMd().format(member.membershipEndDate)}',
                              style: TextStyle(
                                  color:
                                      AppColors.secondaryText.withOpacity(0.7)),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.circle,
                        color: isMembershipActive
                            ? Colors.greenAccent
                            : Colors.redAccent,
                        size: 12,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
