import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:swift_scanner/widgets/home_screen_widgets.dart';

class SearchScreen extends StatefulWidget {
  static const routeName = '/search_screen';
  const SearchScreen({Key? key}) : super(key: key);

  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late TextEditingController _searchTextController;
  List _searchList = [];

  // try with firestore search... firestore_search:

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _searchTextController = TextEditingController();
    _searchTextController.addListener(() {
      // Refresh list
      setState(() {});
    });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _searchTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: size.height,
        width: size.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.pinkAccent.shade100,
              Colors.blueAccent.shade100,
              Colors.yellowAccent.shade100,
              Colors.redAccent.shade100,
            ],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: SafeArea(
          child: Container(
            // color: Colors.green,
            child: Column(
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Padding(
                        padding: EdgeInsets.only(top: 12.0, left: 12.0),
                        child: Icon(Icons.arrow_back),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.only(
                            top: 12.0, right: 12.0, left: 12.0),
                        child: TextFormField(
                          autofocus: true,
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Search Now',
                            hintStyle: GoogleFonts.getFont(
                              'Fira Sans',
                              fontSize: 16.0,
                              color: Colors.black38,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                _searchTextController.text.isNotEmpty && _searchList.isEmpty
                    ? Column(
                        children: [
                          const SizedBox(height: 20.0),
                          Icon(
                            MaterialIcons.search,
                            size: 40.0,
                          ),
                          const SizedBox(height: 20.0),
                          Text(
                            'No Results Found',
                            style: GoogleFonts.getFont(
                              'Roboto Slab',
                              color: Colors.red.shade700,
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : Flexible(
                        child: PDFItem(),
                      ),
                /*GridView.count(
                        crossAxisCount: 2,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        childAspectRatio: 240 / 420,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                        children: List.generate(
                            _searchTextController.text.isEmpty
                                ? productList.length
                                : _searchList.length, (index) {
                          return ChangeNotifierProvider.value(
                            value: _searchTextController.text.isEmpty
                                ? productList[index]
                                : _searchList[index],
                            child: const FeedProductsScreen(),
                          );
                        }),
                      ),*/
              ],
            ),
          ),
        ),
      ),
    );
  }
}
