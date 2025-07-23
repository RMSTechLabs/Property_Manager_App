// Settings Screen - Responsive with Toggle States
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:redacted/redacted.dart';
import 'package:property_manager_app/src/core/constants/app_constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = true;
  String propertyName = "BNH Tower 03";
  
  // Settings state
  Map<String, bool> settings = {};
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    setState(() {
      _isLoading = true;
    });
    
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));
    
    setState(() {
      settings = {
        'vehicleInOut': true,
        'productsFeatures': false,
        'events': false,
        'games': false,
        'familyDetails': false,
        'autoApproval': false,
        'whatsappAlerts': false,
        'approvalNotification': false,
        'servicesMaintenance': false,
        'guest': false,
        'delivery': false,
        'cab': false,
        'newspaper': false,
      };
      _isLoading = false;
    });
  }
  
  void _toggleSetting(String key, bool value) {
    setState(() {
      settings[key] = value;
    });
    // TODO: Save to API
    print('Setting $key changed to $value');
  }
  
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppConstants.secondartGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              _buildHeader(screenWidth),
              
              // Scrollable Content
              Expanded(
                child: Container(
                  margin: EdgeInsets.only(top: screenHeight * 0.02),
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: _isLoading 
                    ? _buildSkeletonContent(screenWidth)
                    : _buildSettingsContent(screenWidth),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(double screenWidth) {
    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.05),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: screenWidth * 0.12,
              height: screenWidth * 0.12,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha:0.2),
                borderRadius: BorderRadius.circular(screenWidth * 0.06),
              ),
              child: Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: screenWidth * 0.05,
              ),
            ),
          ),
          SizedBox(width: screenWidth * 0.04),
          Expanded(
            child: Text(
              "Settings for $propertyName",
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: screenWidth * 0.045,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsContent(double screenWidth) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(screenWidth * 0.05),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main Settings Section
          _buildSettingsList([
            SettingItem(
              title: "Vehicle In/Out Notifications",
              key: 'vehicleInOut',
            ),
            SettingItem(
              title: "Products & Features",
              subtitle: "Notification of new products, app features etc.",
              key: 'productsFeatures',
            ),
            SettingItem(
              title: "Events",
              subtitle: "Notification of new events, winner announcement etc.",
              key: 'events',
            ),
            SettingItem(
              title: "Games",
              subtitle: "Receive game and game event related notifications",
              key: 'games',
            ),
            SettingItem(
              title: "Family Details",
              subtitle: "Show family members in the resident directory",
              key: 'familyDetails',
            ),
            SettingItem(
              title: "Auto Approval",
              subtitle: "Turn on auto approval for zomato & blinkit to avoid approval notification.",
              key: 'autoApproval',
            ),
            SettingItem(
              title: "Get Whatsapp Alerts",
              subtitle: "Bill generation notification, payment reminder etc.",
              key: 'whatsappAlerts',
            ),
          ], screenWidth),
          
          SizedBox(height: screenWidth * 0.04),
          
          // Notification Issues Link
          GestureDetector(
            onTap: () => _handleNotificationIssues(),
            child: Text(
              "Notification issues",
              style: GoogleFonts.lato(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF10B981),
              ),
            ),
          ),
          
          SizedBox(height: screenWidth * 0.06),
          
          // Visitor Notifications Section
          _buildSettingsList([
            SettingItem(
              title: "Approval Notification",
              subtitle: "Your new visitors",
              key: 'approvalNotification',
            ),
          ], screenWidth),
          
          SizedBox(height: screenWidth * 0.04),
          
          // Notify when inside society Link
          GestureDetector(
            onTap: () => _handleNotifyInsideSociety(),
            child: Text(
              "Notify me when inside society",
              style: GoogleFonts.lato(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF10B981),
              ),
            ),
          ),
          
          SizedBox(height: screenWidth * 0.06),
          
          // Services Section
          _buildSettingsList([
            SettingItem(
              title: "Services/Maintenance",
              subtitle: "Maid, Cook etc",
              key: 'servicesMaintenance',
            ),
            SettingItem(
              title: "Guest",
              subtitle: "Your invited guests",
              key: 'guest',
            ),
            SettingItem(
              title: "Delivery",
              subtitle: "Your scheduled delivery",
              key: 'delivery',
            ),
            SettingItem(
              title: "Cab",
              subtitle: "Your scheduled cab",
              key: 'cab',
            ),
          ], screenWidth),
          
          SizedBox(height: screenWidth * 0.04),
          
          // Notify me for Link
          GestureDetector(
            onTap: () => _handleNotifyMeFor(),
            child: Text(
              "Notify me for",
              style: GoogleFonts.lato(
                fontSize: screenWidth * 0.04,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF10B981),
              ),
            ),
          ),
          
          SizedBox(height: screenWidth * 0.06),
          
          // Additional Settings
          _buildSettingsList([
            SettingItem(
              title: "Newspaper",
              subtitle: "Newspaper notifications",
              key: 'newspaper',
            ),
          ], screenWidth),
          
          SizedBox(height: screenWidth * 0.05),
        ],
      ),
    );
  }

  Widget _buildSettingsList(List<SettingItem> items, double screenWidth) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == items.length - 1;
          
          return Column(
            children: [
              _buildSettingTile(item, screenWidth),
              if (!isLast)
                Divider(
                  height: 1,
                  color: Colors.grey.shade200,
                  indent: screenWidth * 0.05,
                  endIndent: screenWidth * 0.05,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSettingTile(SettingItem item, double screenWidth) {
    final isEnabled = settings[item.key] ?? false;
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.05,
        vertical: screenWidth * 0.04,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.lato(
                    fontSize: screenWidth * 0.04,
                    fontWeight: FontWeight.w600,
                    color: AppConstants.black,
                  ),
                ),
                if (item.subtitle != null) ...[
                  SizedBox(height: screenWidth * 0.01),
                  Text(
                    item.subtitle!,
                    style: GoogleFonts.lato(
                      fontSize: screenWidth * 0.032,
                      color: AppConstants.black50,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          SizedBox(width: screenWidth * 0.04),
          Transform.scale(
            scale: 0.8,
            child: Switch(
              value: isEnabled,
              onChanged: (value) => _toggleSetting(item.key, value),
              activeColor: Colors.white,
              activeTrackColor: AppConstants.purple50,
              inactiveThumbColor: Colors.white,
              inactiveTrackColor: Colors.grey.shade300,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonContent(double screenWidth) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(screenWidth * 0.05),
      child: Column(
        children: List.generate(8, (index) => _buildSkeletonSection(screenWidth)),
      ),
    );
  }

  Widget _buildSkeletonSection(double screenWidth) {
    return Container(
      margin: EdgeInsets.only(bottom: screenWidth * 0.04),
      padding: EdgeInsets.all(screenWidth * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: List.generate(2, (index) {
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 16,
                          width: screenWidth * 0.5,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ).redacted(context: context, redact: true),
                        SizedBox(height: screenWidth * 0.02),
                        Container(
                          height: 12,
                          width: screenWidth * 0.7,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ).redacted(context: context, redact: true),
                      ],
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ).redacted(context: context, redact: true),
                ],
              ),
              if (index == 0)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: screenWidth * 0.03),
                  child: Divider(
                    height: 1,
                    color: Colors.grey.shade200,
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  
  // Action handlers
  void _handleNotificationIssues() {
    print('Navigate to notification issues');
    // TODO: Navigate to notification troubleshooting page
  }

  void _handleNotifyInsideSociety() {
    print('Configure inside society notifications');
    // TODO: Show location-based notification settings
  }

  void _handleNotifyMeFor() {
    print('Configure notification preferences');
    // TODO: Show detailed notification preferences
  }
}

// Data Models
class SettingItem {
  final String title;
  final String? subtitle;
  final String key;

  SettingItem({
    required this.title,
    this.subtitle,
    required this.key,
  });
}

// Settings Model for API/State Management
class SettingsData {
  final Map<String, bool> notifications;
  final String propertyId;
  final String propertyName;

  SettingsData({
    required this.notifications,
    required this.propertyId,
    required this.propertyName,
  });

  factory SettingsData.fromJson(Map<String, dynamic> json) {
    return SettingsData(
      notifications: Map<String, bool>.from(json['notifications'] ?? {}),
      propertyId: json['propertyId'] ?? '',
      propertyName: json['propertyName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifications': notifications,
      'propertyId': propertyId,
      'propertyName': propertyName,
    };
  }

  SettingsData copyWith({
    Map<String, bool>? notifications,
    String? propertyId,
    String? propertyName,
  }) {
    return SettingsData(
      notifications: notifications ?? this.notifications,
      propertyId: propertyId ?? this.propertyId,
      propertyName: propertyName ?? this.propertyName,
    );
  }
}