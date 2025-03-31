import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class CatGridView extends StatefulWidget {
  const CatGridView({super.key});

  @override
  State<CatGridView> createState() => _CatGridViewState();
}

class _CatGridViewState extends State<CatGridView> {
  final scrollController = ScrollController();
  final dio = Dio();

  bool isLoading = false;
  List<String> catImageUrl = [];

  Future<void> fetchCats() async {
    Response response = await dio.get(
      'https://api.thecatapi.com/v1/images/search?limit=10',
    );
    final List data = response.data;
    catImageUrl.addAll(data.map((element) => element['url']));
  }

  Future<void> loadCatImage() async {
    await fetchCats();
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadCatImage();
    scrollController.addListener(() {
      if (!isLoading &&
          scrollController.position.pixels >=
              scrollController.position.maxScrollExtent + 80) {
        isLoading = true;
        loadCatImage();
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      controller: scrollController,
      padding: EdgeInsets.all(8),
      physics: BouncingScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        crossAxisCount: 2,
      ),
      itemCount: catImageUrl.length,
      itemBuilder: (context, index) {
        return Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: const Color.fromARGB(127, 158, 158, 158),
          ),
          child: CachedNetworkImage(
            imageUrl: catImageUrl[index],
            fit: BoxFit.cover,
            placeholder:
                (context, url) => CircularProgressIndicator(
                  padding: EdgeInsets.all(64),
                  strokeWidth: 8,
                ),
            errorWidget:
                (context, url, error) => Center(
                  child: Icon(Icons.pets, color: Colors.red, size: 48),
                ),
          ),

          // Image.network(
          //   catImageUrl[index],
          //   fit: BoxFit.cover,
          //   errorBuilder:
          //       (context, error, stackTrace) => Center(
          //         child: Icon(Icons.pets, color: Colors.red, size: 48),
          //       ),
          // ),
        );
      },
    );
  }
}
