import 'package:flutter/material.dart';
import 'package:SIMANIS_V1/providers/news.provider.dart';
import 'package:provider/provider.dart';
import 'package:SIMANIS_V1/helpers/url_launcher.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController searchController = TextEditingController();

  void _searchNews(NewsProvider news) {
    final query = searchController.text.trim();
    if (query.isNotEmpty) {
      news.search(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<NewsProvider>(
      builder: (context, news, child) {
        return Scaffold(
          appBar: AppBar(title: const Text('Cari Berita')),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: searchController,
                        decoration: InputDecoration(
                          hintText: 'Cari berita...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onFieldSubmitted: (_) => _searchNews(news),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () => _searchNews(news),
                      child: const Icon(Icons.send),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Expanded(
                  child:
                      news.isLoadingSearch
                          ? const Center(child: CircularProgressIndicator())
                          : news.isDataEmpty
                          ? const Center(
                            child: Text('Tidak ada hasil ditemukan'),
                          )
                          : ListView.builder(
                            itemCount: news.resSearch?.articles?.length ?? 0,
                            itemBuilder: (context, index) {
                              final article = news.resSearch!.articles![index];
                              final imageUrl = article.urlToImage ?? '';
                              final title = article.title ?? 'Tanpa Judul';
                              final url = article.url ?? '';

                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: InkWell(
                                  onTap: () {
                                    if (url.isNotEmpty) {
                                      launchURL(context, url);
                                    }
                                  },
                                  child: Card(
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              imageUrl,
                                              width: 100,
                                              height: 80,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => const Icon(
                                                    Icons.broken_image,
                                                    size: 80,
                                                  ),
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              title,
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
