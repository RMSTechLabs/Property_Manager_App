import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:property_manager_app/src/core/constants/app_constants.dart';
import 'package:property_manager_app/src/core/utils/app_snackbar.dart';
import 'package:property_manager_app/src/data/models/category_model.dart';
import 'package:property_manager_app/src/data/services/complaint/complaint_service.dart';
import 'package:property_manager_app/src/presentation/providers/society_provider.dart';

// Enhanced Category Selection Screen with API Integration
class CategorySelectionScreen extends ConsumerStatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  ConsumerState<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState
    extends ConsumerState<CategorySelectionScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<CategoryModel> _filteredCategories = [];
  List<CategoryModel> _allCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_filterCategories);
    _loadCategories();
  }

  void _loadCategories() async {
    try {
      final societyState = ref.read(societyStateProvider);
      final societyId = societyState.societies.isNotEmpty
          ? societyState.societies.first.societyId
          : "";

      final complaintService = ref.read(complaintServiceProvider);
      final categories = await complaintService.getAllCategoryList(
        societyId.toString(),
      );

      setState(() {
        _allCategories =
            categories; //data.map((item) => CategoryModel.fromJson(item)).toList();
        _filteredCategories = List.from(_allCategories);
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        // ScaffoldMessenger.of(
        //   context,
        // ).showSnackBar(SnackBar(content: Text('Error loading categories: $e')));
        AppSnackBar.showError(
          context: context,
          message: 'Error loading categories: $e',
        );
      }
    }
  }

  void _filterCategories() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCategories = _allCategories
          .where(
            (category) => category.categoryTitle.toLowerCase().contains(query),
          )
          .toList();
    });
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

              // Categories List
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
                  child: Column(
                    children: [
                      // Search Bar
                      _buildSearchBar(screenWidth),

                      // Categories List
                      Expanded(
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : _buildCategoriesList(screenWidth),
                      ),
                    ],
                  ),
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
                color: Colors.white.withOpacity(0.2),
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
              "Select Issue Category",
              style: GoogleFonts.lato(
                color: Colors.white,
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(double screenWidth) {
    return Container(
      margin: EdgeInsets.all(screenWidth * 0.05),
      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.lato(
          fontSize: screenWidth * 0.04,
          color: AppConstants.black,
        ),
        decoration: InputDecoration(
          hintText: "Search categories...",
          hintStyle: GoogleFonts.lato(
            fontSize: screenWidth * 0.04,
            color: AppConstants.black50,
          ),
          border: InputBorder.none,
          suffixIcon: Icon(
            Icons.search,
            color: AppConstants.black50,
            size: screenWidth * 0.05,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesList(double screenWidth) {
    if (_filteredCategories.isEmpty) {
      return Center(
        child: Text(
          "No categories found",
          style: GoogleFonts.lato(
            fontSize: screenWidth * 0.04,
            color: AppConstants.black50,
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListView.separated(
        padding: EdgeInsets.zero,
        itemCount: _filteredCategories.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          color: Colors.grey.shade200,
          indent: screenWidth * 0.04,
          endIndent: screenWidth * 0.04,
        ),
        itemBuilder: (context, index) {
          final category = _filteredCategories[index];
          return ListTile(
            title: Text(
              category.categoryTitle,
              style: GoogleFonts.lato(
                fontSize: screenWidth * 0.04,
                color: AppConstants.black,
                fontWeight: FontWeight.w500,
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenWidth * 0.01,
            ),
            onTap: () => Navigator.pop(context, category),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
